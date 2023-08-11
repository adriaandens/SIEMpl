package SIEMpl::Parser::Authlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;
use SIEMpl::Event::NonInteractiveSession;
use SIEMpl::Event::InteractiveSession;
use SIEMpl::Event::FailedLogin;

class SIEMpl::Parser::Authlog :isa(SIEMpl::Parser) {

	field $f;
	field %incomplete_events = (); # Our events can be multi-line before being complete.

	method open() {
		open($f, '<', $self->source()) or die "Cannot open " . $self->source() . "\n";
	}

	# Magic happens here
	method parse() {
		while(<$f>) {
			$self->parse_line($_);
		}
	}

	method parse_line($line) {
		my $event = $self->base_parsing($line);
		my ($hostname, $program, $wrap, $pid, $more) = $event->{log} =~ m/(\S+)\s+([\w-]+)(\[(\d+)\])?(.*)/;
		$event->{hostname} = lc($hostname);
		$event->{program} = lc($program);
		$event->{pid} = $pid if $pid;
		if($event->{program} eq 'cron') {
			$self->parse_cron($event, $more)
		} elsif($event->{program} eq 'sshd') {
			$self->parse_sshd($event, $more)
		} elsif($event->{program} eq 'su') {
			$self->parse_su($event, $more)
		} elsif($event->{program} eq 'sudo') {
			$self->parse_sudo($event, $more)
		} elsif($event->{program} eq 'systemd') {
			$self->parse_systemd($event, $more)
		} elsif($event->{program} eq 'systemdlogind') {
			$self->parse_systemdlogind($event, $more)
		} else {
			# we don't care? If we do care, make a case for it.
		}
		return $event; # For allowing testing/introspection.
	}

	# State diagram:
	# 1 -> 2
	method parse_cron($event, $log) { # 1
		if($log =~ m/session opened for user ([^\(]+)\(uid=(\d+)\) by \(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_userid} = $3;
			$event->{type} = 'session_start';
			# TODO: Make a new unfinished event
			my $session = SIEMpl::Event::NonInteractiveSession->new();
			$session->add_raw_event($event);

			my $key = $event->{hostname} . $event->{pid} . $event->{target_username};
			$incomplete_events{$key} = $session;
		} elsif($log =~ m/session closed for user (\S+)/) { # 2
			$event->{target_username} = $1;
			$event->{type} = 'session_end';
			my $key = $event->{hostname} . $event->{pid} . $event->{target_username};
			my $session = $incomplete_events{$key};
			return if ! $session; # We miss the session start...
			$session->add_raw_event($event);

			# The event is now complete.
			$self->add_completed_event($session);
			delete $incomplete_events{$key};
		}
	}

	# TODO: The obvious problem here is that one failed login and one successful login generate multiple parsed events. But it should count as 1 "logical" event such that counts in the SIEM are correct.
	# State diagram:
	# * 1 -> 2
	# * 2 (2 on its own contains all info, in case we would miss 1 in our log)
	# * 1 -> 4 -> 5
	# * 5 (5 on its own contains all info, in case we would miss 1 or 4 in our log)
	# * 3
	method parse_sshd($event, $log) {
		if($log =~ m/Invalid user (\S+) from (\S+) port (\d+)/) { # 1
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;

			$self->start_failed_login($event);
		} elsif($log =~ m/Connection closed by invalid user (\S+) (\S+) port (\d+)/) { # 2
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;

			$self->complete_failed_login($event);
		} elsif($log =~ m/Connection closed by authenticating user (\S+) (\S+) port (\d+)/) { # 3
			$event->{target_username} = $1;
			$event->{target_valid_username} = 1;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;

			$self->complete_failed_login($event);
		} elsif($log =~ m/Received disconnect from (\S+) port (\d+)/) { # 4
			$event->{source_ip} = $1;
			$event->{source_port} = $2;

			# TODO: not completed! otherwise a following #5 won't find the event back...
			#complete_failed_login($event);
		} elsif($log =~ m/Disconnected from invalid user (\S+) (\S+) port (\d+)/) { # 5
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;

			$self->complete_failed_login($event);
		} elsif($log =~ m/Accepted publickey from for (\S+) from (\S+) port (\d+) ssh2: RSA SHA256:(\S+)/) {
			$event->{target_username} = $1;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;
			$event->{key_type} = 'RSA';
			$event->{key_sha256} = $4;
		} elsif($log =~ m/pam_unix\(sshd:session\): session opened for user ([^\(]+)\(uid=(\d+)\) by \(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			# The one who allowed it will always be root == user of sshd?
		}

		# TODO: generate a log with a successful login with password
		# TODO: generate a log with other types of Keys (not RSA)
	}

	method complete_failed_login($event) {
		my $key = $event->{hostname} . $event->{pid} . $event->{source_ip};
		my $e = $incomplete_events{$key};
		my $new_event = 0;
		if(!$e) {
			$new_event = 1;	
			$e = SIEMpl::Event::FailedLogin->new();
		}
		$e->add_raw_event($event);
		$self->add_completed_event($e);
		delete $incomplete_events{$key} if $new_event == 0; # Cleanup

	}

	method start_failed_login($event) {
		my $e = SIEMpl::Event::FailedLogin->new();
		$e->add_raw_event($event);
		my $key = $event->{hostname} . $event->{pid} . $event->{source_ip};
		$incomplete_events{$key} = $e;
	}

	method parse_su($event, $log) {
		if($log =~ m/\(to ([^\)]+)\) (\S+) on (\S+)/) { # 1
			$event->{target_username} = $1;
			$event->{source_username} = $2;
			$event->{source_terminal} = $3;
		} elsif($log =~ m/pam_unix\(su:session\): session opened for user ([^\(]+)\(uid=(\d+)\) by ([^\(]+)?\(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_userid} = $3;
		} elsif($log =~ m/pam_unix\(su:session\): session closed for user (\S+)/) {
			$event->{target_username} = $1;
		}

	}

	method parse_sudo($event, $log) {
		if($log =~ m/(\S+) : TTY=(\S+) ; PWD=([^;]+) ; USER=(\S+) ; COMMAND=(.+)$/) { # 1
			$event->{source_username} = $1;
			$event->{tty} = $2;
			$event->{pwd} = $3;
			$event->{target_username} = $4;
			$event->{cmd} = $5; 

		} elsif($log =~ m/pam_unix\(sudo:session\): session opened for user ([^\(]+)\(uid=(\d+)\) by ([^\(]+)?\(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_username} = $3;
			$event->{source_userid} = $4;
		}

	}

	method parse_systemd($event, $log) {
		if($log =~ m/pam_unix\(systemd-user:session\): session oepend for user ([^\(]+)\(uid=(\d+)\) by ([^\(]+)?\(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_username} = $3;
			$event->{source_userid} = $4;
		}
	}

	method parse_systemdlogind($event, $log) {
		if($log =~ m/New session (\S+) of user (\S+)\./) {
			$event->{session_id} = $1;
			$event->{username} = $2;
		} elsif($log =~ m/Removed session (\S+)\./) {
			$event->{session_id} = $1;
		}

	}

	method close() {
		close($f);
	}

}

1;
__END__

=encoding utf-8

=head1 NAME

SIEMpl - It's new $module

=head1 SYNOPSIS

    use SIEMpl;

=head1 DESCRIPTION

SIEMpl is ...

=head1 LICENSE

Copyright (C) Adriaan.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Adriaan

=cut


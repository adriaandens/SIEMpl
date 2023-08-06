package SIEMpl::Parser::Authlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;
use SIEMpl::Event::NonInteractiveSession;
use SIEMpl::Event::InteractiveSession;

class SIEMpl::Parser::Authlog :isa(SIEMpl::Parser) {

	field $f;
	field %incomplete_events = ();
	field %completed_events = ();

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

	method parse_cron($event, $log) {
		if($log =~ m/session opened for user ([^\(]+)\(uid=(\d+)\) by \(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_userid} = $3;
			# TODO: Make a new unfinished event
			my $session = SIEMpl::Event::NonInteractiveSession->new(%$event);
		} elsif($log =~ m/session closed for user (\S+)/) {
			$event->{target_username} = $1;
			# TODO: End the unfinished event and move to finished events.
			$event->{end_time} = $event->{epoch};
		}
	}

	# TODO: The obvious problem here is that one failed login and one successful login generate multiple parsed events. But it should count as 1 "logical" event such that counts in the SIEM are correct.
	method parse_sshd($event, $log) {
		if($log =~ m/Connection closed by invalid user (\S+) (\S+) port (\d+)/) {
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;
		} elsif($log =~ m/Connection closed by authenticating user (\S+) (\S+) port (\d+)/) {
			$event->{target_username} = $1;
			$event->{target_valid_username} = 1;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;

		} elsif($log =~ m/Invalid user (\S+) from (\S+) port (\d+)/) {
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;
		} elsif($log =~ m/Received disconnect from (\S+) port (\d+)/) {
			$event->{source_ip} = $1;
			$event->{source_port} = $2;
		} elsif($log =~ m/Disconnected from invalid user (\S+) (\S+) port (\d+)/) {
			$event->{target_username} = $1;
			$event->{target_valid_username} = 0;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;
		} elsif($log =~ m/Accepted publickey from for (\S+) from (\S+) port (\d+) ssh2: RSA SHA256:(\S+)/) {
			$event->{target_username} = $1;
			$event->{source_ip} = $2;
			$event->{source_port} = $3;
			$event->{key_type} = 'RSA';
			$event->{key_sha256} = $4;
		} elsif($log =~ m/pam_unix\(sshd:session\): session opened for user ([^\(]+)\(uid=(\d+)\) by \(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;

			# 
			# The one who allowed it will always be root == user of sshd?
		}

		# TODO: generate a log with a successful login with password
		# TODO: generate a log with other types of Keys (not RSA)
	}

	method parse_su($event, $log) {

	}

	method parse_sudo($event, $log) {

	}

	method parse_systemd($event, $log) {

	}

	method parse_systemdlogind($event, $log) {

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


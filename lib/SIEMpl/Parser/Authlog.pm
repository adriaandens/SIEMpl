package SIEMpl::Parser::Authlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

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
			my $event = $self->base_parsing($_);
			#die "Line: $event->{epoch}, Log: $event->{log}";
			my ($hostname, $program, $pid, $more) = $event->{log} =~ m/(\S+)\s+([\w-]+)(\[(\d+)\])?(.*)/;
			$event->{hostname} = lc($hostname);
			$event->{program} = lc($program);
			$event->{pid} if defined($pid);
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

		}
	}

	method parse_cron($event, $log) {
		if($log =~ m/session opened for user ([^\(]+)\(uid=(\d+)\) by \(uid=(\d+)\)/) {
			$event->{target_username} = $1;
			$event->{target_userid} = $2;
			$event->{source_userid} = $3;
			# TODO: Make a new unfinished event
		} elsif($log =~ m/session closed for user (\S+)/) {
			$event->{target_username} = $1;
			# TODO: End the unfinished event and move to finished events.
		}
	}

	method parse_sshd($event, $log) {

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


package SIEMpl::Event::NonInteractiveSession;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;

class SIEMpl::Event::NonInteractiveSession :isa(SIEMpl::Event) {

	field $target_username;
	field $target_userid;
	field $source_userid;
	field $hostname;
	field $program;
	field $pid;

	method target_username { $target_username }
	method target_userid { $target_userid }
	method source_userid { $source_userid }
	method hostname { $hostname }
	method program { $program }
	method pid { $pid }

	# Overloading SIEMpl::Event->add_raw_event
	method add_raw_event($event) {
		$self->add_base_event($event); # Extracts epoch for us and sets start/end time

		if($event->{type} eq 'session_start') {
			$target_username = $event->{target_username};
			$target_userid = $event->{target_userid};
			$source_userid = $event->{source_userid};
			$hostname = $event->{hostname};
			$program = $event->{program};
			$pid = $event->{pid};
		} elsif($event->{type} eq 'session_end') {
			# We don't have any new info, everything is done in the super class.
		} else {
			croak("Unexpected type");
		}
	}

	method getString() {
		return "$source_userid opened a non-interactive session of type $program with PID $pid for user $target_username with uid $target_userid";
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

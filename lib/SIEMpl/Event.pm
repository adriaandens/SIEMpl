package SIEMpl::Event;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

# This class only knows about the "epoch" and "log" key in an event.
class SIEMpl::Event {

	field @raw_events = ();
	field $start_time;
	field $end_time;

	method add_raw_event($event) {
		$self->add_base_event($event);
	}

	method add_base_event($event) {
		if(! @raw_events) {
			$start_time = $event->{epoch};
			$end_time = $event->{epoch};
		} else {
			$start_time = $event->{epoch} if $event->{epoch} < $start_time;
			$end_time = $event->{epoch} if $event->{epoch} > $end_time;
		}
		push @raw_events, $event;
		
	}

	method get_start_time() {
		croak("No raw events stored in Event.") if ! @raw_events;
		return $start_time;
	}

	method get_end_time() {
		croak("No raw events stored in Event.") if ! @raw_events;
		return $end_time;
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

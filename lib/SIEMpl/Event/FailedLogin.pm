package SIEMpl::Event::FailedLogin;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;

class SIEMpl::Event::FailedLogin :isa(SIEMpl::Event) {

	field $target_username //= "unknown";
	field $target_valid_username //= "unknown";
	field $source_ip //= "unknown";
	field $source_port //= "unknown";
	field $hostname //= "unknown";
	field $program //= "unknown";
	field $pid //= "unknown";

	method target_username { $target_username }
	method target_valid_username { $target_valid_username }
	method source_ip { $source_ip }
	method source_port { $source_port }
	method hostname { $hostname }
	method program { $program }
	method pid { $pid }

	# Overloading SIEMpl::Event->add_raw_event
	method add_raw_event($event) {
		$self->add_base_event($event); # Extracts epoch for us and sets start/end time

		$target_username = $event->{target_username} if defined($event->{target_username});
		$target_valid_username = $event->{target_valid_username} if defined($event->{target_valid_username});
		$source_ip = $event->{source_ip} if defined($event->{source_ip});
		$source_port = $event->{source_port} if defined($event->{source_port});
		$hostname = $event->{hostname};
		$program = $event->{program};
		$pid = $event->{pid};
	}

	method getString() {
		return "Failed login from $source_ip:$source_port with user $target_username (valid: $target_valid_username)";
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

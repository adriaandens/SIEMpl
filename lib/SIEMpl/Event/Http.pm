package SIEMpl::Event::Http;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;

class SIEMpl::Event::Http :isa(SIEMpl::Event) {

	field $source_ip;
	field $username;
	field $request;
	field $version;
	field $status_code;
	field $body_length;
	field $referrer;
	field $user_agent;
	field $method;
	field $path;
	field $args;

	method source_ip { $source_ip }
	method username { $username }
	method request { $request }
	method version { $version }
	method status_code { $status_code }
	method body_length { $body_length }
	method referrer { $referrer }
	method user_agent { $user_agent }
	method method { $method }
	method path { $path }
	method args { $args }

	# Overloading SIEMpl::Event->add_raw_event
	method add_raw_event($event) {
		$self->add_base_event($event); # Extracts epoch for us and sets start/end time

		$source_ip = $event->{source_ip};
		$username = $event->{username};
		$request = $event->{http_request};
		$version = $event->{http_version};
		$status_code = $event->{http_status_code};
		$body_length = $event->{http_body_length};
		$referrer = $event->{http_referrer};
		$user_agent = $event->{http_user_agent};
		$method = $event->{http_method};
		$path = $event->{http_path};
		$args = $event->{http_args};
	}

	method getString() {
		return "$source_ip (user: $username) did a $method request to $request";
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

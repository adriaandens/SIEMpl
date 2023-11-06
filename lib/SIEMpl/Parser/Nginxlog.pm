package SIEMpl::Parser::Nginxlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use DateTime::Format::Strptime qw(strftime);
use Carp;

use SIEMpl::Event;
use SIEMpl::Event::Http;

class SIEMpl::Parser::Nginxlog :isa(SIEMpl::Parser) {

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

#64.227.148.219 - - [02/Nov/2023:05:19:45 +0000] "GET /wp-includes/wlwmanifest.xml HTTP/1.1" 404 555 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
	method parse_line($line) {
		my %event = ();
		my ($source_ip, $username, $time, $request, $status_code, $body_bytes, $referrer, $user_agent) = $line =~ m/^(\S+) - (\S+) \[([^\]]+)\] "([^"]*)" (\d+) (\d+) "([^"]+)" "([^"]+)"/;
		$event{source_ip} = $source_ip;
		$event{username} = "-" eq $username ? "" : $username;
		$event{http_request} = $request;
		$event{http_status_code} = $status_code;
		$event{http_body_length} = $body_bytes;
		$event{http_referrer} = "-" eq $referrer ? "" : $referrer;
		$event{http_user_agent} = "-" eq $user_agent ? "" : $user_agent;

		# TODO: Use a module for this (or for the path/args only) since it's too tricky to do myself.
		my ($method, $path, $args, $version) = $request =~ m/^(\w+) ([^\?]+)\??(.*) HTTP\/(.*)/;
		$event{http_method} = defined($method) ? $method : "";
		$event{http_path} = defined($path) ? $path : "";
		$event{http_args} = defined($args) ? $args : "";
		$event{http_version} = defined($version) ? $version : "";

		my $format = "%d/%b/%Y:%T %z";
		my $strp = DateTime::Format::Strptime->new(
			pattern => $format,
			locale => 'en_US',
			on_error => 'croak'
		);
		my $dt = $strp->parse_datetime($time);
		my $epoch = strftime("%s", $dt);
		$event{"epoch"} = $epoch;

		my $http_event = SIEMpl::Event::Http->new();
		$http_event->add_raw_event(\%event);

		return \%event;
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


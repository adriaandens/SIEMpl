package SIEMpl::Parser::Nginxlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use DateTime::Format::Strptime qw(strftime);
use Carp;

use SIEMpl::Event;

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
		my %event = ("heheheheh" => "hahahaha");
		my ($source_ip, $username, $time, $request, $status_code, $body_bytes) = $line =~ m/^(\S+) - (\S+) \[([^\]]+)\] "([^"]+)" (\d+) (\d+)/;

		my $format = "%d/%b/%Y:%T %z";
		my $strp = DateTime::Format::Strptime->new(
			pattern => $format,
			locale => 'en_US',
			time_zone => 'Europe/Brussels',
			on_error => 'croak'
		);
		my $dt = $strp->parse_datetime($time);
		my $epoch = strftime("%s", $dt);
		$event{"epoch"} = $epoch;

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


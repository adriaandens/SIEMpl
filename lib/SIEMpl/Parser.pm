package SIEMpl::Parser;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use DateTime::Format::Strptime qw(strftime);
use Time::Piece;
use Carp;

class SIEMpl::Parser {

	field $source :param; # A file, a DB connection string, ...

	method source { $source }
	# TODO: If we can set the source to something else we can continue with
	# the unfinished events from Parsers, because files can logically follow
	# one an other and complete eachother
	method set_source($s) { $source = $s }

	method open() {
		croak("You need to call a subclass");
	}

	# Magic happens here
	method parse() {
		croak("You need to call a subclass");
	}

	# Default timestamp looks like: Aug  2 16:01:02
	# Returns a hashref with "epoch" and "log" as keys.
	method base_parsing($line) {
		my ($date, $log) = $line =~ m/^(\w+\s+\d+\s+\d+:\d+:\d+)\s+(.*)$/;
		# DateTime gives back weird time because we don't have a Year in our string, so it thinks we are in year 1....
		# TODO: If we take the current year but we are January 1st and we are parsing something from yesterday, then the year is wrong! Might be best to assume (even if we are in July "right now") that everything that gets parsed as an epoch bigger than "now" is wrong. Logs are about the passed, not the future.
		my $year = localtime->strftime("%Y");
		# %b or %B or %h: The month name according to the given locale, in abbreviated form or the full name.
		# %d or %e: The day of month (01-31). This will parse single digit numbers as well.
		my $format = "%Y %b %d %T";
		my $strp = DateTime::Format::Strptime->new(
			pattern   => $format,
			locale    => 'en_US',
			time_zone => 'Europe/Brussels',
			on_error => 'croak'
		);
		my $dt = $strp->parse_datetime($year . ' ' . $date);

		my %event = ("epoch" => strftime("%s", $dt), "log" => $log);
		return \%event; 
	}

	method close() {
		croak("You need to call a subclass");
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


package SIEMpl::Parser::Authlog;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
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

	method parse_line($line) {
		my %event = ("heheheheh" => "hahahaha");
		return \$event;
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


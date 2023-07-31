package SIEMpl::Parser;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Parser {

	field $source :param; # A file, a DB connection string, ...

	method source { $source }

	method open() {
		croak("You need to call a subclass");
	}

	# Magic happens here
	method parse() {
		croak("You need to call a subclass");
	}

	method close() {

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


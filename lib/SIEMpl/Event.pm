package SIEMpl::Event;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Event {

	field $time;
	field $data;

	method time { $time };
	method data { $data };

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


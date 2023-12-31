package SIEMpl::Object::Device;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Object::Device :isa(SIEMpl::Object) {

	field $hostname;
	field $domain; # where it makes sense
	field $fqdn;

	field @ipv4 = ();
	field @ipv6 = (); # IPv6 support!
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

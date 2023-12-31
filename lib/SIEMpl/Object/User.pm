package SIEMpl::Object::User;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Object::User :isa(SIEMpl::Object) {

	field $username;
	field $userid; # Linux == uid, Windows = sid

	field $isLocal; #isLocal decides whether it's a domain User (like from AD/LDAP) or it's a local user account
	field $domain; # set if isLocal=0
	field $device; # set if isLocal=1

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

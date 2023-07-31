package SIEMpl::Event::Authentication;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Event::Authentication :isa(SIEMpl::Event) {

	field $type; # 'login', 'logout'
	field $scope; # 'local', 'external'

	# Actor
	field $user; # the username
	field $userid; # the user ID
	field $domain; # the domain

	# Source
	field $source;

	# Destination


	# Authentications where you privesc to a new user, like sudo, su, ...
	field $privesc; # 
	field $new_user;
	field $new_userid;

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


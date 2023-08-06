package SIEMpl::Event::NonInteractiveSession;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

use SIEMpl::Event;

class SIEMpl::Event::NonInteractiveSession :isa(SIEMpl::Event) {

	field $epoch :param;
	field $log :param; # Not sure if needed
	field $target_username :param;
	field $target_userid :param;
	field $source_userid :param;
	field $hostname :param;
	field $program :param;
	field $pid :param;

	ADJUST {

	}

	method getString() {
		return "$source_userid opened a non-interactive session of type $program with PID $pid for user $target_username with uid $target_userid";
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

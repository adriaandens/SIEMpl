package SIEMpl::Config;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::Config {

	field $name :param //= "SIEMpl";

	method name { $name }
	
	# SIEM.pl internal schemas like 'Web', 'Authentication', ...
	method schemas {

	}

	# SIEM.pl rules that will trigger alerts
	method rules {

	}

	# SIEM.pl parsers for files, they generate objects of a certain schema
	method parsers {

	}
	
	# SIEM.pl files and directories (or globs) that we ingest
	method monitors {

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


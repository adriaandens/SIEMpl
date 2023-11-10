package SIEMpl::QueryEngine;
use 5.038000;

our $VERSION = "0.01";

use feature 'class';
use Carp;

class SIEMpl::QueryEngine {

	field @columns;
	field $table;
	field $where;
	field @groupby_columns;
	field @order_columns;
	field $order_ascdesc;
	field $limit_rows; 

	method columns() { @columns; }
	method table() { $table; }

	method execute_query($query_string) {
		$self->reset_state();
		$self->parse_query_string($query_string);
		# Invoke the query planner
		# DB gets filled with events
		# Query the internal DB
	}

	method reset_state() {
		@columns = ();
		$table = undef;
		$where = undef;
		@groupby_columns = ();
		@order_columns = ();
		$order_ascdesc = undef;
		$limit_rows = undef;
	}
	
	method parse_query_string($q) {
		my ($columnstr, $tablestr, $wheres, $groupby, $orders, $limit) = $q =~ m/SELECT (.*) FROM (\w+) ?(?:WHERE (.*))?(?:ORDER BY (\w+))?(?:LIMIT (\d+))?/; 
		$columnstr =~ s/\s*,\s*/, /g;
		@columns = split /, /, $columnstr;
		$table = $tablestr;
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

use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::QueryEngine;

ok(1 == 1, "Owkee");
my $engine = SIEMpl::QueryEngine->new();
$engine->execute_query("SELECT abc FROM tabel");
ok(scalar($engine->columns()) == 1, "One selected column");
ok(($engine->columns())[0] eq "abc", "The column is 'abc'");
ok($engine->table() eq "tabel", "FROM is 'tabel'");

$engine->execute_query("SELECT abc FROM tabel WHERE a = 'haha'");
ok(scalar($engine->columns()) == 1, "One selected column");
ok(($engine->columns())[0] eq "abc", "The column is 'abc'");
ok($engine->table() eq "tabel", "FROM is 'tabel'");

$engine->execute_query("SELECT abc, def , ghi FROM tabel WHERE a = 'haha'");
ok(scalar($engine->columns()) == 3, "Three selected columns");
ok(($engine->columns())[0] eq "abc", "The column is 'abc'");
ok(($engine->columns())[1] eq "def", "The column is 'def'");
ok(($engine->columns())[2] eq "ghi", "The column is 'ghi'");
ok($engine->table() eq "tabel", "FROM is 'tabel'");

done_testing();

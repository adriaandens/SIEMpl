use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Parser;
use SIEMpl::Parser::Authlog;

my $p = SIEMpl::Parser::Authlog->new(source => 't/samplelogs/desktop_authlog.txt');
$p->open();
$p->parse();
$p->close();

ok(1 == 1, "Owkee");

done_testing;


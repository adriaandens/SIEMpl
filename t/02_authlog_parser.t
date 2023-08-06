use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Parser;
use SIEMpl::Parser::Authlog;

my $a = SIEMpl::Parser::Authlog->new(source => 'doesnt matter');
my $event = $a->parse_line('Jul 31 21:30:01 desktop CRON[6451]: pam_unix(cron:session): session closed for user root');
ok($event->{hostname} eq 'desktop', 'The hostname is desktop');
ok($event->{program} eq 'cron', 'Program is cron');
ok($event->{pid} == 6451, 'The PID is 6451');



my $p = SIEMpl::Parser::Authlog->new(source => 't/samplelogs/desktop_authlog.txt');
$p->open();
$p->parse();
$p->close();

my $p2 = SIEMpl::Parser::Authlog->new(source => 't/samplelogs/server_authlog.txt');
$p2->open();
$p2->parse();
$p2->close();


ok(1 == 1, "Owkee");

done_testing;


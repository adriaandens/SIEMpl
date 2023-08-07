use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Parser;
use SIEMpl::Parser::Authlog;

my $a = SIEMpl::Parser::Authlog->new(source => 'doesnt matter');
my $event = $a->parse_line('Jul 31 21:30:00 desktop CRON[6451]: pam_unix(cron:session): session opened for user root(uid=0) by (uid=0)');
ok($event->{hostname} eq 'desktop', 'The hostname is desktop');
ok($event->{program} eq 'cron', 'Program is cron');
ok($event->{pid} == 6451, 'The PID is 6451');
$event = $a->parse_line('Jul 31 21:30:01 desktop CRON[6451]: pam_unix(cron:session): session closed for user root');
ok($event->{hostname} eq 'desktop', 'The hostname is desktop');
ok($event->{program} eq 'cron', 'Program is cron');
ok($event->{pid} == 6451, 'The PID is 6451');

# Now check that we have a completed event.
my $events = $a->completed_events();
ok(@{$events} == 1, "We have one completed event");
my $completed_event = ${$events}[0];
ok($completed_event->target_username() eq 'root', "User is root");
ok($completed_event->target_userid() == 0, "User ID of root is 0");
ok($completed_event->source_userid() == 0, "User ID of the one starting the cron is 0");
ok($completed_event->hostname() eq 'desktop', "The hostname is desktop");
ok($completed_event->program() eq 'cron', "The program is 'cron'.");
ok($completed_event->pid() == 6451, "The PID is 6451");
ok($completed_event->start_time() == 1690831800, "The start time epoch is 1690831800");
ok($completed_event->end_time() == 1690831801, "The end time epoch is 1690831801");





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


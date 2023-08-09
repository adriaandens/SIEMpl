use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Parser;
use SIEMpl::Parser::Authlog;

## CRON parsing
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


## SSHD parsing
# 1 -> 4 -> 5
#Aug  2 14:44:42 vps-abcdefg1337 sshd[4186517]: Invalid user lab from 141.98.11.11 port 56826
#Aug  2 14:44:42 vps-abcdefg1337 sshd[4186517]: Received disconnect from 141.98.11.11 port 56826:11: Bye Bye [preauth]
#Aug  2 14:44:43 vps-abcdefg1337 sshd[4186517]: Disconnected from invalid user lab 141.98.11.11 port 56826 [preauth]
my $b = SIEMpl::Parser::Authlog->new(source => 'doesnt matter');
$event = $b->parse_line('Aug  2 14:44:42 vps-abcdefg1337 sshd[4186517]: Invalid user lab from 141.98.11.11 port 56826');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4186517, 'PID is 4186517');
ok($event->{target_username} eq 'lab', 'User is lab');
ok(!$event->{target_valid_username}, 'User lab is an invalid user.');
ok($event->{source_ip} eq '141.98.11.11', 'The source IP is 141.98.11.11');
ok($event->{source_port} == 56826, 'The source port is 56826');
$event = $b->parse_line('Aug  2 14:44:42 vps-abcdefg1337 sshd[4186517]: Received disconnect from 141.98.11.11 port 56826:11: Bye Bye [preauth]');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4186517, 'PID is 4186517');
ok($event->{source_ip} eq '141.98.11.11', 'The source IP is 141.98.11.11');
ok($event->{source_port} == 56826, 'The source port is 56826');
$event = $b->parse_line('Aug  2 14:44:43 vps-abcdefg1337 sshd[4186517]: Disconnected from invalid user lab 141.98.11.11 port 56826 [preauth]');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4186517, 'PID is 4186517');
ok($event->{target_username} eq 'lab', 'User is lab');
ok(!$event->{target_valid_username}, 'User lab is an invalid user.');
ok($event->{source_ip} eq '141.98.11.11', 'The source IP is 141.98.11.11');
ok($event->{source_port} == 56826, 'The source port is 56826');

# Now check that we have a completed event.
$events = $b->completed_events();
ok(@{$events} == 1, "We have one completed event");
$completed_event = ${$events}[0];
ok($completed_event->target_username() eq 'lab', "User is lab");
ok($completed_event->target_valid_username() == 0, "User lab is not valid");
ok($completed_event->source_ip() eq '141.98.11.11', "The source ip is 141.98.11.11");
ok($completed_event->source_port() == 56826, "The source port is 56826");
ok($completed_event->hostname() eq 'vps-abcdefg1337', "The hostname is vps-abcdefg1337");
ok($completed_event->program() eq 'sshd', "The program is 'sshd'.");
ok($completed_event->pid() == 4186517, "The PID is 4186517");
ok($completed_event->start_time() == 1690980282, "The start time epoch is 1690980282");
ok($completed_event->end_time() == 1690980283, "The end time epoch is 1690980283");


# 2 
#Aug  2 10:33:08 vps-abcdefg1337 sshd[4185775]: Connection closed by invalid user azureuser 170.64.145.78 port 51934 [preauth]
$event = $b->parse_line('Aug  2 10:33:08 vps-abcdefg1337 sshd[4185775]: Connection closed by invalid user azureuser 170.64.145.78 port 51934 [preauth]');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4185775, 'PID is 4185775');
ok($event->{target_username} eq 'azureuser', 'User is azureuser');
ok(!$event->{target_valid_username}, 'User azureuser is an invalid user.');
ok($event->{source_ip} eq '170.64.145.78', 'The source IP is 170.64.145.78');
ok($event->{source_port} == 51934, 'The source port is 51934');
$events = $b->completed_events();
ok(@{$events} == 2, "We have two completed events");

# 3
#Aug  2 10:33:26 vps-abcdefg1337 sshd[4185779]: Connection closed by authenticating user root 170.64.145.78 port 56318 [preauth]
$event = $b->parse_line('Aug  2 10:33:26 vps-abcdefg1337 sshd[4185779]: Connection closed by authenticating user root 170.64.145.78 port 56318 [preauth]');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4185779, 'PID is 4185779');
ok($event->{target_username} eq 'root', 'User is root');
ok($event->{target_valid_username}, 'User root is a valid user.');
ok($event->{source_ip} eq '170.64.145.78', 'The source IP is 170.64.145.78');
ok($event->{source_port} == 56318, 'The source port is 56318');
$events = $b->completed_events();
ok(@{$events} == 3, "We have three completed events");

# 5
#Aug  2 15:01:25 vps-abcdefg1337 sshd[4186532]: Disconnected from invalid user dspace 141.98.11.113 port 55992 [preauth]
$event = $b->parse_line('Aug  2 15:01:25 vps-abcdefg1337 sshd[4186532]: Disconnected from invalid user dspace 141.98.11.113 port 55992 [preauth]');
ok($event->{hostname} eq 'vps-abcdefg1337', 'Hostname is vps-abcdefg1337');
ok($event->{program} eq 'sshd', 'Program is sshd');
ok($event->{pid} == 4186532, 'PID is 4286532');
ok($event->{target_username} eq 'dspace', 'User is dspace');
ok(!$event->{target_valid_username}, 'User dspace is an invalid user.');
ok($event->{source_ip} eq '141.98.11.113', 'The source IP is 141.98.11.113');
ok($event->{source_port} == 55992, 'The source port is 55992');
$events = $b->completed_events();
ok(@{$events} == 4, "We have four completed events");


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


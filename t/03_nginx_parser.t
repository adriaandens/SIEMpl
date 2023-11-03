use v5.38;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Parser;
use SIEMpl::Parser::Nginxlog;

## Trivial example
my $a = SIEMpl::Parser::Nginxlog->new(source => 'doesnt matter');
my $event = $a->parse_line('64.227.148.219 - - [02/Nov/2023:05:19:45 +0000] "GET /wp-includes/wlwmanifest.xml HTTP/1.1" 404 555 "-" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"');
ok($event->{hah} eq "heh", "Owkeeeeeeeee");
ok($event->{source_ip} eq '64.227.148.219', 'The source is 64.227.148.219');
ok($event->{http_request} eq 'GET /wp-includes/wlwmanifest.xml HTTP/1.1', 'The request is correct');
ok($event->{http_method} eq 'GET', 'The http method is GET');
ok($event->{http_path} eq '/wp-includes/wlwmanifest.xml', 'The http path is /wp-includes/wlwmanifest.xml');
ok($event->{http_version} eq "1.1", 'The version is 1.1');
ok($event->{http_status_code} == 404, 'The status code is 404');
ok($event->{http_body_length} == 555, 'Body length is 555');
ok($event->{http_referrer} eq "", 'The referrer is empty');
ok($event->{http_user_agent} eq "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36", 'The User agent is correct');

# We are still missing examples with query args, a logged in user (like you get when using basic authentication), other methods, one with a referrer, ...

# Now check that we have a completed event.
#my $events = $a->completed_events();
#ok(@{$events} == 1, "We have one completed event");
#my $completed_event = ${$events}[0];
#ok($completed_event->target_username() eq 'root', "User is root");
#ok($completed_event->target_userid() == 0, "User ID of root is 0");
#ok($completed_event->source_userid() == 0, "User ID of the one starting the cron is 0");
#ok($completed_event->hostname() eq 'desktop', "The hostname is desktop");
#ok($completed_event->program() eq 'cron', "The program is 'cron'.");
#ok($completed_event->pid() == 6451, "The PID is 6451");
#ok($completed_event->start_time() == 1690831800, "The start time epoch is 1690831800");
#ok($completed_event->end_time() == 1690831801, "The end time epoch is 1690831801");
#ok(@{$events} == 1, "We have one completed events");


#my $p = SIEMpl::Parser::Nginxlog->new(source => 't/samplelogs/server_nginx.txt');
#$p->open();
#$p->parse();
#$p->close();

done_testing;

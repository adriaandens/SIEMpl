use strict;
use Test::More 0.98;

use SIEMpl;
use SIEMpl::Config;

my $config = SIEMpl::Config->new(
	"name" => "Adriaans amazing SIEM",
);
my $siem = SIEMpl->new("config" => $config);

ok(1 == 1, "Owkee");

done_testing;


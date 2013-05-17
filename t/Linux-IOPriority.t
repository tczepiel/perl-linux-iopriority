use strict;
use warnings;
use diagnostics;
use Test::More tests => 5;
use Linux::IOPriority qw(get_io_priority set_io_priority);
pass "module loaded file...";

my $i = set_io_priority(4,2,$$);
is( $i, 4 );

$i = get_io_priority();
is($i, 4 );
diag("ioprio: $i");

$i = set_io_priority(2,2,$$);
is( $i, 2 );
diag("ioprioafter: $i");

ok(!set_io_priority(-10),"can't set higher priority...");

use strict;
use warnings;

use Test::More tests => 13;
use Linux::IOPriority;

pass "module loaded ok...";

my $prio = set_io_priority(4,IOPRIO_CLASS_BE,$$);
is( $prio, 4 );

$prio = get_io_priority();
is($prio, 4 );
diag("ioprio: $prio");

$prio = set_io_priority(2,IOPRIO_CLASS_BE,$$);
is( $prio, 2 );
diag("ioprioafter: $prio");

ok(!set_io_priority(-1),"can't set higher priority...");

{
    my $ioprio;
    ok(get_io_priority() == 2, 'ipriority is still 2');

    ok($ioprio = Linux::IOPriority->new( priority => 5 ));

    ok(get_io_priority() == 5, 'priority now at 5');
}

ok(get_io_priority() == 2, 'ipriority back at 2');

my $ioprio = Linux::IOPriority->new();

$prio = get_io_priority();
diag("priority $prio");
ok($prio == 2, 'ipriority still at 2');

ok($ioprio->set( priority => 5 ), 'iopriority set returns true');

$prio = get_io_priority();
diag("priority $prio");
ok($prio == 5, 'ipriority now at 5');
diag($ioprio->get());
ok($ioprio->get() == 5, 'priority reported at 5');



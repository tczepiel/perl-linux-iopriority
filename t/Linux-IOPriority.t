use strict;
use warnings;

use Test::More tests => 22;

use Linux::IOPriority qw(
    get_io_priority
    set_io_priority

    IOPRIO_CLASS_NONE
    IOPRIO_CLASS_RT 
    IOPRIO_CLASS_BE
    IOPRIO_CLASS_IDLE

    IOPRIO_PROCESS
    IOPRIO_PROCESS_GROUP
    IOPRIO_USER
);

pass "module loaded ok...";

my $prio = set_io_priority(4,IOPRIO_CLASS_BE,$$);
is( $prio, 4, "ioprio returned by set priority is 4" );

$prio = get_io_priority();
is($prio, 4, "ioprio is 4" );
diag("ioprio: $prio");

my $ioprio_class;
($prio,$ioprio_class) = get_io_priority();

is($prio,4, "ioprio is 4 in list context");
diag("ioprio class $ioprio_class");
is($ioprio_class,IOPRIO_CLASS_BE,"ioprio class is 'best effort'");

set_io_priority(4,IOPRIO_CLASS_IDLE,$$);
my @ret = get_io_priority();
is($ret[1],IOPRIO_CLASS_IDLE, "class is 'idle'...");

$prio = set_io_priority(3,IOPRIO_CLASS_BE,$$);
diag("prio:$prio");
is($prio,3, "prio ret value from set_io_prio returns 3");
@ret = get_io_priority();
is($ret[1],IOPRIO_CLASS_BE, "class is 'best effort'...");
diag("prio $ret[0]");
is($ret[0], 3, 'iopriority set to 3...');



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
diag(scalar $ioprio->get());
ok($ioprio->get() == 5, 'priority reported at 5');

my @prio = $ioprio->get();
is($prio[0],5, "priority at 5");
is($prio[1],IOPRIO_CLASS_BE, "priority class is 'best effort'");

ok($ioprio->set(priority => 6, class => 'IOPRIO_CLASS_IDLE'));





package Linux::IOPriority;

use strict;
use warnings;
use base 'Exporter';
use XSLoader;

use constant {
    IOPRIO_CLASS_NONE => 0,
    IOPRIO_CLASS_RT   => 1,
    IOPRIO_CLASS_BE   => 2,
    IOPRIO_CLASS_IDLE => 3,
};

use constant {
    IOPRIO_PROCESS       => 1,
    IOPRIO_PROCESS_GROUP => 2,
    IOPRIO_USER          => 3,
};

our $VERSION = '0.02';

our @EXPORT = qw(
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

XSLoader::load('Linux::IOPriority', $VERSION);

1;

=head1 NAME

Linux::IOPriority

=head1 SYNOPSIS

=head2 Functional Interface

    use Linux::IOPriority;

    my $prority = get_io_priority();
    my $prio    = get_io_priority($pid);

    die "failed to set requested io priority" unless defined set_io_priority(-10);

    set_io_priority(-10,IOPRIO_CLASS_BE,$pid);

=head1 Priority classes and process groups

These symbols are exported by default:

=head2 Priority classes

    IOPRIO_CLASS_NONE 
    IOPRIO_CLASS_RT    # Realtime
    IOPRIO_CLASS_BE    # Best effort
    IOPRIO_CLASS_IDLE

=head2 Process groups

    IOPRIO_PROCESS          # pid
    IOPRIO_PROCESS_GROUP    # pgid
    IOPRIO_USER             # uid

=head2 OO Interface

    use Linux::IOPriority;

    # set new priority for own process
    my $ioprio = LinuxPriority->new(
        priority => $priority,
    );

    $ioprio->set(
        user => $uid,
        priority => $priority,
    );

    $ioprio->get(
        pid => $somepid,
    );
    
=head1 METHODS

=head2 new

=head3 set

=head3 get




=cut

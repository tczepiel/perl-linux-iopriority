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


sub new {
    my $class = shift;
    my %args  = @_;

    $class    = ref($class) || $class;
    my @pid = qw(pid uid gid);

    if ( (@args{@pid}||0) > 1 ) {
        die "ambiguous parameters (", 
            join ",", @args{@pid},
            ")";
    }

    my $prio       = $args{priority};
    my ($pid)      = grep { defined } (@args{@pid}, $$);
    my $prio_class = $args{class} || Linux::IOPriority::IOPRIO_CLASS_BE;

    my $current_prio = Linux::IOPriority::get_io_priority($pid) || die "unable to get priority for process $pid";

    if ( $prio ) {
        return if ($current_prio == $prio && $prio_class == Linux::IOPriority::IOPRIO_CLASS_BE);
        Linux::IOPriority::set_io_priority($prio,$prio_class,$pid) || die "failed to set priority ($prio) for $pid";
    }

    $current_prio = undef unless exists $args{priority};

    return 
        bless \$current_prio => $class;
}

sub set {
    my $self = shift;
    my %args = @_;
    my $priority = $args{priority} || die "parameter priority required!";
    my $class    = $args{class}    || Linux::IOPriority::IOPRIO_CLASS_BE;

    my @pid = qw(pid uid gid);
    if ( (@args{@pid}||0) > 1 ) {
        die "ambiguous parameters (", 
            join ",", grep { exists $args{$_} } @args{@pid},
            ")";
    }

    my ($pid) = grep { defined } @args{@pid}, $$;

    return Linux::IOPriority::set_io_priority($priority,$class,$pid);
}

sub get {
    my $self = shift;
    my %args = @_;
    my $pid  = $args{pid} || $$;
    return Linux::IOPriority::get_io_priority($pid);
}

sub DESTROY {
    my $self = shift;
    return unless defined $$self;
    $self->set(priority => $$self);
}

1;

=head1 NAME

Linux::IOPriority

=head1 Functional Interface

    use Linux::IOPriority qw(
        get_io_priority
        set_io_priority

        IOPRIO_CLASS_BE
        IOPRIO_CLASS_RT
    );

    my $prority = get_io_priority();
    my $prio    = get_io_priority($pid);

    # maybe we don't have appropriate permissions?
    die "failed to set requested io priority" unless defined set_io_priority(-10);

    set_io_priority(-10,IOPRIO_CLASS_BE,$pid);

    # or

    set_io_priority(-5,IOPRIO_CLASS_RT,$pid);

=head2 Priority classes and process groups

Nothing exported by default.

=head2 Priority classes

    IOPRIO_CLASS_NONE 
    IOPRIO_CLASS_RT    # Realtime
    IOPRIO_CLASS_BE    # Best effort
    IOPRIO_CLASS_IDLE

=head2 Process groups

    IOPRIO_PROCESS          # pid
    IOPRIO_PROCESS_GROUP    # pgid
    IOPRIO_USER             # uid

=head1 OO Interface

    use Linux::IOPriority;

    # set new priority for own process
    my $ioprio = LinuxPriority->new(
        priority => $priority,
    );

    $ioprio->set(
        uid      => $uid,
        priority => $priority,
    );

    $ioprio->get(
        pid => $somepid,
    );

    
=head2 METHODS

=head3 new

Parameters:

=over 

=item *

priority 
    Required.

=item *

class
    optional, default 'best effort'

=item *

pid
    default: $$

=back

=head3 set

=over 

=item *

priority 
    Required.

=item *

class
    optional, default 'best effort'

=item *

pid
    default: $$

=back

=head3 get

=over

=item *

pid
    default: $$

=back

=cut

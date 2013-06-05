package Linux::IOPriority;

use strict;
use warnings;
use base 'Exporter';
use XSLoader;

our $VERSION;

BEGIN {
    $VERSION = "0.02";
    XSLoader::load('Linux::IOPriority', $VERSION);
}

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

sub _parse_params {
    my $class  = shift;
    my %args   = @_;

    my %who2id = ( pid => IOPRIO_PROCESS, gid => IOPRIO_PROCESS_GROUP, uid => IOPRIO_USER );
    my @pid    = keys %who2id;

    if ( (@args{@pid}||0) > 1 ) {
        die "ambiguous parameters (", 
            join ",", @args{@pid},
            ")";
    }

    my $prio       = $args{priority};
    my ($pid)      = grep { defined } (@args{@pid}, $$);
    my $prio_class = $args{class} || IOPRIO_CLASS_BE;
    my ($ioprio_who_class) = (grep { exists $args{$_} && $args{$_} } keys %who2id) || 'pid';

    return ($prio,$prio_class,$pid,$who2id{$ioprio_who_class});
}

sub new {
    my $class = shift;
    $class  = ref($class) || $class;

    my ( $prio, $prio_class, $pid, $ioprio_who_class) = $class->_parse_params(@_);
    my $current_prio = get_io_priority($pid) || die "unable to get priority for process $pid";

    if ( $prio ) {
        return if ($current_prio == $prio && $prio_class == IOPRIO_CLASS_BE);
        set_io_priority($prio,$prio_class,$pid,$ioprio_who_class) || die "failed to set priority ($prio) for $pid";
    }

    return 
        bless [ $current_prio, $prio_class, $pid, $ioprio_who_class ] => $class;
}

sub set {
    my $self = shift;
    my %args = @_;
    die "parameter priority required!" unless $args{priority};

    my @rev = $self->_parse_params(%args);
    return set_io_priority(@rev);
}

sub get {
    my $self = shift;
    my %args = @_;
    my $pid  = $args{pid} || $$;
    return get_io_priority($pid);
}

sub DESTROY {
    my $self = shift;
    return unless @$self;
    set_io_priority(@$self) or die "unable to set io priority: @$self";
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
    die "failed to set requested io priority" unless set_io_priority(-10);

    set_io_priority(-10,IOPRIO_CLASS_BE,$pid);

    # set the threads' priority

    set_io_priority(-5,IOPRIO_CLASS_RT,$pid, IOPRIO_WHO_PROCESS_GROUP);

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
    {
        my $ioprio = LinuxPriority->new(
            priority => $priority,
            uid      => $uid,
        );
    }
    # priority of $uid is back to what it was previously

    $ioprio->set(
        pid      => $uid,
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
    optional: default none

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

pid/gid/uid
pid
    default: 'pid' : $$

=back

=head1 SEE ALSO

L<Linux::IO_Prio>

=cut

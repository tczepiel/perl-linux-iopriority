package Linux::IOPriority;

use strict;
use warnings;
use base 'Exporter';
use XSLoader;
use Carp qw(croak);

our $VERSION;

BEGIN {
    $VERSION = "0.02";
    XSLoader::load('Linux::IOPriority', $VERSION);
}

my %export = map { $_ => undef } qw(
    get_io_priority
    set_io_priority

    IOPRIO_CLASS_NONE
    IOPRIO_CLASS_RT 
    IOPRIO_CLASS_BE
    IOPRIO_CLASS_IDLE

    IOPRIO_PROCESS
    IOPRIO_PROCESS_GROUP_ID
    IOPRIO_USER
);

our @EXPORT_OK = keys %export;

sub _get_class_value {
    return unless defined $_[0];
    return $_[0] if length($_[0]) == 1;
    return if not exists $export{$_[0]};

    no strict 'refs';
    return &{"$_[0]"};
}

sub _parse_params {
    my $class  = shift;
    my %args   = @_;

    my %who2id = ( pid => IOPRIO_PROCESS, gid => IOPRIO_PROCESS_GROUP_ID, uid => IOPRIO_USER );
    my @pid    = keys %who2id;

    if ( (@args{@pid}||0) > 1 ) {
        no warnings 'once';
        local $Carp::CarlLevel = 1;
        croak "ambiguous parameters (", 
            join ",", @args{@pid},
            ")";
    }

    my $prio       = $args{priority};
    my ($pid)      = grep { defined } (@args{@pid}, $$);
    my $prio_class = _get_class_value($args{class}) || IOPRIO_CLASS_BE;
    my ($ioprio_who_class) = (grep { exists $args{$_} && $args{$_} } keys %who2id) || 'pid';

    return ($prio,$prio_class,$pid,$who2id{$ioprio_who_class});
}

sub new {
    my $class = shift;
    $class  = ref($class) || $class;

    my ( $prio, $prio_class, $pid, $ioprio_who_class) = $class->_parse_params(@_);
    my $current_prio = get_io_priority($pid) || croak "unable to get priority for process $pid";

    if ( $prio ) {
        return if ($current_prio == $prio && $prio_class == IOPRIO_CLASS_BE);
        set_io_priority($prio,$prio_class,$pid,$ioprio_who_class) || croak "failed to set priority ($prio) for $pid";
    }

    return 
        bless [ $current_prio, $prio_class, $pid, $ioprio_who_class ] => $class;
}

sub set {
    my $self = shift;
    my %args = @_;
    croak "parameter priority required!" unless $args{priority};

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
    set_io_priority(@$self) or croak "unable to set io priority: @$self during DESTROY";
}

1;

=head1 NAME

Linux::IOPriority

=head1 DESCRIPTION

Set/get the IO priority of (process,thread,uid) on Linux.

=head1 Functional Interface

    use Linux::IOPriority qw(
        get_io_priority
        set_io_priority

        IOPRIO_CLASS_BE
        IOPRIO_CLASS_RT
        ...
    );

    my $prority = get_io_priority();
    my $prio    = get_io_priority($pid);

    # maybe we don't have appropriate permissions?
    die "failed to set requested io priority" unless set_io_priority(-10);

    set_io_priority(-10,IOPRIO_CLASS_BE,$pid);

    # set the threads' priority

    set_io_priority(-5,IOPRIO_CLASS_RT,$pid,IOPRIO_PROCESS_GROUP_ID);

=head2 Constants
    
    IOPRIO_CLASS_NONE 
    IOPRIO_CLASS_RT    # Realtime
    IOPRIO_CLASS_BE    # Best effort
    IOPRIO_CLASS_IDLE

    IOPRIO_PROCESS          # pid
    IOPRIO_PROCESS_GROUP_ID # pgid
    IOPRIO_USER             # uid

=head2 EXPORT

Nothing exported by default.

=head1 OO Interface

    use Linux::IOPriority;

    # set new priority for own process
    {
        my $ioprio = LinuxPriority->new(
            priority => $priority,
            uid      => $uid,
        );
    }
    # $ioprio fails out of scope, iopriority restored to previous value

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

=item * priority

optional: default none

=item * class

optional, default 'best effort'

=item * pid/uid/gid

default: $$

=back

    my $ioprio = Linux::IOPriority->new(
        priority => 4,
        uid      => 333234,
    );

    my $ioprio = Linux::IOPriority->new();


=head3 set

=over 

=item * priority

Required.

=item * class

optional, default 'best effort'

=item * pid/uid/gid

default: $$

=back

    my $ioprio = Linux::IOPriority->new;

    $ioprio->set(
        pid      => 4334534,
        priority =>  1,
        class    => 'IOPRIO_CLASS_RT',
    );

=head3 get

=over

=item * pid/gid/uid

default: 'pid' : $$

=back


    my $ioprio = Linux::IOPriority->new;

    my ($priority,$class) = $ioprio->get();

=head1 BUGS

Please report any bugs on L<http://rt.cpan.org>

=head1 SEE ALSO

L<Linux::IO_Prio>

=head1 AUTHOR

Tomasz Czepiel E<lt>tjmc@cpan.org<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.4 or,
at your option, any later version of Perl 5 you may have available.

=cut

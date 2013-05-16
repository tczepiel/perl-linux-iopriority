package Linux::IOPriority;

use strict;
use warnings;
use base 'Exporter';
use XSLoader;

our $VERSION = '0.01';

our @EXPORT = qw(
    get_io_priority
    set_io_priority
);

XSLoader::load('Linux::IOPriority', $VERSION);

1;

=head1 NAME

Linux::IOPriority

=head1 SYNOPSIS

use Linux::IOPriority;

my $prority = get_io_priority();
my $prio    = gET_priority($pid);

die "err" unless defined set_io_priority(-10);

use constant {
    IOPRIO_CLASS_NONE
    IOPRIO_CLASS_RT 
    IOPRIO_CLASS_BE
    IOPRIO_CLASS_IDLE
}

use constant {
    IOPRIO_PROCESS       => 1,
    IOPRIO_PROCESS_GROUP => 2,
    IOPRIO_USER          => 3,
}

set_io_priority(-10,2,$pid);


=cut

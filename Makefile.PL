use strict;
use warnings;

unless ($^O eq 'linux') {
    die "OS not supported.";
}

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Linux::IOPriority',
    VERSION_FROM      => 'lib/Linux/IOPriority.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT       => 'set/get your process io priority on linux',
       AUTHOR         => 'Tomasz Czepiel <tjmc@cpan.org>') : ()),
    LICENSE           => 'perl',
    META_MERGE => {
        resources => {
            repository => 'git://github.com/tczepiel/perl-linux-iopriority.git',
        },
    },
);

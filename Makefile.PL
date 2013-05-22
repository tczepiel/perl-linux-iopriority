use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'Linux::IOPriority',
    VERSION_FROM      => 'lib/Linux/IOPriority.pm',
    PREREQ_PM         => {},
    ($] >= 5.005 ?
      (ABSTRACT       => 'set/get your process io priority on linux',
       AUTHOR         => 'Tomasz Czepiel <tczepiel@cpan.org>') : ()),
    LIBS              => [''],
    DEFINE            => '',
    INC               => '-I.',
);

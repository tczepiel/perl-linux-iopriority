#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "syscall.h"

MODULE = Linux::IOPriority		PACKAGE = Linux::IOPriority
PROTOTYPES: ENABLE

BOOT:
    HV *stash;
    stash = gv_stashpvn("Linux::IOPriority", 17, TRUE);
    newCONSTSUB(stash,"__NR_ioprio_get",newSViv(__NR_ioprio_get));
    newCONSTSUB(stash,"__NR_ioprio_set",newSViv(__NR_ioprio_set));


#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#if defined(__i386__)
#define __NR_ioprio_set     289
#define __NR_ioprio_get     290
#elif defined(__ppc__)
#define __NR_ioprio_set     273
#define __NR_ioprio_get     274
#elif defined(__x86_64__)
#define __NR_ioprio_set     251
#define __NR_ioprio_get     252
#elif defined(__ia64__)
#define __NR_ioprio_set     1274
#define __NR_ioprio_get     1275
#else
#error "Unsupported arch"
#endif

enum {
    IOPRIO_CLASS_NONE,
    IOPRIO_CLASS_RT,
    IOPRIO_CLASS_BE,
    IOPRIO_CLASS_IDLE,
};

enum {
    IOPRIO_WHO_PROCESS = 1,
    IOPRIO_WHO_PROCESS_GROUP_ID,
    IOPRIO_WHO_USER,
};

#define IOPRIO_CLASS_SHIFT  13


MODULE = Linux::IOPriority		PACKAGE = Linux::IOPriority		
PROTOTYPES: ENABLE
BOOT:
    HV *stash;
    stash = gv_stashpvn("Linux::IOPriority", 17, TRUE);
    newCONSTSUB(stash,"IOPRIO_CLASS_NONE",newSViv(IOPRIO_CLASS_NONE));
    newCONSTSUB(stash,"IOPRIO_CLASS_RT",newSViv(IOPRIO_CLASS_RT));
    newCONSTSUB(stash,"IOPRIO_CLASS_BE",newSViv(IOPRIO_CLASS_BE));
    newCONSTSUB(stash,"IOPRIO_CLASS_IDLE",newSViv(IOPRIO_CLASS_IDLE));
    newCONSTSUB(stash,"IOPRIO_PROCESS",newSViv(IOPRIO_WHO_PROCESS));
    newCONSTSUB(stash,"IOPRIO_PROCESS_GROUP_ID",newSViv(IOPRIO_WHO_PROCESS_GROUP_ID));
    newCONSTSUB(stash,"IOPRIO_USER",newSViv(IOPRIO_WHO_USER));

void
get_io_priority(int pid = 0, int ioprio_who=1)
    PROTOTYPE: DISABLE
    PPCODE:
       int ioprio_class = 0;
       int ioprio = syscall(__NR_ioprio_get, ioprio_who, pid);
       SV * return_value;
       if ( ioprio == -1 ) {
            return_value = &PL_sv_undef;
       }
       else {
           ioprio_class = ioprio >> IOPRIO_CLASS_SHIFT;
           ioprio = ioprio & 0xff;
           return_value = newSViv(ioprio);
       }
       I32 wantarray = GIMME_V;
       SV * return_class = &PL_sv_undef;
       if ( wantarray == G_ARRAY && SvTRUE(return_value)) {
           EXTEND(SP,2);
           return_class = newSViv(ioprio_class);
       }
       else {
           EXTEND(SP,1);
       }

       PUSHs(sv_2mortal(return_value));

       if (SvTRUE(return_class)) {
           PUSHs(sv_2mortal(return_class));
       }

SV *
set_io_priority(int io_prio=0,int class=2,int pid=0,int ioprio_who=1)
        PROTOTYPE: DISABLE
        CODE:

        SV * return_value;
        if( syscall(__NR_ioprio_set,ioprio_who, pid, io_prio | class << IOPRIO_CLASS_SHIFT ) == -1 ) {
            return_value = &PL_sv_undef;
        }
        else {
          return_value = newSViv(io_prio);
        }

        RETVAL = return_value;

        OUTPUT:
        RETVAL


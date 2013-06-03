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
    IOPRIO_WHO_PGRP,
    IOPRIO_WHO_USER,
};

#define IOPRIO_CLASS_SHIFT  13


MODULE = Linux::IOPriority		PACKAGE = Linux::IOPriority		
PROTOTYPES: DISABLE 

SV *
get_io_priority(int pid = 0)
    CODE:
       int ioprio_class, ioprio;
       ioprio = syscall(__NR_ioprio_get, IOPRIO_WHO_PROCESS, pid);
       SV * return_value;
       if ( ioprio == -1 ) {
            return_value = &PL_sv_undef;
       }
       ioprio_class = ioprio >> IOPRIO_CLASS_SHIFT;
       ioprio = ioprio & 0xff;
       RETVAL = newSViv(ioprio);
       OUTPUT:
        RETVAL

SV *
set_io_priority(int io_prio=0,int class=2,int pid=0,int ioprio_who=IOPRIO_WHO_PROCESS)
    CODE:

    switch (io_prio) {
        case IOPRIO_CLASS_NONE:
            class = IOPRIO_CLASS_BE;
            break;
        case IOPRIO_CLASS_RT:
        case IOPRIO_CLASS_BE:
            break;
        case IOPRIO_CLASS_IDLE:
            io_prio = 7;
           break;
   }

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



//
//  patch$UNIX.c
//
//  a patch for iOS simulator library
//  e.g. Undefined symbols for architecture i386:
//  "_send$UNIX2003", referenced from: ...
//
//  Created by apple on 15/1/30.
//  Copyright (c) 2000015年 wu_pengzhou. All rights reserved.
//

#include <stdio.h>
#include <time.h>
#include <string.h>
#include <sys/socket.h>

// if you get a 'Undefined symbol' error
// add a wrap function like below

// and if you get a 'duplicate symbol linkage error
// comment out the function memtioned the error message

FILE *fopen$UNIX2003(const char *restrict p1, const char *restrict p2)
{
    return fopen(p1, p2);
}

size_t	 fwrite$UNIX2003(const void * __restrict p1, size_t p2, size_t p3, FILE * __restrict p4)
{
    return fwrite(p1, p2, p3, p4);
}

int	 fputs$UNIX2003(const char * __restrict p1, FILE * __restrict p2)
{
    return fputs(p1, p2);
}

time_t mktime$UNIX2003(struct tm * p1)
{
    return mktime(p1);
}

ssize_t	recv$UNIX2003(int p1, void * p2, size_t p3, int p4)
{
    return recv(p1, p2, p3, p4);
}

ssize_t	send$UNIX2003(int p1, const void * p2, size_t p3, int p4)
{
    return send(p1, p2, p3, p4);
}

char	*strerror$UNIX2003(int p1)
{
    return strerror(p1);
}

size_t strftime$UNIX2003(char * __restrict p1, size_t p2, const char * __restrict p3, const struct tm * __restrict p4)
{
    return strftime(p1, p2, p3, p4);
}


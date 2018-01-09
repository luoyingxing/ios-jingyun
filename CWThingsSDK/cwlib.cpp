#include <string.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>
#include "cwlib.h"
// #include "console.h"

#ifdef AVR

char* index(const char* s, int c) {
    int i = 0, len = strlen(s);
    while (i < len) {
        if (s[i] == c) {
            return (char*)&s[i];
        };
        i++;
    };
    return 0;
};

char* rindex(const char* s, const char c) {
    size_t i;
    i = strlen(s);
    if (i == 0) return NULL;
    i--;
    while ((s[i] != c) && (i >= 0)) {
        i--;
    };
    if (i < 0) return NULL;
    return (char*)&s[i];
};
#endif


void tick_to_time_str(time_t *time, char *buf, int len) {
    // 2015-01-27 11:35:09
    if (len < 20) { return; };
    if (!*time) { buf[0] = 0; return; };
    struct tm *result = localtime(time);
    result->tm_year = result->tm_year + 1900;
    result->tm_mon  = result->tm_mon  + 1;
    sprintf(buf, "%04d-%02d-%02d %02d:%02d:%02d",
            result->tm_year,
            result->tm_mon,
            result->tm_mday,
            result->tm_hour,
            result->tm_min,
            result->tm_sec);
};

time_t str_to_time_tick(char *time) {
    time = get_token_first(time, '-');
    char *year   = time; time = get_token_next(time, '-'); 
    char *month  = time; time = get_token_next(time, ' '); 
    char *day    = time; time = get_token_next(time, ':'); 
    char *hour   = time; time = get_token_next(time, ':'); 
    char *minute = time; time = get_token_rest(time);
    char *second = time; 
    struct tm _time;
    _time.tm_year = strtol(year,   NULL, 10) - 1900;
    _time.tm_mon  = strtol(month,  NULL, 10) - 1;
    _time.tm_mday = strtol(day,    NULL, 10);
    _time.tm_hour = strtol(hour,   NULL, 10);
    _time.tm_min  = strtol(minute, NULL, 10);
    _time.tm_sec  = strtol(second, NULL, 10);
    _time.tm_isdst= 0;
    return mktime(&_time);
};


char* get_token_first(char* buf, const char deli) {
    if (buf == NULL) return NULL;
    size_t end = 0;
    while ((buf[end] != deli) && (buf[end] != 0)) end++;
    buf[end] = 0;
    return buf;
};
char* get_token_next(char* buf, const char deli) {
    if (buf == NULL) return NULL;
    size_t pos = (int)strlen(buf);
    pos++;
    size_t end = pos;
    while ((buf[end] != deli) && (buf[end] != 0)) end++;
    buf[end] = 0;
    return &buf[pos];
};
char* get_token_rest(char* buf) {
    if (buf == NULL) return NULL;
    size_t pos = (int)strlen(buf);
    pos++;
    return &buf[pos];
};

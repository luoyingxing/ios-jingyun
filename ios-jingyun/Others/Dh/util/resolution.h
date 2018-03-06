#ifndef _RESOLUTIOIN_H
#define _RESOLUTIOIN_H

#include "global_macro_define.h"

typedef struct
{
	int		nWidth;
	int		nHeight;
} Resolution;


static const char* s_resolutionName[] = {
    "D1", "HD1", "BCIF", "CIF", "QCIF", "VGA", "QVGA", "SVCD", 
    "QQVGA", "SVGA", "XVGA", "WXGA", "SXGA", "WSXGA", "UXGA", "WUXGA", 
    "LFT", "720", "1080", "1.3M (1280*960)", "2.5M (1872*1408)", "5M (3744*1408)", "3M (2048*1536)", "5M (2432*2050)",
    "1.2M (1216*1024)", "1408*1024", "8M (3296*2472)", "5M (2560*1920)", "960H", "960*720", "NHD", "QNHD", "QQNHD"
};

static const Resolution s_resolutionPal[] = {
    //PAL
    704,	576,	
    352,	576,	
    704,	288,	
    352,	288,	
    176,	144,	
    640,	480,	 
    320,	240,	
    480,	480,	
    160,	128,	
    800,	592,	
    1024,	768,	
    1280,	800,	
    1280,	1024,	
    1600,	1024,	
    1600,	1200,	
    1900,	1200,	
    240,	192,	
    1280,	720,	
    1920,	1080,	
    1280,	960,	
    1872,	1408,	
    3744,	1408,	
    2048,	1536,	
    2432,	2050,	
    1216,	1024,	
    1408,	1024,	
    3296,	2472,	
    2560,	1920,	
    960,	576,	
    960,   720,
    640,   360,    
    320,   180,    
    160,   90,     
};

static const Resolution s_resolutionNtsc[] = {
    //NTSC
    704,	480,	
    352,	480,	
    704,	240,	
    352,	240,	
    176,	120,	
    640,	480,	
    320,	240,	
    480,	480,	
    160,	128,	
    800,	592,	
    1024,	768,	
    1280,	800,	
    1280,	1024,	
    1600,	1024,	
    1600,	1200,	
    1900,	1200,	
    240,	192,	
    1280,	720,	
    1920,	1080,	
    1280,	960,	
    1872,	1408,	
    3744,	1408,	
    2048,	1536,	
    2432,	2050,	
    1216,	1024,	
    1408,	1024,	
    296,	2472,	
    2560,	1920,	
    960,	480,	
    960,   720,
    640,   360,    
    320,   180,    
    160,   90,     
};

static size_t s_resolutionCount = COUNT_OF(s_resolutionName);
    
int res_cmp(const Resolution* lhs, const Resolution* rhs);
int res2idx(int width, int height);
const Resolution* idx2res(int idx, int ntsc);

#endif
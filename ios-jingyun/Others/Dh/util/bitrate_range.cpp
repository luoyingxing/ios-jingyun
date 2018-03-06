#include "bitrate_range.h"
#include <math.h>

static int round_to_factor(int n, int f)
{
    if (!f) {
        return n;
    }
    return f*roundf(n/(float)f);
}

void get_bitrate_range(int fps, int iframes, int width, int height, int encode, int* min, int* max)
{
    unsigned gop = (iframes > 149) ? 50 : iframes;
    double scalar = width*height/(352.0*288)/gop;
    
    double minRaw = 0;
    if (encode == 5) { //mjpg
        minRaw = (gop + IFRAME_PFRAME_QUOTIENT - 1)*fps*7*3*scalar;
    }
//    else if (encode == ?) { // h.264h
//        minRaw = (gop + IFRAME_PFRAME_QUOTIENT - 1)*fps*2*scalar;
//    }
    else {
        minRaw = (gop + IFRAME_PFRAME_QUOTIENT - 1)*fps*MIN_CIF_PFRAME_SIZE*scalar;
    }
    *min = round_to_factor(minRaw, (1 << (int)log2(minRaw))/4);
    
    double maxRaw = (gop + IFRAME_PFRAME_QUOTIENT - 1)*fps*MAX_CIF_PFRAME_SIZE*scalar;
    *max = round_to_factor(maxRaw, (1 << (int)log2(maxRaw))/4);
}
//
//  resolution.c
//  netsdk_demo
//
//  Created by wu_pengzhou on 14-4-18.
//  Copyright (c) 2014年 wu_pengzhou. All rights reserved.
//

#include "resolution.h"
#include <stdio.h>
#include <assert.h>

static_assert(COUNT_OF(s_resolutionName) == COUNT_OF(s_resolutionNtsc) &&
              COUNT_OF(s_resolutionName) == COUNT_OF(s_resolutionPal), "resolution size mismatch");

int res_cmp(const Resolution* lhs, const Resolution* rhs)
{
    if (lhs->nHeight == rhs->nHeight && lhs->nWidth == rhs->nWidth) {
        return 0;
    }
    else if (lhs->nHeight*lhs->nWidth > rhs->nHeight*rhs->nWidth) {
        return 1;
    }
    else {
        return -1;
    }
}

int res2idx(int width, int height)
{
    const Resolution res = {width, height};
    for (int i = 0; i < sizeof(s_resolutionNtsc)/sizeof(Resolution); ++i) {
        if (res_cmp(&res, &s_resolutionNtsc[i]) == 0 ||
            res_cmp(&res, &s_resolutionPal[i]) == 0) {
            return i;
        }
    }
    fprintf(stderr, "%d * %d is not found in predefined resolution list\n", width, height);
    return -1;
}

const Resolution* idx2res(int idx, int ntsc)
{
    assert(0 <= idx && idx < s_resolutionCount);
    
    return ntsc ? &s_resolutionNtsc[idx] : &s_resolutionPal[idx];
}
//
//  bitrate_range.h
//  netsdk_demo
//
//  Created by wu_pengzhou on 14-4-21.
//  Copyright (c) 2014年 wu_pengzhou. All rights reserved.
//

#ifndef netsdk_demo_bitrate_range_h
#define netsdk_demo_bitrate_range_h

#define MIN_CIF_PFRAME_SIZE 7 // CIF最小P帧大小，单位为Kbits
#define MAX_CIF_PFRAME_SIZE 40 // CIF最大P帧大小，单位为Kbits
#define IFRAME_PFRAME_QUOTIENT 3 // 剧烈运动情况下I帧大小与P帧大小之比

void get_bitrate_range(int fps, int iframes, int width, int height, int encode, int* min, int* max);

#endif

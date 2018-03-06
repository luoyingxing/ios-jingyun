//
//  CIPParser.m
//  TS
//
//  Created by hzci on 14-2-15.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//

#import "IPParser.h"
#define INVALID_IP(field) ((field < 0) || (field > 255))

@implementation CIPParser

-(id) init{
    if ( self = [super init]) {
    }
    return self;
}

+ (BOOL) isValidIpv4:(NSString*) strIpAddr
{
    int nField[4] = {0};
    char szEnd[256] = {0};
    const char *szIp = [strIpAddr cStringUsingEncoding: NSASCIIStringEncoding];
    
    //以"."进行分隔,取每段的前3位,保证形如 .00000.xx格式能正确判断 1.0000001.10.10000
    int iRet = sscanf(szIp, "%3d.%3d.%3d.%3d%s",
                      &nField[0], &nField[1], &nField[2], &nField[3], szEnd);
    if (4 != iRet || INVALID_IP(nField[0]) || INVALID_IP(nField[1]) ||
        INVALID_IP(nField[2]) || INVALID_IP(nField[3]))
    {
        return  NO;
    }
    return YES;
}

@end

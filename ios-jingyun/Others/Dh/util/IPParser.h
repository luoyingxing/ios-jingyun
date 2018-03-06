//
//  CIPParser.h
//  TS
//
//  Created by hzci on 14-2-15.
//  Copyright (c) 2014年 dahatech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIPParser : NSObject

//判断是否为ipv4格式
+ (BOOL) isValidIpv4:(NSString*) strIpAddr;
@end

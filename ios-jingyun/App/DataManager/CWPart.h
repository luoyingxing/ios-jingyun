//
//  CWPart.h
//  ThingsIOSClient
//
//  Created by yeung  on 14-4-23.
//  Copyright (c) 2014年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWPart : NSObject
{
@public
    NSString *part_id;
    NSString *part_name;
    NSMutableArray *actions_array;
}
@end

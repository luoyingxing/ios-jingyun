//
//  CWService.h
//  ThingsIOSClient
//
//  Created by yeung  on 14-4-17.
//  Copyright (c) 2014年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWService : NSObject
{
@public
    NSString *service_name;
    NSString *api_root;
    NSMutableArray *ap_array;
}
@end

//
//  CWRecordInfo.h
//  ThingsIOSClient
//
//  Created by yeung on 26/05/15.
//  Copyright (c) 2015年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "netsdk.h"

@interface CWRecordModel : NSObject
{
}

@property (nonatomic, assign) BOOL show_date;

@property (nonatomic, assign) BOOL show_time;

@property NET_RECORDFILE_INFO net_recordfile_info;
@end

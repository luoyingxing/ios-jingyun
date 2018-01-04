//
//  JMTaskInfo.h
//  ThingsIOSClient
//
//  Created by yeung on 29/12/15.
//  Copyright © 2015年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmTaskCellModel : NSObject
{
@public
    NSInteger           task_id;
    NSString            *tid;
    NSInteger           case_id;
    NSString            *type;
    NSString            *status;
    NSString            *content;
    NSString            *note;
    
    NSString            *tid_source;
    NSString            *tid_incharge;//
    
    NSString            *time_assign;
    NSString            *time_accept;
    NSString            *time_finish;
    
    NSString            *case_location;
    NSString            *case_time;
    NSString            *case_title;
    NSString            *case_content;
    NSString            *case_lon;
    NSString            *case_lat;
    NSString            *case_contact_name;
    NSString            *case_contact_tel;
}
@end

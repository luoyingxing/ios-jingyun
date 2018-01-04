//
//  AlarmCaseModel.h
//  TYeung
//
//  Created by yeung on 31/12/15.
//  Copyright © 2015年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmCaseModel : NSObject
{
@public
    //basic
    NSInteger           case_id;
    NSString            *case_fkey;
    NSString            *case_group_id;
    NSString            *case_type;
    NSString            *case_title;
    NSString            *case_content;
    NSString            *case_note;
    NSString            *case_location;
    NSString            *case_time;
    NSString            *case_contact_name;
    NSString            *case_contact_tel;
    NSString            *case_location_lon;
    NSString            *case_location_lat;
    NSString            *case_status;
    NSString            *case_result;
    NSString            *case_evaulate_score;
    NSString            *case_evaulate_note;
    NSString            *case_report_time;
    NSString            *case_report_tid;
    NSString            *case_report_note;
    float               case_report_lon;
    float               case_report_lat;
    NSString            *case_assign_time;
    NSString            *case_incharge_tid;
    NSString            *case_incharge_task_id;
    NSString            *case_incharge_time;
    NSString            *case_incharge_name;
    NSString            *case_incharge_note;
    NSString            *case_accept_time;
    NSString            *case_arrive_time;
    NSString            *case_arrive_tid;
    NSString            *case_arrive_name;
    NSString            *case_arrive_note;
    NSString            *case_arrive_lon;
    NSString            *case_arrive_lat;
    NSString            *case_close_time;
    NSString            *case_close_tid;
    NSString            *case_close_name;
    NSString            *case_close_note;
    NSString            *case_participants;
    
    //task list
    NSMutableArray      *taskArray;
    
}
@end

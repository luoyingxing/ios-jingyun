//
//  CWDataManager.h
//  ThingsIOSClient
//
//  Created by yeung  on 14-4-9.
//  Copyright (c) 2014年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CWProtocalDefine.h"
//#import "MsgPlaySound.h"
//#import "FMDB.h"
#import "LoginUserInfo.h"

#import <CoreLocation/CoreLocation.h>

#define NAME_LEN_ 128

@interface CWDataManager : NSObject<CWThingsListDelegate, CLLocationManagerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate>
{
@public
    NSMutableDictionary *alarm_user_dictionary;
    NSLock          *alarm_user_dic_lock;
    
    //关注对象
    NSMutableArray  *followed_things_array;
    NSMutableArray  *followed_friends_array;
    NSMutableArray  *followed_groups_array;
    NSLock          *followed_things_lock;
    BOOL            followed_things_init;
    BOOL            followed_things_init_grid;
    
    //过虑后的对象列表
    NSMutableArray  *followed_things_filter_array;
    NSLock          *followed_things_filter_lock;
    int              followed_things_filter_value;
    BOOL             followed_things_filter_update;
    int              followed_things_filter_count;
    
    
    /**
     *  未处理事件 for things table
     */
    NSMutableArray  *not_handle_event_array;
    NSLock          *not_handle_event_lock;
    BOOL            new_event_input;
    
    BOOL                chat_message_update;
    BOOL                event_message_update;
    
    BOOL                    by_pass_right_;
    BOOL                relay_mode_right_;
    
    BOOL                p2p_mode_right_;
    
    int                 things_count_;
    
    BOOL            things_connected_;
    
    BOOL            lock_pwd_invalide_;
    
    /**
     *  事件列表 for chat dialog
     */
    NSMutableDictionary *chat_message_dictionary;
    NSLock              *chat_message_lock;
    
    NSMutableArray      *event_message_array;
    
    NSString *           server_addr_;
    
@private
    /**
     *  part定义
     */
    NSMutableDictionary *things_parts_dictionary;
    NSLock              *things_parts_lock;
    
    NSTimer             *data_msg_timer_;
    
    NSInteger            image_server_port_;
    
    NSInteger           check_on_off_line_;
    //FMDatabase          *record_database_;
    
    //MsgPlaySound         *play_sound_msg_;
    //BOOL                 back_ground_running;
    //BOOL                 back_ground_sound;
    
    //BOOL                 open_device_p2p;
    
    char                 fuzzy_query_text_[NAME_LEN_];
    
    BOOL                 check_update_;
    NSString*            app_update_track_url_;
    
    
    NSString*           relay_server_ip_;
    NSString*           relay_server_port_;
    
    
    NSString            *current_device_tid_;
    
    CLLocationManager   *_locationManager;
    
    BOOL                init_flag;
    
@public
    int                  no_read_message_count;
    BOOL                update_relay_flag_;
    
    BOOL                save_user_info;
    LoginUserInfo       *login_user_info;
    
    
    NSMutableArray      *self_task_info_array;
    BOOL                update_task_info_array;
    
    NSMutableArray      *self_case_info_array;
    BOOL                update_case_info_array;
    
    NSMutableArray      *self_repair_task_info_array;
    BOOL                update_repair_task_info_array;
    
    NSMutableArray      *self_repair_case_info_array;
    BOOL                update_repair_case_info_array;
    
    NSMutableArray      *self_query_user_data_array;
    BOOL                update_query_user_data_array;
    
    BOOL                user_login_ok;
    
    NSString            *self_to_tid;
    
    NSString            *self_name;
    
@private
    UIView              *main_view_;
    UIView              *parent_view_;
    
    BOOL                show_network_Status;
    UIView              *network_status_view_;
    
    BOOL                show_message_tip;
    UIView              *message_tip_view_;
    
    BOOL                show_notice;
    UIView              *notice_view_;
}

+ (CWDataManager *) sharedInstance;

- (void) initData;
- (int) getThingsCount;
- (id) ThingsObjectAtIndex:(id)index;

-(void) playMP3Sound:(BOOL)init;
- (void)playOrPause:(BOOL) stop;

- (int) getThingsObjectCount;
- (id) ThingsMsgObjectAtIndex:(NSInteger)index;
- (id) ThingsMsgObjectForKey:(NSString*)key;
- (int) ThingsMsgUnreadCount;
- (void) ThingsMsgMoveFirst:(NSString*)tid;
- (void) ThingsMsgUpdate:(NSString*)tid time:(NSString*)time event:(NSString*)content;
- (BOOL) needUpdate;
- (void) setNeedUpdate:(BOOL)update;

- (void) get_status;

- (id) PartObjectAtIndex:(NSString*)partid;

- (id) getMessage;

- (id) getThingsLastEventForTid:(NSString*)tid;

- (NSMutableArray*) getChatMessageArray4Tid:(NSString*)tid;

- (void) saveUnreadEvent4Things:(NSString*)tid value:(NSInteger)value;

- (NSInteger) getUnreadEevent4Things:(NSString*)tid;

- (void)select_all:(BOOL)selected;
- (void) updateFilterValue:(BOOL)selected num:(int)num;
- (BOOL) getFilterValue:(int)num;


- (void) turnToRunningBackground:(BOOL) flag;
- (void) reportNotHandleEvent : (BOOL)increase;
- (void) open_device_p2p : (BOOL)open;
- (BOOL) getDeviceP2P;
- (void) open_device_relay : (BOOL)open;
- (void) background_sound : (BOOL)open;
- (BOOL) getBackgrouSound;
- (void) playBackgroudSoud: (BOOL)vibrate;

- (void) setFuzzyQuery:(char*)text;
- (char*) getFuzzyQuery;


-(void) pushNotifyEvent:(NSString*)eventBody;

-(void) checkVersion;

//old not use
- (void) setMainView:(UIView*) mainView parentView:(UIView*)inView;

- (void) updateMainView;

- (void) setNavigationBar:(UINavigationBar*)navBar;
- (void) showToast:(NSString*)strText withTID:(NSString*)tid withType:(NSInteger)type;

- (NSString*) get_relay_server_ip;
- (NSString*) get_relay_server_port;

- (void) showGestureLockViewController;

@property (nonatomic, assign) CGFloat           userLon;
@property (nonatomic, assign) CGFloat           userLat;

@property (nonatomic, strong) NSMutableArray    *selfUserAlarmDataArray;
@property (nonatomic, assign) BOOL              selfUserAlarmDataUpdate;

@property (nonatomic, assign) NSInteger         selectedMenuIndex;
@property (nonatomic, assign) NSInteger         leftSideSelectedMenuIndex;
@property (nonatomic, strong) NSString          *selectedMenuCaption;
@property (nonatomic, strong) NSString          *selectedConfigCaption;

@property (nonatomic, assign) BOOL              queryUserInfoRight;
@property (nonatomic, assign) BOOL              modifyUserInfoRight;
@property (nonatomic, assign) BOOL              alarmCaseRight;
@property (nonatomic, assign) BOOL              repairCaseRight;

@property (nonatomic, assign) BOOL  videoRight;
@property (nonatomic, assign) BOOL  awayRight;
@property (nonatomic, assign) BOOL  openRight;

@property (nonatomic, assign) BOOL              isOldSystemVersion;

@property (nonatomic, strong) NSString          *scanQRCode;

@property (nonatomic, strong) NSString          *playSoundName;

@property (nonatomic, assign) NSInteger         selectedSoundIndex;

@property (nonatomic, strong) NSString          *myNewUserPassword;
@property (nonatomic, strong) NSString          *noBindUserPassword;

@property (nonatomic, assign) BOOL              isCloseLocation;

@property (nonatomic, assign) BOOL              isOpenGesturePwd;

@property (nonatomic, assign) BOOL              isNavBarHidden;

@property (nonatomic, assign) BOOL              isInitDataFinished;

@property (nonatomic, strong) NSString          *currentUserPassword;

@property (nonatomic, assign) BOOL              isLostPassword;

@property (nonatomic, strong) NSString          *deviceToken;

@property (nonatomic, assign) BOOL              queryAlarmUserNearby;

@property (nonatomic, strong) NSMutableArray    *queryAlarmUserNearbyArray;

@property (nonatomic, assign) BOOL              queryRepairUserNearby;

@property (nonatomic, strong) NSMutableArray    *queryRepairUserNearbyArray;

@property (nonatomic, assign) BOOL              bindUID2Device;
@end

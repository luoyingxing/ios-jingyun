//
//  CWDataManager.m
//  ThingsIOSClient
//
//  Created by yeung  on 14-4-9.
//  Copyright (c) 2014年 yeung . All rights reserved.
//

#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "DeviceStatusModel.h"
#import "CWVideoChannel.h"
#import "CWPart.h"
#import "CWAction.h"
#import "DeviceMessageModel.h"
#import "AlarmTaskCellModel.h"
#import "AlarmCaseModel.h"
#import "UserDataModel.h"
#import "ZoneDataModel.h"
#import "ContactDataModel.h"
#import "AlarmDataModel.h"
#import "NSObject+BAProgressHUD.h"
#import "TYToastView.h"
#import <AudioToolbox/AudioToolbox.h>
//#import "JinnLockViewController.h"
#import "NCChineseConverter.h"
#import "NSString+NCAddition.h"
#import "DXAudioTool.h"
#import <MediaPlayer/MediaPlayer.h>
//#import "UserViewController.h"
//#import "SDBaseNavigationController.h"
//#import "UIView+TYAlertView.h"
#import "AlarmUserLocation.h"
#import "RepairUserLocation.h"
#import "CLLocation+YCLocation.h"

#define MY_APP_URL @"http://itunes.apple.com/lookup?id=940312644"

static NSString *DownloadURLString = @"http://localhost/app_logo.png";

@interface CWDataManager() <AVAudioPlayerDelegate>

@property (nonatomic, assign) BOOL openLocation;

@property (nonatomic, strong) UINavigationBar *navgationBar;

@property (nonatomic, assign) NCChineseConverterDictType chineseConverterDictType;

@property (nonatomic, assign) BOOL isRunningInBackground;

@property (nonatomic, assign) BOOL isOpenMessageSound;

//for background download data
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;


@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL backgroundSoundPlaying;

@property (nonatomic, assign) NSInteger lockPasswordErrCount;
@end

@implementation CWDataManager

static CWDataManager *sharedInstance = nil;

+ (CWDataManager *) sharedInstance
{
	return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}


#pragma mark - initialize
- (void) initData
{
    if (init_flag == NO) {
        init_flag = YES;
    }
    else {
        return ;
    }
    check_on_off_line_ = 0;
    
    if (followed_things_lock == nil) {
        followed_things_lock = [[NSLock alloc] init];
    }
    
    if (followed_things_array == nil) {
        followed_things_array = [[NSMutableArray alloc] init];
    }
    
    if (followed_things_filter_lock == nil) {
        followed_things_filter_lock = [[NSLock alloc] init];
    }
    
    if (followed_things_filter_array == nil) {
        followed_things_filter_array = [[NSMutableArray alloc] init];
    }
    
    if (alarm_user_dictionary == nil) {
        alarm_user_dictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (chat_message_dictionary == nil) {
        chat_message_dictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (chat_message_lock == nil) {
        chat_message_lock = [[NSLock alloc] init];
    }
    
    if (alarm_user_dic_lock == nil) {
        alarm_user_dic_lock = [[NSLock alloc] init];
    }
    
    
    if (things_parts_dictionary == nil) {
        things_parts_dictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (things_parts_lock == nil) {
        things_parts_lock = [[NSLock alloc] init];
    }
    
    [[CWThings4Interface sharedInstance] set_login_delegate:self];
    [[CWThings4Interface sharedInstance] set_data_delegate:self];
    
    [self recognitionLanguage];
    
    new_event_input = NO;
    followed_things_init = NO;
    followed_things_filter_update = NO;
    followed_things_filter_count = 0;
    [self select_all:YES];
    followed_things_init_grid = NO;
    
    _isNavBarHidden         = NO;
    _isRunningInBackground = NO;
    _isInitDataFinished = NO;
    
    _lockPasswordErrCount = 0;
    
    by_pass_right_ = NO;
    
    things_count_ = 0;
    
    lock_pwd_invalide_ = NO;
    
    _isOpenGesturePwd = NO;
    no_read_message_count = 0;
    
    
    
    memset(fuzzy_query_text_, 0, NAME_LEN_);
    
    p2p_mode_right_ = [[NSUserDefaults standardUserDefaults] boolForKey:@"open_device_p2p"];
    relay_mode_right_ = [[NSUserDefaults standardUserDefaults] boolForKey:@"open_device_relay"];
    _bindUID2Device = [[NSUserDefaults standardUserDefaults] boolForKey:@"bindUID2Device"];
    
    _isOpenMessageSound = [[NSUserDefaults standardUserDefaults] boolForKey:@"open_sound_switch"];
    _selectedMenuCaption = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedMenuCaption"];
    if (_selectedMenuCaption == nil) {
        _selectedMenuCaption = NSLocalizedString(@"LeftMenuController_Device", @"");
    }
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"fuzzy_query_name"];
    if (name) {
        strcpy(fuzzy_query_text_, [name UTF8String]);
    }
    
    _selectedSoundIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"SelectedSoundIndex"];
    
    _isOpenGesturePwd = [[NSUserDefaults standardUserDefaults] boolForKey:@"isOpenGesturePwd"];
    
    _playSoundName = [[NSUserDefaults standardUserDefaults] stringForKey:@"setPlaySoundName"];
#pragma mark - notify setting
    if (_isOpenMessageSound) {
        /*if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        }*/
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
        else
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    //play_sound_msg_ = [[MsgPlaySound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
    
    //[[CWEnvManager sharedInstance] initEnv];
    
    check_update_ = NO;
    app_update_track_url_ = nil;
    [self checkVersion];
    
    relay_server_port_ = nil;
    relay_server_ip_ = nil;
    update_relay_flag_ = NO;
    
#pragma mark - location setting
    //location
    //BOOL isCloseLot = [[NSUserDefaults standardUserDefaults] boolForKey:@"isCloseLocation"];
    //[self setIsCloseLocation:isCloseLot];
    
    data_msg_timer_ = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(data_update) userInfo:nil repeats:YES];
    
    UIScreen *currentScreen = [UIScreen mainScreen];
    network_status_view_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, currentScreen.applicationFrame.size.width, 100)];
    [network_status_view_ setBackgroundColor:[UIColor lightGrayColor]];
    show_network_Status = NO;
    
    message_tip_view_ = [[UIView alloc] initWithFrame:CGRectZero];
    [message_tip_view_  setBackgroundColor: [UIColor lightGrayColor]];
    show_message_tip = NO;
    
    notice_view_ = [[UIView alloc] initWithFrame:CGRectZero];
    [notice_view_ setBackgroundColor:[UIColor lightGrayColor]];
    show_notice = YES;
    
    save_user_info = NO;
    
    user_login_ok = NO;
    
    event_message_update = NO;
    
    update_query_user_data_array = NO;
    
    _scanQRCode = @"";
    
    char *self_tid = [[CWThings4Interface sharedInstance] get_var_with_path:"" path:"" sessions:NO];
    if (self_tid) {
        self_to_tid = [[NSString alloc] initWithUTF8String:self_tid];
    }

    
    //_backgroundSoundPlaying = NO;
    //[self playMP3Sound:NO];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - play background sound
- (void) playMP3Sound:(BOOL)init
{
    if (user_login_ok == NO) return ;
    AVAudioPlayer *currentPlayer = [DXAudioTool playMusicWithMusicName:@"nosound.mp3"];
    if (currentPlayer) {
        self.audioPlayer = currentPlayer;
    }
    
    MPNowPlayingInfoCenter *playingInfoCenter = [MPNowPlayingInfoCenter defaultCenter];
    
    // 2.设置展示的信息
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    [playingInfo setObject:@"警云" forKey:MPMediaItemPropertyAlbumTitle];
    //[playingInfo setObject:@"nosound.mp3" forKey:MPMediaItemPropertyArtist];
    //MPMediaItemArtwork *artWork = [[MPMediaItemArtwork alloc] initWithImage:lockImage];
    //[playingInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
    //[playingInfo setObject:@(self.duration) forKey:MPMediaItemPropertyPlaybackDuration];
    //[playingInfo setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    playingInfoCenter.nowPlayingInfo = playingInfo;
    
    // 3.让应用程序可以接受远程事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)playOrPause:(BOOL) stop{
    if (user_login_ok == NO) return ;
    if (stop) {
        if (self.audioPlayer.playing) {
            [self.audioPlayer pause];
        }
    }else {
        if ([self.audioPlayer play]) {
            NSLog(@"play ok");
        }
        else {
            NSLog(@"play failue");
        }
    }
}

- (void) onAudioSessionEvent: (NSNotification *) notification
{
    //Check the type of notification, especially if you are sending multiple AVAudioSession events here
    NSLog(@"Interruption notification name %@", notification.name);
    
    if ([notification.name isEqualToString:AVAudioSessionInterruptionNotification]) {
        NSLog(@"Interruption notification received %@!", notification);
        
        int interruptionType = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
        if (interruptionType == AVAudioSessionInterruptionTypeBegan) {
            [self playOrPause:YES];
            NSLog(@"Pausing for audio session interruption");
        } else if (interruptionType == AVAudioSessionInterruptionTypeEnded) {
            if ([notification.userInfo[AVAudioSessionInterruptionOptionKey] intValue] == AVAudioSessionInterruptionOptionShouldResume) {
                NSLog(@"Resuming after audio session interruption");
                [self playOrPause:NO];
            }
        }
    }
}

// 监听远程事件
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            //[self playOrPause];
            break;
            
        case UIEventSubtypeRemoteControlNextTrack:
            //[self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            //[self previous];
            break;
            
        default:
            break;
    }
}

#pragma mark - timer
- (void)data_update
{
    if (_openLocation == NO && _openLocation == NO) {
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
            [self startStandardUpdates];
            _openLocation = YES;
        }
    }
    BOOL update_filter = NO;
    if (followed_things_filter_update == YES && (followed_things_filter_value & (1<<1)) == 0) {
        [followed_things_filter_lock lock];
        [followed_things_filter_array removeAllObjects];
        [followed_things_filter_lock unlock];
        
        [followed_things_lock lock];
        for (DeviceStatusModel* object in followed_things_array) {
            DeviceStatusModel *thing_object = nil;
            
            //online or off line
            char *online = [[CWThings4Interface sharedInstance] get_var_with_path:[object.tid UTF8String] path:"online" sessions:NO];
            if (online && strcmp(online, "false") == 0) {
                if ((followed_things_filter_value & (1<<7)) > 0) {
                    thing_object = object;
                }
            }
            else if(online && strcmp(online, "true") == 0){
                if ((followed_things_filter_value & (1<<6)) > 0) {
                    thing_object = object;
                }
            }
            
            char *part_id = [[CWThings4Interface sharedInstance] get_var_with_path:[object.tid UTF8String] path:"part_id" sessions:NO];
            char var_path[64] = {0};
            if (part_id && (strcmp(part_id, "1000") == 0 || strcmp(part_id, "1001") == 0 || strcmp(part_id, "1002") == 0)) {
                sprintf(var_path, "pnl.s.s");
            }
            else if (part_id && (strcmp(part_id, "1100") == 0 || strcmp(part_id, "1101") == 0 || strcmp(part_id, "1104") == 0)) {
                sprintf(var_path, "pnl.r.s");
            }
            else if (part_id && strcmp(part_id, "2000") == 0) {
                sprintf(var_path, "areas");
            }
            //away etc.
            char *status = NULL;
            if (part_id && strcmp(part_id, "2000") == 0) {
                status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[object.tid UTF8String] prepath:var_path member:0 backpath:"stat"];
            }
            else {
                status = [[CWThings4Interface sharedInstance] get_var_with_path:[object.tid UTF8String] path:var_path sessions:YES];
            }
            //char *status = [[CWThings4Interface sharedInstance] get_var_with_path:[object->tid UTF8String] path:var_path sessions:YES];
            if (status) {
                if (status) {
                    if (strcmp(status, "away") == 0 ){
                        //布防
                        if ((followed_things_filter_value & (1<<2)) > 0) {
                            thing_object = object;
                        }
                    }
                    else if(strcmp(status, "open") == 0) {
                        //撤防
                        if ((followed_things_filter_value & (1<<3)) > 0) {
                            thing_object = object;
                        }
                    }
                    else if(strcmp(status, "stay") == 0) {
                        //在线
                        if ((followed_things_filter_value & (1<<4)) > 0) {
                            thing_object = object;
                        }
                    }
                    else if(strcmp(status, "alarm") == 0) {
                        //离线
                        if ((followed_things_filter_value & (1<<5)) > 0) {
                            thing_object = object;
                        }
                    }
                    
                    int zone_numbers = 0;
                    if (part_id && strcmp(part_id, "2000") == 0) {
                        zone_numbers = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[object.tid  UTF8String] path:"zones"];
                    }
                    else {
                        zone_numbers = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[object.tid  UTF8String] path:"z"];
                    }
                    BOOL zone_alarm_status = NO;
                    for (int i = 0; i < zone_numbers; i++) {
                        char zone_path[256] = {0};
                        char *status = NULL;
                        if (strcmp(part_id, "2000") == 0) {
                            status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[object.tid UTF8String] prepath:"zones" member:i backpath:"stat"];
                        }
                        else {
                            sprintf(zone_path, "z.%03d.s", i + 1);
                            status = [[CWThings4Interface sharedInstance] get_var_with_path:[object.tid UTF8String] path:zone_path sessions:YES];
                        }
                        
                        if (status) {
                            if (strcmp(status, "alarm") == 0) {
                                zone_alarm_status = YES;
                                if ((followed_things_filter_value & (1<<5)) > 0) {
                                    thing_object = object;
                                    break;
                                }
                            }
                        }
                    }
                }
            }
            //Fuzzy query
            char *thing_name = [[CWThings4Interface sharedInstance] get_var_with_path:[object.tid UTF8String] path:"name" sessions:NO];
            if (thing_name) {
                if ((followed_things_filter_value & (1<<8)) > 0) {
                    char *name = strstr(thing_name,  fuzzy_query_text_);
                    if (name) {
                        thing_object = object;
                    }
                    else {
                        thing_object = nil;
                    }
                }
            }
            
            if (thing_object != nil ) {
                [followed_things_lock unlock];
                [followed_things_filter_lock lock];
                [followed_things_filter_array addObject:thing_object];
                
                [followed_things_filter_lock unlock];
                [followed_things_lock lock];
            }
        }
        [followed_things_lock unlock];
        followed_things_filter_update = NO;
        update_filter = YES;
    }
    
    followed_things_filter_count++;
    if (followed_things_filter_count == 20) {
        followed_things_filter_update = YES;
        followed_things_filter_count = 0;
        [self checkVersion];
    }
    
    if (update_filter == YES) {
        followed_things_init_grid = YES;
        followed_things_init = YES;
        followed_things_filter_count = 0;
    }
    
    //network status
    
    int socket_state = [[CWThings4Interface sharedInstance] get_state];
    switch (socket_state) {
        case 1:
        case 2:
        case 3:
        //case 4:
        {
            show_network_Status = YES;
        }
            break;
        case 5:
        {
            show_network_Status = NO;
        }
            break;
        case 6:
        {
            
            break;
        }
        case 7:
        {
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - data handle
- (int) getThingsCount
{
    int nCount = 0;
    [alarm_user_dic_lock lock];
    nCount = (int)[alarm_user_dictionary count];
    [alarm_user_dic_lock unlock];
    
    return nCount;
}

- (id) ThingsObjectAtIndex:(id)index
{
    id alarm_user = nil;
    [alarm_user_dic_lock lock];
    alarm_user = [alarm_user_dictionary objectForKey:index];
    [alarm_user_dic_lock unlock];
    return alarm_user;
}


- (int) getThingsObjectCount
{
    int nCount = 0;
    if ((followed_things_filter_value & (1<<1)) > 0) {
        [followed_things_lock lock];
        nCount = (int)[followed_things_array count];
        [followed_things_lock unlock];
    }
    else {
        [followed_things_filter_lock lock];
        nCount = (int)[followed_things_filter_array count];
        [followed_things_filter_lock unlock];
    }
    
    return nCount;
}

- (id) ThingsMsgObjectAtIndex:(NSInteger)index
{
    id alarm_user = nil;
    
    if ((followed_things_filter_value & (1<<1)) > 0) {
        [followed_things_lock lock];
        alarm_user = [followed_things_array objectAtIndex:index];
        [followed_things_lock unlock];
    }
    else {
        [followed_things_filter_lock lock];
        alarm_user = [followed_things_filter_array objectAtIndex:index];
        [followed_things_filter_lock unlock];
    }
    
    return alarm_user;
}

- (id) ThingsMsgObjectForKey:(NSString*)key
{
    if ((followed_things_filter_value & (1<<1)) > 0) {
        [followed_things_lock lock];
        for(DeviceStatusModel *deviceModel in followed_things_array) {
            if (deviceModel && [deviceModel.tid isEqualToString:key]) {
                [followed_things_lock unlock];
                return deviceModel;
            }
        }
        [followed_things_lock unlock];
    }
    else {
        [followed_things_filter_lock lock];
        for(DeviceStatusModel *deviceModel in followed_things_filter_array) {
            if (deviceModel && [deviceModel.tid isEqualToString:key]) {
                [followed_things_filter_lock unlock];
                return deviceModel;
            }
        }
        [followed_things_filter_lock unlock];
    }
    return nil;;
}

- (int) ThingsMsgUnreadCount
{
    int unread_count = 0;
    if ((followed_things_filter_value & (1<<1)) > 0) {
        [followed_things_lock lock];
        for(DeviceStatusModel *things in followed_things_array) {
            unread_count += things.unread_count;
        }
        [followed_things_lock unlock];
    }
    else {
        [followed_things_filter_lock lock];
        for(DeviceStatusModel *things in followed_things_filter_array) {
            unread_count += things.unread_count;
        }
        [followed_things_filter_lock unlock];
    }
    return unread_count;;
}

- (void) ThingsMsgMoveFirst:(NSString*)tid
{
    NSUInteger uCount = 0;
    DeviceStatusModel *thing_object = nil;
    if ((followed_things_filter_value & (1<<1)) > 0) {
        [followed_things_lock lock];
        for (DeviceStatusModel* pDevice in followed_things_array) {
            if ([pDevice.tid isEqualToString:tid]) {
                thing_object = [[DeviceStatusModel alloc] init];
                thing_object.tid = pDevice.tid;
                thing_object.device_status = pDevice.device_status;
                thing_object.unread_count = pDevice.unread_count;
                if (pDevice.device_status == YES && uCount > 0) {
                    if (pDevice.on_off_line) {
                        [followed_things_array removeObjectAtIndex:uCount];
                        [followed_things_array insertObject:thing_object atIndex:0];
                    }
                    [followed_things_lock unlock];
                    return ;
                }
                else {
                    [followed_things_array removeObjectAtIndex:uCount];
                    //[followed_things_array addObject:thing_object];
                }
                break;
            }
            uCount++;
        }
        
        uCount = 0;
        for (DeviceStatusModel *thing_obj in followed_things_array) {
            if (thing_obj.device_status == NO ) {
                if (thing_object) {
                    [followed_things_array insertObject:thing_object atIndex:uCount];
                }
                break;
            }
            uCount++;
        }
        if (uCount == [followed_things_array count]) {
            if (thing_object) {
                [followed_things_array insertObject:thing_object atIndex:uCount];
            }
        }
        [followed_things_lock unlock];
    }
    else {//filter array
        [followed_things_filter_lock lock];
        for (DeviceStatusModel* pDevice in followed_things_filter_array) {
            if ([pDevice.tid isEqualToString:tid]) {
                thing_object = [[DeviceStatusModel alloc] init];
                thing_object.tid = pDevice.tid;
                thing_object.device_status = pDevice.device_status;
                thing_object.unread_count = pDevice.unread_count;
                if (pDevice.device_status == YES && uCount > 0) {
                    if (pDevice.on_off_line) {
                        [followed_things_filter_array removeObjectAtIndex:uCount];
                        [followed_things_filter_array insertObject:thing_object atIndex:0];
                    }
                    
                    [followed_things_filter_lock unlock];
                    return ;
                }
                else {
                    [followed_things_filter_array removeObjectAtIndex:uCount];
                    //[followed_things_array addObject:thing_object];
                }
                break;
            }
            uCount++;
        }
        
        uCount = 0;
        for (DeviceStatusModel *thing_obj in followed_things_filter_array) {
            if (thing_obj.device_status == NO ) {
                if (thing_object) {
                    [followed_things_filter_array insertObject:thing_object atIndex:uCount];
                }
                break;
            }
            uCount++;
        }
        
        if (uCount == [followed_things_array count]) {
            if (thing_object) {
                [followed_things_array insertObject:thing_object atIndex:uCount];
            }
        }
        [followed_things_filter_lock unlock];
    }
    
    
}

- (void) ThingsMsgUpdate:(NSString*)tid time:(NSString*)time event:(NSString*)content
{
    return ;
    [followed_things_lock lock];
    NSUInteger uCount = 0;
    for (id device in followed_things_array) {
        DeviceStatusModel *pDevice = (DeviceStatusModel*)device;
        if ([pDevice.tid isEqualToString:tid]) {
            //pDevice.time = time;
            //pDevice.event_content = content;
            new_event_input = YES;
            break;
        }
        uCount++;
    }
    [followed_things_lock unlock];
    //need_update = YES;
    
}
- (BOOL) needUpdate
{
    return new_event_input;
}

- (void) setNeedUpdate:(BOOL)update
{
    new_event_input = update;
}

- (void) get_status
{
    
}

- (id) PartObjectAtIndex:(NSString*)partid
{
    [things_parts_lock lock];
    id part = [things_parts_dictionary objectForKey:partid];
    if (part) {
        [things_parts_lock unlock];
        return part;
    }
    [things_parts_lock unlock];
    return nil;
}

- (id) getMessage
{
    [not_handle_event_lock lock];
    if (not_handle_event_array && [not_handle_event_array count] > 0)
    {
        id msg = [not_handle_event_array objectAtIndex:0];
        if (msg) {
            [not_handle_event_array removeObjectAtIndex:0];
            [not_handle_event_lock unlock];
            return msg;
        }
    }
    [not_handle_event_lock unlock];
    return nil;
}

- (id) getThingsLastEventForTid:(NSString*)tid
{
    [chat_message_lock lock];
    NSMutableArray *deviceModel_array = [chat_message_dictionary objectForKey:tid];
    if (deviceModel_array && [deviceModel_array count] > 0) {
        int count = [deviceModel_array count];
        id thing_object = [deviceModel_array objectAtIndex:count - 1];
        [chat_message_lock unlock];
        return thing_object;
    }
    [chat_message_lock unlock];
    return nil;
}

- (NSMutableArray*) getChatMessageArray4Tid:(NSString *)tid
{
    [chat_message_lock lock];
    NSMutableArray *event_array = [chat_message_dictionary objectForKey:tid];
    if (event_array && [event_array count] > 0) {
        [chat_message_lock unlock];
        return event_array;
    }
    
    [chat_message_lock unlock];
    return nil;
}


#pragma mark - system message
-(void)cwPostThingsList:(const char*)inThingsJson Header:(const char*)inHeader
{
    [followed_things_lock lock];
    if (followed_things_array == nil) {
        followed_things_array = [[NSMutableArray alloc] init];
    }
    if ([followed_things_array count] > 0) {
        [followed_things_array removeAllObjects];
    }
    [followed_things_lock unlock];
    
    if ([followed_groups_array count] > 0) {
        [followed_groups_array removeAllObjects];
    }
    if ([followed_friends_array count] > 0) {
        [followed_friends_array removeAllObjects];
    }
    
    
    
    
    BOOL video_right = NO;
    BOOL away_right = NO;
    BOOL open_right = NO;
   
    NSMutableArray *tmp_followed_things = [[NSMutableArray alloc] init];
    NSMutableArray *tmp_followed_alarm = [[NSMutableArray alloc] init];
    
    NSDictionary *things_list = nil;
    if (inThingsJson != NULL) {
        NSError *error;
        NSString *json = [NSString stringWithUTF8String:inThingsJson];
        NSLog(@"%@\r\n", json);
        NSData *things_list_json = [NSData dataWithBytes:inThingsJson length:strlen(inThingsJson)];
        NSDictionary* thingsResult  = [NSJSONSerialization JSONObjectWithData:things_list_json options:NSJSONReadingMutableLeaves error:&error];
        if (thingsResult) {
            things_list = [thingsResult objectForKey:@"result"];
            if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
                things_list = thingsResult;
            }
        }
    }
    
    id followed_things = nil;
    if (things_list) {
        followed_things = [things_list objectForKey:@"followed"];
    }
    if (followed_things) {
        for (NSString *things_id in followed_things) {
            DeviceStatusModel *deviceModel = [[DeviceStatusModel alloc] init];
            deviceModel.videoPlayMode = 0;
            deviceModel.tid = things_id;
            NSInteger unread_count_last = [self getUnreadEevent4Things:things_id];
            NSLog(@"CWDataManager cwPostThingsList -----> TID:  %@  unreadCount:  %lu", things_id, unread_count_last);
            deviceModel.unread_count = unread_count_last;
            [tmp_followed_things addObject:deviceModel];
        }
    }
    else {
        int things_count = [[CWThings4Interface sharedInstance] get_sync_with_things];
        things_count_ = things_count;
        for (int i = 0; i < things_count; i++) {
            char *things_id = [[CWThings4Interface sharedInstance] get_var_with_thing:i];
            if (things_id) {
                NSString *ns_things_id = [[NSString alloc] initWithUTF8String:things_id];
                DeviceStatusModel *deivceModel = [[DeviceStatusModel alloc] init];
                deivceModel.videoPlayMode = 0;
                char *part_id = [[CWThings4Interface sharedInstance] get_var_with_path:things_id path:"part_id" sessions:NO];
                char *online = [[CWThings4Interface sharedInstance] get_var_with_path:things_id path:"online" sessions:NO];
                if (part_id && strcmp(part_id, "100") == 0  && online && strcmp(online, "true") == 0) {
                    char *center_name = [[CWThings4Interface sharedInstance] get_var_with_path:things_id path:"name" sessions:NO];
                    if (center_name) {
                        NSString *ns_center_name = [[NSString alloc] initWithUTF8String:center_name];
                        [[NSUserDefaults standardUserDefaults] setObject:ns_center_name forKey:@"cw_center_name"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    }
                }
                if (part_id) {
                    deivceModel.partID = [[NSString alloc] initWithUTF8String:part_id];
                }
                
                char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:things_id path:"name" sessions:NO];
                if (things_name) {
                    deivceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
                }
                
                char *things_type = [[CWThings4Interface sharedInstance] get_var_with_path:things_id path:"type" sessions:NO];
                
                if (things_type && strcmp(things_type, "group") == 0)
                {
                    if (followed_groups_array == nil) {
                        followed_groups_array = [[NSMutableArray alloc] init];
                    }
                    [followed_groups_array addObject:deivceModel];
                }
                else if (things_type && strcmp(things_type, "user") == 0)
                {
                    if (followed_friends_array == nil) {
                        followed_friends_array = [[NSMutableArray alloc] init];
                    }
                    [followed_friends_array addObject:deivceModel];
                }
                else {
                    [tmp_followed_things addObject:deivceModel];
                }
                deivceModel.tid = ns_things_id;
                
                NSInteger unread_count_last = [self getUnreadEevent4Things:ns_things_id];
                deivceModel.unread_count = unread_count_last;
            }
        }
    }
    
    if (things_list) {
        self_name = [things_list objectForKey:@"name"];
        //rights
        id profile_things = [things_list objectForKey:@"profile"];
        if (profile_things) {
            id pub_things = [profile_things objectForKey:@"pub"];
            if (pub_things && ![pub_things isKindOfClass:[NSNull class]] && ![pub_things isKindOfClass:[NSString class]]) {
                id rights_things = [pub_things objectForKey:@"rights"];
                if (rights_things) {
                    id video_ = [rights_things objectForKey:@"视频操作"];
                    video_right = [video_ boolValue];
                    _videoRight = video_right;
                    id away_ = [rights_things objectForKey:@"布防操作"];
                    away_right = [away_ boolValue];
                    _awayRight = away_right;
                    id open_ = [rights_things objectForKey:@"撤防操作"];
                    open_right = [open_ boolValue];
                    _openRight = open_right;
                    id bypass_ = [rights_things objectForKey:@"旁路操作"];
                    by_pass_right_ = [bypass_ boolValue];
                    id alarmCaseRight = [rights_things objectForKey:@"出警操作"];
                    _alarmCaseRight = [alarmCaseRight boolValue];
                    id repairCaseRight = [rights_things objectForKey:@"维修操作"];
                    _repairCaseRight = [repairCaseRight boolValue];
                    id queryUserInfoRight = [rights_things objectForKey:@"查询操作"];
                    _queryUserInfoRight = [queryUserInfoRight boolValue];
                    id modifyUserInfoRight = [rights_things objectForKey:@"修改操作"];
                    _modifyUserInfoRight = [modifyUserInfoRight boolValue];
                    //id relay_ = [rights_things objectForKey:@"转发模式"];
                    //relay_mode_right_ = [relay_ boolValue];
                    //id p2p_ = [rights_things objectForKey:@"P2P模式"];
                    //p2p_mode_right_ = [p2p_ boolValue];
                }
            }
        }
        
        //unreads
        id unreads_things = [things_list objectForKey:@"unreads"];
        NSArray *unread_keks = [unreads_things allKeys];
        for (NSString *key_t in unread_keks) {
            id unread_info = [unreads_things objectForKey:key_t];
            for (DeviceStatusModel *thing_object in tmp_followed_things) {
                if ([thing_object.tid isEqualToString:key_t]) {
                    NSString *unread_cnt = [unread_info objectForKey:@"cnt"];
                    thing_object.unread_count += [unread_cnt integerValue];
                    [self saveUnreadEvent4Things:thing_object.tid value:thing_object.unread_count];
                    break;
                }
            }
        }
    }
    
    for (DeviceStatusModel *thing_object in tmp_followed_things) {
        char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:[thing_object.tid UTF8String] path:"name" sessions:NO];
        
            thing_object.device_status = NO;
            thing_object.caption = [[NSString alloc] initWithUTF8String:things_name];
            [followed_things_lock lock];
            [followed_things_array addObject:thing_object];
            [followed_things_lock unlock];
        
    }
    
    [followed_things_lock lock];
    [followed_things_array sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
        DeviceStatusModel *things_obj_pre = (DeviceStatusModel*)obj1;
        DeviceStatusModel *things_obj_next = (DeviceStatusModel*)obj2;
        
        return [things_obj_pre.caption compare:things_obj_next.caption];
    }];
    [followed_things_lock unlock];
    
    followed_things_init = YES;
    followed_things_init_grid = YES;
    
    if (inThingsJson == NULL) {
        return;
    }
    
    [things_parts_lock lock];
    if (things_parts_dictionary == nil ) {
        things_parts_dictionary = [[NSMutableDictionary alloc] init];
    }
    if ([things_parts_dictionary count] > 0) {
        [things_parts_dictionary removeAllObjects];
    }
    [things_parts_lock unlock];
    
    //100
    CWPart *cw_part_100 = [[CWPart alloc] init];
    //part
    cw_part_100->part_id = @"100";
    cw_part_100->part_name = @"警讯中心接口";
    
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_100 forKey:cw_part_100->part_id];
    [things_parts_lock unlock];
    
    //101
    CWPart *cw_part_101 = [[CWPart alloc] init];
    //part
    cw_part_101->part_id = @"101";
    cw_part_101->part_name = @"IPR";
    
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_101 forKey:cw_part_101->part_id];
    [things_parts_lock unlock];
    
    //102
    CWPart *cw_part_102 = [[CWPart alloc] init];
    //part
    cw_part_102->part_id = @"102";
    cw_part_102->part_name = @"图片服务器";
    
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_102 forKey:cw_part_102->part_id];
    [things_parts_lock unlock];
    
    //103
    CWPart *cw_part_103 = [[CWPart alloc] init];
    //part
    cw_part_103->part_id = @"103";
    cw_part_103->part_name = @"NVS服务器";
    
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_103 forKey:cw_part_103->part_id];
    [things_parts_lock unlock];
    
    //1000
    CWPart *cw_part_1000 = [[CWPart alloc] init];
    //part
    cw_part_1000->part_id = @"1000";
    cw_part_1000->part_name = @"虚拟警云设备(无反控）";
    
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1000 forKey:cw_part_1000->part_id];
    [things_parts_lock unlock];
    
    //1001
    CWPart *cw_part_1001 = [[CWPart alloc] init];
    //part
    cw_part_1001->part_id = @"1001";
    cw_part_1001->part_name = @"虚拟警云设备(布撤防）";
    
    //actions
    if (away_right == YES) {
        CWAction *action_away_1001 = [[CWAction alloc] init];
        action_away_1001->name = @"away";
        action_away_1001->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_1001->type = @"push";
        action_away_1001->format = @"cmd";
        action_away_1001->action = @"away";
        action_away_1001->action_image_nor = @"chat_away_nor";
        action_away_1001->action_image_hot = @"chat_away_hot";
        if (cw_part_1001->actions_array == nil) {
            cw_part_1001->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1001->actions_array addObject:action_away_1001];
    }

    if (open_right == YES) {
        CWAction *action_open_1001 = [[CWAction alloc] init];
        action_open_1001->name = @"open";
        action_open_1001->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_1001->type = @"push";
        action_open_1001->format = @"cmd";
        //action_open->part_id = @"1000";
        action_open_1001->action = @"open";
        action_open_1001->action_image_nor = @"chat_open_nor";
        action_open_1001->action_image_hot = @"chat_open_hot";
        if (cw_part_1001->actions_array == nil) {
            cw_part_1001->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1001->actions_array addObject:action_open_1001];
    }
    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1001 forKey:cw_part_1001->part_id];
    [things_parts_lock unlock];
    
    //1002
    CWPart *cw_part_1002 = [[CWPart alloc] init];
    //part
    cw_part_1002->part_id = @"1002";
    cw_part_1002->part_name = @"虚拟警云设备(布撤防旁路）";
    
    //actions
    if (away_right == YES) {
        CWAction *action_away_1002 = [[CWAction alloc] init];
        action_away_1002->name = @"away";
        action_away_1002->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_1002->type = @"push";
        action_away_1002->format = @"cmd";
        action_away_1002->action = @"away";
        action_away_1002->action_image_nor = @"chat_away_nor";
        action_away_1002->action_image_hot = @"chat_away_hot";
        if (cw_part_1002->actions_array == nil) {
            cw_part_1002->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1002->actions_array addObject:action_away_1002];
    }
    
    if (open_right == YES) {
        CWAction *action_open_1002 = [[CWAction alloc] init];
        action_open_1002->name = @"open";
        action_open_1002->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_1002->type = @"push";
        action_open_1002->format = @"cmd";
        //action_open->part_id = @"1000";
        action_open_1002->action = @"open";
        action_open_1002->action_image_nor = @"chat_open_nor";
        action_open_1002->action_image_hot = @"chat_open_hot";
        if (cw_part_1002->actions_array == nil) {
            cw_part_1002->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1002->actions_array addObject:action_open_1002];
    }

    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1002 forKey:cw_part_1002->part_id];
    [things_parts_lock unlock];
    
    
    //1100
    CWPart *cw_part_1100 = [[CWPart alloc] init];
    //part
    cw_part_1100->part_id = @"1100";
    cw_part_1100->part_name = @"警云设备（无视频）";
    
    //actions
    if (away_right == YES) {
        CWAction *action_away_1100 = [[CWAction alloc] init];
        action_away_1100->name = @"away";
        action_away_1100->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_1100->type = @"push";
        action_away_1100->format = @"cmd";
        action_away_1100->action = @"away";
        action_away_1100->action_image_nor = @"chat_away_nor";
        action_away_1100->action_image_hot = @"chat_away_hot";
        if (cw_part_1100->actions_array == nil) {
            cw_part_1100->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1100->actions_array addObject:action_away_1100];
    }
    
    if (open_right == YES) {
        CWAction *action_open_1100 = [[CWAction alloc] init];
        action_open_1100->name = @"open";
        action_open_1100->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_1100->type = @"push";
        action_open_1100->format = @"cmd";
        action_open_1100->action = @"open";
        action_open_1100->action_image_nor = @"chat_open_nor";
        action_open_1100->action_image_hot = @"chat_open_hot";
        if (cw_part_1100->actions_array == nil) {
            cw_part_1100->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1100->actions_array addObject:action_open_1100];
    }
    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1100 forKey:cw_part_1100->part_id];
    [things_parts_lock unlock];
    
    //1101
    CWPart *cw_part_1101 = [[CWPart alloc] init];
    //part
    cw_part_1101->part_id = @"1101";
    cw_part_1101->part_name = @"警云设备（1路视频）";
    
    //actions
    if (video_right) {
        CWAction *action_cap_1101 = [[CWAction alloc] init];
        action_cap_1101->name = @"view";
        action_cap_1101->title = NSLocalizedString(@"DataManager_Capture", @"");
        action_cap_1101->type = @"push";
        action_cap_1101->format = @"cmd";
        action_cap_1101->action = @"cap";
        action_cap_1101->action_image_nor = @"chat_cap_nor";
        action_cap_1101->action_image_hot = @"chat_cap_hot";
        if (cw_part_1101->actions_array == nil) {
            cw_part_1101->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1101->actions_array addObject:action_cap_1101];
    }
    
    if (away_right == YES) {
        CWAction *action_away_1101 = [[CWAction alloc] init];
        action_away_1101->name = @"away";
        action_away_1101->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_1101->type = @"push";
        action_away_1101->format = @"cmd";
        action_away_1101->action = @"away";
        action_away_1101->action_image_nor = @"chat_away_nor";
        action_away_1101->action_image_hot = @"chat_away_hot";
        if (cw_part_1101->actions_array == nil) {
            cw_part_1101->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1101->actions_array addObject:action_away_1101];
    }
    
    if (open_right == YES) {
        CWAction *action_open_1101 = [[CWAction alloc] init];
        action_open_1101->name = @"open";
        action_open_1101->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_1101->type = @"push";
        action_open_1101->format = @"cmd";
        action_open_1101->action = @"open";
        action_open_1101->action_image_nor = @"chat_open_nor";
        action_open_1101->action_image_hot = @"chat_open_hot";
        if (cw_part_1101->actions_array == nil) {
            cw_part_1101->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1101->actions_array addObject:action_open_1101];
    }
    
    if (video_right == YES) {
        CWAction *action_video_1101 = [[CWAction alloc] init];
        action_video_1101->name = @"video";
        action_video_1101->title = NSLocalizedString(@"DataManager_Video", @"");
        action_video_1101->type = @"url";
        //action_video_1->format = @"cmd";
        action_video_1101->action = @"real";
        action_video_1101->action_image_nor = @"chat_video_nor";
        action_video_1101->action_image_hot = @"chat_video_hot";
        if (cw_part_1101->actions_array == nil) {
            cw_part_1101->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1101->actions_array addObject:action_video_1101];
    }
    
    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1101 forKey:cw_part_1101->part_id];
    [things_parts_lock unlock];
    
    
    //1104
    CWPart *cw_part_1104 = [[CWPart alloc] init];
    //part
    cw_part_1104->part_id = @"1104";
    cw_part_1104->part_name = @"警云设备（4路视频）";
    
    //actions
    if (video_right == YES) {
        CWAction *action_cap_1104 = [[CWAction alloc] init];
        action_cap_1104->name = @"view";
        action_cap_1104->title = NSLocalizedString(@"DataManager_Capture", @"");
        action_cap_1104->type = @"push";
        action_cap_1104->format = @"cmd";
        action_cap_1104->action = @"cap";
        action_cap_1104->action_image_nor = @"chat_cap_nor";
        action_cap_1104->action_image_hot = @"chat_cap_hot";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1104->actions_array addObject:action_cap_1104];
    }
    
    if (away_right == YES) {
        CWAction *action_away_1104 = [[CWAction alloc] init];
        action_away_1104->name = @"away";
        action_away_1104->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_1104->type = @"push";
        action_away_1104->format = @"cmd";
        action_away_1104->action = @"away";
        action_away_1104->action_image_nor = @"chat_away_nor";
        action_away_1104->action_image_hot = @"chat_away_hot";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1104->actions_array addObject:action_away_1104];
    }
    
    if (open_right == YES) {
        CWAction *action_open_1104 = [[CWAction alloc] init];
        action_open_1104->name = @"open";
        action_open_1104->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_1104->type = @"push";
        action_open_1104->format = @"cmd";
        action_open_1104->action = @"open";
        action_open_1104->action_image_nor = @"chat_open_nor";
        action_open_1104->action_image_hot = @"chat_open_hot";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1104->actions_array addObject:action_open_1104];
    }
    
    if (video_right) {
        CWAction *action_video_1104 = [[CWAction alloc] init];
        action_video_1104->name = @"video";
        action_video_1104->title = NSLocalizedString(@"DataManager_Video", @"");
        action_video_1104->type = @"url";
        //action_video_1->format = @"cmd";
        action_video_1104->action = @"real";
        action_video_1104->action_image_nor = @"chat_video_nor";
        action_video_1104->action_image_hot = @"chat_video_hot";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1104->actions_array addObject:action_video_1104];
        
        
        /*CWAction *action_record_1104 = [[CWAction alloc] init];
        action_record_1104->name = @"record";
        action_record_1104->title = @"录像";
        action_record_1104->type = @"url";
        //action_video_1->format = @"cmd";
        action_record_1104->action = @"record";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_1104->actions_array addObject:action_record_1104];*/
        
    }
    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_1104 forKey:cw_part_1104->part_id];
    [things_parts_lock unlock];
    
    
    //2000
    CWPart *cw_part_2000 = [[CWPart alloc] init];
    //part
    cw_part_2000->part_id = @"2000";
    cw_part_2000->part_name = @"警云设备（DH）";
    
    //actions
    if (video_right == YES) {
        CWAction *action_cap_2000 = [[CWAction alloc] init];
        action_cap_2000->name = @"capture";
        action_cap_2000->title = NSLocalizedString(@"DataManager_Capture", @"");
        action_cap_2000->type = @"push";
        action_cap_2000->format = @"cmd";
        action_cap_2000->action = @"cap";
        action_cap_2000->action_image_nor = @"chat_cap_nor";
        action_cap_2000->action_image_hot = @"chat_cap_hot";
        
        if (cw_part_2000->actions_array == nil) {
            cw_part_2000->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_2000->actions_array addObject:action_cap_2000];
    }
    
    if (away_right == YES) {
        CWAction *action_away_2000 = [[CWAction alloc] init];
        action_away_2000->name = @"away";
        action_away_2000->title = NSLocalizedString(@"DataManager_Away", @"");
        action_away_2000->type = @"push";
        action_away_2000->format = @"cmd";
        action_away_2000->action = @"away";
        action_away_2000->action_image_nor = @"chat_away_nor";
        action_away_2000->action_image_hot = @"chat_away_hot";
        if (cw_part_2000->actions_array == nil) {
            cw_part_2000->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_2000->actions_array addObject:action_away_2000];
    }
    
    if (open_right == YES) {
        CWAction *action_open_2000 = [[CWAction alloc] init];
        action_open_2000->name = @"open";
        action_open_2000->title = NSLocalizedString(@"DataManager_Open", @"");
        action_open_2000->type = @"push";
        action_open_2000->format = @"cmd";
        action_open_2000->action = @"open";
        action_open_2000->action_image_nor = @"chat_open_nor";
        action_open_2000->action_image_hot = @"chat_open_hot";
        if (cw_part_2000->actions_array == nil) {
            cw_part_2000->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_2000->actions_array addObject:action_open_2000];
    }
    
    if (video_right) {
        CWAction *action_video_2000 = [[CWAction alloc] init];
        action_video_2000->name = @"video";
        action_video_2000->title = NSLocalizedString(@"DataManager_Video", @"");
        action_video_2000->type = @"url";
        //action_video_1->format = @"cmd";
        action_video_2000->action = @"real";
        action_video_2000->action_image_nor = @"chat_video_nor";
        action_video_2000->action_image_hot = @"chat_video_hot";
        if (cw_part_2000->actions_array == nil) {
            cw_part_2000->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_2000->actions_array addObject:action_video_2000];
        
        CWAction *action_record_2000 = [[CWAction alloc] init];
        action_record_2000->name = @"record";
        action_record_2000->title = NSLocalizedString(@"DataManager_Record", @"");
        action_record_2000->type = @"url";
        //action_video_1->format = @"cmd";
        action_record_2000->action = @"record";
        action_record_2000->action_image_nor = @"chat_record_nor";
        action_record_2000->action_image_hot = @"chat_record_hot";
        if (cw_part_1104->actions_array == nil) {
            cw_part_1104->actions_array = [[NSMutableArray alloc] init];
        }
        [cw_part_2000->actions_array addObject:action_record_2000];
    }
    
    //end action
    [things_parts_lock lock];
    [things_parts_dictionary setObject:cw_part_2000 forKey:cw_part_2000->part_id];
    [things_parts_lock unlock];
    
    _isInitDataFinished = YES;
}
#pragma mark - update system message
- (void) cwUpdateThingsList:(NSInteger)type withTID:(const char*)tid
{
    NSString *tid_ = [[NSString alloc] initWithUTF8String:tid];
    char *things_type = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"type" sessions:NO];
    
    if (things_type && strcmp(things_type, "group") == 0)
    {
        if (type == 2) {
            /*for (DeviceStatusModel *deviceModel in followed_groups_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    [followed_groups_array removeObject:deviceModel];
                }
            }*/
            [followed_groups_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DeviceStatusModel *deviceModel = (DeviceStatusModel*)obj;
                if ([deviceModel.tid isEqualToString:tid_]) {
                    *stop = YES;
                    if (*stop == YES) {
                        [followed_groups_array removeObject:deviceModel];
                    }
                }
                
                if (*stop) {
                    NSLog(@"array is %@",followed_groups_array);
                }
                
            }];
        }
        else if (type == 1){
            DeviceStatusModel *deviceModel = [[DeviceStatusModel alloc] init];
            deviceModel.videoPlayMode = 0;
            char *part_id = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"part_id" sessions:NO];
            if (part_id && strcmp(part_id, "100") == 0) {
                char *center_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                if (center_name) {
                    NSString *ns_center_name = [[NSString alloc] initWithUTF8String:center_name];
                    [[NSUserDefaults standardUserDefaults] setObject:ns_center_name forKey:@"cw_center_name"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            if (part_id) {
                deviceModel.partID = [[NSString alloc] initWithUTF8String:part_id];
            }
            
            char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
            deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
            deviceModel.tid = tid_;
            
            NSInteger unread_count_last = [self getUnreadEevent4Things:tid_];
            deviceModel.unread_count = unread_count_last;
            
            [followed_groups_array addObject:deviceModel];
        }
        else if (type == 3) {
            for (DeviceStatusModel *deviceModel in followed_groups_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                    deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
                    break;
                    
                }
            }
        }
    }
    else if (things_type && strcmp(things_type, "user") == 0)
    {
        if (type == 2) {
            /*for (DeviceStatusModel *deviceModel in followed_friends_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    
                    [followed_friends_array removeObject:deviceModel];
                    
                }
            }*/
            
            [followed_friends_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DeviceStatusModel *deviceModel = (DeviceStatusModel*)obj;
                if ([deviceModel.tid isEqualToString:tid_]) {
                    *stop = YES;
                    if (*stop == YES) {
                        [followed_friends_array removeObject:deviceModel];
                    }
                }
                
                if (*stop) {
                    NSLog(@"array is %@",followed_groups_array);
                }
                
            }];
        }
        else if (type == 1){
            DeviceStatusModel *deviceModel = [[DeviceStatusModel alloc] init];
            deviceModel.videoPlayMode = 0;
            char *part_id = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"part_id" sessions:NO];
            if (part_id && strcmp(part_id, "100") == 0) {
                char *center_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                if (center_name) {
                    NSString *ns_center_name = [[NSString alloc] initWithUTF8String:center_name];
                    [[NSUserDefaults standardUserDefaults] setObject:ns_center_name forKey:@"cw_center_name"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            if (part_id) {
                deviceModel.partID = [[NSString alloc] initWithUTF8String:part_id];
            }
            
            char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
            deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
            deviceModel.tid = tid_;
            
            NSInteger unread_count_last = [self getUnreadEevent4Things:tid_];
            deviceModel.unread_count = unread_count_last;
            
            [followed_friends_array addObject:deviceModel];
        }
        else if (type == 3) {
            for (DeviceStatusModel *deviceModel in followed_friends_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                    deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
                    break;
                    
                }
            }
        }
    }
    else {
        if (type == 2) {
            /*for (DeviceStatusModel *deviceModel in followed_things_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    [followed_things_array removeObject:deviceModel];
                    
                }
            }*/
            [followed_things_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                DeviceStatusModel *deviceModel = (DeviceStatusModel*)obj;
                if ([deviceModel.tid isEqualToString:tid_]) {
                    *stop = YES;
                    if (*stop == YES) {
                        [followed_things_array removeObject:deviceModel];
                    }
                }
                
                if (*stop) {
                    NSLog(@"array is %@",followed_things_array);
                }
                
            }];
        }
        else if (type == 1){
            DeviceStatusModel *deviceModel = [[DeviceStatusModel alloc] init];
            deviceModel.videoPlayMode = 0;
            char *part_id = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"part_id" sessions:NO];
            if (part_id && strcmp(part_id, "100") == 0) {
                char *center_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                if (center_name) {
                    NSString *ns_center_name = [[NSString alloc] initWithUTF8String:center_name];
                    [[NSUserDefaults standardUserDefaults] setObject:ns_center_name forKey:@"cw_center_name"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
            if (part_id) {
                deviceModel.partID = [[NSString alloc] initWithUTF8String:part_id];
            }
            
            char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
            deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
            deviceModel.tid = tid_;
            
            NSInteger unread_count_last = [self getUnreadEevent4Things:tid_];
            deviceModel.unread_count = unread_count_last;
        
            [followed_things_array addObject:deviceModel];
        }
        else if (type == 3) {
            for (DeviceStatusModel *deviceModel in followed_things_array) {
                if ([deviceModel.tid isEqualToString:tid_]) {
                    char *things_name = [[CWThings4Interface sharedInstance] get_var_with_path:tid path:"name" sessions:NO];
                    deviceModel.caption = [[NSString alloc] initWithUTF8String:things_name];
                    break;
                    
                }
            }
        }
        
        followed_things_init_grid = YES;
    }
    
}

-(void)cwPostPartsList:(const char*)inPartsJson Header:(const char*)inHeader
{
    NSString *parts_json = [NSString stringWithUTF8String:inPartsJson];
    NSLog(@"%@", parts_json);
    
    NSError *error;
    NSData *parts_array_ = [NSData dataWithBytes:inPartsJson length:strlen(inPartsJson)];
    NSDictionary *parts_array  = [NSJSONSerialization JSONObjectWithData:parts_array_ options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *keys = [parts_array allKeys];
    for (NSString *key in keys) {
        id part = [parts_array objectForKey:key];
        if (part) {
            CWPart *cw_part = [[CWPart alloc] init];
            id part_define = [part objectForKey:@"define"];
            if (part_define && [part_define count] > 0) {
                //part
                cw_part->part_id = [part_define objectForKey:@"part_id"];
                if (cw_part->part_id == nil) {
                    continue;
                }
                cw_part->part_name = [part_define objectForKey:@"name"];
                //cw_part->part_version = [part_define objectForKey:@"part_ver"];
                
                id get_status = [part_define objectForKey:@"get_status"];
                if (get_status) {
                    //cw_part->event_template = [get_status objectForKey:@"template"];
                }
                
                //actions
                id cw_actions = [part_define objectForKey:@"actions"];
                for (id cw_action in cw_actions) {
                    CWAction *action = [[CWAction alloc] init];
                    action->name = [cw_action objectForKey:@"name"];
                    action->title = [cw_action objectForKey:@"title"];
                    action->type = [cw_action objectForKey:@"type"];
                    if ([action->type isEqualToString:@"push"]) {
                        action->format = [cw_action objectForKey:@"format"];
                    }
                    action->action = [cw_action objectForKey:@"action"];
                    
                    if (cw_part->actions_array == nil) {
                        cw_part->actions_array = [[NSMutableArray alloc] init];
                    }
                    [cw_part->actions_array addObject:action];

                }//end action
                
                [things_parts_lock lock];
                [things_parts_dictionary setObject:cw_part forKey:cw_part->part_id];
                [things_parts_lock unlock];
            }
        }
    }
}


#pragma mark - message list

/*
 1 报警            11xx
 2 报警恢复         31xx
 4 故障            X3xx
 5 旁路            E5xx / 15XX
 6 环境监测         X2xx
 7 测试            x6xx
 8 布防            34xx
 9 撤防            14xx
 10 解除旁路        R5xx 35XX
 */
-(void)cwPostMsgList:(const char *)inUserListJson Header:(const char *)inHeader
{
    if (inUserListJson == NULL) {
        chat_message_update = YES;
        event_message_update = YES;
        return ;
    }
    
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inUserListJson];
    
    NSLog(@"%@\r\n", json);
    if (json == nil || [json length] == 0) return ;
    NSData *user_list_json = [NSData dataWithBytes:inUserListJson length:strlen(inUserListJson)];
    NSDictionary *messageResult  = [NSJSONSerialization JSONObjectWithData:user_list_json options:NSJSONReadingMutableLeaves error:&error];
    if (messageResult == nil) return ;
    int event_count = 0;
    if ([messageResult count] == 0) {
        chat_message_update = YES;
        event_message_update = YES;
        return ;//報警
    }
    
    id result_msg;
    if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
        result_msg = messageResult;
    }
    else {
        result_msg = [messageResult objectForKey:@"result"];
    }
    if (result_msg) {
        if ([result_msg count] == 0) {
            chat_message_update = YES;
            event_message_update = YES;
            return ;
        }
        for (id msg in result_msg) {
            
            @try{
                NSString* event_code = [msg objectForKey:@"code"];
                if ([event_code intValue] == 1 || [event_code intValue] == 2) {
                    continue;
                }
                
                NSString* event_type = [msg objectForKey:@"type"];
                
                NSString *things_tid;
                DeviceMessageModel *chat_model = [DeviceMessageModel new];
                chat_model.iconName = @"2.jpg";
                chat_model.dateTime = [msg objectForKey:@"time"];
                chat_model.iconName = @"xitong";
                
                if (self_to_tid == nil) {
                    char *self_tid = [[CWThings4Interface sharedInstance] get_var_with_path:"" path:"" sessions:NO];
                    if (self_tid) {
                        self_to_tid = [[NSString alloc] initWithUTF8String:self_tid];
                    }
                }
                NSString *my_tid = self_to_tid;//[[CWEnvManager sharedInstance] getUsrTag:@"tid"];
                NSString *from_tid = [msg objectForKey:@"from"];
                chat_model.tid = from_tid;
                NSString *to_tid = [msg objectForKey:@"to"];
                if (to_tid && [to_tid length]) {
                    if (to_tid && ![to_tid isEqualToString:my_tid]) {
                        things_tid = to_tid;
                    }
                }
                
                if ([event_type isEqualToString:@"e"]) {
                    things_tid = from_tid;
                }
                else {
                    if (things_tid == nil && from_tid) {
                        things_tid = from_tid;
                    }
                    else if(things_tid == nil){
                        continue;
                    }
                }
                
                NSString *name_path = nil;
                char *name = NULL;
                NSString *format = [msg objectForKey:@"format"];
                if ([format isEqualToString:@"task"]) {
                    name_path = [[NSString alloc] initWithFormat:@"members.%@.name", from_tid];
                    
                }
                else {
                    name_path = [[NSString alloc] initWithFormat:@"name"];
                    
                }
                
                
                if([my_tid isEqualToString:from_tid]){
                    chat_model.messageType = MessageTypeForLOCAL;
                    name = "我";
                    chat_model.bgImageName = @"chatto_bg_normal";
                    chat_model.backgroundType = 0;
                }
                else if ([my_tid isEqualToString:to_tid]) {
                    chat_model.bgImageName = @"chatfrom_bg_normal";
                    chat_model.backgroundType = 0;
                    chat_model.messageType = MessageTypeForServer;
                    //name = [[CWThings4Interface sharedInstance] get_var_with_path:[my_tid UTF8String] path:[name_path UTF8String] sessions:YES];
                    if ([format isEqualToString:@"task"]) {
                        name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:YES];
                    }
                    else {
                        name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
                    }
                    //name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
                }
                else {
                    chat_model.bgImageName = @"chatfrom_bg_normal";
                    chat_model.backgroundType = 0;
                    chat_model.messageType = MessageTypeForServer;
                    if ([format isEqualToString:@"task"]) {
                        name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:YES];
                    }
                    else {
                        name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
                    }
                    //name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
                }
                
                if (name) {
                    if (strcmp(name, "我") == 0) {
                        chat_model.userName = self_name;
                    }
                    else {
                        chat_model.userName = [[NSString alloc] initWithUTF8String:name];
                    }
                }
                else {
                    chat_model.userName = self_name;
                }
                
                [followed_things_lock lock];
                for (DeviceStatusModel *device in followed_things_array) {
                    if ([device.tid isEqualToString:to_tid]) {
                        device.unread_count++;
                        device.dateTime = chat_model.dateTime;
                        //msg_body->name = device->name;
                        [self saveUnreadEvent4Things:device.tid value:device.unread_count];
                        break;
                    }
                }
                [followed_things_lock unlock];
                
                
                NSString *s_mid = [msg objectForKey:@"mid"];
                chat_model.mid = [s_mid integerValue];
                //NSRange contentIndex = [json rangeOfString:format];
                NSString *body = [msg objectForKey:@"body"];
                
                if ([format isEqualToString:@"setpwd"]) {
                    continue;
                }
                if ([event_code intValue] != 8 && [format isEqualToString:@"text"]) {
                    NSData *content_json = [body dataUsingEncoding:NSUnicodeStringEncoding];
                    NSDictionary *event_dic  = [NSJSONSerialization JSONObjectWithData:content_json options:NSJSONReadingMutableLeaves error:&error];
                    id event_msg = [event_dic objectForKey:@"msg"];
                    if (event_msg) {
                        chat_model.text = [event_msg objectForKey:@"dat"];
                    }
                    else {
                        chat_model.text = body;
                    }
                    chat_model.messageStatusType = 0;
                    id usr_dic = [event_dic objectForKey:@"usr"];
                    if (usr_dic) {
                        NSString *cid = [usr_dic objectForKey:@"cid"];
                        if (cid) {
                            NSRange range;
                            range.length = 1;
                            range.location = 6;
                            NSString *e_7 = [cid substringWithRange:range];
                            range.length = 1;
                            range.location = 7;
                            NSString *e_8 = [cid substringWithRange:range];
                            if ([e_7 isEqualToString:@"3"] && [e_8 isEqualToString:@"4"]) {
                                chat_model.bgImageName = @"chatfrom_bg_away.png";
                                chat_model.backgroundType = 8;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_away.png";
                            }
                            else if ([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"4"]) {
                                chat_model.bgImageName = @"chatfrom_bg_open.png";
                                chat_model.backgroundType = 9;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_open.png";
                            }
                            else if (([e_7 isEqualToString:@"E"] || [e_7 isEqualToString:@"1"]) && [e_8 isEqualToString:@"5"]) {
                                chat_model.bgImageName = @"chatfrom_bg_panglu.png";
                                chat_model.backgroundType = 5;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_panglu.png";
                            }
                            //else if (([e_7 isEqualToString:@"R"] || [e_7 isEqualToString:@"3"]) && [e_8 isEqualToString:@"5"]) {
                            
                            //}
                            else if([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"1"]) {
                                chat_model.bgImageName = @"chatfrom_bg_baojin.png";
                                chat_model.backgroundType = 1;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_baojin.png";
                            }
                            else {
                                chat_model.bgImageName = @"chatfrom_bg_normal";
                                chat_model.backgroundType = 0;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_normal";
                            }
                        }
                    }
                }
                else if ([event_code intValue] != 8 && [format isEqualToString:@"cmd"]) {
                    NSRange range;
                    range = [body rangeOfString:@"open"];
                    if (range.location != NSNotFound) {
                        body = NSLocalizedString(@"DataManager_OpenRequest", @"");
                        chat_model.messageStatusType = 1;
                    }
                    range = [body rangeOfString:@"away"];
                    if (range.location != NSNotFound) {
                        body = NSLocalizedString(@"DataManager_AwayRequest", @"");
                        chat_model.messageStatusType = 2;
                    }
                    
                    range = [body rangeOfString:@"setpwd"];
                    if (range.location != NSNotFound) {
                        body = NSLocalizedString(@"DataManager_SetPassword", @"");
                        chat_model.messageStatusType = 2;
                        continue;
                    }
                    
                    range = [body rangeOfString:@"unbypass"];
                    if (range.location != NSNotFound && chat_model.messageType == MessageTypeForLOCAL) {
                        //content = @"解旁路";
                        chat_model.messageStatusType = 3;
                        NSRange pwd_index = [body rangeOfString:@","];
                        NSString *sub_content = [body substringFromIndex:(pwd_index.location + pwd_index.length)];
                        NSRange zone_index = [sub_content rangeOfString:@","];
                        if (zone_index.location != NSNotFound) {
                            NSString *zone_content = [sub_content substringFromIndex:(zone_index.location + zone_index.length)];
                            body = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_UnBypassRequest", @""), zone_content];
                        }
                        else {
                            body = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_UnBypassRequest", @""), sub_content];
                        }
                        chat_model.bgImageName = @"chatfrom_bg_panlu.png";
                        chat_model.backgroundType = 5;
                        //msg_body->fuc_image_bg = @"chatfrom_bg_panlu.png";
                    }
                    else {
                        range = [body rangeOfString:@"bypass"];
                        if (range.location != NSNotFound  && chat_model.messageType == MessageTypeForLOCAL) {
                            //content = @"旁路";
                            chat_model.messageStatusType = 4;
                            NSRange pwd_index = [body rangeOfString:@","];
                            NSString *sub_content = [body substringFromIndex:(pwd_index.location + pwd_index.length)];
                            NSRange zone_index = [sub_content rangeOfString:@","];
                            if (zone_index.location != NSNotFound) {
                                NSString *zone_content = [sub_content substringFromIndex:(zone_index.location + zone_index.length)];
                                body = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_BypassRequest", @""), zone_content];
                            }
                            else {
                                body = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_BypassRequest", @""), sub_content];
                            }
                            chat_model.bgImageName = @"chatfrom_bg_panlu.png";
                            chat_model.backgroundType = 5;
                            //msg_body->fuc_image_bg = @"chatfrom_bg_panlu.png";
                        }
                    }
                    
                    if ([body isEqualToString:@"open"]) {
                        body = NSLocalizedString(@"DataManager_OpenRequest", @"");
                        
                    }
                    else if ([body isEqualToString:@"away"]) {
                        body = NSLocalizedString(@"DataManager_AwayRequest", @"");
                        
                    }
                    else if ([body isEqualToString:@"query"]) {
                        body = NSLocalizedString(@"DataManager_QueryRequest", @"");
                    }
                    else {
                        chat_model.messageStatusType = 6;
                        body = [body stringByReplacingOccurrencesOfString:@"cap," withString:NSLocalizedString(@"DataManager_CapCmd", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@"unbypass," withString:NSLocalizedString(@"DataManager_UnbypassCmd", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@"bypass," withString:NSLocalizedString(@"DataManager_BypassCmd", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@"away" withString:NSLocalizedString(@"DataManager_AwayRequest", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@"open" withString:NSLocalizedString(@"DataManager_OpenRequest", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@"capture" withString:NSLocalizedString(@"DataManager_Capture", @"")];
                        body = [body stringByReplacingOccurrencesOfString:@".ch" withString:NSLocalizedString(@"DataManager_ChannelCmd", @"")];
                    }
                    
                    chat_model.text = body;
                }
                else if ([event_code intValue] == 8 || [format length] == 0 ||[format isEqualToString:@"cim"]) {
                    NSError *error;
                    //NSString *content = [json substringFromIndex:(contentIndex.location + contentIndex.length + 1)];
                    NSData *content_json = nil;
                    if (format == nil || [format length] == 0 || [event_code intValue] == 8) {
                        content_json = [NSData dataWithBytes:[body UTF8String] length:strlen([body UTF8String])];
                    }
                    else {
                        content_json = [NSData dataWithBytes:[body UTF8String] length:[body length]];
                    }
                    NSDictionary *image_list  = [NSJSONSerialization JSONObjectWithData:content_json options:NSJSONReadingMutableLeaves error:&error];
                    
                    id event_msg = [image_list objectForKey:@"msg"];
                    if (event_msg) {
                        NSString *format = [event_msg objectForKey:@"fmt"];
                        if (format == nil || [format isEqualToString:@"text"]) {
                            chat_model.text = [event_msg objectForKey:@"dat"];
                            chat_model.messageStatusType = 6;
                            id usr_dic = [image_list objectForKey:@"usr"];
                            if (usr_dic) {
                                NSString *cid = [usr_dic objectForKey:@"cid"];
                                if (cid) {
                                    NSRange range;
                                    range.length = 1;
                                    range.location = 6;
                                    NSString *e_7 = [cid substringWithRange:range];
                                    range.length = 1;
                                    range.location = 7;
                                    NSString *e_8 = [cid substringWithRange:range];
                                    if ([e_7 isEqualToString:@"3"] && [e_8 isEqualToString:@"4"]) {
                                        chat_model.bgImageName = @"chatfrom_bg_away.png";
                                        chat_model.backgroundType = 8;
                                        //msg_body->fuc_image_bg = @"chatfrom_bg_away.png";
                                    }
                                    else if ([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"4"]) {
                                        chat_model.bgImageName = @"chatfrom_bg_open.png";
                                        chat_model.backgroundType = 9;
                                        //msg_body->fuc_image_bg = @"chatfrom_bg_open.png";
                                    }
                                    else if (([e_7 isEqualToString:@"E"] || [e_7 isEqualToString:@"1"]) && [e_8 isEqualToString:@"5"]) {
                                        chat_model.bgImageName = @"chatfrom_bg_panglu.png";
                                        chat_model.backgroundType = 5;
                                        //msg_body->fuc_image_bg = @"chatfrom_bg_panglu.png";
                                    }
                                    //else if (([e_7 isEqualToString:@"R"] || [e_7 isEqualToString:@"3"]) && [e_8 isEqualToString:@"5"]) {
                                    
                                    //}
                                    else if([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"1"]) {
                                        chat_model.bgImageName = @"chatfrom_bg_baojin.png";
                                        chat_model.backgroundType = 1;
                                        //msg_body->fuc_image_bg = @"chatfrom_bg_baojin.png";
                                    }
                                    else {
                                        chat_model.bgImageName = @"chatfrom_bg_normal";
                                        chat_model.backgroundType = 0;
                                        //msg_body->fuc_image_bg = @"chatfrom_bg_normal";
                                    }
                                }
                            }
                        }
                        else if ([format isEqualToString:@"cim"]){
                            id dat = [event_msg objectForKey:@"dat"];
                            id content_list = [dat objectForKey:@"content"];
                            for (id image_content in content_list) {
                                NSString *format = [image_content objectForKey:@"format"];
                                NSString *image_url = [image_content objectForKey:@"url"];
                                NSRange range = [image_url rangeOfString:@"http://"];
                                if (range.length > 0) {
                                    chat_model.imageName = image_url;
                                }
                                else {
                                    char *session_id = [[CWThings4Interface sharedInstance] get_things_sid];
                                    if (session_id && server_addr_) {
                                        chat_model.imageName = [[NSString alloc] initWithFormat:@"http://%@:%ld/download/%@?sid=%s", server_addr_, (long)   image_server_port_, image_url, session_id];
                                    }
                                }
                                
                                if ([format isEqualToString:@"jpg"]) {
                                    NSString *image_data = [image_content objectForKey:@"data"];
                                    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:image_data options:0];
                                    //NSData *pImageData = [NSData dataWithBytes:inImageBuffer length:inImageLen];
                                    
                                    UIImage *pImage = [UIImage imageWithData:decodedData];
                                    chat_model.smallImage = pImage;
                                    chat_model.messageStatusType = 5;
                                    //chat_model.bgImageName = @"chatfrom_bg_normal";
                                }
                                else if ([format isEqualToString:@"crtsp"]) {
                                    UIImage *pImage = [UIImage imageNamed:@"PlayButton.png"];
                                    chat_model.smallImage = pImage;
                                    
                                    NSString *record_start_time = [image_content objectForKey:@"url"];
                                    NSString *record_end_time = [image_content objectForKey:@"data"];
                                    //msg_body->event_start_Time = record_start_time;
                                    //msg_body->event_end_time = record_end_time;
     
                                    chat_model.text = [NSString stringWithFormat:@"%@", record_start_time];
                                    chat_model.messageStatusType = 7;
                                }
                            }
                        }
                    }else {
                        id content_list = [image_list objectForKey:@"content"];
                        for (id image_content in content_list) {
                            NSString *format = [image_content objectForKey:@"format"];
                            NSString *image_url = [image_content objectForKey:@"url"];
                            NSRange range = [image_url rangeOfString:@"http://"];
                            if (range.length > 0) {
                                chat_model.imageName = image_url;
                            }
                            else {
                                char *session_id = [[CWThings4Interface sharedInstance] get_things_sid];
                                if (session_id && server_addr_) {
                                    chat_model.imageName = [[NSString alloc] initWithFormat:@"http://%@:%ld/download/%@?sid=%s", server_addr_, (long)   image_server_port_, image_url, session_id];
                                }
                                
                            }
                            
                            if ([format isEqualToString:@"jpg"]) {
                                NSString *image_data = [image_content objectForKey:@"data"];
                                NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:image_data options:0];
                                //NSData *pImageData = [NSData dataWithBytes:inImageBuffer length:inImageLen];
                                
                                UIImage *pImage = [UIImage imageWithData:decodedData];
                                chat_model.smallImage = pImage;
                                chat_model.messageStatusType = 5;
                            }
                            else if ([format isEqualToString:@"crtsp"]) {
                                UIImage *pImage = [UIImage imageNamed:@"PlayButton.png"];
                                chat_model.smallImage = pImage;
                                
                                NSString *record_start_time = [image_content objectForKey:@"url"];
                                //NSString *record_end_time = [image_content objectForKey:@"data"];
                                //msg_body->event_start_Time = record_start_time;
                                //msg_body->event_end_time = record_end_time;
                                
                                chat_model.text = [NSString stringWithFormat:@"%@", record_start_time];
                                chat_model.messageStatusType = 7;
                            }
                        }
                    }
                    
                    
                    //msg_body->content = @"报警图片";
                    //msg_body->msgType = 1;
                }
                //for task
                else if ([format isEqualToString:@"task"]) {
                    NSData *task_json = [body dataUsingEncoding:NSUTF8StringEncoding]; //[NSData dataWithBytes:body length:strlen(inUserListJson)];
                    NSDictionary *task_dic  = [NSJSONSerialization JSONObjectWithData:task_json options:NSJSONReadingMutableLeaves error:&error];
                    id case_info = [task_dic objectForKey:@"case"];
                    if (case_info) {
                        chat_model.text = [case_info objectForKey:@"content"];
                    }
                }
                
                [chat_message_lock lock];
                NSMutableArray *temp_array = [chat_message_dictionary objectForKey:things_tid];
                if (temp_array == nil) {
                    temp_array = [[NSMutableArray alloc] init];
                    [chat_message_dictionary setObject:temp_array forKey:things_tid];
                }
                [temp_array insertObject:chat_model atIndex:0];
                if (event_message_array == nil) {
                    event_message_array = [[NSMutableArray alloc] init];
                }
                [event_message_array addObject:chat_model];
                
                [temp_array sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                    DeviceMessageModel *chat_obj_pre = (DeviceMessageModel*)obj1;
                    DeviceMessageModel *chat_obj_next = (DeviceMessageModel*)obj2;
                    if (chat_obj_pre.mid > chat_obj_next.mid) {
                        return NSOrderedDescending;
                    }
                    else if (chat_obj_pre.mid < chat_obj_next.mid) {
                        return NSOrderedAscending;
                    }
                    else {
                        return NSOrderedSame;
                    }
                    //return [things_obj_pre.message->mid compare:things_obj_next.message->mid];
                }];
                
                [chat_message_lock unlock];
                
                
            }
            @catch (NSException *exception) {
            }
            
            event_count++;
        }
    }
    
    chat_message_update = YES;
    event_message_update = YES;
}

#pragma mark - event or message realtime
-(void)cwPostEventData:(const char*)body Type:(const char *)type
{
    BOOL show_event = YES;
    
    if ((strcmp(type, "im") != 0) && (strcmp(type, "e") != 0)) {
        return ;
    }
    NSString *json = [NSString stringWithUTF8String:body];
    
    NSLog(@"%@\r\n", json);
    NSArray *array = [json componentsSeparatedByString:@","];
    
    DeviceMessageModel *chat_model = [DeviceMessageModel new];
    chat_model.mid = [[array objectAtIndex:0] integerValue];
    chat_model.dateTime = [array objectAtIndex:1];
    

    DeviceStatusModel *msg = [[DeviceStatusModel alloc] init];
    msg.dateTime = [array objectAtIndex:1];
    //msg->type = [NSString stringWithUTF8String:type];
    msg.tid = [array objectAtIndex:2];
    chat_model.tid = msg.tid;
    //--------------------
    
    chat_model.iconName = @"xitong";
    if (self_to_tid == nil) {
        char *self_tid = [[CWThings4Interface sharedInstance] get_var_with_path:"" path:"" sessions:NO];
        if (self_tid) {
            self_to_tid = [[NSString alloc] initWithUTF8String:self_tid];
        }
    }
    NSString *my_tid = self_to_tid;
    
    
    if ([my_tid isEqualToString:msg.tid]) {
        msg.tid = [array objectAtIndex:2];
    }
    //-------------------
    
    NSString *things_tid;
    
    if (strcmp(type, "im") == 0) {
        NSString *from_tid = [array objectAtIndex:2];
        
        
        [followed_things_lock lock];
        for (DeviceStatusModel *device in followed_things_array) {
            if ([device.tid isEqualToString:from_tid]) {
                device.unread_count++;
                device.dateTime = msg.dateTime;
                //device->on_off_line = NO;
                [self saveUnreadEvent4Things:device.tid value:device.unread_count];
                break;
            }
        }
        [followed_things_lock unlock];
        
        NSString *to_tid = [array objectAtIndex:3];
        if ([to_tid isEqualToString:my_tid]) {
            things_tid = from_tid;
        }
        else {
            things_tid = to_tid;
        }
        
        NSString *name_path;
        char *name = NULL;
        NSString *format = [array objectAtIndex:4];
        if ([format isEqualToString:@"task"]) {
            name_path = [[NSString alloc] initWithFormat:@"members.%@.name", from_tid];
            
        }
        else {
            name_path = [[NSString alloc] initWithFormat:@"name"];
            
        }
        
        if ([my_tid isEqualToString:from_tid]) {
            chat_model.messageType = MessageTypeForLOCAL;
            name = "我";
            chat_model.bgImageName = @"chatto_bg_normal";
            chat_model.backgroundType = 0;
        }
        else if ([my_tid isEqualToString:to_tid]) {
            chat_model.bgImageName = @"chatfrom_bg_normal";
            chat_model.backgroundType = 0;
            chat_model.messageType = MessageTypeForServer;
            if ([format isEqualToString:@"task"]) {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:YES];
            }
            else {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
            }
        }
        else {
            chat_model.bgImageName = @"chatfrom_bg_normal";
            chat_model.backgroundType = 0;
            chat_model.messageType = MessageTypeForServer;
            if ([format isEqualToString:@"task"]) {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:YES];
            }
            else {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
            }
        }
        if (name) {
            if (strcmp(name, "我") == 0) {
                chat_model.userName = self_name;
            }
            else {
                chat_model.userName = [[NSString alloc] initWithUTF8String:name];
            }
            //msg_body->name = [[NSString alloc] initWithUTF8String:name];
        }
        else {
            chat_model.userName = self_name;
        }
        
        
        if ([format isEqualToString:@"setpwd"]) {
            show_event = NO;
        }
        if ([format isEqualToString:@"cmd"] || [format isEqualToString:@"text"]) {
            //---------event
            NSRange contentIndex = [json rangeOfString:format];
            NSString *content = [json substringFromIndex:(contentIndex.location + contentIndex.length + 1)];
            NSRange range;
            range = [content rangeOfString:@"open"];
            if (range.location != NSNotFound && chat_model.messageType == MessageTypeForLOCAL) {
                content = NSLocalizedString(@"DataManager_OpenRequest", @"");
                chat_model.messageStatusType = 1;
            }
            range = [content rangeOfString:@"away"];
            if (range.location != NSNotFound  && chat_model.messageType == MessageTypeForLOCAL) {
                content = NSLocalizedString(@"DataManager_AwayRequest", @"");
                chat_model.messageStatusType = 2;
            }
            
            range = [content rangeOfString:@"setpwd"];
            if (range.location != NSNotFound  && chat_model.messageType == MessageTypeForLOCAL) {
                content = NSLocalizedString(@"DataManager_SetPassword", @"");
                show_event = NO;
                
            }
            
            /*range = [to_tid rangeOfString:@"case-"];
            if (range.location != NSNotFound) {
                range = [content rangeOfString:@"加入警情"];
                if (range.location == NSNotFound) {
                    range = [content rangeOfString:@"出警"];
                    if (range.location != NSNotFound) {
                        [self showToast:content withTID:to_tid withType:1];
                    }
                    else {
                        [self showToast:content withTID:to_tid withType:2];
                    }
                }
            }*/
            
            range = [content rangeOfString:@"unbypass"];
            if (range.location != NSNotFound  && chat_model.messageType == MessageTypeForLOCAL) {
                //content = @"解旁路";
                chat_model.messageStatusType = 3;
                NSRange pwd_index = [content rangeOfString:@","];
                NSString *sub_content = [content substringFromIndex:(pwd_index.location + pwd_index.length)];
                NSRange zone_index = [sub_content rangeOfString:@","];
                if (zone_index.location != NSNotFound) {
                    NSString *zone_content = [sub_content substringFromIndex:(zone_index.location + zone_index.length)];
                    content = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_UnBypassRequest", @""), zone_content];
                }
                else {
                    content = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_UnBypassRequest", @""), sub_content];
                }
                
            }
            else {
                range = [content rangeOfString:@"bypass"];
                chat_model.messageStatusType = 4;
                if (range.location != NSNotFound && chat_model.messageType == MessageTypeForLOCAL) {
                    //content = @"旁路";
                    NSRange pwd_index = [content rangeOfString:@","];
                    NSString *sub_content = [content substringFromIndex:(pwd_index.location + pwd_index.length)];
                    NSRange zone_index = [sub_content rangeOfString:@","];
                    if (zone_index.location != NSNotFound) {
                        NSString *zone_content = [sub_content substringFromIndex:(zone_index.location + zone_index.length)];
                        content = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_BypassRequest", @""), zone_content];
                    }
                    else {
                        content = [[NSString alloc] initWithFormat:@"%@,%@", NSLocalizedString(@"DataManager_BypassRequest", @""), sub_content];
                    }
                    
                }
            }
     
            if ([content isEqualToString:@"open"]) {
                content = NSLocalizedString(@"DataManager_OpenRequest", @"");
            }
            else if ([content isEqualToString:@"away"]) {
                content = NSLocalizedString(@"DataManager_AwayRequest", @"");
            }
            else if ([content isEqualToString:@"query"]) {
                content = NSLocalizedString(@"DataManager_QueryRequest", @"");
            }
            else {
                chat_model.messageStatusType = 0;
                content = [content stringByReplacingOccurrencesOfString:@"cap," withString:NSLocalizedString(@"DataManager_CapCmd", @"")];
                content = [content stringByReplacingOccurrencesOfString:@"unbypass," withString:NSLocalizedString(@"DataManager_UnbypassCmd", @"")];
                content = [content stringByReplacingOccurrencesOfString:@"bypass," withString:NSLocalizedString(@"DataManager_BypassCmd", @"")];
                content = [content stringByReplacingOccurrencesOfString:@"away" withString:NSLocalizedString(@"DataManager_AwayRequest", @"")];
                content = [content stringByReplacingOccurrencesOfString:@"open" withString:NSLocalizedString(@"DataManager_OpenRequest", @"")];
                content = [content stringByReplacingOccurrencesOfString:@"capture" withString:NSLocalizedString(@"DataManager_Capture", @"")];
                content = [content stringByReplacingOccurrencesOfString:@".ch" withString:NSLocalizedString(@"DataManager_ChannelCmd", @"")];
            }
            
            
            
            //msg->event_content = content;
            //-----------event
            
            
            chat_model.text = content;
        }
        else if ([format isEqualToString:@"cim"]) {
            chat_model.messageStatusType = 5;
            NSRange contentIndex = [json rangeOfString:format];
            NSError *error;
            NSString *content = [json substringFromIndex:(contentIndex.location + contentIndex.length + 1)];
            NSString *transString = [NSString stringWithString:[content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSData *content_json = [NSData dataWithBytes:[transString UTF8String] length:[transString length]];
            
            NSDictionary *image_list  = [NSJSONSerialization JSONObjectWithData:content_json options:NSJSONReadingMutableLeaves error:&error];
            id content_list = [image_list objectForKey:@"content"];
            for (id image_content in content_list) {
                NSString *format = [image_content objectForKey:@"format"];
                NSString *image_url = [image_content objectForKey:@"url"];
                NSRange range = [image_url rangeOfString:@"http://"];
                if (range.length > 0) {
                    chat_model.imageName = image_url;
                }
                else {
                    char *session_id = [[CWThings4Interface sharedInstance] get_things_sid];
                    if (session_id && server_addr_) {
                        chat_model.imageName = [[NSString alloc] initWithFormat:@"http://%@:%ld/download/%@?sid=%s", server_addr_, (long)   image_server_port_, image_url, session_id];
                    }
                    
                    
                    
                }
                
                if ([format isEqualToString:@"jpg"]) {
                    NSString *image_data = [image_content objectForKey:@"data"];
                    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:image_data options:0];
                    //NSData *pImageData = [NSData dataWithBytes:inImageBuffer length:inImageLen];
                    
                    UIImage *pImage = [UIImage imageWithData:decodedData];
                    chat_model.smallImage = pImage;
                    
                    
                    //event
                    //msg->event_content = @"图片";
                }
            }
        }
        else if ([format isEqualToString:@"task"]) {
            
            
            chat_model.messageStatusType = 8;
            NSRange contentIndex = [json rangeOfString:format];
            NSError *error;
            NSString *content = [json substringFromIndex:(contentIndex.location + contentIndex.length + 1)];
            NSString *transString = [NSString stringWithString:[content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
           
            NSData *content_json = [NSData dataWithBytes:[transString UTF8String] length:strlen([transString UTF8String])];
            
            NSDictionary *task_list  = [NSJSONSerialization JSONObjectWithData:content_json options:NSJSONReadingMutableLeaves error:&error];
            if (task_list) {
                id case_info = [task_list objectForKey:@"case"];
                NSString *type = [task_list objectForKey:@"type"];
                NSInteger caseID = 0;
                if (case_info) {
                    //msg->event_content = [case_info objectForKey:@"content"];
                    chat_model.text = [case_info objectForKey:@"content"];
                    msg.dateTime = [case_info objectForKey:@"time"];
                    chat_model.dateTime = [case_info objectForKey:@"time"];
                    caseID = [[case_info objectForKey:@"id"] integerValue];
                    
                }
                
                NSString *strToast = nil;
                if ([type isEqualToString:@"alarm"]) {
                    char cmd[256] = {0};
                    sprintf(cmd, "/task/list?type=alarm&limit=100");
                    
                    strToast = [[NSString alloc] initWithFormat:@"%@[%ld]", NSLocalizedString(@"DataManager_AlarmTask", @""), (long)caseID];
                    [self showToast:strToast withTID:to_tid withType:1];
                    
                    if (strlen(cmd) > 0) {
                        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"alarmTaskList"];
                    }
                }
                else if ([type isEqualToString:@"trouble"]) {
                    char cmd[256] = {0};
                    sprintf(cmd, "/task/list?type=trouble&limit=100");
                    
                    strToast = [[NSString alloc] initWithFormat:@"%@[%ld]", NSLocalizedString(@"DataManager_RepairTask", @""), (long)caseID];
                    [self showToast:strToast withTID:to_tid withType:2];
                    
                    if (strlen(cmd) > 0) {
                        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"troubleTaskList"];
                    }
                }
                
            }
            
        }
        //msg_body->content = @"报警图片";
        //[self pushNotifyEvent:chat_model.text];
    }
    else if (strcmp(type, "e") == 0) {
        NSString *to_tid = [array objectAtIndex:2];
        things_tid = to_tid;
        
        NSString *name_path;
        char *name = NULL;
        NSString *format = [array objectAtIndex:4];
        if ([format isEqualToString:@"task"]) {
            name_path = [[NSString alloc] initWithFormat:@"members.%@.name", to_tid];
            
        }
        else {
            name_path = [[NSString alloc] initWithFormat:@"name"];
            
        }
        
        if ([my_tid isEqualToString:to_tid]) {
            chat_model.messageType = MessageTypeForLOCAL;
            name = "我";
            chat_model.bgImageName = @"chatto_bg_normal";
            chat_model.backgroundType = 0;
        }
        else {
            chat_model.bgImageName = @"chatfrom_bg_normal";
            chat_model.backgroundType = 0;
            chat_model.messageType = MessageTypeForServer;
            if ([format isEqualToString:@"task"]) {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:YES];
            }
            else {
                name = [[CWThings4Interface sharedInstance] get_var_with_path:[things_tid UTF8String] path:[name_path UTF8String] sessions:NO];
            }
        }
        if (name) {
            if (strcmp(name, "我") == 0) {
                chat_model.userName = self_name;
            }
            else {
                chat_model.userName = [[NSString alloc] initWithUTF8String:name];
            }
            //msg_body->name = [[NSString alloc] initWithUTF8String:name];
        }
        else {
            chat_model.userName = self_name;
        }
        ///////////////////////
        
        
        
        NSString *event_code = [array objectAtIndex:3];
        if ([event_code isEqualToString:@"1"]) {
            show_event = NO;
            chat_model.text = [array objectAtIndex:4];
            
            //event
            //msg->event_content = [array objectAtIndex:4];
        }
        else if ([event_code isEqualToString:@"2"]) {
            chat_model.text = [array objectAtIndex:4];
     
            show_event = NO;
            //event
           // msg->event_content = [array objectAtIndex:4];
        }
        else if ([event_code isEqualToString:@"8"]) {
            
            [followed_things_lock lock];
            for (DeviceStatusModel *device in followed_things_array) {
                if ([device.tid isEqualToString:to_tid]) {
                    device.unread_count++;
                    device.dateTime = msg.dateTime;
                    //device->on_off_line = NO;
                    [self saveUnreadEvent4Things:device.tid value:device.unread_count];
                    break;
                }
            }
            [followed_things_lock unlock];
            
            NSRange contentIndex = [json rangeOfString:@",8,"];
            NSError *error;
            NSString *content = [json substringFromIndex:(contentIndex.location + contentIndex.length)];
            //NSData *content_json = [NSData dataWithBytes:[content UTF8String] length:[content length]];
            NSData *content_json = [content dataUsingEncoding:NSUnicodeStringEncoding];
            NSDictionary *event_dic  = [NSJSONSerialization JSONObjectWithData:content_json options:NSJSONReadingMutableLeaves error:&error];
            id event_msg = [event_dic objectForKey:@"msg"];
            if (event_msg) {
                NSString *format = [event_msg objectForKey:@"fmt"];
                if (format == nil || [format isEqualToString:@"text"]) {
                    chat_model.text = [event_msg objectForKey:@"dat"];
                    
                    //[self pushNotifyEvent:chat_model.text];
                    
                    id usr_dic = [event_dic objectForKey:@"usr"];
                    if (usr_dic) {
                        NSString *cid = [usr_dic objectForKey:@"cid"];
                        if (cid) {
                            chat_model.messageStatusType = 6;
                            NSRange range;
                            range.length = 1;
                            range.location = 6;
                            NSString *e_7 = [cid substringWithRange:range];
                            range.length = 1;
                            range.location = 7;
                            NSString *e_8 = [cid substringWithRange:range];
                            if ([e_7 isEqualToString:@"3"] && [e_8 isEqualToString:@"4"]) {
                                chat_model.bgImageName = @"chatfrom_bg_away.png";
                                chat_model.backgroundType = 8;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_away.png";
                            }
                            else if ([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"4"]) {
                                chat_model.bgImageName = @"chatfrom_bg_open.png";
                                chat_model.backgroundType = 9;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_open.png";
                            }
                            else if (([e_7 isEqualToString:@"E"] || [e_7 isEqualToString:@"1"]) && [e_8 isEqualToString:@"5"]) {
                                chat_model.bgImageName = @"chatfrom_bg_panglu.png";
                                chat_model.backgroundType = 5;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_panglu.png";
                            }
                            //else if (([e_7 isEqualToString:@"R"] || [e_7 isEqualToString:@"3"]) && [e_8 isEqualToString:@"5"]) {
                                
                            //}
                            else if([e_7 isEqualToString:@"1"] && [e_8 isEqualToString:@"1"]) {
                                chat_model.bgImageName = @"chatfrom_bg_baojin.png";
                                chat_model.backgroundType = 1;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_baojin.png";
                            }
                            else {
                                chat_model.bgImageName = @"chatfrom_bg_normal";
                                chat_model.backgroundType = 0;
                                //msg_body->fuc_image_bg = @"chatfrom_bg_normal";
                            }
                        }
                    }
     
                }
                else if(format && [format isEqualToString:@"cim"]){
                    chat_model.messageStatusType = 5;
                    NSDictionary *data = [event_msg objectForKey:@"dat"];
                    id content_list = [data objectForKey:@"content"];
                    for (id image_content in content_list) {
                        NSString *format = [image_content objectForKey:@"format"];
                        NSString *image_url = [image_content objectForKey:@"url"];
                        NSRange range = [image_url rangeOfString:@"http://"];
                        if (range.length > 0) {
                            chat_model.imageName = image_url;
                        }
                        else {
                            char *session_id = [[CWThings4Interface sharedInstance] get_things_sid];
                            if (session_id && server_addr_) {
                                chat_model.imageName = [[NSString alloc] initWithFormat:@"http://%@:%ld/download/%@?sid=%s", server_addr_, (long)   image_server_port_, image_url, session_id];
                            }
                        }
                        
                        if ([format isEqualToString:@"jpg"]) {
                            NSString *image_data = [image_content objectForKey:@"data"];
                            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:image_data options:0];
                            //NSData *pImageData = [NSData dataWithBytes:inImageBuffer length:inImageLen];
                            
                            UIImage *pImage = [UIImage imageWithData:decodedData];
                            chat_model.smallImage = pImage;
                        }
                        else if ([format isEqualToString:@"crtsp"]) {
                            chat_model.messageStatusType = 7;//video;
                            UIImage *pImage = [UIImage imageNamed:@"PlayButton.png"];
                            chat_model.smallImage = pImage;
                            
                            NSString *record_start_time = [image_content objectForKey:@"url"];
                            NSString *record_end_time = [image_content objectForKey:@"data"];
                            //msg_body->event_start_Time = record_start_time;
                            //msg_body->event_end_time = record_end_time;
     
                            chat_model.text = [NSString stringWithFormat:@"%@", record_start_time];
                            //msg_body->msgType = 2;
                        }
                    }
                    
                }
            }
        }
        
    }
    else {
        return ;
    }
   
    if (show_event == YES) {
        [self pushNotifyEvent:chat_model.text];
        [chat_message_lock lock];
        if (things_tid != nil) {
           
            NSMutableArray *temp_array = [chat_message_dictionary objectForKey:things_tid];
            if (temp_array == nil) {
                temp_array = [[NSMutableArray alloc] init];
                [chat_message_dictionary setObject:temp_array forKey:things_tid];
            }
            
            //[temp_array insertObject:msg_frame atIndex:0];
            if ([temp_array count] > 100) {
                [temp_array removeObjectAtIndex:0];
            }
            [temp_array addObject:chat_model];
        }
        [chat_message_lock unlock];
        
        if (event_message_array == nil) {
            event_message_array = [[NSMutableArray alloc] init];
        }
        [event_message_array insertObject:chat_model atIndex:0];
        //[event_message_array addObject:msg_body];
        chat_message_update = YES;
        event_message_update = YES;
        show_message_tip = YES;
        no_read_message_count++;
    }
    
    //event
    
    if (_isRunningInBackground == YES) {
        [self reportNotHandleEvent:YES];
    }
    else {
        //[self reportNotHandleEvent:NO];
        
        if (_isOpenMessageSound) {
            SystemSoundID soundID;
            NSURL *url = [NSURL URLWithString:_playSoundName];
            AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url,&soundID);
            AudioServicesPlaySystemSound(soundID);
        }
    }
}

#pragma mark - picture server info
-(void)cwPostServerInfo:(const char*)body
{
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:body];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:body length:strlen(body)];
    NSDictionary *server_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (server_json) {
        NSString* port = [server_json objectForKey:@"default_jpg_download_port"];
        image_server_port_ = [port integerValue];
    }
}

#pragma mark - relay server info
-(void)cwPostRelayServerInfo:(const char*)body
{
    if (body == NULL) {
        update_relay_flag_ = YES;
        return ;
    }
    NSError *error;
    update_relay_flag_ = NO;
    NSString *json = [NSString stringWithUTF8String:body];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:body length:strlen(body)];
    NSDictionary *relay_server_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (relay_server_json) {
        relay_server_ip_ = [relay_server_json objectForKey:@"relay-ip"];
        relay_server_port_ = [relay_server_json objectForKey:@"relay-port"];
        update_relay_flag_ = YES;
    }
}

-(void)cwPostThingsInfo:(const char*)body
{
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:body];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:body length:strlen(body)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        NSString *tid = [things_json objectForKey:@"id"];
        id custom = [things_json objectForKey:@"custom"];
        if (custom) {
            for (DeviceStatusModel *device in followed_things_array) {
                if ([device.tid isEqualToString:tid]) {
                    //device->device_ip =[custom objectForKey:@"ip"];
                    //NSString *port = [custom objectForKey:@"port"];
                    //device->device_port = [port intValue];
                    //device->device_user = [custom objectForKey:@"user"];
                    //device->device_pass = [custom objectForKey:@"pass"];
                }
            }
        }
    }
}

-(void) on_vars_change_callback:(const char*)tid status:(const char*)status
{
    [followed_things_filter_lock lock];
    followed_things_filter_update = YES;
    [followed_things_filter_lock unlock];
}

- (void) saveUnreadEvent4Things:(NSString*)tid value:(NSInteger)value
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:value forKey:tid];
    [userDefaults synchronize];
}

- (NSInteger) getUnreadEevent4Things:(NSString*)tid
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger unread_count = [userDefaults integerForKey:tid];
    return unread_count;
}

- (void)select_all:(BOOL)selected
{
    if (selected == YES) {
        followed_things_filter_value = 0;
        
        followed_things_init_grid = YES;
        followed_things_init = YES;
    }
    else {
        [followed_things_filter_lock lock];
        followed_things_filter_update = YES;
        [followed_things_filter_lock unlock];
    }
    followed_things_filter_value ^= (1<<1);
    followed_things_filter_value ^= (1<<2);
    followed_things_filter_value ^= (1<<3);
    followed_things_filter_value ^= (1<<4);
    followed_things_filter_value ^= (1<<5);
    followed_things_filter_value ^= (1<<6);
    followed_things_filter_value ^= (1<<7);
    followed_things_filter_value ^= (1<<8);
    
    //int value = followed_things_filter_value & (1<<1);
}

- (void) updateFilterValue:(BOOL)selected num:(int)num
{
    [followed_things_filter_lock lock];
    switch (num) {
        case 1:
            followed_things_filter_update = YES;
            //followed_things_filter_value = 0;
            followed_things_filter_value ^= (1<<1);
            break;
        case 2:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<2);
            break;
        case 3:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<3);
            break;
        case 4:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<4);
            break;
        case 5:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<5);
            break;
        case 6:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<6);
            break;
        case 7:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<7);
            break;
        case 8:
            followed_things_filter_update = YES;
            followed_things_filter_value ^= (1<<8);
            break;
        default:
            [followed_things_filter_lock unlock];
            return;
    }
    
    //add by yeung, 2015-01-29
    /*if ((followed_things_filter_value & (1<<2)) > 0 &&
        (followed_things_filter_value & (1<<3)) > 0 &&
        (followed_things_filter_value & (1<<4)) > 0 &&
        (followed_things_filter_value & (1<<5)) > 0 &&
        (followed_things_filter_value & (1<<6)) > 0 &&
        (followed_things_filter_value & (1<<7)) > 0 &&
        (followed_things_filter_value & (1<<8)) > 0)
    {
        followed_things_filter_value ^= (1<<1);
    }
    else {
        followed_things_filter_value ^= (1<<1);
    }*/
    
    [followed_things_filter_lock unlock];
    if (followed_things_filter_value == 0) {
        followed_things_init_grid = YES;
        followed_things_init = YES;
    }
}

- (BOOL) getFilterValue:(int)num
{
    if (followed_things_filter_value == 0) {
        return NO;
    }
    int value = 0;
    [followed_things_filter_lock lock];
    switch (num) {
        case 1:
            value = followed_things_filter_value & (1<<1);
            break;
        case 2:
            value = followed_things_filter_value & (1<<2);
            break;
        case 3:
            value = followed_things_filter_value & (1<<3);
            break;
        case 4:
            value = followed_things_filter_value & (1<<4);
            break;
        case 5:
            value = followed_things_filter_value & (1<<5);
            break;
        case 6:
            value = followed_things_filter_value & (1<<6);
            break;
        case 7:
            value = followed_things_filter_value & (1<<7);
            break;
        case 8:
            value = followed_things_filter_value & (1<<8);
            break;
            break;
        default:
            break;
    }
    [followed_things_filter_lock unlock];
    
    if (value > 0) {
        return YES;
    }
    return NO;
}

- (void) turnToRunningBackground:(BOOL) flag
{
    _isRunningInBackground = flag;
    /*if (flag == YES) {
        if ([play_sound_msg_ getSoundID] <= 0) {
            play_sound_msg_ = [[MsgPlaySound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
        }
    }
    else {
        [play_sound_msg_ release_sound];
    }*/
}

#pragma mark - report message notify
- (void) reportNotHandleEvent : (BOOL)increase
{
    float sys_version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (sys_version >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    UIApplication *app = [UIApplication sharedApplication];
    
    
    if (increase == NO) {
        NSInteger unread_count = [self ThingsMsgUnreadCount];
        // 应用程序右上角数字
        if (unread_count > 0) {
            
            app.applicationIconBadgeNumber = unread_count;
        }
        else {
            app.applicationIconBadgeNumber = 0;
        }
    }
    else {
        app.applicationIconBadgeNumber++;
    }
}

- (void) open_device_p2p : (BOOL)open
{
    //open_device_p2p = open;
    p2p_mode_right_ = open;
    
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:@"open_device_p2p"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) getDeviceP2P
{
    return p2p_mode_right_;
}

- (void) open_device_relay : (BOOL)open
{
    relay_mode_right_ = open;
    
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:@"open_device_relay"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) background_sound : (BOOL)open
{
    _isOpenMessageSound = open;
    
    [[NSUserDefaults standardUserDefaults] setBool:open forKey:@"open_sound_switch"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (_isOpenMessageSound == NO) {
        [self cancelLocalNotificationWithKey:@"key"];
    }
}

- (BOOL) getBackgrouSound
{
    return _isOpenMessageSound;
}

- (void) playBackgroudSoud : (BOOL)vibrate
{
    if (_isOpenMessageSound == YES) {
        /*BOOL play_Ok = [play_sound_msg_ play:vibrate];
        if (play_Ok == NO) {
            play_sound_msg_ = [[MsgPlaySound alloc] initSystemSoundWithName:@"sms-received1" SoundType:@"caf"];
        }*/
    }
}

- (void) setFuzzyQuery:(char*)text
{
    memset(fuzzy_query_text_, 0, NAME_LEN_);
    strcpy(fuzzy_query_text_, text);
    NSString *fuzzy_name = [[NSString alloc] initWithUTF8String:text];
    [[NSUserDefaults standardUserDefaults] setObject:fuzzy_name forKey:@"fuzzy_query_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (char*) getFuzzyQuery
{
    return fuzzy_query_text_;
}

- (void) setSelectedMenuCaption:(NSString *)selectedMenuCaption
{
    _selectedMenuCaption = selectedMenuCaption;
    [[NSUserDefaults standardUserDefaults] setObject:selectedMenuCaption forKey:@"selectedMenuCaption"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void) pushNotifyEvent:(NSString*)eventBody
{
    if (_isOpenMessageSound == NO) {
        return;
    }
    if (eventBody == nil) return ;
    //NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1];
    //chuagjian一个本地推送
    NSString *body = [[NSString alloc] initWithString:eventBody];
    body = [body stringByReplacingOccurrencesOfString:@"\\\\r\\\\n" withString:@"\r\n"];
    body = [body stringByReplacingOccurrencesOfString:@"\\r\\n" withString:@"\r\n"];
    
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    
    if (noti) {
        
        //设置推送时间
        
        //noti.fireDate = date;
        
        //设置时区
        
        noti.timeZone = [NSTimeZone defaultTimeZone];
        
        //设置重复间隔
        
        noti.repeatInterval = NSWeekCalendarUnit;
        
        //推送声音
        
        noti.soundName = UILocalNotificationDefaultSoundName;
        
        //内容
        
        noti.alertBody = body;
        
        //显示在icon上的红色圈中的数子
        
        //noti.applicationIconBadgeNumber = 1;
        
        //设置userinfo 方便在之后需要撤销的时候使用
        
        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
        
        noti.userInfo = infoDic;
        
        // ios8后，需要添加这个注册，才能得到授权
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
        {
            UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                     categories:nil];
            [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
            // 通知重复提示的单位，可以是天、周、月
            noti.repeatInterval = NSCalendarUnitDay;
        }
        else
        {
            // 通知重复提示的单位，可以是天、周、月
            noti.repeatInterval = NSCalendarUnitDay;
        }
        
        //添加推送到uiapplication
        
        UIApplication *app = [UIApplication sharedApplication];
        
        [app scheduleLocalNotification:noti];
    }
}

// 取消某个本地推送通知
- (void)cancelLocalNotificationWithKey:(NSString *)key
{
    /*!
     
     有一点需要注意，如果我们的应用程序给系统发送的本地通知是周期性的，那么即使把程序删了重装，之前的本地通知在重装时依然存在（没有从系统中移除）。例如，我们在viewDidLoad方法中启动添加本地通知的方法，多跑几次，然后把程序在模拟器中删除，再重新跑，并用下列方法输出所有的本地通知：
     
     */
    // 获取所有本地通知数组
    NSArray *localNotifications = [UIApplication sharedApplication].scheduledLocalNotifications;
    
    for (UILocalNotification *notification in localNotifications)
    {
        NSDictionary *userInfo = notification.userInfo;
        if (userInfo)
        {
            // 根据设置通知参数时指定的key来获取通知参数
            NSString *info = userInfo[key];
            
            // 如果找到需要取消的通知，则取消
            if (info != nil)
            {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                break;
            }
        }
    }
}

-(void)cwRequestError
{
    /*[eventArrayLock lock];
    CWEventDataMgr *pDataMgr = [[CWEventDataMgr alloc] init];
    int nDataType = 3;
    assert(pDataMgr != nil);
    [pDataMgr initWithStream:nil StreamLen:0 DataType:nDataType];
    [eventArray addObject:pDataMgr];
    [eventArrayLock unlock];*/
}

-(void)cwConnectEvent:(BOOL)connected
{
    things_connected_ = connected;
    if (connected == NO) {
        
        [self showToast:NSLocalizedString(@"DataManager_NetWorkErr", @"") withTID:@"" withType:1];
    }
    else {
        char x_location[32] = {0};
        char y_location[32] = {0};
        sprintf(x_location, "%f", _userLat);
        sprintf(y_location, "%f", _userLon);
        
        [[CWThings4Interface sharedInstance] set_var_with_tid:NULL path:x_location sessions:NO value:y_location];
    }
}

-(void)cwLoginEvent:(BOOL)login
{
    if (login == NO) {
        //[self BA_showAlert:@"用户登录失败"];
    }
    else {
        char x_location[32] = {0};
        char y_location[32] = {0};
        sprintf(x_location, "%f", _userLat);
        sprintf(y_location, "%f", _userLon);
        
        [[CWThings4Interface sharedInstance] set_var_with_tid:NULL path:x_location sessions:NO value:y_location];
    }
    /*[eventArrayLock lock];
    CWEventDataMgr *pDataMgr = [[CWEventDataMgr alloc] init];
    int nDataType = 4;
    assert(pDataMgr != nil);
    [pDataMgr initWithStream:nil StreamLen:0 DataType:nDataType];
    [eventArray addObject:pDataMgr];
    [eventArrayLock unlock];*/
}

- (void) cwPostThingsStatus:(const char *)body tid:(const char *)tid
{
    
}

#pragma mark - version check
-(void) checkVersion
{
    //暂时不做版本更新
    return;
    
    if (check_update_ == YES) return ;
    
    NSURL *url = [NSURL URLWithString:MY_APP_URL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:10.0];

    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   
                               }
                               else {
                                   check_update_ = YES;
                                   NSError* jasonErr = nil;
                                   // jason 解析
                                   
                                   //NSString *json_str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   
                                   NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jasonErr];
                                   if (responseDict && [responseDict objectForKey:@"results"]) {
                                       NSDictionary* results = [[responseDict objectForKey:@"results"] objectAtIndex:0];;
                                       
                                       if (results) {
                                           
                                           NSString *app_store_version = [results objectForKey:@"version"];
                                           //CGFloat  fVeFromNet = [[results objectForKey:@"version"] floatValue];
                                           
                                           NSString *strVerUrl = [results objectForKey:@"trackViewUrl"];
                                           
                                           
                                           
                                           if (app_store_version && strVerUrl) {
                                               /*// app名称
                                                _nameLabel.text = [infoDictionary objectForKey:@"CFBundleDisplayName"];
                                                // app版本
                                                _versionLabel.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
                                                // app build版本
                                                _buildLabel.text = [infoDictionary objectForKey:@"CFBundleVersion"];*/
                                               NSString *app_local_version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                                               //CGFloat fCurVer = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] floatValue];
                                               NSComparisonResult compare_result = [app_store_version compare:app_local_version];
                                               if (compare_result == NSOrderedDescending) {
                                                   app_update_track_url_ = strVerUrl;
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DataManager_AlertTitle", @"") message:NSLocalizedString(@"DataManager_AlertUpdate", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"DataManager_AlertCancel", @"") otherButtonTitles:NSLocalizedString(@"DataManager_AlertOK", @""), nil];
                                                       
                                                       [alert show];
                                                       
                                                   });
                                                   
                                               }
                                               
                                           }
                                           
                                       }
                                       
                                   }
                                   
                               }
                               
                           }];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && [alertView.title isEqualToString:NSLocalizedString(@"DataManager_AlertOK", @"")]) {
        NSURL * url = [NSURL URLWithString:app_update_track_url_];
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) setMainView:(UIView*) mainView parentView:(UIView*)inView
{
    main_view_ = mainView;
    parent_view_ = inView;
}

- (void) updateMainView
{
    
    
    CGRect rc_main = main_view_.frame;
    
    int         view_height = 0;
    //[network_status_view_ setFrame:CGRectMake(0, 0, rc_main.size.width, 100)];
    if (show_network_Status) {
        if (parent_view_) {
            [network_status_view_ removeFromSuperview];
        }
        
        //for main view
        rc_main.origin.y += 42;
        rc_main.size.height -= 42;
        view_height += 42;
        
        //for network status view
        [parent_view_ addSubview:network_status_view_];
        
        UIImageView *error_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(130, 74, 18, 18)];
        UIImage *error_image = [UIImage imageNamed:@"pop_view_guzhang"];
        [error_image_view setImage:error_image];
        [network_status_view_ addSubview:error_image_view];
        
        CGRect rcText = network_status_view_.bounds;
        rcText.origin.y += 64;
        rcText.origin.x += 152;
        rcText.size.width -= 152;
        rcText.size.height = 42;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:rcText];
        [textLabel setText:@"网络故障"];
        [textLabel setTextColor:[UIColor blackColor]];
        [textLabel setTextAlignment:NSTextAlignmentLeft];
        [network_status_view_ addSubview:textLabel];
    }
    else if (show_message_tip) {
        if (parent_view_) {
            [message_tip_view_ removeFromSuperview];
        }
        [parent_view_ addSubview:message_tip_view_];
        if (view_height == 0) {
            view_height = 64;
        }
        [message_tip_view_  setFrame:CGRectMake(0, view_height, rc_main.size.width, 42)];
        view_height += 42;
        rc_main.origin.y += 42;
        rc_main.size.height -= 42;
        
        UIImageView *error_image_view = [[UIImageView alloc] initWithFrame:CGRectMake(130, 6, 30, 30)];
        UIImage *error_image = [UIImage imageNamed:@"pop_view_guzhang"];
        [error_image_view setImage:error_image];
        //[message_tip_view_ addSubview:error_image_view];
        
        CGRect rcMessage = message_tip_view_.bounds;
        rcMessage.origin.x = 30;
        rcMessage.size.width -= 30;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rcMessage];
        [titleLabel setText:@"你有新的消息，请注意查收。"];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        [message_tip_view_ addSubview:titleLabel];
        
    }
    
    if (show_notice) {
        if (parent_view_) {
            [notice_view_ removeFromSuperview];
        }
        [parent_view_ addSubview:notice_view_];
        [notice_view_  setFrame:CGRectMake(0, main_view_.bounds.size.height - 48, rc_main.size.width, 48)];
        rc_main.size.height -= 48;
        
        CGRect rcNotice = notice_view_.bounds;
        UIImageView *error_image_view = [[UIImageView alloc] initWithFrame:rcNotice];
        UIImage *error_image = [UIImage imageNamed:@"guanggao"];
        [error_image_view setImage:error_image];
        [notice_view_ addSubview:error_image_view];
        
        CGSize noticeSize = notice_view_.frame.size;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(noticeSize.width - 22, 0, 22, 22);
        UIImage *buttonImage = [UIImage imageNamed:@"pop_view_guanbi"];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [notice_view_ addSubview:button];
        
        
        /*UILabel *titleLabel = [[UILabel alloc] initWithFrame:rcNotice];
        [titleLabel setText:@"网络状态正常"];
        [titleLabel setTextColor:[UIColor blackColor]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [notice_view_ addSubview:titleLabel];*/
    }
    
    [main_view_ setFrame:rc_main];
}

- (NSString*) get_relay_server_ip
{
    return relay_server_ip_;
}
- (NSString*) get_relay_server_port
{
    return relay_server_port_;
}

#pragma mark - alarm task
-(void) cwPostTaskInfo:(const char*)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL) {
        update_task_info_array = YES;
        //[self BA_showAlert:@"获取出警任务列表为空"];
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        id result = [things_json objectForKey:@"result"];
        if (result) {
            if (self_task_info_array && [self_task_info_array count]) {
                [self_task_info_array removeAllObjects];
            }
            
            if ([result count] == 0) {
                update_task_info_array = YES;
                NSString *strErr = NSLocalizedString(@"DataManager_AlarmTaskEmpty", @"");
                //strErr = [strErr stringByAppendingString:json];
                [self BA_showAlert:strErr];
                
                return ;
            }
            
            
            for (id task_info in result) {
                AlarmTaskCellModel *taskInfoModel = [[AlarmTaskCellModel alloc] init];
                taskInfoModel->task_id = [[task_info objectForKey:@"task_id"] integerValue];
                taskInfoModel->tid = [task_info objectForKey:@"tid"];
                taskInfoModel->case_id = [[task_info objectForKey:@"case_id"] integerValue];
                taskInfoModel->type = [task_info objectForKey:@"type"];
                taskInfoModel->status = [task_info objectForKey:@"status"];
                taskInfoModel->content = [task_info objectForKey:@"content"];
                taskInfoModel->note = [task_info objectForKey:@"note"];
                
                taskInfoModel->tid_source = [task_info objectForKey:@"tid_source"];
                taskInfoModel->time_assign = [task_info objectForKey:@"time_assign"];
                
                taskInfoModel->time_accept = [task_info objectForKey:@"time_accept"];
                taskInfoModel->time_finish = [task_info objectForKey:@"time_finish"];
                taskInfoModel->case_location = [task_info objectForKey:@"case_location"];
                taskInfoModel->case_time = [task_info objectForKey:@"case_time"];
                taskInfoModel->case_title = [task_info objectForKey:@"case_title"];
                taskInfoModel->case_content = [task_info objectForKey:@"case_content"];
                taskInfoModel->case_lon = [task_info objectForKey:@"case_lon"];
                taskInfoModel->case_lat = [task_info objectForKey:@"case_lat"];
                taskInfoModel->case_contact_name = [task_info objectForKey:@"case_contact_name"];
                taskInfoModel->case_contact_tel = [task_info objectForKey:@"case_contact_tel"];
                
                if (self_task_info_array == nil) {
                    self_task_info_array = [[NSMutableArray alloc] init];
                }
                [self_task_info_array addObject:taskInfoModel];
            }
            if (self_task_info_array && [self_task_info_array count]) {
                update_task_info_array = YES;
            }
            else {
                update_task_info_array = YES;
            }
        }
        else {
            NSString *strErr = NSLocalizedString(@"DataManager_AlarmTaskErr", @"");
            //strErr = [strErr stringByAppendingString:json];
            [self BA_showAlert:strErr];
        }
    }
}

#pragma mark - alarm case
-(void) cwPostCaseInfo:(const char*)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL) {
        update_case_info_array = YES;
        [self BA_showAlert:NSLocalizedString(@"DataManager_AlarmCaseEmpty", @"")];
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        id basicInfo = [things_json objectForKey:@"basic"];
        if (basicInfo) {
            if (self_case_info_array && [self_case_info_array count]) {
                [self_case_info_array removeAllObjects];
            }
            
            AlarmCaseModel *caseInfo = [[AlarmCaseModel alloc] init];
            caseInfo->case_id = [[basicInfo objectForKey:@"case_id"] integerValue];
            caseInfo->case_fkey = [basicInfo objectForKey:@"fkey"];
            caseInfo->case_group_id = [basicInfo objectForKey:@"group_tid"];
            caseInfo->case_type = [basicInfo objectForKey:@"type"];
            caseInfo->case_title = [basicInfo objectForKey:@"title"];
            caseInfo->case_content = [basicInfo objectForKey:@"content"];
            caseInfo->case_note = [basicInfo objectForKey:@"note"];
            caseInfo->case_location = [basicInfo objectForKey:@"location"];
            caseInfo->case_time = [basicInfo objectForKey:@"time"];
            caseInfo->case_contact_name = [basicInfo objectForKey:@"contact_name"];
            caseInfo->case_contact_tel = [basicInfo objectForKey:@"contact_tel"];
            caseInfo->case_incharge_tid = [basicInfo objectForKey:@"incharge_tid"];
            caseInfo->case_location_lat = [basicInfo objectForKey:@"location_lat"];
            caseInfo->case_location_lon = [basicInfo objectForKey:@"location_lon"];
            caseInfo->case_status = [basicInfo objectForKey:@"status"];
            caseInfo->case_result = [basicInfo objectForKey:@"result"];
            caseInfo->case_evaulate_score = [basicInfo objectForKey:@"evaulate_score"];
            caseInfo->case_evaulate_note = [basicInfo objectForKey:@"evaulate_note"];
            caseInfo->case_report_time = [basicInfo objectForKey:@"report_time"];
            caseInfo->case_report_tid = [basicInfo objectForKey:@"report_tid"];
            caseInfo->case_report_note = [basicInfo objectForKey:@"report_note"];
            //caseInfo->case_report_lon = [[basicInfo objectForKey:@"report_lon"] floatValue];
            //caseInfo->case_report_lat = [[basicInfo objectForKey:@"report_lat"] floatValue];
            
            caseInfo->case_assign_time = [basicInfo objectForKey:@"assign_time"];
            caseInfo->case_incharge_tid = [basicInfo objectForKey:@"incharge_tid"];
            caseInfo->case_incharge_task_id = [basicInfo objectForKey:@"incharge_task_id"];
            caseInfo->case_incharge_time = [basicInfo objectForKey:@"incharge_time"];
            caseInfo->case_incharge_name = [basicInfo objectForKey:@"incharge_name"];
            caseInfo->case_incharge_note = [basicInfo objectForKey:@"incharge_note"];
            
            caseInfo->case_arrive_time = [basicInfo objectForKey:@"arrive_time"];
            caseInfo->case_arrive_tid = [basicInfo objectForKey:@"arrive_tid"];
            caseInfo->case_arrive_name = [basicInfo objectForKey:@"arrive_name"];
            caseInfo->case_arrive_note = [basicInfo objectForKey:@"arrive_note"];
            caseInfo->case_arrive_lon = [basicInfo objectForKey:@"arrive_lon"];
            caseInfo->case_arrive_lat = [basicInfo objectForKey:@"arrive_lat"];
            caseInfo->case_close_time = [basicInfo objectForKey:@"close_time"];
            caseInfo->case_close_tid = [basicInfo objectForKey:@"close_tid"];
            caseInfo->case_close_name = [basicInfo objectForKey:@"close_name"];
            caseInfo->case_close_note = [basicInfo objectForKey:@"close_note"];
            
            
            //task
            id taskList = [things_json objectForKey:@"tasks"];
            for (id task in taskList) {
                AlarmTaskCellModel *alarmModel = [AlarmTaskCellModel new];
                alarmModel->task_id = [[task objectForKey:@"task_id"] integerValue];
                alarmModel->tid = [task objectForKey:@"tid"];
                alarmModel->case_id = [[task objectForKey:@"case_id"] integerValue];
                alarmModel->status = [task objectForKey:@"status"];
                alarmModel->content = [task objectForKey:@"content"];
                alarmModel->note = [task objectForKey:@"note"];
                alarmModel->tid_source = [task objectForKey:@"tid_source"];
                alarmModel->time_assign = [task objectForKey:@"time_assign"];
                alarmModel->time_accept = [task objectForKey:@"time_accept"];
                alarmModel->time_finish = [task objectForKey:@"time_finish"];
                
                if (caseInfo->taskArray == nil) {
                    caseInfo->taskArray = [NSMutableArray new];
                }
                [caseInfo->taskArray addObject:alarmModel];
            }
            
            if (self_case_info_array == nil) {
                self_case_info_array = [[NSMutableArray alloc] init];
            }
            [self_case_info_array insertObject:caseInfo atIndex:0];
            
            if (self_case_info_array && [self_case_info_array count]) {
                update_case_info_array = YES;
            }
        }
        else {
            NSString *strErr = NSLocalizedString(@"DataManager_AlarmCaseErr", @"");
            //strErr = [strErr stringByAppendingString:json];
            [self BA_showAlert:strErr];
        }
    }
}

#pragma mark - repair task
-(void) cwPostRepairTaskInfo:(const char*)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL)
    {
        update_repair_task_info_array = YES;
        //[self BA_showAlert:@"获取维修任务列表为空"];
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        id result = [things_json objectForKey:@"result"];
        if (result) {
            if (self_repair_task_info_array && [self_repair_task_info_array count]) {
                [self_repair_task_info_array removeAllObjects];
            }
            
            if ([result count] == 0) {
                update_repair_task_info_array = YES;
                NSString *strErr = NSLocalizedString(@"DataManager_RepairTaskEmpty", @"");
                //strErr = [strErr stringByAppendingString:json];
                [self BA_showAlert:strErr];
                return ;
            }
            
            for (id task_info in result) {
                AlarmTaskCellModel *taskInfo = [[AlarmTaskCellModel alloc] init];
                taskInfo->task_id = [[task_info objectForKey:@"task_id"] integerValue];
                taskInfo->tid = [task_info objectForKey:@"tid"];
                taskInfo->case_id = [[task_info objectForKey:@"case_id"] integerValue];
                taskInfo->type = [task_info objectForKey:@"type"];
                taskInfo->status = [task_info objectForKey:@"status"];
                taskInfo->content = [task_info objectForKey:@"content"];
                taskInfo->note = [task_info objectForKey:@"note"];
                
                taskInfo->tid_source = [task_info objectForKey:@"tid_source"];
                taskInfo->time_assign = [task_info objectForKey:@"time_assign"];
                
                taskInfo->time_accept = [task_info objectForKey:@"time_accept"];
                taskInfo->time_finish = [task_info objectForKey:@"time_finish"];
                taskInfo->case_location = [task_info objectForKey:@"case_location"];
                taskInfo->case_time = [task_info objectForKey:@"case_time"];
                taskInfo->case_title = [task_info objectForKey:@"case_title"];
                taskInfo->case_content = [task_info objectForKey:@"case_content"];
                taskInfo->case_lon = [task_info objectForKey:@"case_lon"];
                taskInfo->case_lat = [task_info objectForKey:@"case_lat"];
                taskInfo->case_contact_name = [task_info objectForKey:@"case_contact_name"];
                taskInfo->case_contact_tel = [task_info objectForKey:@"case_contact_tel"];
                
                
                if (self_repair_task_info_array == nil) {
                    self_repair_task_info_array = [[NSMutableArray alloc] init];
                }
                [self_repair_task_info_array addObject:taskInfo];
            }
            if (self_repair_task_info_array && [self_repair_task_info_array count]) {
                update_repair_task_info_array = YES;
            }
            else {
                update_repair_task_info_array = YES;
            }
        }
        else {
            NSString *strErr = NSLocalizedString(@"DataManager_RepairTaskErr", @"");
            //strErr = [strErr stringByAppendingString:json];
            [self BA_showAlert:strErr];
        }
    }
}

#pragma mark - repair case
-(void) cwPostRepairCaseInfo:(const char*)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL) {
        update_repair_case_info_array = YES;
        //[self BA_showAlert:@"获取维修案件信息为空"];
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        id basicInfo = [things_json objectForKey:@"basic"];
        if (basicInfo) {
            if (self_repair_case_info_array && [self_repair_case_info_array count]) {
                [self_repair_case_info_array removeAllObjects];
            }
            
            AlarmCaseModel *caseInfo = [[AlarmCaseModel alloc] init];
            caseInfo->case_id = [[basicInfo objectForKey:@"case_id"] integerValue];
            caseInfo->case_fkey = [basicInfo objectForKey:@"fkey"];
            caseInfo->case_group_id = [basicInfo objectForKey:@"group_tid"];
            caseInfo->case_type = [basicInfo objectForKey:@"type"];
            caseInfo->case_title = [basicInfo objectForKey:@"title"];
            caseInfo->case_content = [basicInfo objectForKey:@"content"];
            caseInfo->case_note = [basicInfo objectForKey:@"note"];
            caseInfo->case_location = [basicInfo objectForKey:@"location"];
            caseInfo->case_time = [basicInfo objectForKey:@"time"];
            caseInfo->case_contact_name = [basicInfo objectForKey:@"contact_name"];
            caseInfo->case_contact_tel = [basicInfo objectForKey:@"contact_tel"];
            caseInfo->case_incharge_tid = [basicInfo objectForKey:@"incharge_tid"];
            caseInfo->case_location_lat = [basicInfo objectForKey:@"location_lat"];
            caseInfo->case_location_lon = [basicInfo objectForKey:@"location_lon"];
            caseInfo->case_status = [basicInfo objectForKey:@"status"];
            caseInfo->case_result = [basicInfo objectForKey:@"result"];
            caseInfo->case_evaulate_score = [basicInfo objectForKey:@"evaulate_score"];
            caseInfo->case_evaulate_note = [basicInfo objectForKey:@"evaulate_note"];
            caseInfo->case_report_time = [basicInfo objectForKey:@"report_time"];
            caseInfo->case_report_tid = [basicInfo objectForKey:@"report_tid"];
            caseInfo->case_report_note = [basicInfo objectForKey:@"report_note"];
            //caseInfo->case_report_lon = [[basicInfo objectForKey:@"report_lon"] floatValue];
            //caseInfo->case_report_lat = [[basicInfo objectForKey:@"report_lat"] floatValue];
            
            caseInfo->case_assign_time = [basicInfo objectForKey:@"assign_time"];
            caseInfo->case_incharge_tid = [basicInfo objectForKey:@"incharge_tid"];
            caseInfo->case_incharge_task_id = [basicInfo objectForKey:@"incharge_task_id"];
            caseInfo->case_incharge_time = [basicInfo objectForKey:@"incharge_time"];
            caseInfo->case_incharge_name = [basicInfo objectForKey:@"incharge_name"];
            caseInfo->case_incharge_note = [basicInfo objectForKey:@"incharge_note"];
            
            caseInfo->case_arrive_time = [basicInfo objectForKey:@"arrive_time"];
            caseInfo->case_arrive_tid = [basicInfo objectForKey:@"arrive_tid"];
            caseInfo->case_arrive_name = [basicInfo objectForKey:@"arrive_name"];
            caseInfo->case_arrive_note = [basicInfo objectForKey:@"arrive_note"];
            caseInfo->case_arrive_lon = [basicInfo objectForKey:@"arrive_lon"];
            caseInfo->case_arrive_lat = [basicInfo objectForKey:@"arrive_lat"];
            caseInfo->case_close_time = [basicInfo objectForKey:@"close_time"];
            caseInfo->case_close_tid = [basicInfo objectForKey:@"close_tid"];
            caseInfo->case_close_name = [basicInfo objectForKey:@"close_name"];
            caseInfo->case_close_note = [basicInfo objectForKey:@"close_note"];
            
            //task
            id taskList = [things_json objectForKey:@"tasks"];
            for (id task in taskList) {
                AlarmTaskCellModel *alarmModel = [AlarmTaskCellModel new];
                alarmModel->task_id = [[task objectForKey:@"task_id"] integerValue];
                alarmModel->tid = [task objectForKey:@"tid"];
                alarmModel->case_id = [[task objectForKey:@"case_id"] integerValue];
                alarmModel->status = [task objectForKey:@"status"];
                alarmModel->content = [task objectForKey:@"content"];
                alarmModel->note = [task objectForKey:@"note"];
                alarmModel->tid_source = [task objectForKey:@"tid_source"];
                alarmModel->time_assign = [task objectForKey:@"time_assign"];
                alarmModel->time_accept = [task objectForKey:@"time_accept"];
                alarmModel->time_finish = [task objectForKey:@"time_finish"];
                
                if (caseInfo->taskArray == nil) {
                    caseInfo->taskArray = [NSMutableArray new];
                }
                [caseInfo->taskArray addObject:alarmModel];
            }
            
            if (self_repair_case_info_array == nil) {
                self_repair_case_info_array = [[NSMutableArray alloc] init];
            }
            [self_repair_case_info_array insertObject:caseInfo atIndex:0];
            
            if (self_repair_case_info_array && [self_repair_case_info_array count]) {
                update_repair_case_info_array = YES;
            }
        }
        else {
            NSString *strErr = NSLocalizedString(@"DataManager_AlarmCaseErr", @"");
            //strErr = [strErr stringByAppendingString:json];
            [self BA_showAlert:strErr];
        }
    }
}

#pragma mark - user query
-(void) cwPostQueryUserData:(const char*)inBody Header:(const char*)inHeader withType:(const char*)type
{
    if (inBody == NULL && inHeader == NULL) {
        update_case_info_array = YES;
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        
        
        NSString *userID = [things_json objectForKey:@"id"];
        NSString *clientType = [things_json objectForKey:@"type"];
        id userDataResult = [things_json objectForKey:@"result"];
        if (userDataResult) {
            if (strcmp(type, "userQuery") == 0 || strcmp(type, "userDataQuery") == 0)  {
                id clientData = [userDataResult objectForKey:@"client"];
                if (clientData) {
                    NSString *strUserID = [clientData objectForKey:@"用户编号"];
                    UserDataModel *userDataModel = nil;
                    if (strcmp(type, "userDataQuery") == 0) {
                        if (self_query_user_data_array && [self_query_user_data_array count]) {
                            for (userDataModel in self_query_user_data_array) {
                                if (userDataModel && [userDataModel.userID isEqualToString:strUserID]) {
                                    break;
                                }
                            }
                        }
                    }
                    else if (strcmp(type, "userQuery") == 0) {
                        if (self_query_user_data_array && [self_query_user_data_array count]) {
                            [self_query_user_data_array removeAllObjects];
                        }
                    }
                    BOOL newNode = NO;
                    if (userDataModel == nil) {
                        newNode = YES;
                        userDataModel = [UserDataModel new];
                    }
                    userDataModel.id_ = userID;
                    userDataModel.clientType = clientType;
                    userDataModel.imageName = @"query_location";
                    userDataModel.userID = strUserID;
                    userDataModel.userName = [clientData objectForKey:@"名称"];
                    userDataModel.userAddr = [clientData objectForKey:@"地址"];
                    userDataModel.leaderName = [clientData objectForKey:@"负责人"];
                    userDataModel.leaderTel = [clientData objectForKey:@"负责人电话"];
                    userDataModel.leaderTel2 = [clientData objectForKey:@"负责人电话2"];
                    userDataModel.userTel = [clientData objectForKey:@"电话"];
                    userDataModel.userFax = [clientData objectForKey:@"传真"];
                    userDataModel.userArea = [clientData objectForKey:@"分局"];
                    userDataModel.mainTel = [clientData objectForKey:@"主机电话"];
                    userDataModel.mainType = [clientData objectForKey:@"主机类型"];
                    userDataModel.installTime = [clientData objectForKey:@"安装日期"];
                    userDataModel.finishTime = [clientData objectForKey:@"管理费终止日期"];
                    userDataModel.userLog = [[clientData objectForKey:@"经度"] floatValue];
                    userDataModel.userLat = [[clientData objectForKey:@"纬度"] floatValue];
                    
                    //zone
                    id zoneData = [userDataResult objectForKey:@"zone"];
                    if (zoneData) {
                        NSMutableArray *zoneArray = [NSMutableArray new];
                        for (id zone in zoneData) {
                            if (zone) {
                                ZoneDataModel *zoneModel = [ZoneDataModel new];
                                zoneModel.zoneNO = [zone objectForKey:@"防区号"];
                                zoneModel.zoneAddr = [zone objectForKey:@"防区位置"];
                                zoneModel.zoneType = [zone objectForKey:@"探头型号"];
                                zoneModel.installTime = [zone objectForKey:@"入网日期"];
                                [zoneArray addObject:zoneModel];
                            }
                        }
                        userDataModel.zoneDataArray = zoneArray;
                    }
                    //contact
                    id contactData = [userDataResult objectForKey:@"cont"];
                    if (contactData) {
                        NSMutableArray *contactArray = [NSMutableArray new];
                        for (id contact in contactData) {
                            if (contact) {
                                ContactDataModel *contactModel = [ContactDataModel new];
                                contactModel.contact = [[contact objectForKey:@"联系人序号"] integerValue];
                                contactModel.contactName = [contact objectForKey:@"姓名"];
                                contactModel.contactTel = [contact objectForKey:@"电话"];
                                contactModel.contactTel2 = [contact objectForKey:@"电话1"];
                                [contactArray addObject:contactModel];
                            }
                        }
                        userDataModel.contDataArray = contactArray;
                    }
                    
                    if (newNode) {
                        if (self_query_user_data_array == nil) {
                            self_query_user_data_array = [[NSMutableArray alloc] init];
                        }
                        //[self_query_user_data_array insertObject:userDataModel atIndex:0];
                        [self_query_user_data_array addObject:userDataModel];
                    }
                    if (self_query_user_data_array && [self_query_user_data_array count]) {
                        update_query_user_data_array = YES;
                    }
                }//client
                
                
            }
            else if (strcmp(type, "userFuzzyQuery") == 0) {
                if (self_query_user_data_array && [self_query_user_data_array count]) {
                    [self_query_user_data_array removeAllObjects];
                }
                for (id userData in userDataResult) {
                    UserDataModel *userDataModel = [[UserDataModel alloc] init];
                    userDataModel.id_ = userID;
                    userDataModel.clientType = clientType;
                    userDataModel.imageName = @"query_location";
                    userDataModel.userID = [userData objectForKey:@"用户编号"];
                    userDataModel.userName = [userData objectForKey:@"名称"];
                    userDataModel.userAddr = [userData objectForKey:@"地址"];
                    
                    if (self_query_user_data_array == nil) {
                        self_query_user_data_array = [[NSMutableArray alloc] init];
                    }
                    //[self_query_user_data_array insertObject:userDataModel atIndex:0];
                    [self_query_user_data_array addObject:userDataModel];
                    
                }
                if (self_query_user_data_array && [self_query_user_data_array count]) {
                    update_query_user_data_array = YES;
                }
            }
        }
    }
}

#pragma mark - user alarm query
-(void) cwPostQueryUserAlarmData:(const char*)inBody Header:(const char*)inHeader withType:(const char*)type
{
    if (inBody == NULL && inHeader == NULL) {
        _selfUserAlarmDataUpdate = YES;
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        NSString *userID = [things_json objectForKey:@"id"];
        NSString *clientType = [things_json objectForKey:@"type"];
        id userDataResult = [things_json objectForKey:@"result"];
        if (userDataResult) {
            if (_selfUserAlarmDataArray && [_selfUserAlarmDataArray count]) {
                [_selfUserAlarmDataArray removeAllObjects];
            }
            
            if ([userDataResult count] == 0) {
                _selfUserAlarmDataUpdate = YES;
                NSString *strErr = NSLocalizedString(@"DataManager_AlarmQueryErr", @"");
                [self BA_showAlert:strErr];
                return ;
            }
            
            for (id alarmData in userDataResult) {
                AlarmDataModel *alarmDataModel = [[AlarmDataModel alloc] init];
                alarmDataModel.alarmTime = [alarmData objectForKey:@"报警时间"];
                alarmDataModel.alarmContent = [alarmData objectForKey:@"报警详情"];
                alarmDataModel.alarmZone = [alarmData objectForKey:@"防区号/使用者号"];
                alarmDataModel.alarmTel = [alarmData objectForKey:@"来电号码"];
                
                if (_selfUserAlarmDataArray == nil) {
                    _selfUserAlarmDataArray = [[NSMutableArray alloc] init];
                }
                [_selfUserAlarmDataArray insertObject:alarmDataModel atIndex:0];
                
            }
            
            /*[_selfUserAlarmDataArray sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
                AlarmDataModel *alarm_obj_pre = (AlarmDataModel*)obj1;
                AlarmDataModel *alarm_obj_next = (AlarmDataModel*)obj2;
                
                return [alarm_obj_pre.alarmTime compare:alarm_obj_next.alarmTime];
            }];*/
            
            if (_selfUserAlarmDataArray && [_selfUserAlarmDataArray count]) {
                _selfUserAlarmDataUpdate = YES;
            }
        }
    }
}

#pragma mark - alarm near by
-(void) cwPostAlarmNearby:(const char *)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL) {
        _queryAlarmUserNearby = YES;
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        if (_queryAlarmUserNearbyArray && [_queryAlarmUserNearbyArray count] ) {
            [_queryAlarmUserNearbyArray removeAllObjects];
        }
        for (id alarmMan in things_json) {
            AlarmUserLocation *userLocation = [AlarmUserLocation new];
            userLocation.tid = [alarmMan objectForKey:@"tid"];
            userLocation.name = [alarmMan objectForKey:@"name"];
            userLocation.lon = [[alarmMan objectForKey:@"lon"] floatValue];
            userLocation.lat = [[alarmMan objectForKey:@"lat"] floatValue];
            userLocation.online = [[alarmMan objectForKey:@"online"] boolValue];
            userLocation.roles = [[NSString alloc] init];
            id userRoles = [alarmMan objectForKey:@"roles"];
            //NSArray *roleArray = [userRoles componentsSeparatedByString:@","];
            userLocation.roleType = 0;
            for (NSString *role in userRoles) {
                if ([role isEqualToString:@"worker"]) {
                    if ([userLocation.roles length] > 0) {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@",维修员"];
                        userLocation.roleType += 2;
                    }
                    else {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@"维修员"];
                        userLocation.roleType += 2;
                    }
                }
                else if ([role isEqualToString:@"guard"]){
                    if ([userLocation.roles length] > 0) {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@",保安员"];
                        userLocation.roleType += 1;
                    }
                    else {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@"保安员"];
                        userLocation.roleType += 1;
                    }
                }
            }
            
            if (_queryAlarmUserNearbyArray == nil) {
                _queryAlarmUserNearbyArray = [NSMutableArray new];
            }
            [_queryAlarmUserNearbyArray addObject:userLocation];
            NSLog(@"%@", userRoles);
        }
        _queryAlarmUserNearby = YES;
    }
}

#pragma mark - repair near by
-(void) cwPostRepairNearby:(const char *)inBody Header:(const char*)inHeader
{
    if (inBody == NULL && inHeader == NULL) {
        _queryRepairUserNearby = YES;
        return ;
    }
    NSError *error;
    NSString *json = [NSString stringWithUTF8String:inBody];
    NSLog(@"%@\r\n", json);
    NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
    NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
    if (things_json) {
        for (id repairMan in things_json) {
            RepairUserLocation *userLocation = [RepairUserLocation new];
            userLocation.tid = [repairMan objectForKey:@"tid"];
            userLocation.name = [repairMan objectForKey:@"name"];
            userLocation.lon = [[repairMan objectForKey:@"lon"] floatValue];
            userLocation.lat = [[repairMan objectForKey:@"lat"] floatValue];
            userLocation.online = [[repairMan objectForKey:@"online"] boolValue];
            userLocation.roles = [[NSString alloc] init];
            id userRoles = [repairMan objectForKey:@"roles"];
            //NSArray *roleArray = [userRoles componentsSeparatedByString:@","];
            for (NSString *role in userRoles) {
                if ([role isEqualToString:@"worker"]) {
                    if ([userLocation.roles length] > 0) {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@",维修员"];
                        userLocation.roleType += 2;
                    }
                    else {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@"维修员"];
                        userLocation.roleType += 2;
                    }
                }
                else if ([role isEqualToString:@"guard"]){
                    if ([userLocation.roles length] > 0) {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@",保安员"];
                        userLocation.roleType += 1;
                    }
                    else {
                        userLocation.roles = [userLocation.roles stringByAppendingString:@"保安员"];
                        userLocation.roleType += 1;
                    }
                }
            }
            NSLog(@"%@", userRoles);
        }
    }
}


- (void) setNavigationBar:(UINavigationBar*)navBar
{
    _navgationBar = navBar;
}

- (void) showToast:(NSString*)strText withTID:(NSString*)tid withType:(NSInteger)type
{
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    TYToastViewConfig *c = [TYToastViewConfig TYToastViewConfig:vc.view.frame.size.width height:50 mode:TYToastViewTop];
    [c setTid:tid];
    [c setType:type];
    c.textColor = [UIColor whiteColor];
    c.toastColor = [UIColor darkTextColor];
    [TYToastView showToastMsg:strText delay:5 config:c superView:_navgationBar];
    
    return ;
}

- (void) setSelectedSoundIndex:(NSInteger)selectedSoundIndex
{
    _selectedSoundIndex = selectedSoundIndex;
    
    [[NSUserDefaults standardUserDefaults] setInteger:selectedSoundIndex forKey:@"SelectedSoundIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) setPlaySoundName:(NSString *)playSoundName
{
    _playSoundName = playSoundName;
    [[NSUserDefaults standardUserDefaults] setObject:playSoundName forKey:@"setPlaySoundName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark CLLocationManagerDelegate<br>/* 获取经纬度 */
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currLocation=[locations lastObject];
    //locations.strLatitude=[NSString stringWithFormat:@"%f",currLocation.coordinate.latitude];
    //locations.strLongitude=[NSString stringWithFormat:@"%f",currLocation.coordinate.longitude];
    //CLLocation *myLocation = [CLLocation new];
    //CLLocation *earthLocation = [myLocation locationEarthFromMarsEx:currLocation.coordinate.latitude withLng:currLocation.coordinate.longitude];
    //NSLog(@"la---%f, lo---%f",earthLocation.coordinate.latitude,earthLocation.coordinate.longitude);
    char x_location[32] = {0};
    char y_location[32] = {0};
    sprintf(x_location, "%f", currLocation.coordinate.latitude);
    sprintf(y_location, "%f", currLocation.coordinate.longitude);
    _userLat = currLocation.coordinate.latitude;
    _userLon = currLocation.coordinate.longitude;
    
    [[CWThings4Interface sharedInstance] set_var_with_tid:NULL path:x_location sessions:NO value:y_location];
}

// 6.0 调用此函数
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"%@", @"ok");
}
/**
  *定位失败，回调此方法
  */
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if ([error code]==kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code]==kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}

#pragma makr -location settting
- (void)startSignificantChangeUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
    }
    
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
        [_locationManager startMonitoringSignificantLocationChanges];
    }
}

- (void) stopSignificantCahngeUpdates
{
    if (_locationManager) {
        [_locationManager  stopMonitoringSignificantLocationChanges];
    }
}

- (void)startStandardUpdates
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        if ([_locationManager respondsToSelector:@selector(allowsBackgroundLocationUpdates)]) {
            [_locationManager setAllowsBackgroundLocationUpdates:NO];
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        if (![CLLocationManager locationServicesEnabled]) {
            [self BA_showAlert:NSLocalizedString(@"DataManager_LocationErr", @"")];
            return;
        }
    }
    
    _openLocation = NO;
    //如果没有授权则请求用户授权
    if ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusNotDetermined){
        [_locationManager requestWhenInUseAuthorization];
    }
    
    if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse){
        //设置代理
        _locationManager.delegate=self;
        //设置定位精度
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance=50.0;//十米定位一次
        _locationManager.distanceFilter=distance;
        //启动跟踪定位
        [_locationManager startUpdatingLocation];
        [_locationManager setPausesLocationUpdatesAutomatically:YES];
        _openLocation = YES;
    }
}

- (void) stopStandardUpdates
{
    if (_locationManager) {
        [_locationManager stopUpdatingLocation];
    }
}


- (void) setIsCloseLocation:(BOOL)isCloseLocation
{
    _isCloseLocation = isCloseLocation;
    
    [[NSUserDefaults standardUserDefaults] setBool:isCloseLocation forKey:@"isCloseLocation"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    
    if (_isCloseLocation == NO) {
        [self startStandardUpdates];
        //[self startSignificantChangeUpdates];
    }
    else {
        [self stopStandardUpdates];
        //[self stopSignificantCahngeUpdates];
    }
}

- (void) setBindUID2Device:(BOOL)bindUID2Device
{
    _bindUID2Device = bindUID2Device;
    
    [[NSUserDefaults standardUserDefaults] setBool:bindUID2Device forKey:@"bindUID2Device"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Language handle
-(NSString*)currentLanguage
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLang = [languages objectAtIndex:0];
    return currentLang;
}

- (void) recognitionLanguage
{

    if([[self currentLanguage] compare:@"zh-Hans-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        _chineseConverterDictType = NCChineseConverterDictTypezh2CN;
    }else if ([[self currentLanguage] compare:@"zh-Hant-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        _chineseConverterDictType = NCChineseConverterDictTypezh2TW;
        NSLog(@"current Language == Chinese");
    }
    else if ([[self currentLanguage] compare:@"zh-HK" options:NSCaseInsensitiveSearch]==NSOrderedSame)
    {
        _chineseConverterDictType = NCChineseConverterDictTypezh2HK;
    }
    else if ([[self currentLanguage] compare:@"en-CN" options:NSCaseInsensitiveSearch]==NSOrderedSame){
        NSLog(@"current Language == English");
        _chineseConverterDictType = NCChineseConverterDictTypezh2EN;
    }
}

#pragma mark - Gesture Password
- (void) setIsOpenGesturePwd:(BOOL)isOpenGesturePwd
{
    _isOpenGesturePwd = isOpenGesturePwd;
    
    [[NSUserDefaults standardUserDefaults] setBool:isOpenGesturePwd forKey:@"isOpenGesturePwd"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) showGestureLockViewController
{
//    if (_isOpenGesturePwd == NO) return ;
//
//    _lockPasswordErrCount = 0;
//
//    JinnLockViewController *lockViewController = [[JinnLockViewController alloc] initWithType:JinnLockTypeVerify
//                                                                               appearMode:JinnLockAppearModePresent];
//    [lockViewController setDelegate:self];
//
//    PPRevealSideViewController *revealSideViewController = (PPRevealSideViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
//    UINavigationController *viewController = (UINavigationController*)[revealSideViewController rootViewController];
//    if (_isNavBarHidden == NO) {
//        //[viewController setNavigationBarHidden:YES];
//    }
//    //[viewController pushViewController:lockViewController animated:YES];
//    [viewController presentViewController:lockViewController animated:YES completion:nil];
}

#pragma mark - Gesture lock password

- (void)passwordDidVerify:(NSString *)oldPassword
{
    NSLog(@"密码验证成功:%@", oldPassword);
    //if (_isNavBarHidden == NO) {
        //PPRevealSideViewController *revealSideViewController = (PPRevealSideViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
        //UINavigationController *viewController = (UINavigationController*)[revealSideViewController rootViewController];
        //[viewController setNavigationBarHidden:NO];
    //}
}

- (void)passwordDidRemove
{
    NSLog(@"密码删除成功");
}

- (void)passwordDidError
{
    NSLog(@"密码验证失败");
    _lockPasswordErrCount++;
   
    [self BA_showAlert:NSLocalizedString(@"DataManager_PasswordErr", @"")];
    
        
    if (user_login_ok) {
        
//        TYAlertView *alertView = [TYAlertView alertViewWithTitle:NSLocalizedString(@"DataManager_PassAlertTitle", @"") message:NSLocalizedString(@"DataManager_PassAlertMessage", @"")];
//
//
//        // 弱引用alertView 否则 会循环引用
//        __typeof (alertView) __weak weakAlertView = alertView;
//        [alertView addAction:[TYAlertAction actionWithTitle:NSLocalizedString(@"DataManager_PassAlertOK", @"") style:TYAlertActionStyleDestructive handler:^(TYAlertAction *action) {
//
//            NSLog(@"%@",action.title);
//            for (UITextField *textField in weakAlertView.textFieldArray) {
//                NSLog(@"%@",textField.text);
//
//                if ([textField.text isEqualToString:_currentUserPassword]) {
//                    [self setIsOpenGesturePwd:NO];
//                    [JinnLockPassword removePassword];
//                    return YES;
//                }
//                return NO;
//            }
//            return NO;
//        }]];
//
//        [alertView addAction:[TYAlertAction actionWithTitle:NSLocalizedString(@"DataManager_PassAlertCancel", @"") style:TYAlertActionStyleCancle handler:^(TYAlertAction *action) {
//            exit(-1);
//            return YES;
//        }]];
//
//        /*[alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//         textField.placeholder = @"请输入账号";
//         }];*/
//        [alertView addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//            textField.placeholder = @"请输入密码";
//        }];
//
//        [alertView showInWindowWithOriginY:140 backgoundTapDismissEnable:NO];
    }
    else {
//        NSArray *user_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_user_array"];
//        NSMutableArray *login_user_info_array = [NSMutableArray arrayWithArray:user_array];
//
//
//        _isLostPassword = YES;
//        if (_isLostPassword == YES) {
//            for (NSInteger index = 0; index < [login_user_info_array count]; index++) {
//                NSData *data = [login_user_info_array objectAtIndex:index];
//                LoginUserInfo *user_info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//                user_info.login_user_pwd = @"";
//                NSData *savedata = [NSKeyedArchiver archivedDataWithRootObject:user_info];
//                [login_user_info_array setObject:savedata atIndexedSubscript:index];
//            }
//
//            NSArray * array = [NSArray arrayWithArray:login_user_info_array];
//            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"login_user_array"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
//
//        [self setIsOpenGesturePwd:NO];
//        [JinnLockPassword removePassword];
    }
}




@end

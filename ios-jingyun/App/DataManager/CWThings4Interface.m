//
//  CWThingsInterface.m
//  ThingsIOSClient
//
//  Created by yeung  on 14-3-28.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import "CWThings4Interface.h"
#import "CWDataManager.h"
#import "NSObject+BAProgressHUD.h"
//#import "JHNotificationManager.h"

@interface CWThings4Interface()
@end

@implementation CWThings4Interface
static CWThings4Interface *sharedInstance = nil;

+ (CWThings4Interface *) sharedInstance
{
	return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

-(BOOL) connect_to:(const char *)inConnectStr
{
    fConnectStatus = NO;
    fAutheStatus = NO;
    _isOldSystemVersion = NO;
    [CWThingsSDK set_delegate:self];
    return [CWThingsSDK connect_to:inConnectStr];
}

-(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd
{
    return [CWThingsSDK user_login:inUserName pass:inUserPwd];
}

-(BOOL) disconnect
{
    return [CWThingsSDK disconnect];;
}

-(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType
{
    return [CWThingsSDK push_msg:inMsg MsgLen:inMsgLen MsgType:inMsgType];
}

-(BOOL) request:(const char *)tid URL:(const char*)inURL UrlLen:(int)inUrlLen ReqID:(const char*)reqid
{
    return [CWThingsSDK request:tid  ReqID:reqid Url:inURL UrlLen:inUrlLen];
}

-(BOOL) requestEx:(const char *)tid URL:(const char*)inURL UrlLen:(int)inUrlLen ReqID:(const char*)reqid
{
    return [CWThingsSDK requestEx:tid  ReqID:reqid Url:inURL UrlLen:inUrlLen];
}

-(BOOL) response:(const char*)inSrc ReqID:(const char*)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody
{
    return [CWThingsSDK response:inSrc ReqID:inReqID Status:inStatus Header:inHeader Body:inBody];
}

-(BOOL) subscribe:(int) inType Reader:(const char *)inReader Filter:(const char *)inFilter
{
    return [CWThingsSDK subscribe:inReader Filter:inFilter];
}

-(void) cw_loop
{
    [CWThingsSDK cw_loop];
}

-(void) init_var_with_tid:(const char *)tid
{
    [CWThingsSDK init_var_with_tid:tid];
}

-(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session
{
    return [CWThingsSDK get_var_with_path:tid path:path sessions:session];
}

-(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath
{
    return [CWThingsSDK get_var_with_path_ex:tid prepath:ppath member:num backpath:bpath];
}

-(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value
{
    return [CWThingsSDK set_var_with_tid:tid path:path sessions:session value:value];
}

- (int)get_sync_with_things
{
    return [CWThingsSDK get_sync_with_things];
}

- (int)get_var_nodes_with_tid:(const char *)tid path:(const char *)path
{
    return [CWThingsSDK get_var_nodes_with_tid:tid path:path];
}

- (char*)get_var_with_thing:(int)member
{
    return [CWThingsSDK get_var_with_thing:member];
}

-(int) get_state
{
    return [CWThingsSDK get_state];
}

-(char *) get_things_sid
{
    return [CWThingsSDK get_things_sid];
}

-(void) set_login_delegate:(id)inDelegate
{
    fLoginDelegate = inDelegate;
}

-(void) set_data_delegate:(id)inDelegate
{
    fDataDelegate = inDelegate;
}

-(void) setResponseDelegate:(id)inDelegate{
    responseDelegate = inDelegate;
}

-(void) showText:(NSString*)text inView:(UIView*)aView Timer:(NSTimeInterval)timeInterval   
{
    /*if(notificationView_ == nil) {
        notificationView_ = [[GCDiscreetNotificationView alloc] initWithText:nil showActivity:YES inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:nil];
    }
    
    [notificationView_ showText:text inView:current_view_ Timer:timeInterval];*/
}

-(void) setCurrentView:(UIView*)aView
{
    current_view_ = aView;
}

- (UIViewController *)activityViewController
{
    UIViewController* activityViewController = nil;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if(window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow *tmpWin in windows)
        {
            if(tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    NSArray *viewsArray = [window subviews];
    if([viewsArray count] > 0)
    {
        UIView *frontView = [viewsArray objectAtIndex:0];
        
        id nextResponder = [frontView nextResponder];
        
        if([nextResponder isKindOfClass:[UIViewController class]])
        {
            activityViewController = nextResponder;
        }
        else
        {
            activityViewController = window.rootViewController;
        }
    }
    
    return activityViewController;
}

/**
 *  connect status
 *
 *  @param inConnected 1 for connect ok , 0 for connect fail
 */
-(void) on_things_connected:(int)inConnected
{
    fConnectStatus = inConnected;
    if (inConnected == 1) {
        if([fLoginDelegate respondsToSelector:@selector(cwTCPConnect:)])
            [fLoginDelegate cwTCPConnect:YES];
        
        if([fDataDelegate respondsToSelector:@selector(cwConnectEvent:)])
            [fDataDelegate cwConnectEvent:YES];
    }
    else {
        //if([fLoginDelegate respondsToSelector:@selector(cwTCPConnect:)])
        //    [fLoginDelegate cwTCPConnect:NO];
        if([fDataDelegate respondsToSelector:@selector(cwConnectEvent:)])
            [fDataDelegate cwConnectEvent:NO];
        NSString *str_err = [[NSString alloc] initWithFormat:NSLocalizedString(@"ThingsInterface_ConnectErr", @"")];
        [self showText:str_err inView:nil Timer:2.0];
        //[JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"连接服务器失败，请检查原因"]];
    }
    
}

-(void) on_things_authed:(int)inEventCode
{
    fAutheStatus = inEventCode;
    if (inEventCode == 1) {
        if([fLoginDelegate respondsToSelector:@selector(cwUserLogin:)])
            [fLoginDelegate cwUserLogin:YES];
        /*const char *pURL = "/get_profile";
        [CWThingsSDK request:"." ReqID:"1" Url:pURL UrlLen:(int)strlen(pURL)];
        
        const char *pServerInfo = "/get_server_info";
        [CWThingsSDK request:"." ReqID:"5" Url:pServerInfo UrlLen:(int)strlen(pServerInfo)];*/
        //const char *pParts = "/get_parts";
        //[CWThingsSDK request:"." ReqID:"4" Url:pParts UrlLen:(int)strlen(pParts)];
    }
    else {
        if([fLoginDelegate respondsToSelector:@selector(cwUserLogin:)])
            [fLoginDelegate cwUserLogin:NO];
        
        if([fDataDelegate respondsToSelector:@selector(cwLoginEvent:)])
            [fDataDelegate cwLoginEvent:NO];
        
        //[JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"登陆失败，可能是用户名、密码错误"]];
    }
}

-(void) on_things_sync_end
{
    const char *pURL = "/sys/get-profile";
    [CWThingsSDK request:"." ReqID:"getProfile" Url:pURL UrlLen:(int)strlen(pURL)];
    
    const char *pServerInfo = "/get_server_info";
    [CWThingsSDK request:"." ReqID:"getServerInfo" Url:pServerInfo UrlLen:(int)strlen(pServerInfo)];
    
    
#ifdef NO_USER_PUSH_NOTI
    NSString *token = [[CWDataManager sharedInstance] deviceToken];
    char sSetProfile[1024] = {0};
    sprintf(sSetProfile, "/user/set-profile?location=priv&key=apn-token&value=%s", [token UTF8String]);
    [CWThingsSDK request:"." ReqID:"userSetProfile" Url:sSetProfile UrlLen:(int)strlen(sSetProfile)];
#endif
}

-(void) on_things_need_update:(NSInteger)type withTID:(char*)tid
{
    if([fDataDelegate respondsToSelector:@selector(cwUpdateThingsList:withTID:)])
    {
        [fDataDelegate cwUpdateThingsList:type withTID:tid];
    }
}

-(void) on_things_post:(char*)from to:(char*)to readers:(const char*)inReaders Src:(const char*)inSrc Body:(const char*)inBody Type:(const char *)type
{
    if ([fDataDelegate respondsToSelector:@selector(cwPostEventData:Type:)]) {
        [fDataDelegate cwPostEventData:inBody Type:type];
    }
}
-(void) on_things_request:(char*)from to:(char*)to ID:(const char*)req_id URL:(char*)url
{
    
}
-(void) on_things_response:(const char*)inReqID Status:(int)inStatus Header:(char*) inHeader Body:(char*)inBody
{
    
    //以下两行，罗新增的语句，注册协议，以便数据解耦操作。
    if ([responseDelegate respondsToSelector:@selector(onThingsResponse:status:header:body:)]) {
        [responseDelegate onThingsResponse:inReqID status:inStatus header:inHeader body:inBody];
    }
    
    if (strcmp(inReqID, "getProfile") == 0) {
        if(inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostThingsList:Header:)])
        {
            [fDataDelegate cwPostThingsList:inBody Header:inHeader];
        }
        else
        {
            printf("request id : %u, status : %d, header : %s, body : %s\n", (unsigned int)inReqID, inStatus, inHeader, inBody);
    
            if (inStatus == 503) {
                _isOldSystemVersion = YES;
                [[CWDataManager sharedInstance] setIsOldSystemVersion:YES];
                const char *pURL = "/get_profile";
                [CWThingsSDK request:"." ReqID:"getProfile" Url:pURL UrlLen:(int)strlen(pURL)];
                
                const char *pServerInfo = "/get_server_info";
                [CWThingsSDK request:"." ReqID:"getServerInfo" Url:pServerInfo UrlLen:(int)strlen(pServerInfo)];
            }
            else {
                [fDataDelegate cwRequestError];
                NSString *str_err = [[NSString alloc] initWithFormat:@"%@:%d", NSLocalizedString(@"ThingsInterface_GetProfileErr", @""), inStatus];
                [self BA_showAlert:str_err];
                
                const char *pURL = "/sys/get-profile";
                [CWThingsSDK request:"." ReqID:"getProfile" Url:pURL UrlLen:(int)strlen(pURL)];
            }
            
        }
    }
    else if (strcmp(inReqID, "userSetProfile") == 0) {
        if (inStatus == 200) {
            
        }
        else {
            NSString *str_err = [[NSString alloc] initWithFormat:@"%@:%d", NSLocalizedString(@"ThingsInterface_SetProfileErr", @""), inStatus];
            [self BA_showAlert:str_err];
        }
    }
    else if (strcmp(inReqID, "messageLast") == 0) {
        if(inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostMsgList:Header:)])
        {
            [fDataDelegate cwPostMsgList:inBody Header:inHeader];
        }
        else
        {
            if (inStatus == 503) {
                _isOldSystemVersion = YES;
            }
            else {
                NSString *str_err = [[NSString alloc] initWithFormat:@"%@:%d", NSLocalizedString(@"ThingsInterface_MessageLastErr", @""), inStatus];
                [self BA_showAlert:str_err];
            }
        }
    }
    else if (strcmp(inReqID, "3") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostThingsInfo:)]) {
            [fDataDelegate cwPostThingsInfo:inBody];
        }
        else
        {
            [self BA_showAlert:@"获取数据失败"];
            [fDataDelegate cwRequestError];
            printf("request id : %u, status : %d, header : %s, body : %s\n", (unsigned int)inReqID, inStatus, inHeader, inBody);
        }
    }
    else if (strcmp(inReqID, "modifyPassword") == 0) {
        if (inStatus == 200) {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UpdatePassOK", @"")];
            
            UIAlertView * alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ThingsInterface_PassAlertTitle", @"") message:NSLocalizedString(@"ThingsInterface_PassAlertMessage", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ThingsInterface_PassAlertOK", @"") otherButtonTitles:nil, nil];
            [alertview show];
        }
        else
        {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UpdatePassErr", @"")];
        }
    }
    else if (strcmp(inReqID, "getServerInfo") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostServerInfo:)]) {
            [fDataDelegate cwPostServerInfo:inBody];
        }
        else
        {
            NSString *str_err = [[NSString alloc] initWithFormat:@"%@:%d", NSLocalizedString(@"ThingsInterface_GetServerInfo", @""), inStatus];
            [self BA_showAlert:str_err];
            [fDataDelegate cwRequestError];
            printf("request id : %u, status : %d, header : %s, body : %s\n", (unsigned int)inReqID, inStatus, inHeader, inBody);
            const char *pServerInfo = "/get_server_info";
            [CWThingsSDK request:"." ReqID:"getServerInfo" Url:pServerInfo UrlLen:(int)strlen(pServerInfo)];
        }
    }
    else if (strcmp(inReqID, "getRelayInfo") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostRelayServerInfo:)]) {
            [fDataDelegate cwPostRelayServerInfo:inBody];
        }
        else
        {
            if ([fDataDelegate respondsToSelector:@selector(cwPostRelayServerInfo:)]) {
                [fDataDelegate cwPostRelayServerInfo:NULL];
            }
            NSString *str_err = [[NSString alloc] initWithFormat:@"%@:%d", NSLocalizedString(@"ThingsInterface_GetReplayInfoErr", @""), inStatus];
            [self BA_showAlert:str_err];
        }
    }
    else if (strcmp(inReqID, "alarmTaskList") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostTaskInfo:Header:)]) {
            [fDataDelegate cwPostTaskInfo:inBody Header:inHeader];
        }
        else
        {
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_AlarmTaskListErr", @""), inStatus];
            [self BA_showAlert:strErr];
            if ([fDataDelegate respondsToSelector:@selector(cwPostTaskInfo:Header:)]) {
                [fDataDelegate cwPostTaskInfo:NULL Header:NULL];
            }
        }
    }
    else if (strcmp(inReqID, "taskHandle") == 0) {
        NSLog(@"%s", inBody);
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostRelayServerInfo:)]) {
            //[fDataDelegate cwPostTaskInfo:inBody Header:inHeader];
        }
        else
        {
            if ([fDataDelegate respondsToSelector:@selector(cwPostRelayServerInfo:)]) {
                [fDataDelegate cwPostRelayServerInfo:NULL];
            }
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_TaskHandleErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "alarmCaseGet") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostCaseInfo:Header:)]) {
            [fDataDelegate cwPostCaseInfo:inBody Header:inHeader];
        }
        else
        {
            [fDataDelegate cwPostCaseInfo:NULL Header:NULL];
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_AlarmCaseGetErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "troubleTaskList") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostRepairTaskInfo:Header:)]) {
            [fDataDelegate cwPostRepairTaskInfo:inBody Header:inHeader];
        }
        else
        {
            if ([fDataDelegate respondsToSelector:@selector(cwPostRepairTaskInfo:Header:)]) {
                [fDataDelegate cwPostRepairTaskInfo:NULL Header:NULL];
            }
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_TroubleTaskListErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "caseArrive") == 0) {
        if (inStatus == 200 ) {
            
        }
        else
        {
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_CaseArriveErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "caseNote") == 0) {
        if (inStatus == 200 ) {
            
        }
        else
        {
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_CaseNodeErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "repairCaseGet") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostRepairCaseInfo:Header:)]) {
            [fDataDelegate cwPostRepairCaseInfo:inBody Header:inHeader];
        }
        else
        {
            [fDataDelegate cwPostRepairCaseInfo:NULL Header:NULL];
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_RepairCaseGetErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "transferTask") == 0) {
        if (inStatus == 200 ) {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_TransferTaskOK", @"")];
        }
        else if (inStatus == 409)
        {
            NSError *error;
            NSData *things_info = [NSData dataWithBytes:inBody length:strlen(inBody)];
            NSDictionary *things_json  = [NSJSONSerialization JSONObjectWithData:things_info options:NSJSONReadingMutableLeaves error:&error];
            if (things_json) {
                //id result = [things_json objectForKey:@"result"];
                //if (result) {
                    NSInteger errCode = [[things_json objectForKey:@"code"] integerValue];
                    switch (errCode) {
                        case -1:
                            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_TransferTaskErr1", @"")];
                            break;
                        case -2:
                            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_TransferTaskErr2", @"")];
                            break;
                        case -3:
                            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_TransferTaskErr3", @"")];
                            break;
                        case -4:
                            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_TransferTaskErr4", @"")];
                            break;
                        default:
                            break;
                    }
                //}
            }
            //[self BA_showAlert:strErr];
            //[self BA_showAlert:@"对不起，不能给督察员转单"];
        }
        else
        {
            NSString *strErr = [[NSString alloc] initWithFormat:@"%@[%d]", NSLocalizedString(@"ThingsInterface_TransferTaskErr", @""), inStatus];
            [self BA_showAlert:strErr];
        }
    }
    else if (strcmp(inReqID, "userQuery") == 0 || strcmp(inReqID, "userDataQuery") == 0 || strcmp(inReqID, "userFuzzyQuery") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostQueryUserData:Header:withType:)]) {
            [fDataDelegate cwPostQueryUserData:inBody Header:inHeader withType:inReqID];
        }
        else
        {
            [fDataDelegate cwPostQueryUserData:NULL Header:NULL withType:inReqID];
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UserQueryErr", @"")];
        }
    }
    else if (strcmp(inReqID, "reportLocation") == 0) {
        if (inStatus == 200) {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_ReportLocationOK", @"")];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_ReportLocationErr", @"")];
        }
    }
    else if (strcmp(inReqID, "userAlarmQuery") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostQueryUserAlarmData:Header:withType:)]) {
            [fDataDelegate cwPostQueryUserAlarmData:inBody Header:inHeader withType:inReqID];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UserAlarmQueryErr", @"")];
        }
    }
    else if (strcmp(inReqID, "userDataReport") == 0) {
        if (inStatus == 200) {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UserDataReportOK", @"")];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UserDataReportErr", @"")];
        }
    }
    else if (strcmp(inReqID, "repairReport") == 0) {
        if (inStatus == 200) {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_RepairReportOK", @"")];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_RepairReportErr", @"")];
        }
    }
    else if (strcmp(inReqID, "sendPicture") == 0) {
        if (inStatus == 200) {
            
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_SendPictureErr", @"")];
        }
    }
    else if (strcmp(inReqID, "alamUserNearby") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostAlarmNearby:Header:)]) {
            [fDataDelegate cwPostAlarmNearby:inBody Header:inHeader];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_AlarmUserNearbyErr", @"")];
        }
    }
    else if (strcmp(inReqID, "repairUserNearby") == 0) {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostRepairNearby:Header:)]) {
            [fDataDelegate cwPostRepairNearby:inBody Header:inHeader];
        }
        else {
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_RepairUserNearbyErr", @"")];
        }
    }
    else {
        if (inStatus == 200 && [fDataDelegate respondsToSelector:@selector(cwPostThingsStatus:tid:)]) {
            [fDataDelegate cwPostThingsStatus:inBody tid:inReqID];
        }
        else
        {
            [fDataDelegate cwRequestError];
            [self BA_showAlert:NSLocalizedString(@"ThingsInterface_UnknowErr", @"")];
            printf("request id : %u, status : %d, header : %s, body : %s\n", (unsigned int)inReqID, inStatus, inHeader, inBody);
        }
    }
    /*else
    {
        printf("request id : %u, status : %d, header : %s, body : %s\n", (unsigned int)inReqID, inStatus, inHeader, inBody);
    }*/
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView.title isEqualToString:NSLocalizedString(@"ThingsInterface_EditPassword", @"")]) {
        
        NSArray *user_array = [[NSUserDefaults standardUserDefaults] objectForKey:@"login_user_array"];
        NSMutableArray *login_user_info_array = [NSMutableArray arrayWithArray:user_array];
        
        
        BOOL isModifyUserPwd = NO;
        LoginUserInfo *myUserInfo = [CWDataManager sharedInstance]->login_user_info;
        for (NSData *data in login_user_info_array)
        {
            LoginUserInfo *user_info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if ([user_info.login_user_name isEqualToString:[CWDataManager sharedInstance]->login_user_info.login_user_name]) {
                isModifyUserPwd = YES;
                break;
            }
        }
        
        if (isModifyUserPwd) {
            [login_user_info_array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSData *curData = (NSData*)obj;
                LoginUserInfo *userInfo = [NSKeyedUnarchiver unarchiveObjectWithData:curData];
                if ([userInfo.login_user_name isEqualToString:myUserInfo.login_user_name]) {
                    userInfo.login_user_pwd = [[CWDataManager sharedInstance] myNewUserPassword];
                    NSData *newUserData = [NSKeyedArchiver archivedDataWithRootObject:userInfo];
                    [login_user_info_array setObject:newUserData atIndexedSubscript:idx];
                }
            }];
            
            NSArray * array = [NSArray arrayWithArray:login_user_info_array];
            [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"login_user_array"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    
        exit(0);
    }
}

-(void) on_vars_change_callback:(const char*)tid status:(const char*)status
{
    if ([fDataDelegate respondsToSelector:@selector(on_vars_change_callback:status:)]) {
        [fDataDelegate on_vars_change_callback:tid status:status];
    }
}
@end

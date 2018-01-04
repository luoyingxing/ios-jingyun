//
//  CWThingsInterface.h
//  ThingsIOSClient
//
//  Created by yeung  on 14-3-28.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWThingsSDK.h"
#import "CWProtocalDefine.h"
#import "ThingsResponseDelegate.h"
//#import "GCDiscreetNotificationView.h"
#import <UIKit/UIKit.h>

@interface CWThings4Interface : NSObject<CWThingsDelegate>
{
@private
    BOOL            fConnectStatus;
    BOOL            fAutheStatus;
    id              fLoginDelegate;
    id              fDataDelegate;
    
    //request的请求回调，add by luoyingxing on 2017-12-20 16:18
    id<ThingsResponseDelegate> responseDelegate;
    
    //GCDiscreetNotificationView *notificationView_;
    
    
    UIView*             current_view_;
}

+ (CWThings4Interface *) sharedInstance;

-(BOOL) connect_to:(const char *)inConnectStr;
-(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd;
-(BOOL) disconnect;
-(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType;
-(BOOL) request:(const char *)tid URL:(const char*)inURL UrlLen:(int)inUrlLen ReqID:(const char*)reqid;
-(BOOL) requestEx:(const char *)tid URL:(const char*)inURL UrlLen:(int)inUrlLen ReqID:(const char*)reqid;
-(BOOL) response:(const char*)inSrc ReqID:(const char*)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody;
-(BOOL) subscribe:(int) inType Reader:(const char *)inReader Filter:(const char *)inFilter;

-(void) cw_loop;

-(void) init_var_with_tid:(const char *)tid;
-(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session;
-(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath;
-(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value;
- (int)get_sync_with_things;
- (int)get_var_nodes_with_tid:(const char *)tid path:(const char *)path;
- (char*)get_var_with_thing:(int)member;
-(int) get_state;
-(char *) get_things_sid;
-(void) set_login_delegate:(id)inDelegate;
-(void) set_data_delegate:(id)inDelegate;

-(void) showText:(NSString*)text inView:(UIView*)aView Timer:(NSTimeInterval)timeInterval;
-(void) setCurrentView:(UIView*)aView;

//setting Response Delegate
-(void) setResponseDelegate:(id)inDelegate;

@property (nonatomic, assign) BOOL isOldSystemVersion;
@end

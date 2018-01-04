//
//  CWThingsInterface.h
//  CWIOSClient
//
//  Created by yeung  on 14-3-26.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "common.h"
class Linux_socket;
class Things;

#define MAX_BUF_IN             5000000
#define MAX_BUF_OUT            5000000
#define CW_MTU                 1000


class CWRequestContext;

@interface CWThingsInterface : NSObject
{
    id              callback_delegate;
    NSThread        *handle_thread;
    
    BOOL            thread_run_flag;
@private
    Linux_socket    *linux_tcp_socket;
    Things          *cw_things;
    NSTimeInterval  cw_pre_time_second;
    
    NSMutableArray  *push_msg_packet_queue;
    NSLock          *push_msg_packet_lock;
    
    NSMutableArray  *request_msg_packet_queue;
    NSRecursiveLock          *request_msg_packet_lock;
    BOOL            isSendRequestMessage;
    int             lastRequestID;
    
    NSString        *cw_user_name;
    NSString        *cw_user_pwd;
    
    NSTimer         *timer;
    
    BOOL            login_ok_;
@public
    BOOL            start_sync_;
    
    BOOL            sync_ok_;
}
-(BOOL) connect_to:(const char *)inConnectStr;
-(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd;
-(void) set_delegate:(id)delegate;
-(BOOL) disconnect;
-(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType;
-(BOOL) request:(const char *)tid ReqID:(const char*)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen;
-(BOOL) requestEx:(const char *)tid ReqID:(const char*)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen;
-(BOOL) response:(const char*)inSrc ReqID:(const char*)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody;
-(BOOL) subscribe:(const char *)inReader Filter:(const char *)inFilter;
-(void) init_var_with_tid:(const char*)tid;
-(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session;
-(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath;
-(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value;
- (int)get_sync_with_things;
- (int) get_var_nodes_with_tid:(const char*)tid path:(const char *)path;
- (char*)get_var_with_thing:(int)member;
-(int) get_state;
-(char *) get_things_sid;
-(void) cw_handle_thread_func;


/**
 *  callback
 */
-(void) connect_callback:(int)inResult;
-(void) authed_callback:(int)inResult;
-(void) vars_change_callback;
-(void) on_things_sync_end;
-(void) on_things_need_update:(NSInteger)type withTID:(char*)tid;
-(void) request_callback:(char*)from to:(char*)to ID:(const char*)req_id URL:(char*)url;
-(void) post_callback:(char*)from to:(char*)to readers:(char*)inReaders source:(char*)inSrc body:(char*)body Type:(char*)type;
-(void) response_callback:(const char*)inReqID Status:(int)inStatus Header:(char*) inHeader Body:(char*)inBody withID:(int)reqID withMessageType:(int)type;

@property (nonatomic, assign) NSInteger             userLoginFlag;

@end

//
//  CWThingsInterface.m
//  CWIOSClient
//
//  Created by yeung  on 14-3-26.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import "CWThingsInterface.h"
#import "CWThingsSDK.h"
#import "conn_linux_socket.h"
#import "things.h"
#import "vsync.h"
#import "CWDataMgr.h"
#import "CWRequestContext.h"

#ifdef THINGS_DEBUG
void user_log(const char* fmt, ...) {
    char tmp[128]; // resulting string limited to 128 chars
    va_list args;
    va_start (args, fmt );
    vsnprintf(tmp, 128, fmt, args);
    va_end (args);
    printf("%s", tmp);
};
#endif

void on_things_connected(Things *this_t, void *data, void *context){
    CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)context;
    if (cw_things_interface != nil) {
        [cw_things_interface connect_callback:1];
    }
};

void on_things_authed(Things *this_t, void *data, void *context){
    T_AUTH *t_auth = (T_AUTH *)data;
    if (t_auth == NULL) return ;
    CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)context;
    if (cw_things_interface != nil) {
        [cw_things_interface authed_callback:t_auth->code];
    }
}

void on_things_event(Things *this_t, T_EVENT event, void *data, void *context) {
    if (this_t == NULL || context == NULL) {
        return ;
    }
    
    VAR_EVENT *ve = (VAR_EVENT*)data;
    CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)context;
    switch (event) {
        case E_CONNECTED :
            [cw_things_interface connect_callback:1];
            break;
        case E_AUTHED :
            [cw_things_interface authed_callback:1];
            break;
        case E_CONNECTING:
            break;
        case E_DISCONNECTED:
            [cw_things_interface connect_callback:2];
            break;
        case E_RESPAWN:
            break;
        case E_RESPAWNED:
            break;
        case E_NEED_RECONNECT:
            
            break;
        case E_AUTH_FAIL:
            [cw_things_interface authed_callback:2];
            break;
        case E_FOLLOWED_NEW:   // event = VAR_EVENT
            [cw_things_interface on_things_need_update:1 withTID:ve->tid];
            printf("\nfollowed new : tid = %s  path = %s\n", ve->tid, ve->path);
            break;
        case E_FOLLOWED_RESET: // event = VAR_EVENT
            [cw_things_interface on_things_need_update:3 withTID:ve->tid];
            printf("\nfollowed reset : tid = %s  path = %s\n", ve->tid, ve->path);
            //[cw_things_interface on_things_need_update];
            break;
        case E_FOLLOWED_BEFORE_UPDATE: // event = VAR_EVENT
        case E_FOLLOWED_AFTER_UPDATE: // event = VAR_EVENT
            printf("\nfollowed update : tid = %s  path = %s\n", ve->tid, ve->path);
            //[cw_things_interface on_things_need_update];
            //[cw_things_interface on_things_need_update:3 withTID:ve->tid];
            break;
        case E_FOLLOWED_LOST_SYNC: // event = VAR_EVENT
            printf("\nfollowed lost sync : tid = %s  path = %s\n", ve->tid, ve->path);
            break;
        case E_FOLLOWED_BEFORE_REMOVE: // event = VAR_EVENT
        case E_FOLLOWED_AFTER_REMOVE: // event = VAR_EVENT
            printf("\nfollowed remove : tid = %s  path = %s\n", ve->tid, ve->path);
            [cw_things_interface on_things_need_update:2 withTID:ve->tid];
            break;
        case E_FOLLOWED_BEFORE_START:
        case E_FOLLOWED_START:
            
            cw_things_interface->start_sync_ = YES;
            printf("\nfollowed start: count = %d\n", *(int*)data);
            break;
        case E_FOLLOWED_END: // event = VAR_EVENT
            printf("\nfollowed end \n");
            cw_things_interface->start_sync_ = NO;
            cw_things_interface->sync_ok_ = YES;
            [cw_things_interface on_things_sync_end];
            break;
            
        /*case E_FOLLOWED_UPDATE:     // event = VAR_EVENT
        {
            [cw_things_interface vars_change_callback];
            break;
        }*/
    }
}

void on_things_request(Things *this_t, void *data, void *context) {
    @try {
        T_REQUEST *t_req = (T_REQUEST *)data;
        if (t_req == NULL) return ;
        CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)context;
        if (cw_things_interface != nil) {
            [cw_things_interface request_callback:t_req->from to:t_req->to ID:0 URL:t_req->url];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"error");
    }
    @finally {
        NSLog(@"error");
    }
    
}

void on_things_post(Things *this_t, void *data, void *context) {
    T_POST *t_post = (T_POST*)data;
    if (t_post == NULL) return ;
    CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)context;
    if (cw_things_interface != nil) {
        [cw_things_interface post_callback:t_post->from to:t_post->to readers:t_post->readers source:t_post->src body:t_post->message Type:t_post->type];
    }
}

void on_things_response(Things *this_t, void *data, void *context){
    T_RESPONSE *t_res = (T_RESPONSE*)data;
    if (t_res == NULL) return ;
    CWRequestContext *cw_request_context = (CWRequestContext*)context;
    if (cw_request_context == NULL) {
        return ;
    }
    CWThingsInterface *cw_things_interface = (__bridge CWThingsInterface*)cw_request_context->GetUserData();
    if (cw_things_interface != nil) {
        [cw_things_interface response_callback:cw_request_context->GetRequestID() Status:t_res->status_code Header:t_res->header Body:t_res->body withID:t_res->req_id withMessageType:cw_request_context->GetMessageType()];
    }
    
    delete cw_request_context;
    cw_request_context = NULL;
}

void on_var_change_callback(TObject *value, void *context)
{
    if (value == NULL || context == NULL) {
        return ;
    }
}

CWThingsInterface *g_things_interface = nil;
void MySignalHandler(int signal)
{
    if (g_things_interface != nil) {
        [g_things_interface connect_callback:2];
    }
}

@implementation CWThingsInterface
-(BOOL) connect_to:(const char *)inConnectStr
{
    /*struct sigaction sa;
    struct sigaction osa;
    sa.sa_handler = MySignalHandler;
    sigaction(SIGPIPE, &sa, &osa);*/
    //signal(SIGFPE, MySignalHandler);
    signal(SIGPIPE, MySignalHandler);
    
    g_things_interface = self;
    
    BOOL bRet = NO;
    _userLoginFlag = 0;
    isSendRequestMessage = YES;
    lastRequestID = -1;
    
    login_ok_ = NO;
    start_sync_ = NO;
    sync_ok_ = NO;
    
    if (timer) {
        [timer invalidate];
    }
    
    if (push_msg_packet_queue == nil) {
        push_msg_packet_queue = [[NSMutableArray alloc] init];
    }
    
    if (push_msg_packet_lock == nil) {
        push_msg_packet_lock = [[NSLock alloc] init];
    }
    
    if (request_msg_packet_queue == nil) {
        request_msg_packet_queue = [[NSMutableArray alloc] init];
    }
    
    if (request_msg_packet_lock == nil) {
        request_msg_packet_lock = [[NSRecursiveLock alloc] init];
    }
    
    cw_pre_time_second = 0;
    [self disconnect];
    
    
    
    
    if(cw_things != NULL)
    {
        delete cw_things;
        cw_things = NULL;
    }
    
    if(linux_tcp_socket != NULL)
    {
        delete linux_tcp_socket;
        linux_tcp_socket = NULL;
    }
    linux_tcp_socket = new Linux_socket();
    
    cw_things = new Things(linux_tcp_socket, MAX_BUF_IN, MAX_BUF_OUT, CW_MTU);
    
    //printf("size of Things structure : %d\n", (int)sizeof(Things));
    //printf("size of connection structure : %d\n", (int)sizeof(Linux_socket));
    
    cw_things->on(ON_EVENT, on_things_event, (__bridge void*)self);
    //cw_things->on(ON_AUTH, on_things_authed, (__bridge void*)self);
    cw_things->on(ON_REQUEST, on_things_request, (__bridge void*)self);
    cw_things->on(ON_POST, on_things_post, (__bridge void*)self);
    
#ifdef THINGS_DEBUG
    cw_things->log             = &user_log;
#endif
    
    cw_things->connect_to(inConnectStr);
    
#ifdef USER_THREAD_
    handle_thread = [[NSThread alloc] initWithTarget:self selector:@selector(cw_handle_thread_func) object:nil];
    thread_run_flag = NO;
    [handle_thread start];
#else
    
    float palFrame = 0.001;
    timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(cw_handle_thread_func) userInfo:nil repeats:YES];
#endif
    return bRet;
}

-(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd
{
    NSString *user_name = [inUserName stringByTrimmingCharactersInSet:
                                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *user_pwd = [inUserPwd stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    cw_user_name = [[NSString alloc] initWithString:user_name];
    cw_user_pwd = [[NSString alloc] initWithString:user_pwd];
    return NO;
}

-(void) set_delegate:(id)delegate
{
    callback_delegate = delegate;
}

-(BOOL) disconnect
{
    BOOL bRet = NO;
    thread_run_flag = NO;
#ifdef USER_THREAD_
    if ([[NSThread currentThread] isCancelled])
    {
        [NSThread exit];
    }
#else
    [timer invalidate];
    timer = nil;
#endif
    
    return bRet;
}

-(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType
{
    [push_msg_packet_lock lock];
    CWDataMgr *pDataMgr = [[CWDataMgr alloc] init];
    if (pDataMgr) {
        //NSLog(@"push message : %d, data len : %d\r\n", (int)pDataMgr, inMsgLen);
        [pDataMgr initWithStream:inMsg StreamLen:strlen(inMsg) DataType:1 MsgType:inMsgType];
        [push_msg_packet_queue addObject:pDataMgr];
    }
    
    //
    [push_msg_packet_lock unlock];
    return YES;
}

-(BOOL) request:(const char *)tid ReqID:(const char*)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen
{
    [push_msg_packet_lock lock];
    CWDataMgr *pDataMgr = [[CWDataMgr alloc] init];
    [pDataMgr initWithStream:inURL StreamLen:inUrlLen DataType:2 MsgType:tid];
    [pDataMgr setRequestID:inReqID];
    [push_msg_packet_queue addObject:pDataMgr];
    [push_msg_packet_lock unlock];
    return YES;
}

-(BOOL) requestEx:(const char *)tid ReqID:(const char*)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen
{
    [request_msg_packet_lock lock];
    CWDataMgr *pDataMgr = [[CWDataMgr alloc] init];
    [pDataMgr initWithStream:inURL StreamLen:inUrlLen DataType:2 MsgType:tid];
    [pDataMgr setRequestID:inReqID];
    //[request_msg_packet_queue addObject:pDataMgr];
    [request_msg_packet_queue insertObject:pDataMgr atIndex:[request_msg_packet_queue count]];
    [request_msg_packet_lock unlock];
    return YES;
}

-(BOOL) response:(const char*)inSrc ReqID:(const char*)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody
{
    [push_msg_packet_lock lock];
    CWDataMgr *pDataMgr = [[CWDataMgr alloc] init];
    [pDataMgr initWithStream:inBody StreamLen:(UInt32)strlen(inBody) DataType:3 MsgType:""];
    [pDataMgr setSource:inSrc];
    [pDataMgr setRequestID:inReqID];
    [pDataMgr setStatus:inStatus];
    [push_msg_packet_queue addObject:pDataMgr];
    [push_msg_packet_lock unlock];
    return YES;
}

-(BOOL) subscribe:(const char *)inReader Filter:(const char *)inFilter
{
        return NO;
}

-(void) init_var_with_tid:(const char*)tid
{
    return ;
    TObject *sync_thing = cw_things->sync_var()->sync_with(tid);
    if (sync_thing) {
        //TObject *sync_panel_status = sync_thing->get_by_path("pnl.r");
        /*if (sync_thing) {
            sync_thing->on(T_ON_AFTER_CHANGE, &on_var_change_callback, (void*)tid);
        }*/
    }
}

-(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session
{
    //if tid is NULL, return self tid
    if (tid && strlen(tid) == 0) {
        return cw_things->tid;
    }
    
    if (tid == NULL) {
        TObject *thing = cw_things->sync_var()->root;
        if (thing) {
            return thing->to_string();
            TObject *sub_node = thing->member(path, BY_PATH);
            if (sub_node) {
                return sub_node->to_string();
            }
        }
        return NULL;
    }
    
    TObject *thing = cw_things->sync_var(tid);
    if (thing) {
        if (path != NULL) {
            //char *things_str = thing->to_string();
            //NSString *str = [NSString stringWithUTF8String:things_str];
            
            if (session) {
                TObject *sessions_node = thing->member("sessions", BY_PATH);
                if (sessions_node) {
                    if (sessions_node->member_count() > 0) {
                        TObject *sub_node = sessions_node->member(0);
                        if (sub_node) {
                            //for vars
                            if (sub_node->member("vars", BY_PATH)) {
                                TObject *path_node = sub_node->member("vars", BY_PATH)->member(path, BY_PATH);
                                if (path_node) {
                                    return path_node->to_string();
                                }
                            }
                            //for runtime
                            else if (sub_node->member("runtime", BY_PATH)) {
                                TObject *path_node = sub_node->member("runtime", BY_PATH)->member(path, BY_PATH);
                                if (path_node) {
                                    return path_node->to_string();
                                }
                                else {
                                    TObject *path_node = sub_node->member(path, BY_PATH);
                                    if (path_node) {
                                        return path_node->to_string();
                                    }
                                }
                            }
                            
                            return NULL;
                        }
                        return NULL;
                    }
                }
                return NULL;
            }
            else {
                TObject *sub_node = thing->member(path, BY_PATH);
                if (sub_node) {
                    return sub_node->to_string();
                }
            }
        }
        else {//if path is NULL, return all¥
            return thing->to_string();
        }
    }
    return NULL;
}

-(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath
{
    //if tid is NULL, return self tid
    if (tid == NULL || strlen(tid) == 0) {
        return cw_things->tid;
    }
    
    TObject *thing = cw_things->sync_var(tid);
    if (thing) {
        if (ppath != NULL) {
            TObject *sessions_node = thing->member("sessions", BY_PATH);
            if (sessions_node) {
                if (sessions_node->member_count() > 0) {
                    TObject *sub_node = sessions_node->member(0);
                    if (sub_node) {
                        //for vars
                        if (sub_node->member("vars", BY_PATH)) {
                            TObject *path_node = sub_node->member("vars", BY_PATH)->member(ppath, BY_PATH);
                            if (path_node) {
                                if (bpath == NULL) {
                                    return path_node->member_name(num);
                                }
                                else {
                                    TObject *member_node = path_node->member(num);
                                    if (member_node) {
                                        
                                        
                                        TObject *target_node = member_node->member(bpath, BY_PATH);
                                        if (target_node) {
                                            return target_node->to_string();
                                        }
                                        
                                    }
                                }
                            }
                        }
                        //for runtime
                        else if (sub_node->member("runtime", BY_PATH)) {
                            TObject *path_node = sub_node->member("runtime", BY_PATH)->member(ppath, BY_PATH);
                            if (path_node) {
                                if (bpath == NULL) {
                                    return path_node->member_name(num);
                                }else {
                                    TObject *member_node = path_node->member(num);
                                    if (member_node) {
                                        
                                        TObject *target_node = member_node->member(bpath, BY_PATH);
                                        if (target_node) {
                                            return target_node->to_string();
                                        }
                                    }
                                }
                            }
                        }
                        return NULL;
                    }
                    return NULL;
                }
            }
            return NULL;
        }
        else {//if path is NULL, return all¥
            return thing->to_string();
        }
    }
    return NULL;
}

-(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value
{
    if (tid == NULL || strlen(tid) == 0) {
        TObject *runtime_ = cw_things->vars();
        if (runtime_) {
            TObject* t_location = new TObject();
            TObject* x_location = new TObject(path);
            TObject* y_location = new TObject(value);
            t_location->set("lat", x_location);
            t_location->set("lon", y_location);
            
            runtime_->set("geo", t_location);
        }
        return NO;
    }
    
    TObject *thing = cw_things->sync_var(tid);
    if (thing) {
        if (path != NULL) {
            if (session) {
                TObject *sessions_node = thing->member("sessions", BY_PATH);
                if (sessions_node) {
                    if (sessions_node->member_count() > 0) {
                        TObject *sub_node = sessions_node->member(0);
                        if (sub_node) {
                            if (sub_node->member("vars", BY_PATH)) {
                                TObject *path_node = sub_node->member("vars", BY_PATH)->member(path, BY_PATH);
                                if (path_node) {
                                    path_node->set(value);
                                    return YES;
                                }
                            }
                            else if (sub_node->member("runtime", BY_PATH)) {
                                TObject *path_node = sub_node->member("runtime", BY_PATH)->member(path, BY_PATH);
                                if (path_node) {
                                    path_node->set(value);
                                    return YES;
                                }
                            }
                            
                            return NO;
                        }
                        return NO;
                    }
                }
                return NO;
            }
            else {
                TObject *sub_node = thing->member(path, BY_PATH);
                if (sub_node) {
                    sub_node->set(value);
                    return YES;
                }
            }
        }
    }
    else {
        
    }
    
    return NO;
}

- (int)get_sync_with_things
{
    if (cw_things) {
        VSync *sync_var = cw_things->sync_var();
        if (sync_var && sync_var->root) {
            return sync_var->root->member_count();
        }
    }
    return 0;
}

- (int) get_var_nodes_with_tid:(const char*)tid path:(const char *)path
{
    if (tid == NULL || strlen(tid) == 0) {
        return NO;
    }
    
    TObject *thing = cw_things->sync_var(tid);
    if (thing) {
        if (path != NULL) {
            TObject *node_sessions = thing->member("sessions", BY_PATH);
            if (node_sessions) {
                if (node_sessions->member_count()) {
                    TObject *session = node_sessions->member(0);
                    if (session) {
                        if (session->member("vars", BY_PATH)) {
                            TObject * node_things = session->member("vars", BY_PATH)->member(path, BY_PATH);
                            if (node_things) {
                                return node_things->member_count();
                            }
                        }
                        else if (session->member("runtime", BY_PATH)) {
                            TObject * node_things = session->member("runtime", BY_PATH)->member(path, BY_PATH);
                            if (node_things) {
                                return node_things->member_count();
                            }
                        }
                    }
                }
            }
            
        }
    }
    return 0;
}

- (char*)get_var_with_thing:(int)member
{
    if (cw_things) {
        VSync *sync_var = cw_things->sync_var();
        if (sync_var && sync_var->root) {
            TObject *current_thing = sync_var->root->member(member);
            if (current_thing) {
                TObject *t_tid = current_thing->member("tid", BY_PATH);
                if (t_tid) {
                    return t_tid->to_string();
                }
            }
        }
    }
    return NULL;
}

-(int) get_state
{
    if (_userLoginFlag == 2) {
        return -8;
    }
    return cw_things->state();
}

-(char *) get_things_sid
{
    return cw_things->sid;
}

-(BOOL) handle_msg
{
    //for push message
    [push_msg_packet_lock lock];
    if( [push_msg_packet_queue count] > 0)
    {
        CWDataMgr *pStreamData = [push_msg_packet_queue objectAtIndex:0];
        if ([pStreamData getDataType] == 1) {//for push
            cw_things->push(".", [pStreamData getMessageType], [pStreamData getStreamData]);
        }
        else if ([pStreamData getDataType] == 2) {//for request
            CWRequestContext *pRequestContext = new CWRequestContext();
            assert(pRequestContext != NULL);
            pRequestContext->Initialize((__bridge void*)self, [pStreamData getRequestID], 1);
            int ret = cw_things->request([pStreamData getMessageType], [pStreamData getStreamData], &on_things_response, (void*)pRequestContext);
            if (ret == -1) {
                //[pStreamData UninitStream];
                [push_msg_packet_lock unlock];
                return NO;
            }
        }
        else if ([pStreamData getDataType] == 3) {//for response
            cw_things->response([pStreamData getSource], 0, [pStreamData getStatus], NULL, [pStreamData getStreamData]);
        }
        [pStreamData UninitStream];
        pStreamData = nil;
        [push_msg_packet_queue removeObjectAtIndex:0];
    }
    [push_msg_packet_lock unlock];
    
    //for request message
    [request_msg_packet_lock lock];
    if( [request_msg_packet_queue count] > 0 && isSendRequestMessage == YES)
    {
        CWDataMgr *pStreamData = [request_msg_packet_queue objectAtIndex:0];
        if ([pStreamData getDataType] == 2) {//for request
            CWRequestContext *pRequestContext = new CWRequestContext();
            assert(pRequestContext != NULL);
            
            pRequestContext->Initialize((__bridge void*)self, [pStreamData getRequestID], 100);
            
            lastRequestID = cw_things->request([pStreamData getMessageType], [pStreamData getStreamData], &on_things_response, (void*)pRequestContext);
            if (lastRequestID == -1) {
                [push_msg_packet_lock unlock];
                return NO;
            }
            isSendRequestMessage = NO;
            [request_msg_packet_lock unlock];
            return YES;//等待数据返回，再删除该节点数据
        }
    }
    [request_msg_packet_lock unlock];
    
    return YES;
}

/**
 *  thread for things
 */
-(void) cw_handle_thread_func
{
    /*if(linux_tcp_socket != NULL)
    {
        delete linux_tcp_socket;
        linux_tcp_socket = NULL;
    }
    linux_tcp_socket = new Linux_socket();
    
    if(cw_things != NULL)
    {
        delete cw_things;
        cw_things = NULL;
    }
    cw_things = new Things(linux_tcp_socket, MAX_BUF_IN, MAX_BUF_OUT, CW_MTU);
    
    //printf("size of Things structure : %d\n", (int)sizeof(Things));
    //printf("size of connection structure : %d\n", (int)sizeof(Linux_socket));
    
    cw_things->on(ON_CONNECTED, (void*)&on_things_connected, (__bridge void*)self);
    cw_things->on(ON_AUTH, (void*)&on_things_authed, (__bridge void*)self);
    cw_things->on(ON_REQUEST, (void*)&on_things_request, (__bridge void*)self);
    cw_things->on(ON_POST, (void*)&on_things_post, (__bridge void*)self);
    
#ifdef THINGS_DEBUG
    cw_things->log             = &user_log;
#endif
    
    cw_things->connect_to("host:us.thingscloud.cn;port:8008");*/
    
    thread_run_flag = YES;
#ifdef USER_THREAD_
    while (thread_run_flag) {
        if (cw_things == nil) {
            sleep(2);
            continue;
        }
#endif
        NSDate *date = [NSDate date];
        NSTimeInterval curSecond = [date timeIntervalSince1970];
        if(cw_pre_time_second == 0)
        {
            cw_pre_time_second = curSecond;
        }
        
        if ((curSecond - cw_pre_time_second) >= 1) {
            cw_pre_time_second = curSecond;
            cw_things->time_tick();
            
        }
        
        //get msg from queue and send it to server
        [self handle_msg];
        cw_things->loop();
        if (cw_things->idle) {
            usleep(50*10);
        }
        else {
            usleep(10);
        }
#ifdef USER_THREAD_
    }
#endif
    
}

-(void) connect_callback:(int)inResult
{
    if([callback_delegate respondsToSelector:@selector(on_things_connected:)])
        [callback_delegate on_things_connected:inResult];
    if (cw_things != nil && inResult == 1) {
        if (login_ok_ == NO) {
            const char *pUserName = [cw_user_name cStringUsingEncoding:NSUTF8StringEncoding];
            const char *pUserPwd = [cw_user_pwd cStringUsingEncoding:NSUTF8StringEncoding];
            cw_things->login(pUserName, pUserPwd);
            login_ok_ = YES;
        }
    }
    else if (inResult == 2) {
        login_ok_ = NO;
        
    }
}

-(void) authed_callback:(int)inResult
{
    //if (cw_things != nil && inResult == 1)
    //    cw_things->subscribe("1", "(type=='json') &&  (event == 'test')");
    if (inResult == 1) {
        _userLoginFlag = 1;
    }
    else if (inResult == 2) {
        _userLoginFlag = 2;
    }
    sync_ok_ = NO;
    if([callback_delegate respondsToSelector:@selector(on_things_authed:)])
        [callback_delegate on_things_authed:inResult];
}

-(void) vars_change_callback
{
    if ([callback_delegate respondsToSelector:@selector(on_vars_change_callback:status:)]) {
        [callback_delegate on_vars_change_callback:NULL status:NULL];
    }
}

-(void) on_things_sync_end
{
    if ([callback_delegate respondsToSelector:@selector(on_things_sync_end)]) {
        [callback_delegate on_things_sync_end];
    }
}

-(void) on_things_need_update:(NSInteger)type withTID:(char*)tid
{
    if (sync_ok_ == NO) {
        return;
    }
    if ([callback_delegate respondsToSelector:@selector(on_things_need_update:withTID:)]) {
        [callback_delegate on_things_need_update:type withTID:tid];
    }
}

-(void) request_callback:(char*)from to:(char*)to ID:(const char*)req_id URL:(char*)url
{
    if([callback_delegate respondsToSelector:@selector(on_things_request:to:ID:URL:)])
        [callback_delegate on_things_request:from to:to ID:req_id URL:url];
}

-(void)post_callback:(char*)from to:(char*)to readers:(char*)inReaders source:(char*)inSrc body:(char*)body Type:(char *)type
{
    //NSLog(@"post callback .......\n");
    printf("post message from[%s] (%s) for: %s\n", inSrc, inReaders, body);
    if([callback_delegate respondsToSelector:@selector(on_things_post:to:readers:Src:Body:Type:)])
        [callback_delegate on_things_post:from to:to readers:inReaders Src:inSrc Body:body Type:type];
}

-(void) response_callback:(const char*)inReqID Status:(int)inStatus Header:(char*) inHeader Body:(char*)inBody withID:(int)reqID withMessageType:(int)type
{
    BOOL handleOK = NO;
    [request_msg_packet_lock lock];
    if(type == 100  && [request_msg_packet_queue count] > 0 )
    {
        CWDataMgr *pStreamData = [request_msg_packet_queue objectAtIndex:0];
        if (inStatus == 200 && lastRequestID == reqID) {
            if ([pStreamData getDataType] == 2) {//for request
                [pStreamData UninitStream];
                pStreamData = nil;
                
                [request_msg_packet_queue removeObjectAtIndex:0];
                handleOK = YES;
            }
            else if ([pStreamData getDataType] == 3) {//for response
                [pStreamData UninitStream];
                pStreamData = nil;
                
                [request_msg_packet_queue removeObjectAtIndex:0];
            }
        }
        else {
            if ([pStreamData getErrCount] > 5) {
                [pStreamData UninitStream];
                pStreamData = nil;
                
                [request_msg_packet_queue removeObjectAtIndex:0];
            }
            else {
                [pStreamData addErrCount];
            }
        }
        isSendRequestMessage = YES;
    }
    [request_msg_packet_lock unlock];
    
    if (handleOK == YES && type == 100) {
        if ([callback_delegate respondsToSelector:@selector(on_things_response:Status:Header:Body:)]) {
            [callback_delegate on_things_response:inReqID Status:inStatus Header:inHeader Body:inBody];
        }
    }
    else if (type != 100){
        if ([callback_delegate respondsToSelector:@selector(on_things_response:Status:Header:Body:)]) {
            [callback_delegate on_things_response:inReqID Status:inStatus Header:inHeader Body:inBody];
        }
    }
}

@end

//
//  CWThingsSDK.m
//  CWThingsSDK
//
//  Created by yeung  on 14-3-26.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import "CWThingsSDK.h"
#import "CWThingsInterface.h"

CWThingsInterface *g_CWThingsInterface = nil;

@implementation CWThingsSDK
+(BOOL) connect_to:(const char *)inConnectStr
{
    BOOL bRet = NO;
    if (g_CWThingsInterface == nil) {
        g_CWThingsInterface = [[CWThingsInterface alloc] init];
    }
    
    bRet = [g_CWThingsInterface connect_to:inConnectStr];
    return bRet;
}

+(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd
{
    if (g_CWThingsInterface == nil) {
        g_CWThingsInterface = [[CWThingsInterface alloc] init];
    }
    return [g_CWThingsInterface user_login:inUserName pass:inUserPwd];
}

+(void) set_delegate:(id)inDelegate
{
    if (g_CWThingsInterface == nil) {
        g_CWThingsInterface = [[CWThingsInterface alloc] init];
    }
    [g_CWThingsInterface set_delegate:inDelegate];
}

+(BOOL) disconnect
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface disconnect];
}

+(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface push_msg:inMsg MsgLen:inMsgLen MsgType:inMsgType];
}

+(BOOL) request:(const char *)tid ReqID:(const char *)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface request: tid ReqID:inReqID Url:inURL UrlLen:inUrlLen];
}

+(BOOL) requestEx:(const char *)tid ReqID:(const char *)inReqID Url:(const char *)inURL UrlLen:(int)inUrlLen
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface requestEx: tid ReqID:inReqID Url:inURL UrlLen:inUrlLen];
}

+(BOOL) response:(const char*)inSrc ReqID:(const char *)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface response:inSrc ReqID:inReqID Status:inStatus Header:inHeader Body:inBody];
}

+(BOOL) subscribe:(const char *)inReader Filter:(const char *)inFilter
{
    if (g_CWThingsInterface == nil) {
        return NO;
    }
    return [g_CWThingsInterface subscribe:inReader Filter:inFilter];
}

+(void) init_var_with_tid:(const char *)tid
{
    if (g_CWThingsInterface == nil) {
        return;
    }
    return [g_CWThingsInterface init_var_with_tid:tid];
}

+(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session
{
    if (g_CWThingsInterface == nil) {
        return NULL;
    }
    return [g_CWThingsInterface get_var_with_path:tid path:path sessions:session];
}

+(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath
{
    if (g_CWThingsInterface == nil) {
        return NULL;
    }
    return [g_CWThingsInterface get_var_with_path_ex:tid prepath:ppath member:num backpath:bpath];
}

+(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value
{
    if (g_CWThingsInterface == nil) {
        return NULL;
    }
    return [g_CWThingsInterface set_var_with_tid:tid path:path sessions:session value:value];
}

+(int)get_sync_with_things
{
    if (g_CWThingsInterface == nil) {
        return NULL;
    }
    return [g_CWThingsInterface get_sync_with_things];
}

+(int)get_var_nodes_with_tid:(const char *)tid path:(const char *)path
{
    if (g_CWThingsInterface == nil ) {
        return 0;
    }
    
    return [g_CWThingsInterface get_var_nodes_with_tid:tid path:path];
}

+(char*)get_var_with_thing:(int)member
{
    if (g_CWThingsInterface == nil) {
        return NULL;
    }
    return [g_CWThingsInterface get_var_with_thing:member];
}

+(int) get_state
{
    return [g_CWThingsInterface get_state];
}

+(char*)get_things_sid
{
    return [g_CWThingsInterface get_things_sid];
}

+(void) cw_loop
{
    if (g_CWThingsInterface == nil) {
        return ;
    }
    [g_CWThingsInterface cw_handle_thread_func];
}
@end


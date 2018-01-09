//
//  CWThingsSDK.h
//  CWThingsSDK
//
//  Created by yeung  on 14-3-26.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "common.h"
/**
 *  callback define
 */
@protocol CWThingsDelegate <NSObject>
/*  说明：连接回调
 参数：
 inConnected（IN），1 表示连接成功，2表示连接失败
 */
-(void) on_things_connected:(int)inConnected;

/*  说明：用户认证回调
 参数：
 inConnected（IN），1 表示认证成功，1表示认证失败
 */
-(void) on_things_authed:(int)inEventCode;

/*  说明：变量同叔结束回调
 参数：
 
 */
-(void) on_things_sync_end;

/*  说明：node节点需要更新回调
 参数：type = 1,表示增加，2表示删除，3表示更新
 
 */
-(void) on_things_need_update:(NSInteger)type withTID:(char*)tid;

/*  说明：消息回调接口，包括事件、消息等
 参数：
 from(IN):       表示来自哪个节点
 to(IN):         表示发送给谁
 inReaders(IN):
 inSrc(IN)
 inBody(IN):     消息、事件内容，具体见通信协议
 type(IN):       im/e等等
 */
-(void) on_things_post:(char*)from to:(char*)to readers:(const char*)inReaders Src:(const char*)inSrc Body:(const char*)inBody Type:(const char*)type;
/*  说明：接收 request 命令回调
 参数：
 from(IN):       表示来自哪个节点
 to(IN):         表示发送给谁
 req_id(IN):     用于区分request请求
 url(INT):       request请求命令
 */
-(void) on_things_request:(char*)from to:(char*)to ID:(const char*)req_id URL:(char*)url;
/*  说明： REQUEST请求响应回调
 参数：
 from(IN):       表示来自哪个节点
 inReqID(IN):    对应 REQUEST请求的 id
 inStatus(IN):   200表示 OK，其他如400、501等表示失败
 inHeader(IN):
 inBody(IN):     表示 REQUEST 请求返回的内容，具体见协议
 */
-(void) on_things_response:(const char*)inReqID Status:(int)inStatus Header:(char*) inHeader Body:(char*)inBody;
/*  说明：同步变量更新回调
 参数：
 tid(IN):      设备的 TID
 status(IN):  状态，未使用
 */
-(void) on_vars_change_callback:(const char*)tid status:(const char*)status;
@end

/**
 *  SDK define
 */
@interface CWThingsSDK : NSObject
{
    
}

/*  说明：同步变量更新回调
 参数：
 inConnectStr，连接服务器的连接串，格式如：XXX.XXX.XXX.XXX:XXXX或者 域名:端口
 返回值：
 YES表示设置成功， NO 表示设置失败，具体是否连接成功要看回调
 */
+(BOOL) connect_to:(const char *)inConnectStr;
/*  说明：设置登录的用户名、密码
 参数：
 inUserName，用户名
 inUserPwd,密码
 返回值：
 YES表示设置成功， NO 表示设置失败，具体是否认证成功要看回调
 */
+(BOOL) user_login:(NSString *)inUserName pass:(NSString*)inUserPwd;

/*  说明：设置回调代理
 参数：
 delegate,代理类
 返回值：
 
 */
+(void) set_delegate:(id)delegate;
/*  说明：断开连接
 参数：
 
 返回值：
 YES 表示断开连接成功，NO 表示断开连接失败
 */
+(BOOL) disconnect;
/*  说明：PUSH请求
 参数：
 inMsg,表示 push内容
 inMsgLen，表示 push 内容长度
 inMsgType，表示类型，e 表示事件，im 表示消息
 返回值：
 YES 表示加入队列成功，NO 表示加入 PUSH 队列失败
 */
+(BOOL) push_msg:(const char*)inMsg MsgLen:(int)inMsgLen MsgType:(const char*)inMsgType;
/*  说明：REQUEST 请求
 参数：
 tid,设备或者用户 TID,根节点用.表示
 inReqID,REQUEST ID
 inURL，表示 REQUEST 内容
 inUrlLen,表示内容长度
 返回值：
 YES 表示加入队列成功，NO 表示加入 PUSH 队列失败
 */
+(BOOL) request:(const char *)tid ReqID:(const char*)inReqID Url:(const char*)inURL UrlLen:(int)inUrlLen;
/*  说明：REQUEST 请求 EX
 参数：
 tid,设备或者用户 TID,根节点用.表示
 inReqID,REQUEST ID
 inURL，表示 REQUEST 内容
 inUrlLen,表示内容长度
 返回值：
 YES 表示加入队列成功，NO 表示加入 PUSH 队列失败
 */
+(BOOL) requestEx:(const char *)tid ReqID:(const char*)inReqID Url:(const char*)inURL UrlLen:(int)inUrlLen;
/*  说明：REQUEST 请求响应
 参数：
 inSrc
 inReqID,REQUEST ID
 inStatus，200表示成功，400表示超时
 inHeader
 inBody,表示内容,inStatus 为200时表示具体内容，其他为 nil
 返回值：
 YES 表示加入队列成功，NO 表示加入 PUSH 队列失败
 */
+(BOOL) response:(const char*)inSrc ReqID:(const char *)inReqID Status:(int)inStatus Header:(const char*)inHeader Body:(const char*)inBody;
/*
 
 弃用
 */
+(BOOL) subscribe:(const char *)inReader Filter:(const char *)inFilter;
/*旧版 things 库接口*/
+(void) init_var_with_tid:(const char *)tid;
/*  说明：获取关联节点的变量内容
 参数：
 tid，节点 TID
 path,变量路径
 session，YES表示path是在sessions节点下的路径，NO 表示path是在非 sessions 下路径
 返回值：
 返回变量内容，NULL 表示失败
 */
+(char*) get_var_with_path:(const char *)tid path:(const char*)path sessions:(BOOL)session;
/*  说明：获取关联节点的变量内容，路径可以表示为 session下面的：ppath + num 节点 + bpath
 参数：
 tid，节点 TID
 ppath,第一部分变量路径
 num,表示第一部分变量路径下的第几个节点
 bpath,表示第 num节点下的路径
 返回值：
 返回变量内容，NULL 表示失败
 */
+(char*) get_var_with_path_ex:(const char *)tid prepath:(const char*)ppath member:(int)num backpath:(const char *)bpath;
/*  说明：设置关联节点的变量内容
 参数：
 tid，节点 TID
 path,变量路径
 session，表示 path 是否在 sessions 节点下面
 value,需要设置的变量值
 返回值：
 返回YES 表示成功，NO表示失败
 */
+(BOOL) set_var_with_tid:(const char *)tid path:(const char *)path sessions:(BOOL)session value:(const char*)value;
/*  说明：获取关联节点数量
 参数：
 
 返回值：
 返回关联的节点数量
 */
+(int)get_sync_with_things;
/*  说明：获取关联节点某路径的变量数量
 参数：
 tid，节点 TID
 path，路径
 返回值：
 返回关联的节点的 path 路径下的变量数量
 */
+(int)get_var_nodes_with_tid:(const char *)tid path:(const char *)path;
/*  说明：获取节点的 TID
 参数：
 member,第几个关联节点
 返回值：
 返回关联节点 TID
 */
+(char*)get_var_with_thing:(int)member;
/*  说明：获取当前SOCKET状态
 参数：
 
 返回值：
 返回当前 SOCKET 状态，具体参照SOCKET_STATE
 */
+(int) get_state;
/*  说明：获取当前用户的 session id
 参数：
 
 返回值：
 返回当前用户的 session id
 */
+(char*)get_things_sid;
/*弃用*/
+(void) cw_loop;
@end



//
//  CWProtocalDefine.h
//  CWIOSClient
//
//  Created by yeung  on 14-3-28.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CWProtocalDefine <NSObject>

@end


@protocol CWLoginDelegate <NSObject>
- (void)cwUserLogin:(BOOL)login;
- (void)cwTCPConnect:(BOOL)status;
@end

@protocol CWEventDelegate <NSObject>

- (void)cwPostEvent:(NSString*)event uID:(NSString*)uid;
- (void)cwConnectLost;
@end

@protocol CWThingsListDelegate <NSObject>

-(void)cwPostThingsList:(const char*)inThingsJson Header:(const char*)inHeader;
- (void) cwUpdateThingsList:(NSInteger)type withTID:(const char*)tid;
-(void)cwPostPartsList:(const char*)inPartsJson Header:(const char*)inHeader;
-(void)cwPostMsgList:(const char *)inUserListJson Header:(const char *)inHeader;
-(void)cwPostEventData:(const char*)body Type:(const char*)type;
-(void)cwRequestError;
-(void)cwConnectEvent:(BOOL)connected;
-(void)cwLoginEvent:(BOOL)login;
-(void)cwPostThingsInfo:(const char*)body;
-(void)cwPostThingsStatus:(const char*)body tid:(const char*)tid;
-(void)cwPostServerInfo:(const char*)body;
-(void)cwPostRelayServerInfo:(const char*)body;

-(void) cwPostTaskInfo:(const char*)inBody Header:(const char*)inHeader;

-(void) cwPostCaseInfo:(const char *)inBody Header:(const char*)inHeader;

-(void) cwPostRepairTaskInfo:(const char*)inBody Header:(const char*)inHeader;

-(void) cwPostRepairCaseInfo:(const char *)inBody Header:(const char*)inHeader;

-(void) cwPostQueryUserData:(const char*)inBody Header:(const char*)inHeader withType:(const char*)type;
-(void) cwPostQueryUserAlarmData:(const char*)inBody Header:(const char*)inHeader withType:(const char*)type;

-(void) on_vars_change_callback:(const char*)tid status:(const char*)status;

-(void) cwPostAlarmNearby:(const char *)inBody Header:(const char*)inHeader;

-(void) cwPostRepairNearby:(const char *)inBody Header:(const char*)inHeader;
@end

@protocol CWImageClickedDelegate <NSObject>

-(void) cwImageClicked:(id)sender tag:(NSInteger)tag;

@end

@protocol CWReadNewEventDelegate <NSObject>

-(void) cwReadClicked;

@end

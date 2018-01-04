//
//  LoginUserInfo.h
//  ThingsIOSClient
//
//  Created by yeung on 04/12/15.
//  Copyright © 2015年 yeung . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginUserInfo : NSObject<NSCoding>

@property(nonatomic, retain) NSString *login_user_name;
@property(nonatomic, retain) NSString *login_user_pwd;
@property(nonatomic, retain) NSString *login_server_name;
@property(nonatomic, retain) NSString *login_server_addr;
@property(nonatomic, retain) NSString *login_server_port;
@property(atomic,assign) BOOL  user_auto_login;
@property(atomic,assign) BOOL  server_visit_type;
@end

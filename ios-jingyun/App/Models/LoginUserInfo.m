//
//  LoginUserInfo.m
//  ThingsIOSClient
//
//  Created by yeung on 04/12/15.
//  Copyright © 2015年 yeung . All rights reserved.
//

#import "LoginUserInfo.h"

@implementation LoginUserInfo

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.login_user_name forKey:@"login_user_name"];
    [aCoder encodeObject:self.login_user_pwd forKey:@"login_user_pwd"];
    [aCoder encodeObject:self.login_server_name forKey:@"login_server_name"];
    [aCoder encodeObject:self.login_server_addr forKey:@"login_server_addr"];
    [aCoder encodeObject:self.login_server_port forKey:@"login_server_port"];
    [aCoder encodeBool:self.user_auto_login forKey:@"user_auto_login"];
    [aCoder encodeBool:self.server_visit_type forKey:@"server_visit_type"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.login_user_name    = [aDecoder decodeObjectForKey:@"login_user_name"];
        self.login_user_pwd     = [aDecoder decodeObjectForKey:@"login_user_pwd"];
        self.login_server_name  = [aDecoder decodeObjectForKey:@"login_server_name"];
        self.login_server_addr  = [aDecoder decodeObjectForKey:@"login_server_addr"];
        self.login_server_port  = [aDecoder decodeObjectForKey:@"login_server_port"];
        self.user_auto_login    = [aDecoder decodeBoolForKey:@"user_auto_login"];
        self.server_visit_type    = [aDecoder decodeBoolForKey:@"server_visit_type"];
    }
    return self;
}

@end

//
//  UserInfoModel.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "UserInfoModel.h"


@implementation UserInfoModel

- (void) print{
    NSLog(@"id:%@  userName:%@  password:%@  serverName:%@  serverAddress:%@  port:%@  isBindSIM:%@  isDomainLogin:%@", self.id, self.userName, self.password, self.serverName, self.serverAddress, self.port, self.isBindSIM?@"YES":@"NO", self.isDomainLogin?@"YES":@"NO");
}

@end

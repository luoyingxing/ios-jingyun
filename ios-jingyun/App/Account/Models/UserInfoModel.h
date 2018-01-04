//
//  UserInfoModel.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfoModel : NSObject

@property (nonatomic, copy) NSString* id;
@property (nonatomic, copy) NSString* serverName;
@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* password;
@property (nonatomic, copy) NSString* serverAddress;
@property (nonatomic, copy) NSString* port;
@property (nonatomic, assign) BOOL isBindSIM;
@property (nonatomic, assign) BOOL isDomainLogin;

- (void) print;

@end

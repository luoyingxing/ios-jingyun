//
//  CWFileUtils.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "CWFileUtils.h"

#define Save_Channel_Name @"Save_Channel_Name"
#define Save_Control_Password @"Save_Control_Password"
#define Use_Lock_Screen @"Use_Lock_Screen"

@implementation CWFileUtils

static CWFileUtils *sharedInstance = nil;

+ (CWFileUtils *) sharedInstance{
    return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

//设置通道类型显示类型为（ch*）
- (void) showChannelName:(BOOL) value{
    [[CWFileUtils sharedInstance] saveBOOL:Save_Channel_Name value:value];
}

//设置通道类型显示类型为（ch*）
- (BOOL) showChannelName{
    return [[CWFileUtils sharedInstance] readBOOL:Save_Channel_Name];
}

//启动密码锁屏
- (void) useLockScreen:(BOOL) value{
    [[CWFileUtils sharedInstance] saveBOOL:Use_Lock_Screen value:value];
}

//启动密码锁屏
- (BOOL) useLockScreen{
    return [[CWFileUtils sharedInstance] readBOOL:Use_Lock_Screen];
}

//保存反控密码
- (void) saveControlPassword:(BOOL) value{
    [[CWFileUtils sharedInstance] saveBOOL:Save_Control_Password value:value];
}

//保存反控密码
- (BOOL) saveControlPassword{
    return [[CWFileUtils sharedInstance] readBOOL:Save_Control_Password];
}

- (void) saveString:(NSString*) key value:(NSString*)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (BOOL) readString:(NSString*) key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

- (void) saveInteger:(NSString*) key value:(NSInteger)value{
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
}

- (BOOL) readInteger:(NSString*) key{
    return [[NSUserDefaults standardUserDefaults] integerForKey:key];
}

- (void) saveBOOL:(NSString*) key value:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
}

- (BOOL) readBOOL:(NSString*) key{
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}


@end

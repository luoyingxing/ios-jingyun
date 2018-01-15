//
//  CWFileUtils.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWFileUtils : NSObject

+ (CWFileUtils *) sharedInstance;

- (void) showChannelName:(BOOL) value;

- (BOOL) showChannelName;

- (void) videoConnectType:(NSInteger) value;

- (NSInteger) videoConnectType;

- (void) useLockScreen:(BOOL) value;

- (BOOL) useLockScreen;

- (void) saveControlPassword:(BOOL) value;

- (BOOL) saveControlPassword;

- (void) saveString:(NSString*) key value:(NSString*)value;

- (BOOL) readString:(NSString*) key;

- (void) saveInteger:(NSString*) key value:(NSInteger)value;

- (BOOL) readInteger:(NSString*) key;

- (void) saveBOOL:(NSString*) key value:(BOOL)value;

- (BOOL) readBOOL:(NSString*) key;

@end

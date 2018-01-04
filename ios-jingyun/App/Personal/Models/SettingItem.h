//
//  SettingItem.h
//  ios-jingyun
//
//  Created by conwin on 2017/12/27.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, assign) BOOL isCheckedMode;
@property(nonatomic, assign) BOOL isChecked;
@property(nonatomic, assign) NSInteger itemId;

-(instancetype)initWithTitle:(NSString*)title checkedMode:(BOOL)checked itemId:(NSInteger)itemId;

-(instancetype)init;

- (NSMutableArray*) get_setting_list;

- (BOOL) showChannelName:(BOOL) checked;

- (BOOL) getShowChannelName;

- (BOOL) saveControlPassword:(BOOL) checked;

- (BOOL) getSaveControlPassword;

- (BOOL) lockScreen:(BOOL) checked;

- (BOOL) getLockScreen;

+ (SettingItem *) sharedInstance;


@end

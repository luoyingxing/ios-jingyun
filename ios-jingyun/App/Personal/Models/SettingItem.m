//
//  SettingItem.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/27.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "SettingItem.h"

#define SHOW_CHANNEL_NAME @"showChannelName"
#define LOCK_SCREEN @"lockScreen"
#define SAVE_CONTROL_PASSWORD @"saveControlPassword"

@implementation SettingItem

static SettingItem *sharedInstance = nil;

+ (SettingItem *) sharedInstance{
    return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

-(instancetype) initWithTitle:(NSString*)title checkedMode:(BOOL)checked itemId:(NSInteger) itemId{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.isCheckedMode = checked;
        self.itemId = itemId;
    }
    return self;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        self.title = @"";
        self.isChecked = NO;
        self.isCheckedMode = NO;
        self.itemId = 0;
    }
    return self;
}

- (NSString*) get_flile_path{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"SettingItemList" ofType:@"plist"];
    return filePath;
}

- (NSMutableArray*) get_setting_list{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:self.get_flile_path];

    NSMutableArray* array = [[NSMutableArray alloc] init];
 
    SettingItem* videoMode = [[SettingItem alloc] initWithTitle:@"选择视频访问方式" checkedMode:NO itemId:3001];
    [array addObject:videoMode];
    
    SettingItem* channelShow = [[SettingItem alloc] initWithTitle:@"设置通道显示类型为(ch*)" checkedMode:YES itemId:3002];
    channelShow.isChecked = [dict[SHOW_CHANNEL_NAME] boolValue];
    [array addObject:channelShow];
    
    SettingItem* lockScreen = [[SettingItem alloc] initWithTitle:@"启动密码锁屏" checkedMode:YES itemId:3003];
    lockScreen.isChecked = [dict[LOCK_SCREEN] boolValue];
    [array addObject:lockScreen];
    
    SettingItem* control = [[SettingItem alloc] initWithTitle:@"保存反控密码" checkedMode:YES itemId:3004];
    control.isChecked = [dict[SAVE_CONTROL_PASSWORD] boolValue];
    [array addObject:control];
    
    SettingItem* voice = [[SettingItem alloc] initWithTitle:@"后台声音提醒" checkedMode:NO itemId:3005];
    [array addObject:voice];
    
    SettingItem* alterPassword = [[SettingItem alloc] initWithTitle:@"修改登陆密码" checkedMode:NO itemId:3006];
    [array addObject:alterPassword];
    
    SettingItem* help = [[SettingItem alloc] initWithTitle:@"系统帮助" checkedMode:NO itemId:3007];
    [array addObject:help];
    
    SettingItem* about = [[SettingItem alloc] initWithTitle:@"关于警云" checkedMode:NO itemId:3008];
    [array addObject:about];
    
    return array;
}

//显示通道名称
- (BOOL) showChannelName:(BOOL) checked{
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:self.get_flile_path];
    [dataDictionary setObject:[NSNumber numberWithBool:checked] forKey:SHOW_CHANNEL_NAME];
    BOOL succeed = [dataDictionary writeToFile:self.get_flile_path atomically:YES];
    return succeed;
}

- (BOOL) getShowChannelName{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:self.get_flile_path];
    return [dict[SHOW_CHANNEL_NAME] boolValue];
}

//保存反控密码
- (BOOL) saveControlPassword:(BOOL) checked{
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:self.get_flile_path];
    [dataDictionary setObject:[NSNumber numberWithBool:checked] forKey:SAVE_CONTROL_PASSWORD];
    BOOL succeed = [dataDictionary writeToFile:self.get_flile_path atomically:YES];
    return succeed;
}

- (BOOL) getSaveControlPassword{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:self.get_flile_path];
    return [dict[SAVE_CONTROL_PASSWORD] boolValue];
    return NO;
}
//密码锁屏
- (BOOL) lockScreen:(BOOL) checked{
    NSMutableDictionary *dataDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:self.get_flile_path];
    [dataDictionary setObject:[NSNumber numberWithBool:checked] forKey:LOCK_SCREEN];
    BOOL succeed = [dataDictionary writeToFile:self.get_flile_path atomically:YES];
    return succeed;
}

- (BOOL) getLockScreen{
    NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:self.get_flile_path];
    return [dict[LOCK_SCREEN] boolValue];
    return NO;
}

@end

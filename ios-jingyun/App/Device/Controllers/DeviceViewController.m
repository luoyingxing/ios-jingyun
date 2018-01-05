//
//  DeviceViewController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "DeviceViewController.h"
#import <Foundation/Foundation.h>
#import "PersonalViewController.h"
#import "CWColorUtils.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "SettingTextViewCell.h"
#import "AccountViewController.h"
#import "SettingCheckedViewCell.h"
#import "SettingItem.h"
#import "DeviceDefaultCell.h"
#import "DeviceImageCell.h"
#import "DeviceStatusModel.h"
#import "DeviceDetailViewController.h"

#define CellIdentifierForDefault @"CellIdentifierForDefault"
#define CellIdentifierForImage @"CellIdentifierForImage"

@interface DeviceViewController ()<UITableViewDelegate, UITableViewDataSource>

//保存数据列表
@property (nonatomic,strong) NSMutableArray* deviceArray;

@end

@implementation DeviceViewController{
    UITableView *tableView;
    UILabel* subtitleLabel;
    UILabel* userLabel;
    UILabel* filterLabel;
    UILabel* allLabel;
    UILabel* alarmLabel;
    UILabel* videoLabel;
    UILabel* otherLabel;
    UILabel* tipLabel;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGFloat childViewsY;
    
    int currentFilterIndex;
    int openDeviceCount;
    
    NSString* filterKey;
    BOOL isFilterAll;
    BOOL isFilterAway;
    BOOL isFilterOPen;
    BOOL isFilterAlarm;
    BOOL isFilterOnline;
    BOOL isFilterOffline;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    self.deviceArray = [[NSMutableArray alloc] init];
    
    isFilterAll = YES;
    isFilterAway = YES;;
    isFilterOPen = YES;;
    isFilterAlarm = YES;;
    isFilterOnline = YES;;
    isFilterOffline = YES;;
    
    [self addTopView];
    [self initTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) initTableView{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 126, screenWidth, screenHeight - 126) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    //分割线颜色
    tableView.separatorColor = [UIColor whiteColor];
    tableView.backgroundColor = [UIColor whiteColor];
    
    //纯文字选择项
    [tableView registerClass:[DeviceDefaultCell class] forCellReuseIdentifier:CellIdentifierForDefault];
    //选择框样式
    [tableView registerClass:[DeviceImageCell class] forCellReuseIdentifier:CellIdentifierForImage];
    
    [self.view addSubview:tableView];
}

- (void) addTopView{
    CGFloat topHeight = 20 + 44 + 44 + 18;
    
    UIView* bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, topHeight)];
    bgView.backgroundColor = [CWColorUtils getThemeColor];
    [self.view addSubview:bgView];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_white_logo"]];
    imageView.frame = CGRectMake(10, 27, 30, 30);
    imageView.contentMode =  UIViewContentModeScaleAspectFit;
    imageView.clipsToBounds  = YES;
    [self.view addSubview:imageView];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 22, screenWidth - 80, 20)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"设备";
    titleLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:titleLabel];
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 42, screenWidth - 80, 20)];
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.numberOfLines = 1;
    subtitleLabel.text = @"全部 | 0";
    subtitleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:subtitleLabel];
    
    filterLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 64, 20, 50, 44)];
    filterLabel.textColor = [UIColor whiteColor];
    filterLabel.textAlignment = NSTextAlignmentRight;
    filterLabel.text = @"过滤";
    filterLabel.font = [UIFont systemFontOfSize:17];
    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(filterOnclickListener)];
    [filterLabel addGestureRecognizer:onclickListener];
    filterLabel.userInteractionEnabled = YES;
    [self.view addSubview:filterLabel];

    CGFloat fliterWidth = (screenWidth - 16) /4;
    
    allLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 71, fliterWidth, 30)];
    allLabel.backgroundColor =  [UIColor whiteColor];
    allLabel.textColor = [CWColorUtils getThemeColor];
    allLabel.textAlignment = NSTextAlignmentCenter;
    allLabel.text = @"全部设备";
    allLabel.font = [UIFont systemFontOfSize:16];
    //    alarmLabel.layer.cornerRadius = 5;
    allLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    allLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *allclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(allOnclickListener)];
    [allLabel addGestureRecognizer:allclickListener];
    allLabel.userInteractionEnabled = YES;
    //设置绘制的圆角
    allLabel.layer.masksToBounds = YES;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:allLabel.bounds  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(5, 5)];//设置圆角大小，弧度为5
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = allLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    allLabel.layer.mask = maskLayer;
    [self.view addSubview:allLabel];

    alarmLabel = [[UILabel alloc] initWithFrame:CGRectMake(8 + fliterWidth, 71, fliterWidth, 30)];
    alarmLabel.backgroundColor =   [CWColorUtils getThemeColor];
    alarmLabel.textColor = [UIColor whiteColor];
    alarmLabel.textAlignment = NSTextAlignmentCenter;
    alarmLabel.text = @"报警设备";
    alarmLabel.font = [UIFont systemFontOfSize:16];
//    alarmLabel.layer.cornerRadius = 5;
    alarmLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    alarmLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *alarmclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(alarmOnclickListener)];
    [alarmLabel addGestureRecognizer:alarmclickListener];
    alarmLabel.userInteractionEnabled = YES;
    [self.view addSubview:alarmLabel];
    
    videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(8 + fliterWidth * 2, 71, fliterWidth, 30)];
    videoLabel.backgroundColor =   [CWColorUtils getThemeColor];
    videoLabel.textColor = [UIColor whiteColor];
    videoLabel.textAlignment = NSTextAlignmentCenter;
    videoLabel.text = @"视频设备";
    videoLabel.font = [UIFont systemFontOfSize:16];
    //    videoLabel.layer.cornerRadius = 5;
    videoLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    videoLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *videoclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(videoOnclickListener)];
    [videoLabel addGestureRecognizer:videoclickListener];
    videoLabel.userInteractionEnabled = YES;
    [self.view addSubview:videoLabel];
    
    otherLabel = [[UILabel alloc] initWithFrame:CGRectMake(8 + fliterWidth * 3, 71, fliterWidth, 30)];
    otherLabel.backgroundColor =   [CWColorUtils getThemeColor];
    otherLabel.textColor = [UIColor whiteColor];
    otherLabel.textAlignment = NSTextAlignmentCenter;
    otherLabel.text = @"其他设备";
    otherLabel.font = [UIFont systemFontOfSize:16];
    //    otherLabel.layer.cornerRadius = 5;
    otherLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    otherLabel.layer.borderWidth = 0.5;
    UITapGestureRecognizer *otherclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(otherOnclickListener)];
    [otherLabel addGestureRecognizer:otherclickListener];
    otherLabel.userInteractionEnabled = YES;
    //设置绘制的圆角
    otherLabel.layer.masksToBounds = YES;
    UIBezierPath *maskPath1 = [UIBezierPath bezierPathWithRoundedRect:allLabel.bounds  byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];//设置圆角大小，弧度为5
    CAShapeLayer *maskLayer1 = [[CAShapeLayer alloc] init];
    maskLayer1.frame = otherLabel.bounds;
    maskLayer1.path = maskPath1.CGPath;
    otherLabel.layer.mask = maskLayer1;
    [self.view addSubview:otherLabel];
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, screenWidth, 18)];
    tipLabel.backgroundColor = [UIColor whiteColor];
    tipLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.text = @"全部0/撤防0";
    [self.view addSubview:tipLabel];
}

- (void) viewWillAppear:(BOOL)animated{
    [self loadDeviceData];
}

//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
//    view.tintColor = [UIColor whiteColor];
//}

- (void) loadDeviceData{
    openDeviceCount = 0;
    [self.deviceArray removeAllObjects];
    
    NSInteger count =[[CWDataManager sharedInstance] getThingsObjectCount];
    for (int i = 0; i < count ; i++) {
        //caption--name  partID--1002 tid
        DeviceStatusModel *model = [[CWDataManager sharedInstance] ThingsMsgObjectAtIndex:i];
         if (model) {
            //先过滤设备类型
            char *type = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"type" sessions:NO];
            NSString* deviceType = [[NSString alloc] initWithUTF8String:type];
            if (![deviceType isEqualToString:@"device"]) {
                continue;
            }
            model.deviceType = deviceType;
            
            //再过滤tab类型（全部、报警、视频、其他）currentFilterIndex
            if (currentFilterIndex == 1 && (![model.partID isEqualToString:@"1000"] && ![model.partID isEqualToString:@"1001"] && ![model.partID isEqualToString:@"1002"])) {
                continue;
            }else if (currentFilterIndex == 2 && (![model.partID isEqualToString:@"2000"])){
                continue;
            }else if (currentFilterIndex == 3 && ([model.partID isEqualToString:@"1000"] || [model.partID isEqualToString:@"1001"] || [model.partID isEqualToString:@"1002"] || [model.partID isEqualToString:@"2000"])){
                continue;
            }
           
            if (model) {
                //名称-即标题
                char *name = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"name" sessions:NO];
                if (name) {
                    NSString *ns_name = [NSString stringWithUTF8String:name];
                    model.caption = ns_name;
                }
                else {
                    model.caption = @"";
                }
                
                //设备类型
                if ([model.tid hasPrefix:@"LC"]) {
                    model.isLeChangeDevice = YES;
                }else if ([model.tid hasPrefix:@"HM"]){
                    model.isHuaMaiDevice = YES;
                }else if ([model.tid hasPrefix:@"EZ"]){
                    model.isEZDevice = YES;
                }
                
                //时间
                if ([model.partID isEqualToString:@"2000"]) {
                    char* d_t = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[model.tid UTF8String] prepath:"areas" member:0 backpath:"t_stat"];
                    if (d_t) {
                        NSString* dataTimeString = [NSString stringWithUTF8String:d_t];
                        model.dateTime = dataTimeString;
                        
                        NSArray *array = [dataTimeString componentsSeparatedByString:@" "]; //分隔符逗号
                        if (array.count > 1) {
                            model.date = [array objectAtIndex:0];
                            model.time = [array objectAtIndex:1];
                        }
                    }
                }else{
                    char* d_t;
                    if ([model.partID isEqualToString:@"1100"] || [model.partID isEqualToString:@"1101"] || [model.partID isEqualToString:@"1104"]) {
                        d_t = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"pnl.r.t" sessions:YES];
                    }else{
                        d_t = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"pnl.s.t" sessions:YES];
                    }
                    
                    if (d_t) {
                        NSString* dataTimeString = [NSString stringWithUTF8String:d_t];
                        model.dateTime = dataTimeString;
                        
                        NSArray *array = [dataTimeString componentsSeparatedByString:@" "]; //分隔符逗号
                        if (array.count > 1) {
                            model.date = [array objectAtIndex:0];
                            model.time = [array objectAtIndex:1];
                        }
                    }
                }
                
                //设备状态
                char *device_status;
                if ([model.partID isEqualToString:@"2000"]) {
                    device_status= [[CWThings4Interface sharedInstance] get_var_with_path_ex:[model.tid UTF8String] prepath:"areas" member:0 backpath:"stat"];
                }else{
                    if ([model.partID isEqualToString:@"1100"] || [model.partID isEqualToString:@"1101"] || [model.partID isEqualToString:@"1104"]) {
                        device_status = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"pnl.r.s" sessions:YES];
                    }else{
                        device_status = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"pnl.s.s" sessions:YES];
                    }
                }
                
                NSString* deviceStatusString;
                if (device_status) {
                    deviceStatusString = [NSString stringWithUTF8String:device_status];
                }
                //防区状态
                BOOL isZoneAlarm = NO;
                char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"zones" sessions:YES];
                if (zone_status) {
                    NSString* zoneStatusString = [NSString stringWithUTF8String:zone_status];
                    NSData *jsonData = [zoneStatusString dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *zoneDit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                    
                    for (NSString *key in zoneDit) {
                        NSString* stat = [zoneDit[key] objectForKey:@"stat"];
                        if ([stat isEqualToString:@"alarm"]) {
                            isZoneAlarm = YES;
                            break;
                        }
                    }
                }
                //设备在线状态
                BOOL isOnline = NO;
                char *online = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"online" sessions:NO];
                if (online && strcmp(online, "true") == 0) {
                    isOnline = YES;
                }
                
                //public static final int OFF_LINE = 9;
                //public static final int SAFETY = 10;
                //public static final int SAFETY_ALARM = 11;
                //public static final int OPEN = 12;
                //public static final int OPEN_ALARM = 13;
                //public static final int STAY = 14;
                //public static final int STAY_ALARM = 15;
                //public static final int UNREADY = 16;
                //public static final int UNREADY_ALARM = 17;
                //public static final int UNKNOWN = 18;
                //public static final int UNKNOWN_ALARM = 19;
                //statusNumber用来记录设备的状态，当时ui的要求不会直接使用，但在此说明
                int statusNumber = 10;
                if (!isOnline || ![model.deviceType isEqualToString:@"device"]) {
                    statusNumber = 9;
                }else if (deviceStatusString == nil || deviceStatusString.length == 0) {
                    statusNumber = 18;
                }else{
                    if ([deviceStatusString isEqualToString:@"open"]) {
                        if (isZoneAlarm) {
                            statusNumber = 13;
                            model.isDeviceOpen = YES;
                        }else{
                            statusNumber = 12;
                            model.isDeviceOpen = YES;
                        }
                    }else if([deviceStatusString isEqualToString:@"away"] || [deviceStatusString isEqualToString:@"away delay"] || [deviceStatusString isEqualToString:@"away entery delay"]){
                        if (isZoneAlarm) {
                            statusNumber = 11;
                        }else{
                            statusNumber = 10;
                        }
                    }else if([deviceStatusString isEqualToString:@"stay"] || [deviceStatusString isEqualToString:@"stay delay"] || [deviceStatusString isEqualToString:@"stay entery delay"]){
                        if (isZoneAlarm) {
                            statusNumber = 15;
                            model.isDeviceOpen = YES;
                        }else{
                            statusNumber = 14;
                        }
                    }else if([deviceStatusString isEqualToString:@"nr"]){
                        if (isZoneAlarm) {
                            statusNumber = 17;
                            model.isDeviceOpen = YES;
                        }else{
                            statusNumber = 16;
                        }
                    }else if([deviceStatusString isEqualToString:@"na"]){
                        if (isZoneAlarm) {
                            statusNumber = 19;
                            model.isDeviceOpen = YES;
                        }else{
                            statusNumber = 18;
                        }
                    }
                }

                //标签 -- 防区状态
                NSMutableArray* tagArray = [[NSMutableArray alloc] init];
                BOOL isByPass = NO;
                BOOL isAlarm = NO;
                BOOL isAway = NO;
                BOOL isOpen = NO;
                BOOL isUnknown = NO;
                BOOL isNoReady = NO;
                
                if (model.partID != nil && [model.partID isEqualToString:@"2000"]) {
                    char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"zones" sessions:YES];
                    if (zone_status) {
                        NSString* zoneStatusString = [NSString stringWithUTF8String:zone_status];
                        NSData *jsonData = [zoneStatusString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *zoneDit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                        
                        for (NSString *key in zoneDit) {
                            NSString* stat = [zoneDit[key] objectForKey:@"stat"];
                            if ([stat isEqualToString:@"bypass"]) {
                                isByPass = YES;
                                continue;
                            }else if ([stat isEqualToString:@"alarm"]) {
                                isAlarm = YES;
                                continue;
                            }else if ([stat isEqualToString:@"away"]) {
                                isAway = YES;
                                continue;
                            }else if ([stat isEqualToString:@"open"]) {
                                isOpen = YES;
                                continue;
                            }else if ([stat isEqualToString:@"na"]) {
                                isUnknown = YES;
                                continue;
                            }else if ([stat isEqualToString:@"nr"]) {
                                isNoReady = YES;
                                continue;
                            }
                        }
                    }
                }else{
                    char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"z" sessions:YES];
                    if (zone_status) {
                        NSString* zoneStatusString = [NSString stringWithUTF8String:zone_status];
                        NSData *jsonData = [zoneStatusString dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *zoneDit = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
                        
                        for (NSString *key in zoneDit) {
                            NSString* stat = [zoneDit[key] objectForKey:@"s"];
                            if ([stat isEqualToString:@"bypass"]) {
                                isByPass = YES;
                                continue;
                            }else if ([stat isEqualToString:@"alarm"]) {
                                isAlarm = YES;
                                continue;
                            }else if ([stat isEqualToString:@"away"]) {
                                isAway = YES;
                                continue;
                            }else if ([stat isEqualToString:@"open"]) {
                                isOpen = YES;
                                continue;
                            }else if ([stat isEqualToString:@"na"]) {
                                isUnknown = YES;
                                continue;
                            }else if ([stat isEqualToString:@"nr"]) {
                                isNoReady = YES;
                                continue;
                            }
                        }
                    }
                }
                
                
                if (isByPass) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#ff9801" forKey:@"bgColor"];
                    [dit setObject:@"旁路" forKey:@"name"];
                    [tagArray addObject:dit];
                }
                
                if (isAlarm) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#ff5555" forKey:@"bgColor"];
                    [dit setObject:@"报警" forKey:@"name"];
                    [tagArray addObject:dit];
                }
                
                if (isNoReady) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#a8a8a8" forKey:@"bgColor"];
                    [dit setObject:@"未准备" forKey:@"name"];
                    [tagArray addObject:dit];
                }
                
                if (tagArray.count == 0) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#00bec8" forKey:@"bgColor"];
                    [dit setObject:@"正常" forKey:@"name"];
                    [tagArray addObject:dit];
                }
                
                //标签 -- 全局状态
                NSString* connected = @"-1";
                if([model.partID isEqualToString:@"1000"] || [model.partID isEqualToString:@"1001"] || [model.partID isEqualToString:@"1002"]){
                    char* deviceConnectStr = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"pnl.s.net.connected" sessions:YES];
                    if (deviceConnectStr) {
                        connected = [NSString stringWithUTF8String:deviceConnectStr];
                    }
                }else{
                    connected = isOnline ? @"1" : @"0";
                }
                model.globalSatus = connected;

                if ([connected isEqualToString:@"0"]) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#a8a8a8" forKey:@"bgColor"];
                    [dit setObject:@"离线" forKey:@"name"];
                    [tagArray insertObject:dit atIndex:0];
                }else if ([connected isEqualToString:@"1"]) {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#3ec0fe" forKey:@"bgColor"];
                    [dit setObject:@"在线" forKey:@"name"];
                    [tagArray insertObject:dit atIndex:0];
                }else {
                    NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                    [dit setObject:@"#a8a8a8" forKey:@"bgColor"];
                    [dit setObject:@"未知" forKey:@"name"];
                    [tagArray insertObject:dit atIndex:0];
                }
                
                //因为是有显示缩略图，所以增加一个是否布撤防的标签
                if (currentFilterIndex == 2) {
                    if(model.isDeviceOpen){
                        NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                        [dit setObject:@"#d1d100" forKey:@"bgColor"];
                        [dit setObject:@"撤防" forKey:@"name"];
                        [tagArray insertObject:dit atIndex:1];
                    }else{
                        NSMutableDictionary* dit = [[NSMutableDictionary alloc] init];
                        [dit setObject:@"#3cc25c" forKey:@"bgColor"];
                        [dit setObject:@"布防" forKey:@"name"];
                        [tagArray insertObject:dit atIndex:1];
                    }
                }
                
                model.tagArray = tagArray;
            
    //            char *unReadCount = [[CWThings4Interface sharedInstance] get_var_with_path:[model.tid UTF8String] path:"name" sessions:NO];
    //            if (unReadCount) {
    //                NSString *ns_name = [NSString stringWithUTF8String:name];
    //
    //                model.unread_count = ns_name;
    //            }
    //            else {
    //                model.unread_count = 0;
    //            }
            
                //以上是通过帅选出的符合，接下来还需要进一步过略条件
                if (isFilterAll) {
                    [self.deviceArray addObject:model];
                }else{
                    if (filterKey == nil || filterKey.length == 0) {
                        if ((isFilterAway && deviceStatusString != nil && [deviceStatusString isEqualToString:@"away"]) ||
                            (isFilterOPen && deviceStatusString != nil && [deviceStatusString isEqualToString:@"open"]) ||
                            (isFilterAlarm && ((deviceStatusString != nil && [deviceStatusString isEqualToString:@"alarm"]) || isAlarm )) ||
                            (isFilterOnline && [connected isEqualToString:@"1"]) ||
                            (isFilterOffline && [connected isEqualToString:@"0"])) {
                            [self.deviceArray addObject:model];
                        }
                    }else{
                        if ([model.caption containsString:filterKey]) {
                            [self.deviceArray addObject:model];
                        }
                    }
                }
                
                if (deviceStatusString != nil && [deviceStatusString isEqualToString:@"open"]) {
                    openDeviceCount++;
                }
            }
         }
    }
    
    //显示一些标签信息
    NSString* titleStrings = [[NSString alloc] init];
    
    if (isFilterAll) {
        titleStrings = [titleStrings stringByAppendingString:@"全部 | "];
    }else{
        if (isFilterAlarm) {
            titleStrings = [titleStrings stringByAppendingString:@"布防 | "];
        }
        
        if (isFilterOPen) {
            titleStrings = [titleStrings stringByAppendingString:@"撤防 | "];
        }
        
        if (isFilterAlarm) {
            titleStrings = [titleStrings stringByAppendingString:@"报警 | "];
        }
        
        if (isFilterOnline) {
            titleStrings = [titleStrings stringByAppendingString:@"在线 | "];
        }
        
        if (isFilterOffline) {
            titleStrings = [titleStrings stringByAppendingString:@"离线 | "];
        }
    }
    
    subtitleLabel.text = [NSString stringWithFormat:@"%@%lu", titleStrings, _deviceArray.count];
    tipLabel.text = [NSString stringWithFormat:@"全部%lu/撤防%d", _deviceArray.count, openDeviceCount];
    
    [tableView reloadData];
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.deviceArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    DeviceStatusModel *model = [_deviceArray objectAtIndex:index];
    
    if (currentFilterIndex == 2) {
        //image mode
        DeviceImageCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForImage forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForImage];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([model.globalSatus isEqualToString:@"1"]) {
            cell.nameLabel.textColor = [CWColorUtils getThemeColor];
        }else {
            cell.nameLabel.textColor = [CWColorUtils colorWithHexString:@"666666"];
        }
        cell.nameLabel.text = model.caption;
        
        if (model.date != nil) {
            cell.dataTimeLabel.text = [NSString stringWithFormat:@"%@ %@", model.date, model.time];
        }
    
        if (model.unread_count > 0) {
            [cell.messageLabel setHidden:NO];
            cell.messageLabel.text = [NSString stringWithFormat:@"%ld", (long)model.unread_count];
        }else{
            cell.messageLabel.text = @"";
            [cell.messageLabel setHidden:YES];
        }
        
        NSMutableArray* tagArray = model.tagArray;
        int perX = 0;
        //移除所有子视图，避免复用引起的重叠
        for(UIView *view in [cell.tagView subviews]){
            [view removeFromSuperview];
        }
        for(NSMutableDictionary* dit in tagArray){
            int perWidth = 36;
            if ([dit[@"name"] isEqualToString:@"未准备"]) {
                perWidth = 46;
            }
            UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(perX, 3, perWidth, 20)];
            tagLabel.numberOfLines = 1;
            tagLabel.textAlignment = NSTextAlignmentCenter;
            tagLabel.font = [UIFont systemFontOfSize:14];
            tagLabel.text = dit[@"name"];
            tagLabel.textColor = [UIColor whiteColor];
            tagLabel.backgroundColor = [CWColorUtils colorWithHexString:dit[@"bgColor"]];
            [cell.tagView addSubview:tagLabel];
            
            perX += perWidth + 3;
        }
        
        //显示缩略图和logo
        if (model.isLeChangeDevice) {
            cell.logoImage.image = [UIImage imageNamed:@"ic_lc_logo"];
        }else if (model.isHuaMaiDevice) {
            cell.logoImage.image = [UIImage imageNamed:@"ic_hm_logo"];
        }else if (model.isEZDevice) {
            cell.logoImage.image = [UIImage imageNamed:@"ic_ez_logo"];
        }else{
            cell.logoImage.image = [UIImage imageNamed:@"ic_cw_logo"];
        }
        
        return cell;
    }else{
        //default mode
     
        DeviceDefaultCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierForDefault forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceDefaultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierForDefault];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ([model.globalSatus isEqualToString:@"1"]) {
            cell.nameLabel.textColor = [CWColorUtils getThemeColor];
        }else {
            cell.nameLabel.textColor = [CWColorUtils colorWithHexString:@"666666"];
        }
        cell.nameLabel.text = model.caption;
        
        cell.dataLabel.text = model.date;
        cell.timeLabel.text = model.time;
        
        if (model.unread_count > 0) {
            [cell.messageLabel setHidden:NO];
            cell.messageLabel.text = [NSString stringWithFormat:@"%ld", (long)model.unread_count];
        }else{
            cell.messageLabel.text = @"";
            [cell.messageLabel setHidden:YES];
        }
        
        
        if (model.isDeviceOpen) {
            cell.statusImage.image = [UIImage imageNamed:@"icon_device_alarm"];
        }else{
            cell.statusImage.image = [UIImage imageNamed:@"icon_device_safety"];
        }
        
        
        NSMutableArray* tagArray = model.tagArray;
        int perX = 0;
        //移除所有子视图，避免复用引起的重叠
        for(UIView *view in [cell.tagView subviews]){
            [view removeFromSuperview];
        }
        for(NSMutableDictionary* dit in tagArray){
            int perWidth = 36;
            if ([dit[@"name"] isEqualToString:@"未准备"]) {
                perWidth = 46;
            }
            UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(perX, 3, perWidth, 20)];
            tagLabel.numberOfLines = 1;
            tagLabel.textAlignment = NSTextAlignmentCenter;
            tagLabel.font = [UIFont systemFontOfSize:14];
            tagLabel.text = dit[@"name"];
            tagLabel.textColor = [UIColor whiteColor];
            tagLabel.backgroundColor = [CWColorUtils colorWithHexString:dit[@"bgColor"]];
            [cell.tagView addSubview:tagLabel];
            
            perX += perWidth + 3;
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentFilterIndex == 2) {
        return [DeviceImageCell getCellHeight];
    }else{
        return [DeviceDefaultCell getCellHeight];
    }
}

- (void) filterOnclickListener{
    NSLog(@"filterOnclickListener");
    
}

- (void) allOnclickListener{
    NSLog(@"allOnclickListener");
    currentFilterIndex = 0;
    allLabel.backgroundColor =  [UIColor whiteColor];
    allLabel.textColor = [CWColorUtils getThemeColor];
    alarmLabel.backgroundColor = [CWColorUtils getThemeColor];
    alarmLabel.textColor = [UIColor whiteColor];
    videoLabel.backgroundColor = [CWColorUtils getThemeColor];
    videoLabel.textColor = [UIColor whiteColor];
    otherLabel.backgroundColor = [CWColorUtils getThemeColor];
    otherLabel.textColor = [UIColor whiteColor];
    [self loadDeviceData];
}

- (void) alarmOnclickListener{
    NSLog(@"alarmOnclickListener");
    currentFilterIndex = 1;
    alarmLabel.backgroundColor =  [UIColor whiteColor];
    alarmLabel.textColor = [CWColorUtils getThemeColor];
    allLabel.backgroundColor = [CWColorUtils getThemeColor];
    allLabel.textColor = [UIColor whiteColor];
    videoLabel.backgroundColor = [CWColorUtils getThemeColor];
    videoLabel.textColor = [UIColor whiteColor];
    otherLabel.backgroundColor = [CWColorUtils getThemeColor];
    otherLabel.textColor = [UIColor whiteColor];
    [self loadDeviceData];
}

- (void) videoOnclickListener{
    NSLog(@"videoOnclickListener");
    currentFilterIndex = 2;
    videoLabel.backgroundColor =  [UIColor whiteColor];
    videoLabel.textColor = [CWColorUtils getThemeColor];
    allLabel.backgroundColor = [CWColorUtils getThemeColor];
    allLabel.textColor = [UIColor whiteColor];
    alarmLabel.backgroundColor = [CWColorUtils getThemeColor];
    alarmLabel.textColor = [UIColor whiteColor];
    otherLabel.backgroundColor = [CWColorUtils getThemeColor];
    otherLabel.textColor = [UIColor whiteColor];
    [self loadDeviceData];
}

- (void) otherOnclickListener{
    NSLog(@"otherOnclickListener");
    currentFilterIndex = 3;
    otherLabel.backgroundColor =  [UIColor whiteColor];
    otherLabel.textColor = [CWColorUtils getThemeColor];
    alarmLabel.backgroundColor = [CWColorUtils getThemeColor];
    alarmLabel.textColor = [UIColor whiteColor];
    videoLabel.backgroundColor = [CWColorUtils getThemeColor];
    videoLabel.textColor = [UIColor whiteColor];
    allLabel.backgroundColor = [CWColorUtils getThemeColor];
    allLabel.textColor = [UIColor whiteColor];
    [self loadDeviceData];
}


// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click item %li", indexPath.row);
    
    DeviceDetailViewController *controller = [[DeviceDetailViewController alloc] init];
    controller.deviceStatusModel = [_deviceArray objectAtIndex:indexPath.row];
    [self presentViewController:controller animated:TRUE completion:nil];
}

- (NSDictionary *) dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

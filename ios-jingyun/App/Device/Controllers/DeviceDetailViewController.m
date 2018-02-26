//
//  DeviceDetailViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/5.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceDetailViewController.h"
#import "CWColorUtils.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "DeviceStatusModel.h"
#import "DeviceMessageLocalCell.h"
#import "ZoneViewCell.h"
#import "DeviceMessageModel.h"
#import "DeviceMessageServerCell.h"
#import "CWThings4Interface.h"
#import "MBProgressHUD.h"
#import "DeviceZoneModel.h"
#import "SDPhotoBrowser.h"
#import "ZoneViewController.h"
#import "ChannelAlertView.h"

#define CellIdentifierZone @"CellIdentifierZone"

#define CellIdentifierLocal @"CellIdentifierLocal"
#define CellIdentifierServer @"CellIdentifierServer"

@interface DeviceDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, SDPhotoBrowserDelegate>{
    
    NSTimer *message_update_timer;
    
}

//保存数据列表
@property (nonatomic,strong) NSMutableArray* deviceArray;

//保存防区列表
@property (nonatomic,strong) NSMutableArray* zoneArray;

//未读消息条数
@property (nonatomic, assign) NSInteger preMessageCount;

//通道数
@property (nonatomic, strong) NSMutableArray* channelArray;

@property (nonatomic, assign) BOOL isEndOfTableView;

@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL isHideMenu;

@end

@implementation DeviceDetailViewController {
    UITableView *tableView;
    UIImageView* backImageView;
    UILabel* titleLabel;
    UILabel* subtitleLabel;
    UILabel* zoneLabel;
    UILabel* unreadTipLabel;
    
    UIImageView* statusImageView;
    UILabel* statusLabel;
    UICollectionView* collectionView;
    
    UIImageView* showMenu;
    UIImageView* captureMenu;
    UIImageView* awayMenu;
    UIImageView* passMenu;
    UIImageView* videoMenu;
    UIImageView* recordMenu;
    
    UIRefreshControl *refreshControl;
    
    CGFloat screenHeight;
    CGFloat screenWidth;
    CGFloat childViewsY;
    
    MBProgressHUD *mbProgress;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    self.deviceArray = [[NSMutableArray alloc] init];
    self.zoneArray = [[NSMutableArray alloc] init];
    self.channelArray = [[NSMutableArray alloc] init];
    
    _preMessageCount = 0;
    _isEndOfTableView = YES;
    _isRefreshing = YES;
    
    [self addToolbarView];
    [self addTopView];
    [self addCollectionView];
    [self initTableView];
    [self addUnreadLabel];
    [self addControlMenu];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) addToolbarView{
    CGFloat toolbarHeight = 20 + 44;
    childViewsY += toolbarHeight;
    
    UIView* toolbarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, toolbarHeight)];
    toolbarView.backgroundColor = [CWColorUtils getThemeColor];
    [self.view addSubview:toolbarView];
    
    backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_white.png"]];
    backImageView.frame = CGRectMake(20, 20 + 8, 28, 28);
    backImageView.contentMode =  UIViewContentModeScaleAspectFit;
    backImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *backListener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goback)];
    [backImageView addGestureRecognizer:backListener];
    backImageView.clipsToBounds  = YES;
    [self.view addSubview:backImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 22, screenWidth - 100, 22)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:titleLabel];
    
    subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 42, screenWidth - 100, 20)];
    subtitleLabel.textColor = [UIColor whiteColor];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.numberOfLines = 1;
    subtitleLabel.text = @"设备状态：连接";
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:subtitleLabel];
    
    zoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 60, 20, 44, 44)];
    zoneLabel.textColor = [UIColor whiteColor];
    zoneLabel.textAlignment = NSTextAlignmentRight;
    zoneLabel.text = @"防区";
    zoneLabel.font = [UIFont systemFontOfSize:17];
    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(zoneOnclickListener)];
    [zoneLabel addGestureRecognizer:onclickListener];
    zoneLabel.userInteractionEnabled = YES;
    [self.view addSubview:zoneLabel];
}

- (void) addTopView{
    CGFloat topHeight = 80 + 2;
    CGFloat topY = 20 + 44 + 2;
    childViewsY += topHeight;
    
    UIImageView* statusBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_device_detail_status.png"]];
    statusBgImageView.frame = CGRectMake(8, topY, 80 , 80);
    statusBgImageView.contentMode =  UIViewContentModeScaleToFill;
    statusBgImageView.clipsToBounds  = YES;
    [self.view addSubview:statusBgImageView];
    
    UIImageView* zoneBgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_device_detail_zone.png"]];
    zoneBgImageView.frame = CGRectMake(8 + 80, topY, screenWidth - 8 - 8 - 80, 80);
    zoneBgImageView.contentMode =  UIViewContentModeScaleToFill;
    zoneBgImageView.clipsToBounds  = YES;
    [self.view addSubview:zoneBgImageView];
    
    statusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_device_safety.png"]];
    statusImageView.frame = CGRectMake(8 + 20, topY + 10, 40 , 40);
    statusImageView.contentMode =  UIViewContentModeScaleToFill;
    statusImageView.clipsToBounds  = YES;
    [self.view addSubview:statusImageView];
    
    statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, topY + 50, 80 , 30)];
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.textAlignment = NSTextAlignmentCenter;
    statusLabel.text = @"布防";
    statusLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:statusLabel];
}

- (void) addCollectionView{
    CGFloat topY = 20 + 44 + 2 + 6;
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    //设置每个单元格的尺寸
    layout.itemSize = CGSizeMake((screenWidth - 16 - 80 - 4) / 4, 22);
    //设置整个CollectionView的内边距
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    //设置单元格之间的间距
    layout.minimumInteritemSpacing = 0;
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(8 + 80, topY, screenWidth - 8 - 8 - 80, 80 - 6) collectionViewLayout:layout];
    //设置可重用单元格标识与单元格类型
    //    [collectionView registerNib:[ZoneViewCell class]  forCellWithReuseIdentifier:CellIdentifierZone];
    [collectionView registerNib:[UINib nibWithNibName:@"ZoneViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifierZone];
    
    collectionView.backgroundColor = [CWColorUtils colorWithHexString:@"#ffffff" alpha:0.0f];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    
    [self.view addSubview:collectionView];
}

- (void) initTableView{
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, childViewsY, screenWidth, screenHeight - childViewsY) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    //分割线颜色
    tableView.separatorColor = [UIColor whiteColor];
    tableView.backgroundColor = [UIColor whiteColor];
    
    //本地模式（自己）
    [tableView registerClass:[DeviceMessageLocalCell class] forCellReuseIdentifier:CellIdentifierLocal];
    //服务器返回模式（接受到的消息）
    [tableView registerClass:[DeviceMessageServerCell class] forCellReuseIdentifier:CellIdentifierServer];
    
    [self.view addSubview:tableView];
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉加载更多消息"];
    [refreshControl addTarget:self action:@selector(refreshClick:) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
}

- (void) addUnreadLabel{
    unreadTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 90, childViewsY + 10, 80, 30)];
    unreadTipLabel.textAlignment = NSTextAlignmentRight;
    unreadTipLabel.font = [UIFont systemFontOfSize:15];
    unreadTipLabel.textColor = [UIColor redColor];
    unreadTipLabel.backgroundColor = [CWColorUtils colorWithHexString:@"eeeeee" alpha:0.5];
    //    unreadTipLabel.text = @"78条未读消息";
    UITapGestureRecognizer *onclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(unreadOnclickListener)];
    [unreadTipLabel addGestureRecognizer:onclickListener];
    unreadTipLabel.userInteractionEnabled = YES;
    
    //设置绘制的圆角
    unreadTipLabel.layer.masksToBounds = YES;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:unreadTipLabel.bounds  byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft cornerRadii:CGSizeMake(14, 14)];//设置圆角大小，弧度为5
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = unreadTipLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    unreadTipLabel.layer.mask = maskLayer;
    unreadTipLabel.hidden = YES;
    [self.view addSubview:unreadTipLabel];
}

- (void) addControlMenu{
    CGFloat memuSize = 40;
    CGFloat memuY = screenHeight - memuSize - 30;
    
    showMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_hide.png"]];
    showMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
    showMenu.contentMode =  UIViewContentModeScaleToFill;
    showMenu.clipsToBounds  = YES;
    showMenu.userInteractionEnabled = YES;
    UITapGestureRecognizer *listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuControl:)];
    [showMenu addGestureRecognizer:listener];
    [self.view addSubview:showMenu];
    memuY = memuY - 8 - memuSize;
    
    BOOL isOnline = NO;
    char *online = [[CWThings4Interface sharedInstance] get_var_with_path:[_deviceStatusModel.tid UTF8String] path:"online" sessions:NO];
    if (online && strcmp(online, "true") == 0) {
        isOnline = YES;
    }
    
    if (!isOnline) {
        return;
    }
    
    BOOL capture = NO;
    BOOL away = NO;
    BOOL pass = NO;
    BOOL video = NO;
    BOOL record = NO;
    
    if ([_deviceStatusModel.partID isEqualToString:@"1001"] || [_deviceStatusModel.partID isEqualToString:@"1002"]) {
        away = YES;
        pass = YES;
    } else if ([_deviceStatusModel.partID isEqualToString:@"2000"]){
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"zones"];
        if (count > 0) {
            capture = YES;
            away = YES;
            pass = YES;
            video = YES;
            record = YES;
        } else {
            capture = YES;
            video = YES;
            record = YES;
        }
    }
    
    if (record) {
        recordMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_record.png"]];
        recordMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
        recordMenu.contentMode =  UIViewContentModeScaleToFill;
        recordMenu.clipsToBounds  = YES;
        recordMenu.hidden = YES;
        recordMenu.userInteractionEnabled = YES;
        UITapGestureRecognizer *record_listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(recordControl:)];
        [recordMenu addGestureRecognizer:record_listener];
        [self.view addSubview:recordMenu];
        memuY = memuY - 8 - memuSize;
    }
    
    if (video) {
        videoMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_video.png"]];
        videoMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
        videoMenu.contentMode =  UIViewContentModeScaleToFill;
        videoMenu.clipsToBounds  = YES;
        videoMenu.hidden = YES;
        videoMenu.userInteractionEnabled = YES;
        UITapGestureRecognizer *video_listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoControl:)];
        [videoMenu addGestureRecognizer:video_listener];
        [self.view addSubview:videoMenu];
        memuY = memuY - 8 - memuSize;
    }
    
    if (pass) {
        passMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_pass.png"]];
        passMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
        passMenu.contentMode =  UIViewContentModeScaleToFill;
        passMenu.clipsToBounds  = YES;
        passMenu.hidden = YES;
        passMenu.userInteractionEnabled = YES;
        UITapGestureRecognizer *pass_listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(passControl:)];
        [passMenu addGestureRecognizer:pass_listener];
        [self.view addSubview:passMenu];
        memuY = memuY - 8 - memuSize;
    }
    
    if (away) {
        awayMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_away.png"]];
        awayMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
        awayMenu.contentMode =  UIViewContentModeScaleToFill;
        awayMenu.clipsToBounds  = YES;
        awayMenu.hidden = YES;
        awayMenu.userInteractionEnabled = YES;
        UITapGestureRecognizer *away_listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(awayControl:)];
        [awayMenu addGestureRecognizer:away_listener];
        [self.view addSubview:awayMenu];
        memuY = memuY - 8 - memuSize;
    }
    
    if (capture) {
        captureMenu = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_floating_button_capture.png"]];
        captureMenu.frame = CGRectMake(screenWidth - memuSize - 20, memuY, memuSize, memuSize);
        captureMenu.contentMode =  UIViewContentModeScaleToFill;
        captureMenu.clipsToBounds  = YES;
        captureMenu.hidden = YES;
        captureMenu.userInteractionEnabled = YES;
        UITapGestureRecognizer *capture_listener = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captureControl:)];
        [captureMenu addGestureRecognizer:capture_listener];
        [self.view addSubview:captureMenu];
        memuY = memuY - 8 - memuSize;
    }
}

- (void) showMenuControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:_isHideMenu];
}

/**
 * 抓图
 */
- (void) captureControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:YES];
    if ([self checkViewdoDevice]) {
        if (self.channelArray.count == 1) {
            NSString* sendCmd = [NSString stringWithFormat:@"%@,,cmd,capture,0,%@,0,1", _deviceStatusModel.tid, [_channelArray objectAtIndex:0]];
            [[CWThings4Interface sharedInstance] push_msg:[sendCmd UTF8String] MsgLen:(int)sendCmd.length MsgType:"im"];
        } else {
            ChannelAlertView *channelAlertView = [[ChannelAlertView alloc] initWithDefaultStyle:self.channelArray];
            channelAlertView.resultIndex = ^(NSString* channel, NSInteger index){
                NSString* sendCmd = [NSString stringWithFormat:@"%@,,cmd,capture,0,%@,0,1", _deviceStatusModel.tid, [_channelArray objectAtIndex:index]];
                [[CWThings4Interface sharedInstance] push_msg:[sendCmd UTF8String] MsgLen:(int)sendCmd.length MsgType:"im"];
            };
            
            [channelAlertView show];
        }
        
    }else{
        [self showToast:@"该设备目前没有视频通道!"];
    }
}

- (void) passControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:YES];
    NSLog(@"passControl");
}

- (void) awayControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:YES];
    NSLog(@"awayControl");
}

- (void) videoControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:YES];
    NSLog(@"videoControl");
}

- (void) recordControl:(UIGestureRecognizer *)gestureRecognizer{
    [self showMenu:YES];
    NSLog(@"recordControl");
}

- (void) showMenu:(BOOL)show{
    if (show) {
        _isHideMenu = NO;
        showMenu.image = [UIImage imageNamed:@"icon_floating_button_hide.png"];
        if (captureMenu) {
            captureMenu.hidden = YES;
        }
        if (awayMenu) {
            awayMenu.hidden = YES;
        }
        if (passMenu) {
            passMenu.hidden = YES;
        }
        if (videoMenu) {
            videoMenu.hidden = YES;
        }
        if (recordMenu) {
            recordMenu.hidden = YES;
        }
    }else{
        _isHideMenu = YES;
        showMenu.image = [UIImage imageNamed:@"icon_floating_button_show.png"];
        if (captureMenu) {
            captureMenu.hidden = NO;
        }
        if (awayMenu) {
            awayMenu.hidden = NO;
        }
        if (passMenu) {
            passMenu.hidden = NO;
        }
        if (videoMenu) {
            videoMenu.hidden = NO;
        }
        if (recordMenu) {
            recordMenu.hidden = NO;
        }
    }
}

/**
 * 检查设备的视频通道数，如果为0，则不具备抓图、视频和录像功能
 * return 视频通道数
 */
- (BOOL) checkViewdoDevice{
    if ([CWDataManager sharedInstance].videoRight) {
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"dev.videos"];
        
        [self.channelArray removeAllObjects];
        
        for (int i = 0; i < count; i ++) {
            char* channel_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"dev.videos" member:i backpath:NULL];
            
            if (channel_name && strcmp(channel_name, "default") == 0) {
                continue;
            }

            [self.channelArray addObject:[NSString stringWithFormat:@"*.%@", [NSString stringWithUTF8String:channel_name]]];
        }
        
        if (self.channelArray.count> 0) {
            return YES;
        }
        
    }else{
        [self showToast:@"没有操作权限!"];
        return NO;
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated{
    if (message_update_timer == nil) {
        float palFrame = 1.0;
        message_update_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(message_update_func) userInfo:nil repeats:YES];
    }
    
    _deviceStatusModel.unread_count = 0;
    
    [self updateDeviceInfo];
    [refreshControl beginRefreshing];
    [self refreshClick:refreshControl];
    
}

- (void) viewWillDisappear:(BOOL)animated{
    if (message_update_timer) {
        [message_update_timer invalidate];
        message_update_timer = nil;
    }
    
    _deviceStatusModel.unread_count = 0;
    [[CWDataManager sharedInstance] saveUnreadEvent4Things:_deviceStatusModel.tid value:0];
    
}

// 下拉刷新触发，在此获取数据
- (void)refreshClick:(UIRefreshControl *) refreshControl {
    if (refreshControl.refreshing) {
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"加载中..."];
        [self loadMessageData:YES];
        _isRefreshing = YES;
    }
}

//加载防区等信息
- (void) updateDeviceInfo{
    if (_deviceStatusModel) {
        if (_deviceStatusModel.caption != nil) {
            titleLabel.text = _deviceStatusModel.caption;
        }else{
            titleLabel.text = @"设备";
        }
        
        if(_deviceStatusModel.isDeviceOpen){
            statusLabel.text = @"撤防";
            statusImageView.image = [UIImage imageNamed:@"icon_device_alarm.png"];
        }else{
            statusLabel.text = @"布防";
            statusImageView.image = [UIImage imageNamed:@"icon_device_safety.png"];
        }
        
        if ([_deviceStatusModel.globalSatus isEqualToString:@"0"]) {
            subtitleLabel.text = @"设备状态：断开";
        }else if ([_deviceStatusModel.globalSatus isEqualToString:@"1"]) {
            subtitleLabel.text = @"设备状态：连接";
        }else {
            subtitleLabel.text = @"设备状态：未知";
        }
    }
    
    //load zone data
    [self.zoneArray removeAllObjects];
    
    if ([_deviceStatusModel.partID isEqualToString:@"2000"]) {
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"zones"];
        //后台数据的顺序是倒叙的，无奈重新排序
        for (int i = count - 1; i >= 0; i --) {
            DeviceZoneModel* zoneModel = [[DeviceZoneModel alloc] init];
            
            char* channel_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"zones" member:i backpath:NULL];
            
            if (channel_name && strcmp(channel_name, "default") == 0) {
                continue;
            }
            zoneModel.name = [NSString stringWithUTF8String:channel_name];
            
            char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"zones" member:i backpath:"stat"];
            
            zoneModel.status = [NSString stringWithUTF8String:zone_status];
            
            [self.zoneArray addObject:zoneModel];
        }
    }else{
        int count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_deviceStatusModel.tid UTF8String] path:"z"];
        //后台数据的顺序是倒叙的，无奈重新排序
        for (int i = count - 1; i >= 0; i --) {
            DeviceZoneModel* zoneModel = [[DeviceZoneModel alloc] init];
            
            char* channel_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"z" member:i backpath:NULL];
            if (channel_name && strcmp(channel_name, "default") == 0) {
                continue;
            }
            zoneModel.name = [NSString stringWithUTF8String:channel_name];
            
            //            NSLog(@"count = %d   channel_name: %s", count, channel_name);
            char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_deviceStatusModel.tid UTF8String] prepath:"z" member:i backpath:"s"];
            zoneModel.status = [NSString stringWithUTF8String:zone_status];
            
            [self.zoneArray addObject:zoneModel];
        }
    }
    
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.zoneArray.count;
}

#pragma mark - UICollectionViewDelegate
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZoneViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifierZone forIndexPath:indexPath];
    
    DeviceZoneModel* model = [self.zoneArray objectAtIndex:indexPath.row];
    
    cell.contentLabel.text = model.name;
    
    if ([model.status isEqualToString:@"alarm"]) {
        cell.contentLabel.textColor = [UIColor redColor];
    }else if ([model.status isEqualToString:@"bypass"]) {
        cell.contentLabel.textColor = [UIColor orangeColor];
    }else if ([model.status isEqualToString:@"nr"] || [model.status isEqualToString:@"na"]) {
        cell.contentLabel.textColor = [UIColor blackColor];
    }else{
        cell.contentLabel.textColor = [CWColorUtils getThemeColor];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select indexPath.row : %lu", indexPath.row);
}

#pragma mark --UITableViewDataSource 协议方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    DeviceMessageModel* messageModel = [self.dataArray objectAtIndex:index];
    
    if (messageModel.messageType == MessageTypeForLOCAL) {
        //自己发出的消息
        DeviceMessageLocalCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierLocal forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceMessageLocalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierLocal];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.timeLabel.text = messageModel.dateTime;
        cell.contentLabel.text = messageModel.text;
        
        return cell;
        
    }else{
        //接收的消息
        DeviceMessageServerCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierServer forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[DeviceMessageServerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierServer];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.timeLabel.text = messageModel.dateTime;
        
        NSString* contentText = messageModel.text;
        if (contentText) {
            cell.contentLabel.hidden = NO;
            cell.photoImageView.hidden = YES;
            
            CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 40 - 14 - 40 - 14;
            cell.contentLabel.frame = CGRectMake(40 + 14, 10 + 12 + 16 + 4, labelWidth, messageModel.cellHeight - 10 - 12 - 16 - 4 - 8);
            
            //设置圆角
            cell.contentLabel.layer.masksToBounds = YES;
            cell.contentLabel.layer.cornerRadius = 4;
            
            if(messageModel.backgroundType == 1) {
                cell.contentLabel.backgroundColor = [CWColorUtils colorWithHexString:@"#f28c8c"];
            }else if(messageModel.backgroundType == 5) {
                cell.contentLabel.backgroundColor = [CWColorUtils colorWithHexString:@"#f5c790"];
            }else if(messageModel.backgroundType == 8) {
                cell.contentLabel.backgroundColor = [CWColorUtils colorWithHexString:@"#d1ec8f"];
            }else if(messageModel.backgroundType == 9) {
                cell.contentLabel.backgroundColor = [CWColorUtils colorWithHexString:@"#ffff66"];
            }else{
                cell.contentLabel.backgroundColor = [UIColor whiteColor];
            }
            
            contentText = [contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            contentText = [contentText stringByReplacingOccurrencesOfString:@"\\\\r\\\\n" withString:@"\r"];
            contentText = [contentText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
            cell.contentLabel.text = contentText;
            
        }else{
            cell.contentLabel.hidden = YES;
            cell.photoImageView.hidden = NO;
            
            if (messageModel.smallImage){
                cell.photoImageView.image = messageModel.smallImage;
            }else if (messageModel.imageName) {
                cell.photoImageView.image = [UIImage imageNamed:messageModel.imageName];
            }
            
        }
        
        return cell;
    }
    
    return nil;
}

/**
 *  给出cell的估计高度，主要目的是优化cell高度的计算次数
 */
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [indexPath row];
    DeviceMessageModel* messageModel = [self.dataArray objectAtIndex:index];
    
    if (messageModel.messageType == MessageTypeForLOCAL) {
        CGFloat cellHeight = [DeviceMessageLocalCell getCellHeight];
        messageModel.cellHeight = cellHeight;
        return cellHeight;
    }else{
        CGFloat cellHeight = [DeviceMessageServerCell getCellHeight:messageModel];
        messageModel.cellHeight = cellHeight;
        return cellHeight;
    }
    
    return 0;
}

// like item click listener
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceMessageModel* messageModel = [self.dataArray objectAtIndex:indexPath.row];
    
    //点击显示大图
    if (messageModel.messageType == MessageTypeForServer && !messageModel.text){
        
        if (_imageArray == nil) {
            _imageArray = [NSMutableArray new];
        }else {
            [_imageArray removeAllObjects];
        }
        
        int image_count = 0;
        int current_image_index = 0;
        for (DeviceMessageModel* model in self.dataArray) {
            if (model && model.smallImage) {
                [_imageArray addObject:model];
                if (messageModel == model) {
                    current_image_index = image_count;
                }
                image_count++;
            }
        }
        
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.currentImageIndex = current_image_index;
        browser.sourceImagesContainerView = tableView;
        browser.imageCount = image_count;
        browser.delegate = self;
        [browser show];
    }
}

#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    DeviceMessageModel* messageModel = [self.imageArray objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:messageModel.imageName];
    return url;
}

#pragma mark - SDPhotoBrowserDelegate 返回默认的占位图片
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index{
//    return [UIImage imageNamed:@"img_empty_conwin.png"];
    return nil;
}


- (void) goback{
    //back to device controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to device ");
    }];
}

- (void) zoneOnclickListener{
    NSLog(@"zoneOnclickListener");
    ZoneViewController* zoneVC = [[ZoneViewController alloc] init];
    zoneVC.deviceStatusModel= _deviceStatusModel;
    UINavigationController* navigationController = [[UINavigationController alloc]
                                                    initWithRootViewController:zoneVC];
    [self presentViewController:navigationController animated:TRUE completion:nil];
}

- (NSMutableArray *) dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

- (void) message_update_func{
    if ([CWDataManager sharedInstance]->chat_message_update == YES) {
        //load message data
        self.dataArray = [[CWDataManager sharedInstance] getChatMessageArray4Tid:_deviceStatusModel.tid];

        NSInteger messageCountInteger = [self.dataArray count] - _preMessageCount;
        if (messageCountInteger) {
            if (!_isEndOfTableView && !_isRefreshing) {
                unreadTipLabel.hidden = NO;
                unreadTipLabel.text = [NSString stringWithFormat:@"%lu条新消息", messageCountInteger];
            }

            if (_isRefreshing) {
                _isRefreshing = NO;
            }
        }
        
        [CWDataManager sharedInstance]->chat_message_update = NO;
        
        _preMessageCount = [self.dataArray count];
        [tableView reloadData];
        [refreshControl endRefreshing];
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉加载更多消息"];
        
        if (_isEndOfTableView && _preMessageCount > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0];
            if (indexPath != nil) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
    
    [self updateInfo];
    [self updateDeviceInfo];
}

/*
 * 加载消息数据
 */
- (void) loadMessageData:(BOOL)more{
    char cmd[128] = {0};
    if ([self.dataArray count]) {
        DeviceMessageModel *chat_model = [self.dataArray objectAtIndex:0];
        if (chat_model && more) {
            if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
                sprintf(cmd, "/get_msg_of?tid=%s&mode=before&mid=%ld&cnt=%d", [_deviceStatusModel.tid UTF8String], (long)chat_model.mid, 10);
            }else {
                sprintf(cmd, "/message/last?of=%s&limit=%d&dir=before&mid=%ld", [_deviceStatusModel.tid UTF8String], 10, (long)chat_model.mid);
            }
        }
    }else {
        NSMutableArray *messageArray = [[CWDataManager sharedInstance] getChatMessageArray4Tid:_deviceStatusModel.tid];
        if (messageArray == nil || [messageArray count] == 0) {
            if ([[CWDataManager sharedInstance] isOldSystemVersion]) {
                sprintf(cmd, "/get_msg_of?tid=%s&mode=%s&cnt=%ld", [_deviceStatusModel.tid UTF8String], "last", (long)10);
            }else {
                sprintf(cmd, "/message/last?of=%s&limit=%d", [_deviceStatusModel.tid UTF8String], 10);
            }
        }else {
            self.dataArray = messageArray;
        }
    }
    
    if (strlen(cmd) > 0) {
        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"messageLast"];
    }else {
        [tableView reloadData];
        [refreshControl endRefreshing];
        refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉加载更多消息"];
        
        if (_preMessageCount < 4) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0];
            if (indexPath != nil) {
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
            _preMessageCount = [self.dataArray count];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint contentOffsetPoint = tableView.contentOffset;
    CGRect frame = tableView.frame;
    NSLog(@"[contentOffsetPoint.y = %f  tableViewHeight: %f  frameheight: %f" , contentOffsetPoint.y , tableView.contentSize.height , frame.size.height);
    if (tableView.contentSize.height - frame.size.height - contentOffsetPoint.y < 1 || tableView.contentSize.height < frame.size.height){
        _isEndOfTableView = YES;
        
        if (!unreadTipLabel.isHidden) {
            unreadTipLabel.hidden = YES;
        }
        
        _preMessageCount = [self.dataArray count];
    }else{
        _isEndOfTableView = NO;
    }
}

//点击未读消息，滚动到底部，查阅最新的消息
- (void) unreadOnclickListener{
    _preMessageCount = [self.dataArray count];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.dataArray count] - 1) inSection:0];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    unreadTipLabel.hidden = YES;
    _isEndOfTableView = YES;
}

- (void) updateInfo{
    NSString* tid = _deviceStatusModel.tid;
    if (tid) {
        //设备状态
        char *device_status;
        if ([_deviceStatusModel.partID isEqualToString:@"2000"]) {
            device_status= [[CWThings4Interface sharedInstance] get_var_with_path_ex:[tid UTF8String] prepath:"areas" member:0 backpath:"stat"];
        }else{
            if ([_deviceStatusModel.partID isEqualToString:@"1100"] || [_deviceStatusModel.partID isEqualToString:@"1101"] || [_deviceStatusModel.partID isEqualToString:@"1104"]) {
                device_status = [[CWThings4Interface sharedInstance] get_var_with_path:[tid UTF8String] path:"pnl.r.s" sessions:YES];
            }else{
                device_status = [[CWThings4Interface sharedInstance] get_var_with_path:[tid UTF8String] path:"pnl.s.s" sessions:YES];
            }
        }
        
        NSString* deviceStatusString;
        if (device_status) {
            deviceStatusString = [NSString stringWithUTF8String:device_status];
        }
        
        //防区状态
        BOOL isZoneAlarm = NO;
        char* zone_status = [[CWThings4Interface sharedInstance] get_var_with_path:[tid UTF8String] path:"zones" sessions:YES];
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
        char *online = [[CWThings4Interface sharedInstance] get_var_with_path:[tid UTF8String] path:"online" sessions:NO];
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
        if (!isOnline || ![_deviceStatusModel.deviceType isEqualToString:@"device"]) {
            statusNumber = 9;
        }else if (deviceStatusString == nil || deviceStatusString.length == 0) {
            statusNumber = 18;
        }else{
            if ([deviceStatusString isEqualToString:@"open"]) {
                if (isZoneAlarm) {
                    statusNumber = 13;
                    _deviceStatusModel.isDeviceOpen = YES;
                }else{
                    statusNumber = 12;
                    _deviceStatusModel.isDeviceOpen = YES;
                }
            }else if([deviceStatusString isEqualToString:@"away"] || [deviceStatusString isEqualToString:@"away delay"] || [deviceStatusString isEqualToString:@"away entery delay"]){
                if (isZoneAlarm) {
                    statusNumber = 11;
                    _deviceStatusModel.isDeviceOpen = NO;
                }else{
                    statusNumber = 10;
                    _deviceStatusModel.isDeviceOpen = NO;
                }
            }else if([deviceStatusString isEqualToString:@"stay"] || [deviceStatusString isEqualToString:@"stay delay"] || [deviceStatusString isEqualToString:@"stay entery delay"]){
                if (isZoneAlarm) {
                    statusNumber = 15;
                    _deviceStatusModel.isDeviceOpen = YES;
                }else{
                    statusNumber = 14;
                    _deviceStatusModel.isDeviceOpen = NO;
                }
            }else if([deviceStatusString isEqualToString:@"nr"]){
                if (isZoneAlarm) {
                    statusNumber = 17;
                    _deviceStatusModel.isDeviceOpen = YES;
                }else{
                    statusNumber = 16;
                    _deviceStatusModel.isDeviceOpen = NO;
                }
            }else if([deviceStatusString isEqualToString:@"na"]){
                if (isZoneAlarm) {
                    statusNumber = 19;
                    _deviceStatusModel.isDeviceOpen = YES;
                }else{
                    statusNumber = 18;
                    _deviceStatusModel.isDeviceOpen = NO;
                }
            }else{
                _deviceStatusModel.isDeviceOpen = NO;
            }
        }
        
        //全局状态
        NSString* connected = @"-1";
        if([_deviceStatusModel.partID isEqualToString:@"1000"] || [_deviceStatusModel.partID isEqualToString:@"1001"] || [_deviceStatusModel.partID isEqualToString:@"1002"]){
            char* deviceConnectStr = [[CWThings4Interface sharedInstance] get_var_with_path:[tid UTF8String] path:"pnl.s.net.connected" sessions:YES];
            if (deviceConnectStr) {
                connected = [NSString stringWithUTF8String:deviceConnectStr];
            }
        }else{
            connected = isOnline ? @"1" : @"0";
        }
        _deviceStatusModel.globalSatus = connected;
        
    }
}

- (void) showToast:(NSString*) message{
    mbProgress = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:mbProgress];
    mbProgress.color = [CWColorUtils colorWithHexString:@"#00c7c7" alpha:0.8f];
    mbProgress.labelText = message;
    mbProgress.mode = MBProgressHUDModeText;
    
    //指定距离中心点的X轴和Y轴的偏移量，如果不指定则在屏幕中间显示
    mbProgress.yOffset = [UIScreen mainScreen].bounds.size.height / 4 ;
    //mbProgress.xOffset = 100.0f;
    
    [mbProgress showAnimated:YES whileExecutingBlock:^{
        sleep(2);
    } completionBlock:^{
        [mbProgress removeFromSuperview];
        mbProgress = nil;
    }];
}


@end


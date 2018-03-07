//
//  VideoPlayViewController.m
//  ThingsIOSClient
//
//  Created by yeung on 05/01/16.
//  Copyright © 2016年 yeung . All rights reserved.
//

#import "PlayViewController.h"
#import "VideoPlayView.h"
#import "ColumnToolBar.h"
#import "VideoPlayerCell.h"
#import "CWThings4Interface.h"
#import "DHVideoDeviceHelper.h"
#import "ChannelInfoModel.h"
#import "ZFPlayer.h"
#import "UIView+SDAutoLayout.h"
#import "NSObject+BAProgressHUD.h"
#import "CWDataManager.h"
#import "CWFileUtils.h"
#import "CWColorUtils.h"

ZFPlayerView *gTYPlayerView = nil;

@interface PlayViewController () <VideoPlayViewDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    BOOL                is_full_screen_video;
    
    UITableView         *video_play_table_view;
    
    NSMutableArray      *device_channel_info;
    
    UILabel             *start_time_label_;
    UILabel             *end_time_label_;
    
    int                 selected_time_mode_;
    
    BOOL                video_sound;
    BOOL                video_talk;
    BOOL                video_res;
    
    BOOL                video_record_stop_play;
    
    //temp
    CGRect playerFrame;
}

@property (assign, nonatomic) NSInteger numberOfItemsInRow;

//@property (strong, nonatomic) UIImageView *background_image_view_;

@property (strong, nonatomic) ZFPlayerView *playerView;

@property (strong, nonatomic) ColumnToolBar *videoToolBar;

@property (strong, nonatomic) ColumnToolBar *recordToolBar;

@property (strong, nonatomic) ColumnToolBar *videoPlayTypeView;

@property (strong, nonatomic) UITableView       *tableView;

@property (nonatomic, strong) NSTimer           *handleTimer;

@property (nonatomic, assign) NSInteger         videoType;

@property (nonatomic, copy) NSString            *start_date_and_time;

@property (nonatomic, copy) NSString            *end_date_and_time;

@property (nonatomic, strong) NSMutableArray *channelArray;

@property (nonatomic, assign) BOOL isScrolling;
@end

@implementation PlayViewController{
    CGFloat screenHeight;
    CGFloat screenWidth;
    
    CGFloat chanelHeight;
    
    UIScrollView *channelScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    chanelHeight = 50;
    
    self.channelArray = [[NSMutableArray alloc] init];
    
    [[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
    
    [self createPlayer];
    [self createToolBar];
    [self addChanelScrollView];
    
    [self loadChannelList];
    [self showChannelArray];
    
    [self.playerView setVideoIsPlayingType:_VideoPlayFormat];
    [[DHVideoDeviceHelper sharedInstance] StartRealStream:_DeviceChannel withView:[_playerView getVideoWnd]];
    
    [_videoPlayTypeView selectButtonAtIndex:0 withClick:YES];

}

- (void) addChanelScrollView{
    channelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 20 + screenWidth * 9 / 16, screenWidth, chanelHeight)];
    [channelScrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:channelScrollView];
    //设置不显示横拉动条
    channelScrollView.showsHorizontalScrollIndicator = NO;
    //设置反弹效果
    channelScrollView.bounces = YES;
    //决定是否可以滚动
    //navigationController 默认为yes 自动调整uiscrollview的高度inset大小
    self.automaticallyAdjustsScrollViewInsets = NO;
}

//fill the channel array in the scroll view
- (void) showChannelArray{
    if (self.channelArray.count > 0) {
        NSString* title;
        BOOL showChannelName = [[CWFileUtils sharedInstance] showChannelName];
        if (showChannelName) {
            title = @"ch";
        }else{
            title = @"通道";
        }
        
        int widthX = 0;
        for (int i = 0; i< self.channelArray.count; i ++) {
            ChannelInfoModel *model = [self.channelArray objectAtIndex:i];
            
            UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(widthX, 5, 80, chanelHeight - 5 - 5)];
            [lable setText:[NSString stringWithFormat:@"%@%@", title, model.channelName]];
            [channelScrollView addSubview:lable];
            [lable setTag:i];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.textColor = [UIColor grayColor];
            lable.userInteractionEnabled=YES;
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(channelClickListener:)];
            [lable addGestureRecognizer:recognizer];
            widthX += 80 + 8;
        }
        
        CGSize size = channelScrollView.contentSize;
        size.width = widthX;
        channelScrollView.contentSize = size;
    }
}

// channel click listener
-(void) channelClickListener:(UITapGestureRecognizer *)recognizer{
    UILabel *label = (UILabel*)recognizer.view;
    NSInteger position = label.tag;
    NSLog(@"点击了通道 %lu ", position);
    
    if ([[DHVideoDeviceHelper sharedInstance] isStartRealStreamFinished] == NO) {
        [self BA_showAlert:NSLocalizedString(@"正连接实时视频内容，请稍后", @"")];
        return ;
    }

    ChannelInfoModel *channel_model  = [self.channelArray objectAtIndex:position];
    NSInteger chanIndex = [channel_model.channelName integerValue];
    
    _DeviceChannel = chanIndex - 1;
    
    if ([[DHVideoDeviceHelper sharedInstance] isPlayingSound]) {
        [_videoToolBar selectButtonAtIndex:1 withClick:NO];
    }
    if ([[DHVideoDeviceHelper sharedInstance] isTalking]) {
        [_videoToolBar selectButtonAtIndex:0 withClick:NO];
    }
    
    [[DHVideoDeviceHelper sharedInstance] StartRealStream:_DeviceChannel withView:[_playerView getVideoWnd]];
  
}

// 滑动事件
//-(void)handleMoveFrom:(UISwipeGestureRecognizer *)swipe
//{
//    if(swipe.direction == UISwipeGestureRecognizerDirectionRight){
//        //[self showLeft];
//    }
//    if(swipe.direction == UISwipeGestureRecognizerDirectionLeft){
//        //[self showRight];
//    }
//}

- (void)createPlayer{
    //status bar to black color
//    UIView *topView = [[UIView alloc] init];
//    topView.backgroundColor = [UIColor blackColor];
//    [self.view addSubview:topView];
//    [topView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.equalTo(self.view);
//        make.height.mas_offset(20);
//    }];
    
    //self.playerView = [ZFPlayerView new];
    self.playerView = [[ZFPlayerView alloc] init];
    gTYPlayerView = self.playerView;
    [self.view addSubview:self.playerView];
    self.playerView.playerLayerGravity = ZFPlayerLayerGravityResize;
    self.playerView.videoURL = [NSURL URLWithString:@""];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
        make.height.equalTo(self.playerView.mas_width).multipliedBy(9.0f / 16.0f).with.priority(750);
    }];
    
    // Back button event
    __weak typeof(self) weakSelf = self;
    
    self.playerView.fullScreenBlock = ^(BOOL isFullScreen){
        if (isFullScreen) {
            [weakSelf.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.view).offset(20);
                make.left.right.equalTo(weakSelf.view);
                make.bottom.equalTo(weakSelf.view);
                // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
                make.height.equalTo(weakSelf.playerView.mas_width).multipliedBy(9.0f / 16.0f).with.priority(750);
            }];
        }
        else {
            [weakSelf.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.view).offset(20);
                make.left.right.equalTo(weakSelf.view);
                // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9.0f / 16.0f).with.priority(750);
            }];
        }
    };
    
    self.playerView.goBackBlock = ^{
//        [weakSelf.navigationController popViewControllerAnimated:YES];
        [weakSelf dismissViewControllerAnimated:TRUE completion:^{
            NSLog(@"back to device detial");
        }];
    };
    
//    self.playerView.changeVideoBlock = ^(NSInteger index){
//        NSLog(@"change video type---%ld", (long)index);
//        _videoType = index;
//
//        if (index == 1) {
//            if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished] == NO) {
//                [weakSelf BA_showAlert:NSLocalizedString(@"VideoController_IsFindingRecordFile", @"")];
//                return ;
//            }
//            [weakSelf getDeviceInfo];
//            [weakSelf.tableView reloadData];
//
//            weakSelf.videoToolBar.hidden = NO;
//            weakSelf.recordToolBar.hidden = YES;
//        }
//        else {
//            //_isFindRecordFiles = YES;
//            weakSelf.videoToolBar.hidden = YES;
//            weakSelf.recordToolBar.hidden = NO;
//            NSDate *now = [NSDate date];
//            NSCalendar *calendar = [NSCalendar currentCalendar];
//            NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
//            NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
//
//            weakSelf.start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
//            weakSelf.end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
//
//
//            float palFrame = 1.0;
//            if (weakSelf.handleTimer == nil) {
//                weakSelf.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:weakSelf selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
//            }
//
//            [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:weakSelf.DeviceChannel withStartTime:weakSelf.start_date_and_time withEndTime:weakSelf.end_date_and_time];
//        }
//    };
}

//- (void) recordDateUpdate
//{
//    if ([[DHVideoDeviceHelper sharedInstance] getVideoSearch] == YES) {
//        self.dataArray = [DHVideoDeviceHelper sharedInstance]->video_record_files_array;
//        [_tableView reloadData];
//
//        [_handleTimer invalidate];
//        _handleTimer = nil;
//        //_isLocalFindRecordFiles = NO;//表示录像列表不是在本界面搜索出来的
//        [self BA_hideProgress];
//    }
//    else {
//        /*if (_videoType == 2 && _isFirstInit == YES) {
//         if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished]) {
//         [self BA_hideProgress];
//         }
//         }*/
//    }
//}

//- (void) createVideoTypeView
//{
//    ColumnToolBarSetting *titlesSetting = [[ColumnToolBarSetting alloc] init];
//    titlesSetting.titlesArr = @[NSLocalizedString(@"VideoController_RealVideoTitle", @""), NSLocalizedString(@"VideoController_RecordVideoTitle", @"")];
//    titlesSetting.textColor = [UIColor whiteColor];
//    titlesSetting.buttonDisable = YES;
//    //titlesSetting.frame = CGRectMake(0, 64, winSize.width, 48);
//
//    // 通过设置创建 SlideTitlesView
//    _videoPlayTypeView = [[ColumnToolBar alloc] initWithSetting:titlesSetting];
//    _videoPlayTypeView.delegate = self;
//    [self.view addSubview:_videoPlayTypeView];
//
//    _videoPlayTypeView.sd_layout
//    .leftSpaceToView(self.view, 0)
//    .rightSpaceToView(self.view, 0)
//    .topSpaceToView(self.playerView, 0)
//    .heightIs(48);
//}

- (void) createTableView
{
//    if (_videoType == 1) {
//        [self getDeviceInfo];
//    }
//    else {
//        float palFrame = 1.0;
//        if (self.handleTimer == nil) {
//            self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
//        }
//    }
    
    _tableView = [UITableView new];
    _tableView.hidden = NO;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    
    _tableView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.videoPlayTypeView, 1)
    .bottomSpaceToView(self.videoToolBar, 0);
}

- (void) createToolBar
{
    ColumnToolBarSetting *titlesSetting = [[ColumnToolBarSetting alloc] init];
    titlesSetting.titlesArr = @[NSLocalizedString(@"VideoController_Talk", @""), NSLocalizedString(@"VideoController_Sound", @""), NSLocalizedString(@"VideoController_Capture", @""), NSLocalizedString(@"VideoController_VideoResS", @"")];
    //titlesSetting.selectedTitlesArr = @[@"说话",@"监听",@"拍照", @"高清"];
    titlesSetting.imagesArr = @[@"icon_device_detail_system.png",@"icon_device_detail_system.png", @"icon_device_detail_system.png", @"icon_device_detail_system.png"];
    titlesSetting.selectedImagesArr = @[@"C201shuohua",@"C201jianting", @"C201paizhaodianji", @"C201gaoqingbai"];
    titlesSetting.textColor = [UIColor blackColor];
    titlesSetting.middleHidden = YES;
    titlesSetting.selectedTextColor = [UIColor blueColor];
    
    _videoToolBar = [[ColumnToolBar alloc] initWithSetting:titlesSetting];
    _videoToolBar.delegate = self;
    [self.view addSubview:_videoToolBar];
    
    _videoToolBar.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0)
    .heightIs(80);
    
    
    ColumnToolBarSetting *recordSetting = [[ColumnToolBarSetting alloc] init];
    recordSetting.titlesArr = @[@"今天",@"昨天",@"前天", @"选时"];
    recordSetting.imagesArr = @[@"C201jintian",@"C201zuotian", @"C201qiantian", @"C201xuanshi"];
    recordSetting.selectedImagesArr = @[@"C201jintianxuanzhong",@"C201zuotiandianji", @"C201qiantiandianji", @"C201xuanshidianji"];
    recordSetting.textColor = [UIColor whiteColor];
    recordSetting.selectedTextColor = [UIColor whiteColor];
    
    _recordToolBar = [[ColumnToolBar alloc] initWithSetting:recordSetting];
    _recordToolBar.delegate = self;
    [self.view addSubview:_recordToolBar];
    
    _recordToolBar.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0)
    .heightIs(80);
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) {
        self.view.backgroundColor = [UIColor whiteColor];
        //if use Masonry,Please open this annotation
        
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
        }];
        
        if (_videoType == 1) {
            self.videoToolBar.hidden = NO;
        }
        else if (_videoType == 2) {
            self.recordToolBar.hidden = NO;
        }
        _tableView.hidden = NO;
        self.videoPlayTypeView.hidden = NO;
        
    }else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight || toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        self.view.backgroundColor = [UIColor blackColor];
        //if use Masonry,Please open this annotation
        
        [self.playerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(0);
        }];
        
        if (_videoType == 1) {
            self.videoToolBar.hidden = YES;
        }
        else if (_videoType == 2) {
            self.recordToolBar.hidden = YES;
        }
        self.tableView.hidden = YES;
        self.videoPlayTypeView.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //[[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self.playerView stop];
    gTYPlayerView = nil;
    
    if (_VideoPlayFormat == 1) {
        [[DHVideoDeviceHelper sharedInstance] StopRealStream:_DeviceChannel];
    }
    else if (_VideoPlayFormat == 2) {
        [[DHVideoDeviceHelper sharedInstance] StopRecordStream:NO];
    }
    //[[DHVideoDeviceHelper sharedInstance] DisconnectDevice];
    [[CWDataManager sharedInstance] setIsNavBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO];
    
    [[DHVideoDeviceHelper sharedInstance] DisconnectDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadChannelList{
    [self.channelArray removeAllObjects];
    
    int channel_count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_tid UTF8String] path:"devs.videos"];
    if (channel_count > 0) {
        for (int i = 0; i < channel_count; i++) {
            char *chan_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_tid UTF8String] prepath:"devs.videos" member:i backpath:NULL];
            if (chan_name && strcmp(chan_name, "default") == 0) {
                continue;
            }

            NSString *channel_name = [[NSString alloc] initWithFormat:@"%s", chan_name];
            channel_name = [channel_name stringByReplacingOccurrencesOfString:@"ch" withString:NSLocalizedString(@"", @"")];
            ChannelInfoModel *channel_model = [[ChannelInfoModel alloc] init];
            channel_model.deviceName = _tid;
            channel_model.channelName = channel_name;
            [self.channelArray addObject:channel_model];
            
        }
    }else {
        channel_count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_tid UTF8String] path:"profile.devs.videos"];
        if (channel_count > 0) {
            for (int i = 0; i < channel_count; i++) {
                char *chan_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_tid UTF8String] prepath:"profile.devs.videos" member:i backpath:NULL];
                if (chan_name && strcmp(chan_name, "default") == 0) {
                    continue;
                }
                
                NSString *channel_name = [[NSString alloc] initWithFormat:@"%s", chan_name];
                channel_name = [channel_name stringByReplacingOccurrencesOfString:@"ch" withString:NSLocalizedString(@"", @"")];
                ChannelInfoModel *channel_model = [[ChannelInfoModel alloc] init];
                channel_model.deviceName = _tid;
                channel_model.channelName = channel_name;
                [self.channelArray addObject:channel_model];
            }
        }
    }
    
    int tid_count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_tid UTF8String] path:"parts"];
    for (int j = 0; j < tid_count; j++) {
        char *tid_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_tid UTF8String] prepath:"parts" member:j backpath:NULL];
        if (tid_name && strcmp(tid_name, "settings") == 0) {
            continue;
        }else if (tid_name) {
            char node_part_path[128] = {0};
            sprintf(node_part_path, "parts.%s.devs.videos", tid_name);
            int node_channel_count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_tid UTF8String] path:node_part_path];
            if (node_channel_count > 0) {
                for (int i = 0; i < node_channel_count; i++) {
                    char *chan_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_tid UTF8String] prepath:node_part_path member:i backpath:NULL];
                    if (chan_name && strcmp(chan_name, "default") == 0) {
                        continue;
                    }
                    
                    NSString *channel_name = [[NSString alloc] initWithFormat:@"%s", chan_name];
                    channel_name = [channel_name stringByReplacingOccurrencesOfString:@"ch" withString:NSLocalizedString(@"", @"")];
                    ChannelInfoModel *channel_model = [[ChannelInfoModel alloc] init];
                    channel_model.deviceName = [[NSString alloc] initWithUTF8String:tid_name];
                    channel_model.channelName = channel_name;
                    [self.channelArray addObject:channel_model];
                }
            }else {
                memset(node_part_path, 0, 128);
                sprintf(node_part_path, "parts.%s.profile.devs.videos", tid_name);
                node_channel_count = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[_tid UTF8String] path:node_part_path];
                if (node_channel_count > 0) {
                    for (int i = 0; i < node_channel_count; i++) {
                        char *chan_name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[_tid UTF8String] prepath:node_part_path member:i backpath:NULL];
                        if (chan_name && strcmp(chan_name, "default") == 0) {
                            continue;
                        }
                        
                        NSString *channel_name = [[NSString alloc] initWithFormat:@"%s", chan_name];
                        channel_name = [channel_name stringByReplacingOccurrencesOfString:@"ch" withString:NSLocalizedString(@"", @"")];
                        ChannelInfoModel *channel_model = [[ChannelInfoModel alloc] init];
                        channel_model.deviceName = [[NSString alloc] initWithUTF8String:tid_name];
                        channel_model.channelName = channel_name;
                        [self.channelArray addObject:channel_model];
                    }
                }
            }
        }
    }
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.channelArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (_videoType == 1) {
        ChannelInfoModel *model = [self.channelArray objectAtIndex:indexPath.row];
        static NSString *Identifier = @"VIDEO_PLAYER_CELL";
        VideoPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
        if (cell == nil) {
            cell = [[VideoPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        }
        
        [cell setModel:model];
        return cell;
//    }
//    else if (_videoType == 2){
//        CWRecordModel *model = [self.dataArray objectAtIndex:indexPath.row];
//        static NSString *Identifier = @"RECORD_PLAYER_CELL";
//        VideoPlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
//        if (cell == nil) {
//            cell = [[VideoPlayerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
//        }
//
//        [cell setRecordModel:model];
//        return cell;
//    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(3_0)
{
    VideoPlayerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        //cell.backgroundColor = [UIColor clearColor];
        [cell didDeselectedCell];
        
    }
    return ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VideoPlayerCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
//        if (_videoType == 1) {
            if ([[DHVideoDeviceHelper sharedInstance] isStartRealStreamFinished] == NO) {
                [self BA_showAlert:NSLocalizedString(@"VideoController_IsOpeningRealVideo", @"")];
                return ;
            }
            
            [cell didSelectedCell];
            
            ChannelInfoModel *channel_model  = [self.channelArray objectAtIndex:indexPath.row];
            NSString *channel_name = NSLocalizedString(@"VideoController_ChannelName", @"");
            int chanIndex = [[channel_model.channelName substringFromIndex:[channel_name length]] intValue];
            
            _DeviceChannel = chanIndex - 1;
            if ([[DHVideoDeviceHelper sharedInstance] isPlayingSound]) {
                [_videoToolBar selectButtonAtIndex:1 withClick:NO];
            }
            if ([[DHVideoDeviceHelper sharedInstance] isTalking]) {
                [_videoToolBar selectButtonAtIndex:0 withClick:NO];
            }
            
            [[DHVideoDeviceHelper sharedInstance] StartRealStream:_DeviceChannel withView:[_playerView getVideoWnd]];
            _VideoPlayFormat = 1;
            _videoToolBar.hidden = NO;
            _recordToolBar.hidden = YES;
//        }
//        else if (_videoType == 2) {
//            if ([[DHVideoDeviceHelper sharedInstance] isStartRecordStreamFinished] == NO) {
//                [self BA_showAlert:NSLocalizedString(@"VideoController_IsOpeningRecordVideo", @"")];
//                return ;
//            }
//            [cell didSelectedCell];
//
//
//            [[DHVideoDeviceHelper sharedInstance] StartRecordStream:indexPath.row withView:[_playerView getVideoWnd]];
//            _VideoPlayFormat = 2;
//            _videoToolBar.hidden = YES;
//            _recordToolBar.hidden = NO;
//        }
//
        [self.playerView setVideoIsPlayingType:_VideoPlayFormat];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [UIView new];
//    [view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
//
//    UIImageView* _menu_separator_image_view = [UIImageView new];
//    [_menu_separator_image_view setTag:20003];
//    UIImage *separator_image = [UIImage imageNamed:@"video_play_jindutiao"];
//    [_menu_separator_image_view setImage:separator_image];
//    [view addSubview:_menu_separator_image_view];
//    _menu_separator_image_view.sd_layout
//    .leftSpaceToView(view, 0)
//    .rightSpaceToView(view, 0)
//    .bottomSpaceToView(view, 0)
//    .heightIs(1);
//
//    UILabel *_tableHeaderLabel = [UILabel new];
//    [_tableHeaderLabel setTextColor:[UIColor whiteColor]];
//    [_tableHeaderLabel setTextAlignment:NSTextAlignmentLeft];
//    if (_videoType == 1) {
//        [_tableHeaderLabel setText:NSLocalizedString(@"VideoController_ChannelListTitle", @"")];
//    }
//    else if (_videoType == 2) {
//        [_tableHeaderLabel setText:NSLocalizedString(@"VideoController_RecordListTitle", @"")];
//    }
//    [view addSubview:_tableHeaderLabel];
//
//    _tableHeaderLabel.sd_layout
//    .leftSpaceToView(view, 16)
//    .rightSpaceToView(view, 16)
//    .centerYEqualToView(view)
//    .heightIs(24);
//
//    return view;
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _isScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate){
        //[self loadImagesForOnscreenRows];
        _isScrolling = NO;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[self loadImagesForOnscreenRows];
    _isScrolling = NO;
}

#pragma mark - ColumnToolBar
- (void)columnToolBar:(ColumnToolBar *)titlesView didSelectButton:(UIButton *)button atIndex:(NSUInteger)index
{
    if (_isScrolling == YES) {
        return ;
    }
    
    if (titlesView == _videoPlayTypeView) {
        /*if (index == 0) {
         _videoType = 1;
         if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished] == NO) {
         [self BA_showAlert:@"正在搜索录像文件,请稍候操作"];
         return ;
         }
         
         [self getDeviceInfo];
         [self.tableView reloadData];
         
         self.videoToolBar.hidden = NO;
         self.recordToolBar.hidden = YES;
         }
         else if (index == 1) {
         _videoType = 2;
         if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished] == NO) {
         [self BA_showAlert:@"正在搜索录像文件,请稍候操作"];
         return ;
         }
         
         [self BA_showBusy];
         
         self.videoToolBar.hidden = YES;
         self.recordToolBar.hidden = NO;
         NSDate *now = [NSDate date];
         NSCalendar *calendar = [NSCalendar currentCalendar];
         NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
         NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
         
         self.start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
         self.end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
         
         
         float palFrame = 1.0;
         if (self.handleTimer == nil) {
         self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
         }
         
         if (_isLocalFindRecordFiles == YES) {
         [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:self.DeviceChannel withStartTime:self.start_date_and_time withEndTime:self.end_date_and_time];
         }
         else {
         _isLocalFindRecordFiles = YES;
         }
         }*/
    }
    if (titlesView == _videoToolBar) {
        switch (index) {
            case 0:
            {
                BOOL bRet = [[DHVideoDeviceHelper sharedInstance] OpenTalk:!button.isSelected];
                if (bRet == YES) {
                    [_videoToolBar selectButtonAtIndex:index withClick:NO];
                }
                else {
                    //[self BA_showAlert:@"打开对讲失败，请稍候再试"];
                }
            }
                break;
            case 1:
            {
                BOOL bRet = [[DHVideoDeviceHelper sharedInstance] OpenSound:!button.isSelected];
                if (bRet == YES) {
                    [_videoToolBar selectButtonAtIndex:index withClick:NO];
                }
                else {
                    //[self BA_showAlert:@"打开监听失败，请稍候再试"];
                }
            }
                break;
            case 2:
                [[DHVideoDeviceHelper sharedInstance] CaptureImage];
                break;
            case 3:
            {
                BOOL bRet = [[DHVideoDeviceHelper sharedInstance] ChangeResType:button.isSelected];
                if (bRet == YES) {
                    [_videoToolBar selectButtonAtIndex:index withClick:NO];
                    if (button.isSelected) {
                        [_videoToolBar setTitleAtIndex:index withTitle:NSLocalizedString(@"VideoController_VideoResH", @"")];
                    }
                    else {
                        [_videoToolBar setTitleAtIndex:index withTitle:NSLocalizedString(@"VideoController_VideoResS", @"")];
                    }
                }
                else {
                    [self BA_showAlert:NSLocalizedString(@"VideoController_ChangeResErr", @"")];
                }
            }
                break;
            default:
                break;
        }
    }
    if (titlesView == _recordToolBar) {
        _VideoPlayFormat = 2;
        
        if ([[DHVideoDeviceHelper sharedInstance] isFindRecordStreamFinished] == NO) {
            [self BA_showAlert:NSLocalizedString(@"VideoController_IsFindingRecordFile", @"")];
            return ;
        }
        
        [self BA_showBusy];
//        _isLocalFindRecordFiles = YES;
        [_recordToolBar selectButtonAtIndex:index withClick:NO];
        
        switch (index) {
            case 0:
            {
                NSDate *now = [NSDate date];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
                
                _start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
                _end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
                
                float palFrame = 1.0;
                if (self.handleTimer == nil) {
                    self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
                }
                
                [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:self.DeviceChannel withStartTime:self.start_date_and_time withEndTime:self.end_date_and_time];
            }
                break;
            case 1:
            {
                NSDate *yesterday = [NSDate dateWithTimeIntervalSinceNow:-(24*60*60)];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:yesterday];
                
                _start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
                _end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
                
                float palFrame = 1.0;
                if (self.handleTimer == nil) {
                    self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
                }
                
                [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:self.DeviceChannel withStartTime:self.start_date_and_time withEndTime:self.end_date_and_time];
            }
                break;
            case 2:
            {
                NSDate *befor_yesterday = [NSDate dateWithTimeIntervalSinceNow:-(48*60*60)];
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:befor_yesterday];
                
                _start_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 0, 0, 0];
                _end_date_and_time = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", [dateComponent year], [dateComponent month], [dateComponent day], 23, 59, 59];
                
                float palFrame = 1.0;
                if (self.handleTimer == nil) {
                    self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
                }
                
                [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:self.DeviceChannel withStartTime:self.start_date_and_time withEndTime:self.end_date_and_time];
            }
                break;
            case 3:
            {
                UIDatePicker *datePicker = [[UIDatePicker alloc] init];
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                datePicker.frame = CGRectMake(0, 0, 300, 160);
                [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
                
                UIAlertController *alert = nil;
                if (INTERFACE_IS_IPAD)
                {
                    alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                }
                else {
                    alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                }
                //alert.view.frame = CGRectMake(0, 0, 320, 320);
                
                [alert.view addSubview:datePicker];
                
                UIView * pre_view = [[UIView alloc] init];
                pre_view.frame = CGRectMake(0, 160, alert.view.frame.size.width - 16, 50);
                [pre_view setBackgroundColor:[UIColor lightGrayColor]];
                
                UIButton *start_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                start_btn.frame = CGRectMake(20, 160, 90, 50);
                [start_btn setTitle:NSLocalizedString(@"RecordController_StartTimeTitle", "") forState:UIControlStateNormal];
                [start_btn addTarget:self action:@selector(startDateTimeSelected:) forControlEvents:UIControlEventTouchUpInside];
                UILabel *start_Label = [[UILabel alloc] init];
                start_Label.frame = CGRectMake(120, 160, 150, 50);
                [start_Label setText:NSLocalizedString(@"RecordController_StartTime", @"")];
                start_time_label_ = start_Label;
                //UIBarButtonItem *bbtTitle = [[UIBarButtonItem alloc] initWithCustomView:pre_view];
                [alert.view addSubview:pre_view];
                [alert.view addSubview:start_btn];
                [alert.view addSubview:start_Label];
                
                UIView * back_view = [[UIView alloc] init];
                back_view.frame = CGRectMake(0, 220, alert.view.frame.size.width-16, 50);
                [back_view setBackgroundColor:[UIColor lightGrayColor]];
                [alert.view addSubview:back_view];
                
                UIButton *end_btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                end_btn.frame = CGRectMake(20, 220, 90, 50);
                [end_btn setTitle:NSLocalizedString(@"RecordController_EndTimeTitle", @"") forState:UIControlStateNormal];
                [end_btn addTarget:self action:@selector(endDateTimeSelected:) forControlEvents:UIControlEventTouchUpInside];
                UILabel *end_Label = [[UILabel alloc] init];
                end_Label.frame = CGRectMake(120, 220, 150, 50);
                [end_Label setText:NSLocalizedString(@"RecordController_EndTime", @"")];
                end_time_label_ = end_Label;
                
                [alert.view addSubview:end_btn];
                [alert.view addSubview:end_Label];
                
                UIAlertAction *commit_btn = [UIAlertAction actionWithTitle:NSLocalizedString(@"RecordController_AlertActionOK", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSLog(@"start date time : %@, end date time : %@", start_time_label_.text, end_time_label_.text);
                    _start_date_and_time = start_time_label_.text;
                    _end_date_and_time = end_time_label_.text;
                    
                    float palFrame = 1.0;
                    if (self.handleTimer == nil) {
                        self.handleTimer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(recordDateUpdate) userInfo:nil repeats:YES];
                    }
                    
                    [[DHVideoDeviceHelper sharedInstance] FindVideoRecord:self.DeviceChannel withStartTime:self.start_date_and_time withEndTime:self.end_date_and_time];
                }];
                
                UIAlertAction *cancel_btn = [UIAlertAction actionWithTitle:NSLocalizedString(@"RecordController_AlertActionCancel", @"") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    　 }];
                
                [alert addAction:commit_btn];
                [alert addAction:cancel_btn];
                
                [self presentViewController:alert animated:YES completion:^{ }];
            }
                break;
            default:
                break;
        }
        
        
    }
}

- (void)startDateTimeSelected:(id)sender
{
    //UIButton *btn = (UIButton*)sender;
    //[btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [start_time_label_ setTextColor:[UIColor redColor]];
    [end_time_label_ setTextColor:[UIColor blackColor]];
    selected_time_mode_ = 1;
}

- (void)endDateTimeSelected:(id)sender
{
    //UIButton *btn = (UIButton*)sender;
    //[btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [start_time_label_ setTextColor:[UIColor blackColor]];
    [end_time_label_ setTextColor:[UIColor redColor]];
    selected_time_mode_ = 2;
}

- (void)datePickerValueChanged:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker*)sender;
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    //实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式
    NSString *dateString = [dateFormat stringFromDate:datePicker.date];
    //求出当天的时间字符串
    NSLog(@"Selected date and time : %@",dateString);
    
    
    if (start_time_label_ && selected_time_mode_ == 1) {
        [start_time_label_ setText:dateString];
    }
    else if (end_time_label_ && selected_time_mode_ == 2) {
        [end_time_label_ setText:dateString];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}
@end



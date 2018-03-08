//
//  PlayViewController.m
//  ThingsIOSClient
//
//  Created by yeung on 2018/03/06.
//  Copyright © 2018年 luoyingxing . All rights reserved.
//

#import "PlayViewController.h"
#import "VideoPlayView.h"
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

@interface PlayViewController (){
    
}

@property (strong, nonatomic) ZFPlayerView *playerView;

@property (nonatomic, strong) NSMutableArray *channelArray;

@end

@implementation PlayViewController{
    CGFloat screenHeight;
    CGFloat screenWidth;
    
    CGFloat chanelHeight;
    
    UIScrollView *channelScrollView;
    UIView* divilerUIView;
    UIView* captureUIView;
    UIView* talkUIView;
    UIView* listenerUIView;
    UILabel *talkLabel;
    UILabel *listenerLabel;
    
    BOOL talking;
    BOOL listening;
    
    NSInteger _deviceChannel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;
    chanelHeight = 50;
    _deviceChannel = 0;
    
    self.channelArray = [[NSMutableArray alloc] init];
    
    [[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
    
    [self createPlayer];
    [self addChanelScrollView];
    [self addControllerView];
    
    [self loadChannelList];
    [self showChannelArray];
    
    [self.playerView setVideoIsPlayingType:1];
    [[DHVideoDeviceHelper sharedInstance] StartRealStream:_deviceChannel withView:[_playerView getVideoWnd]];

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

- (void) addControllerView{
    CGFloat controllerY = 20 + screenWidth * 9 / 16 + chanelHeight;
    
    //add diviler
    divilerUIView = [[UIView alloc] initWithFrame:CGRectMake(0, controllerY, screenWidth, 8)];
    divilerUIView.backgroundColor = [CWColorUtils colorWithHexString:@"#F0F0F2"];
    [self.view addSubview:divilerUIView];
    
    //add controller view
    controllerY += (8 + 10);
   
    CGFloat perWidth = (screenWidth - 10 * 5) / 4;
    CGFloat perHeight = perWidth;
    
    // -----  capture  ---------
    captureUIView = [[UIView alloc] initWithFrame:CGRectMake(10, controllerY, perWidth, perHeight)];
    captureUIView.backgroundColor = [UIColor whiteColor];
    //添加边框
    CALayer * captureLayer = [captureUIView layer];
    captureLayer.borderColor = [[CWColorUtils colorWithHexString:@"#f7f7f7"] CGColor];
    captureLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *captureOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(captureOnclickListener)];
    [captureUIView addGestureRecognizer:captureOnclickListener];
    captureUIView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    [self.view addSubview:captureUIView];
    
    UIImage *captureImage = [[UIImage alloc] init];
    captureImage = [UIImage imageNamed:@"ic_play_menu_capture.png"];
    //注意此处的x，y，是添加到uiview里面，所以位置要相对uiview来确立
    UIImageView* capture = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth / 4, 8, perWidth / 2, perWidth / 2)];
    capture.image = captureImage;
    [captureUIView addSubview:capture];
    
    UILabel *captureLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, perWidth / 2 + 8 + 4, perWidth, perHeight - (perWidth / 2 + 8 + 4))];
    captureLabel.textAlignment = NSTextAlignmentCenter;
    captureLabel.text = @"抓图";
    captureLabel.font = [UIFont systemFontOfSize:15];
    captureLabel.textColor = [CWColorUtils colorWithHexString:@"#333333"];
    [captureUIView addSubview:captureLabel];
    
    // -----  talk  ---------
    talkUIView = [[UIView alloc] initWithFrame:CGRectMake(10 + perWidth + 10, controllerY, perWidth, perHeight)];
    talkUIView.backgroundColor = [UIColor whiteColor];
    //添加边框
    CALayer * talkLayer = [talkUIView layer];
    talkLayer.borderColor = [[CWColorUtils colorWithHexString:@"#f7f7f7"] CGColor];
    talkLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *talkOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(talkOnclickListener)];
    [talkUIView addGestureRecognizer:talkOnclickListener];
    talkUIView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    [self.view addSubview:talkUIView];
    
    UIImage *talkImage = [[UIImage alloc] init];
    talkImage = [UIImage imageNamed:@"ic_play_menu_talking.png"];
    //注意此处的x，y，是添加到uiview里面，所以位置要相对uiview来确立
    UIImageView* talk = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth / 4, 8, perWidth / 2, perWidth / 2)];
    talk.image = talkImage;
    [talkUIView addSubview:talk];
    
    talkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, perWidth / 2 + 8 + 4, perWidth, perHeight - (perWidth / 2 + 8 + 4))];
    talkLabel.textAlignment = NSTextAlignmentCenter;
    talkLabel.text = @"对讲";
    talkLabel.font = [UIFont systemFontOfSize:15];
    talkLabel.textColor = [CWColorUtils colorWithHexString:@"#333333"];
    [talkUIView addSubview:talkLabel];
    
    // -----  listener  ---------
    listenerUIView = [[UIView alloc] initWithFrame:CGRectMake(10 + perWidth + 10 + perWidth + 10, controllerY, perWidth, perHeight)];
    listenerUIView.backgroundColor = [UIColor whiteColor];
    //添加边框
    CALayer * listenerLayer = [listenerUIView layer];
    listenerLayer.borderColor = [[CWColorUtils colorWithHexString:@"#f7f7f7"] CGColor];
    listenerLayer.borderWidth = 1.0f;
    UITapGestureRecognizer *listenerOnclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(listenerOnclickListener)];
    [listenerUIView addGestureRecognizer:listenerOnclickListener];
    listenerUIView.userInteractionEnabled = YES; // 可以理解为设置label可被点击
    [self.view addSubview:listenerUIView];
    
    UIImage *listenerImage = [[UIImage alloc] init];
    listenerImage = [UIImage imageNamed:@"ic_play_menu_listener.png"];
    //注意此处的x，y，是添加到uiview里面，所以位置要相对uiview来确立
    UIImageView* listener = [[UIImageView alloc] initWithFrame:CGRectMake(perWidth / 4, 8, perWidth / 2, perWidth / 2)];
    listener.image = listenerImage;
    [listenerUIView addSubview:listener];
    
    listenerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, perWidth / 2 + 8 + 4, perWidth, perHeight - (perWidth / 2 + 8 + 4))];
    listenerLabel.textAlignment = NSTextAlignmentCenter;
    listenerLabel.text = @"监听";
    listenerLabel.font = [UIFont systemFontOfSize:15];
    listenerLabel.textColor = [CWColorUtils colorWithHexString:@"#333333"];
    [listenerUIView addSubview:listenerLabel];
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
    
    talking = NO;
    listening = NO;
    talkLabel.text = @"对讲";
    listenerLabel.text = @"监听";
    
    if ([[DHVideoDeviceHelper sharedInstance] isStartRealStreamFinished] == NO) {
        [self BA_showAlert:NSLocalizedString(@"正连接实时视频内容，请稍后", @"")];
        return ;
    }

    ChannelInfoModel *channel_model  = [self.channelArray objectAtIndex:position];
    NSInteger chanIndex = [channel_model.channelName integerValue];
    
    _deviceChannel = chanIndex - 1;
    
    [[DHVideoDeviceHelper sharedInstance] StartRealStream:_deviceChannel withView:[_playerView getVideoWnd]];
  
}

- (void) captureOnclickListener{
    NSLog(@"capture");
    [[DHVideoDeviceHelper sharedInstance] CaptureImage];
}

- (void) talkOnclickListener{
    NSLog(@"talk");
    
    BOOL bRet = [[DHVideoDeviceHelper sharedInstance] OpenTalk:!talking];
    if (bRet == YES) {
        talking = !talking;
        if (talking) {
            talkLabel.text = @"对讲中";
        }else{
            talkLabel.text = @"对讲";
        }
    }else {
        NSLog(@"打开对讲失败，请稍候再试");
    }
}

- (void) listenerOnclickListener{
    NSLog(@"listener");
    BOOL bRet = [[DHVideoDeviceHelper sharedInstance] OpenSound:!listening];
    if (bRet == YES) {
        listening = !listening;
        if (listening) {
            listenerLabel.text = @"监听中";
        }else{
            listenerLabel.text = @"监听";
        }
    }else {
        NSLog(@"打开监听失败，请稍候再试");
    }
}

- (void)createPlayer{
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
                make.top.equalTo(weakSelf.view).offset(0);
                make.left.right.equalTo(weakSelf.view);
                make.bottom.equalTo(weakSelf.view);
                // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
                make.height.equalTo(weakSelf.playerView.mas_width).multipliedBy(9.0f / 16.0f).with.priority(750);
            }];
            [weakSelf fullScree:YES];
        }
        else {
            [weakSelf.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.view).offset(20);
                make.left.right.equalTo(weakSelf.view);
                // 注意此处，宽高比16：9优先级比1000低就行，在因为iPhone 4S宽高比不是16：9
                make.height.equalTo(weakSelf.view.mas_width).multipliedBy(9.0f / 16.0f).with.priority(750);
            }];
            [weakSelf fullScree:NO];
        }
    };
    
    self.playerView.goBackBlock = ^{
        [weakSelf dismissViewControllerAnimated:TRUE completion:^{
            NSLog(@"back to device detial");
        }];
    };
}

- (void) fullScree:(BOOL) isFullScreen{
    channelScrollView.hidden = isFullScreen;
    divilerUIView.hidden = isFullScreen;
    captureUIView.hidden = isFullScreen;
    talkUIView.hidden = isFullScreen;
    listenerUIView.hidden = isFullScreen;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    //[[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.playerView stop];
    gTYPlayerView = nil;
    
    [[DHVideoDeviceHelper sharedInstance] StopRealStream:_deviceChannel];
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

@end



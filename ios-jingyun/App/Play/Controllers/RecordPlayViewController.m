//
//  PlayViewController.m
//  ThingsIOSClient
//
//  Created by yeung on 2018/03/06.
//  Copyright © 2018年 luoyingxing . All rights reserved.
//

#import "RecordPlayViewController.h"
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

extern ZFPlayerView *gTYPlayerView ;

@interface RecordPlayViewController (){
    
}

@property (strong, nonatomic) ZFPlayerView *playerView;

@end

@implementation RecordPlayViewController{
    CGFloat screenHeight;
    CGFloat screenWidth;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    screenHeight = self.view.bounds.size.height;
    screenWidth = self.view.bounds.size.width;

//    [[DHVideoDeviceHelper sharedInstance] ConnectDevice:_tid withNodeTID:nil withPartID:@"2000"];
    
    [self createPlayer];
    
    [self.playerView setVideoIsPlayingType:2];
    [[DHVideoDeviceHelper sharedInstance] StartRecordStream:self.deviceChannelIndex withView:[self.playerView getVideoWnd]];
    
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
            NSLog(@"back to history");
        }];
    };
}

- (void) fullScree:(BOOL) isFullScreen{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated{
    [self.playerView stop];
    gTYPlayerView = nil;
    
    [[DHVideoDeviceHelper sharedInstance] StopRecordStream:NO];
//    [[CWDataManager sharedInstance] setIsNavBarHidden:NO];
//    [self.navigationController setNavigationBarHidden:NO];
//    [[DHVideoDeviceHelper sharedInstance] DisconnectDevice];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end




//
//  VideoTypeViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "VideoTypeViewController.h"
#import "CWColorUtils.h"
#import "CWFileUtils.h"

@interface VideoTypeViewController ()

@end

@implementation VideoTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaigaBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setNaigaBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"选择视频访问方式";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white.png"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void) viewWillAppear:(BOOL)animated{
    NSInteger type = [[CWFileUtils sharedInstance] videoConnectType];
    if (type == 0) {
        self.directImageView.hidden = NO;
        self.p2pImageView.hidden = YES;
    }else if(type == 1){
        self.p2pImageView.hidden = NO;
        self.directImageView.hidden = YES;
    }
}

- (void) back:(id)sender{
    //jump to add personal controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to personal ");
    }];
}

- (IBAction)directOnClick:(UIButton *)sender {
    self.directImageView.hidden = NO;
    self.p2pImageView.hidden = YES;
    [[CWFileUtils sharedInstance] videoConnectType:0];
}

- (IBAction)p2pOnClick:(UIButton *)sender {
    self.p2pImageView.hidden = NO;
    self.directImageView.hidden = YES;
    [[CWFileUtils sharedInstance] videoConnectType:1];
}

@end

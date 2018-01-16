//
//  AboutViewController.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/16.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "AboutViewController.h"
#import "CWColorUtils.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setNaigaBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    NSString *center_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"cw_center_name"];
    if (center_name) {
        self.centerNameLabel.text = center_name;
    }
}

- (void) setNaigaBar{
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[CWColorUtils getThemeColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                                      NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationItem.title = @"关于警云";
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"icon_back_white.png"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(back:)];
    backButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void) back:(id)sender{
    //jump to add personal controller
    [self dismissViewControllerAnimated:TRUE completion:^{
        NSLog(@"back to personal ");
    }];
}

@end

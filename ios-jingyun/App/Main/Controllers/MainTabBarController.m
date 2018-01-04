//
//  MainTabBarController.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "MainTabBarController.h"
#import "HomeViewController.h"
#import "DeviceViewController.h"
#import "PersonalViewController.h"
#import "UIImage+OriginUIImage.h"
#import "CWColorUtils.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //由于默认是透明的，所以在此添加背景色，避免跳转出现界面重叠现象。
    self.view.backgroundColor = [UIColor whiteColor];
    [self setAllChildViewControllers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Method
- (void)setAllChildViewControllers {
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    [self setChildViewController:homeVC
                              image:[UIImage imageNamed:@"tab_icon_home_normal"]
                      selectedImage:[UIImage imageWithOriginalName:@"tab_icon_home_selected"]
                              title:@"首页"];
    
    DeviceViewController *deviceVC = [[DeviceViewController alloc] init];
    [self setChildViewController:deviceVC
                              image:[UIImage imageNamed:@"tab_icon_device_normal"]
                      selectedImage:[UIImage imageWithOriginalName:@"tab_icon_device_selected"]
                              title:@"设备"];

    PersonalViewController *meVC = [[PersonalViewController alloc] init];
    [self setChildViewController:meVC
                              image:[UIImage imageNamed:@"tab_icon_personal_normal"]
                      selectedImage:[UIImage imageWithOriginalName:@"tab_icon_personal_selected"]
                              title:@"我的"];
    
    [self setSelectedIndex:0];
}

/**
 * 编码规范：有汉字的放最后边，如此处的"title"（自定义方法时）
 */
- (void)setChildViewController:(UIViewController *)viewController image:(UIImage *)image selectedImage:(UIImage *)selectedImage title:(NSString *)title{
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navi setNavigationBarHidden:YES animated:YES];
    navi.tabBarItem.image = image;
    navi.tabBarItem.selectedImage = selectedImage;
    navi.title = title;
    navi.tabBarItem.badgeValue = nil;
    [navi.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[CWColorUtils getThemeColor]} forState:UIControlStateSelected];
    
//    if ([viewController isKindOfClass:[RSHomeViewController class]]) {
//        navi.tabBarItem.badgeValue = @"32";
//    }
    
    [self addChildViewController:navi];
}

/**
 初始化类：
 1.appearance：只要一个类遵守UIAppearance协议，就能获取全局的外观，如：UIView。
 2.获取项目中所有的tabBarItem外观标识（推荐，不会改变别人的）：
 UITabBarItem *item = [UITabBarItem appearance];
 3.获取当前类下面的所有tabBarItem外观标识：
 UITabBarItem *item = [UITabBarItem appearanceWhenContainedIn:self, nil];
 */
+ (void)initialize {
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    UITabBarItem *item = [UITabBarItem appearance];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor colorWithRed:0x09/255.0 green:0xbb/255.0 blue:0x07/255.0 alpha:1.0];
    [item setTitleTextAttributes:attributes forState:UIControlStateSelected];
}

@end

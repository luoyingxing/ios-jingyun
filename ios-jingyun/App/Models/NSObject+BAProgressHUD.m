//
//  NSObject+BAProgressHUD.m
//  demoTest
//
//  Created by 博爱 on 16/4/20.
//  Copyright © 2016年 博爱之家. All rights reserved.
//

#import "NSObject+BAProgressHUD.h"

@implementation NSObject (BAProgressHUD)

/** 获取当前屏幕的最上方正在显示的那个view */
- (UIView *)getCurrentView
{
    if ([self isKindOfClass:[UIView class]]) {
        return self;
    }
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    // vc: 导航控制器, 标签控制器, 普通控制器
    if ([vc isKindOfClass:[UITabBarController class]])
    {
        vc = [(UITabBarController *)vc selectedViewController];
    }
    if ([vc isKindOfClass:[UINavigationController class]])
    {
        vc = [(UINavigationController *)vc visibleViewController];
    }
    
    return vc.view;
}

/** 弹出文字提示 */
- (void)BA_showAlert:(NSString *)text
{
    // 防止在非主线程中调用此方法,会报错
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 弹出新的提示之前,先把旧的隐藏掉
        //        [self hideProgress]; // 主线程中会先调用这个，所以速度很快
        [MBProgressHUD hideAllHUDsForView:[self getCurrentView] animated:YES];
        MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self getCurrentView] animated:YES];
        
        progressHUD.mode = MBProgressHUDModeText;
        progressHUD.labelText = text;
        [progressHUD hide:YES afterDelay:1.5];
    });
}

/** 显示忙 */
- (void)BA_showBusy
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MBProgressHUD hideAllHUDsForView:[self getCurrentView] animated:YES];
        MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:[self getCurrentView] animated:YES];
        
        // 最长显示15秒
        [progressHUD hide:YES afterDelay:15];
    }];
}

/** 隐藏提示 */
- (void)BA_hideProgress
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [MBProgressHUD hideAllHUDsForView:[self getCurrentView] animated:YES];
    }];
}

@end

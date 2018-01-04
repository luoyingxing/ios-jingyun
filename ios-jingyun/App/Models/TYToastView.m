//
//  TYToastView.m
//  TYeung
//
//  Created by yeung on 16/5/6.
//  Copyright © 2016年 TYeung. All rights reserved.
//

#import "TYToastView.h"
#import "AppDelegate.h"
//#import "AlarmTaskViewController.h"

static TYToastView *toast;
@implementation TYToastViewConfig

+(instancetype) TYToastViewConfig:(CGFloat) width height:(CGFloat)height mode:(TYToastViewMode)mode
{
    TYToastViewConfig *config = [[TYToastViewConfig alloc] init];
    config.width = width;
    config.height = height;
    config.mode = mode;
    return config;
}

@end

@implementation TYToastView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupViews];
    }
    return self;
}

- (void) setupViews
{
    [self setBackgroundColor:[UIColor yellowColor]];
    
    //UITapGestureRecognizer *content_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleToastTap:)];
    //[self addGestureRecognizer:content_tap];
}

- (void)handleToastTap:(UITapGestureRecognizer *)tap {
    self.hidden = YES;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate) {
        if ([_toastConfig type] == 1) {
//            AlarmTaskViewController *viewController = [AlarmTaskViewController new];
//
//            UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:viewController];
//            [appDelegate.revealSideViewController popViewControllerWithNewCenterController:n animated:YES];
//            PP_RELEASE(viewController);
//            PP_RELEASE(n);
        }
    }
}

//msg 提醒的消息
//delay 关闭时间
+(void) showToastMsg:(NSString *) msg delay :(CGFloat) delay config:(TYToastViewConfig *) config superView:(UIView *) superview{
    
    if (toast) {
        [TYToastView hidden];
    }
    toast = [[TYToastView alloc] initWithFrame:CGRectMake(10, superview.frame.origin.y , config.width - 20, config.height)];
    [toast.layer setMasksToBounds:YES];
    [toast.layer setCornerRadius:5];
    [toast setBackgroundColor:[UIColor blackColor]];
    [toast setToastConfig:config];
    UILabel *lib = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, config.width - 5, config.height - 5)];
    lib.textAlignment = NSTextAlignmentLeft|NSTextAlignmentCenter;
    lib.text = msg;
    lib.userInteractionEnabled = YES;
    UITapGestureRecognizer *content_tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleToastTap:)];
    [lib addGestureRecognizer:content_tap];
    if (config.textColor) {
        lib.textColor = config.textColor;
    }
    if (config.textFont) {
        lib.font = config.textFont;
    }
    [toast setAlpha:0];
    [toast addSubview:lib];
    
    
    
    if (superview.superview) {
        [superview.superview addSubview:toast];
        [superview.superview bringSubviewToFront:superview];
    }else{
        CGRect s = toast.frame;
        s.origin.y = superview.frame.origin.y - config.height;
        toast.frame = s;
        [superview addSubview:toast];
        [superview bringSubviewToFront:toast];
    }
    
    
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [toast setAlpha:0.7];
        CGRect frame = toast.frame;
        frame.origin.y += frame.size.height;
        [toast setFrame:frame];
        
    } completion:^(BOOL finch){
        if (delay != 0) {
            [UIView animateWithDuration:0.3f delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                [toast setAlpha:0];
                CGRect frame = toast.frame;
                frame.origin.y -= frame.size.height;
                [toast setFrame:frame];
                
            } completion:^(BOOL is){
                [toast removeFromSuperview];
                toast = nil;
            }];
        }
    }];

    
}

//view 显示在里面的View，可自由发挥
//delay 关闭时间
// mode 显示方向
+(void) showToastView :(UIView *) view delay :(CGFloat) delay config:(TYToastViewConfig *) config superView:(UIView *) superview{
    
    if (toast) {
        [TYToastView hidden];
    }
    
    toast = [[TYToastView alloc] initWithFrame:CGRectMake(10, superview.frame.origin.y , config.width - 20, config.height)];
    [toast.layer setMasksToBounds:YES];
    [toast.layer setCornerRadius:5];
    [toast setBackgroundColor:[UIColor grayColor]];
    [toast addSubview:view];
    
    if (superview.superview) {
        [superview.superview addSubview:toast];
        [superview.superview bringSubviewToFront:superview];
    }else{
        CGRect s = toast.frame;
        s.origin.y = superview.frame.origin.y - config.height;
        toast.frame = s;
        [superview addSubview:toast];
        [superview bringSubviewToFront:toast];
    }

    if (delay != 0) {
        [UIView animateWithDuration:0.3f delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
            [toast setAlpha:0];
            CGRect frame = toast.frame;
            frame.origin.y -= frame.size.height;
            [toast setFrame:frame];
            
        } completion:^(BOOL is){
            [toast removeFromSuperview];
            toast = nil;
        }];
    }

    
}

//手动关闭所有提示
+(void) hidden
{
    [UIView animateWithDuration:0.3f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [toast setAlpha:0];
        CGRect frame = toast.frame;
        frame.origin.y -= frame.size.height;
        [toast setFrame:frame];
        
    } completion:^(BOOL is){
        [toast removeFromSuperview];
    }];
}

@end

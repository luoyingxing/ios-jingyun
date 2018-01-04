//
//  TYToastView.h
//  TYeung
//
//  Created by yeung on 16/6/27.
//  Copyright © 2016年 TYeung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TYToastViewTop,
    TYToastViewLeft,
    TYToastViewRight,
    TYToastViewBottom,
} TYToastViewMode;

@interface TYToastViewConfig : NSObject

@property CGFloat width;
@property CGFloat height;
@property TYToastViewMode mode;
@property UIColor *textColor;
@property UIFont *textFont;
@property UIColor *toastColor;

@property (nonatomic, strong) NSString *tid;
@property (nonatomic, assign) NSInteger type;


+(instancetype) TYToastViewConfig:(CGFloat) width height:(CGFloat)height mode :(TYToastViewMode) mode;

@end

@interface TYToastView : UIView
@property (nonatomic, strong) TYToastViewConfig *toastConfig;

//msg 提醒的消息
//delay 关闭时间
+(void) showToastMsg:(NSString *) msg delay :(CGFloat) delay config:(TYToastViewConfig *) config superView:(UIView *) superview;

//view 显示在里面的View，可自由发挥
//delay 关闭时间
// mode 显示方向
+(void) showToastView :(UIView *) view delay :(CGFloat) delay config:(TYToastViewConfig *) config superView:(UIView *) superview;

//手动关闭所有提示
+(void) hidden;

@end

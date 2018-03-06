//
//  JMSlideTitlesView.h
//  JMSlideTitlesView
//
//  Created by yeung on 3/10/16.
//  Copyright © 2016 yeung. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColumnToolBar;
@class ColumnToolBarSetting;

@protocol ColumnToolBarDelegate <NSObject>

@optional

// 通知外部选中按钮更换
- (void)columnToolBar:(ColumnToolBar *)titlesView didSelectButton:(UIButton *)button atIndex:(NSUInteger)index;

@end

@interface ColumnToolBar : UIView

@property (nonatomic, weak) id<ColumnToolBarDelegate> delegate;

// 两种创建方法
+ (instancetype)columnToolBarWithSetting:(ColumnToolBarSetting *)setting;
- (instancetype)initWithSetting:(ColumnToolBarSetting *)setting;

// 外部修改选中按钮
- (void)selectButtonAtIndex:(NSUInteger)index withClick:(BOOL)isClicked;

- (void) appendTitleAtIndex:(NSUInteger)index withTitle:(NSString*)caption;

- (void) setTitleAtIndex:(NSUInteger)index withTitle:(NSString*)caption;

@end

@interface ColumnToolBarSetting : NSObject

#pragma mark 标题设置
// 普通状态按钮标题
@property (nonatomic, strong) NSArray *titlesArr;
// 选中状态按钮标题，默认与普通状态一样
@property (nonatomic, strong) NSArray *selectedTitlesArr;
//普通状态按钮图片
@property (nonatomic, strong) NSArray *imagesArr;
//选中状态按钮图片
@property (nonatomic, strong) NSArray *selectedImagesArr;
//选中状态按钮图片
//@property (nonatomic, strong) NSArray *selectedImagesArr;
// 整个 view 的尺寸
@property (nonatomic, assign) CGRect frame;
// 整个 view 的背景颜色
@property (nonatomic, strong) UIColor *backgroundColor;
// 普通状态标题颜色，默认为黑色
@property (nonatomic, strong) UIColor *textColor;
// 选中状态标题颜色，默认为橙色
@property (nonatomic, strong) UIColor *selectedTextColor;
// 普通状态字体大小，默认为系统大小
@property (nonatomic, assign) CGFloat textFontSize;
// 选中状态字体大小，默认与普通状态一样
@property (nonatomic, assign) CGFloat selectedTextFontSize;

#pragma mark 横线设置
// 隐藏状态，默认为不隐藏
@property (nonatomic, assign) BOOL buttonDisable;
// 隐藏状态，默认为不隐藏
@property (nonatomic, assign) BOOL topHidden;
// 隐藏状态，默认为不隐藏
@property (nonatomic, assign) BOOL middleHidden;
// 隐藏状态，默认为不隐藏
@property (nonatomic, assign) BOOL lineHidden;
// 横线宽度，默认为与标题文字同宽
@property (nonatomic, assign) CGFloat lineWidth;
// 横线高度，默认为 1
@property (nonatomic, assign) CGFloat lineHeight;
// 横线颜色，默认为与选中状态标题颜色一样
@property (nonatomic, strong) UIColor *lineColor;
// 横线与底部距离，默认为 1
@property (nonatomic, assign) CGFloat lineBottomSpace;
// 横线动画时间，默认为 0.5 妙
@property (nonatomic, assign) NSTimeInterval animateDuration;

@end

//
//  JMNavbarMenu.h
//  JMNavbarMenu
//
//  Created by yeung on 5/14/16.
//  Copyright (c) 2016 yeung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "UIView+JMExtension.h"

@interface UITouchGestureRecognizer : UIGestureRecognizer
@end

@interface JMNavbarMenuItem : NSObject

@property (copy, nonatomic, readonly) NSString *title;
@property (strong, nonatomic, readonly) UIImage *icon;

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon;
+ (JMNavbarMenuItem *)ItemWithTitle:(NSString *)title icon:(UIImage *)icon;

@end

@class JMNavbarMenu;
@protocol JMNavbarMenuDelegate <NSObject>
@optional
- (void)didShowMenu:(JMNavbarMenu *)menu;
- (void)didDismissMenu:(JMNavbarMenu *)menu;
- (void)didSelectedMenu:(JMNavbarMenu *)menu atIndex:(NSInteger)index;

@end

//iOS7+
@interface JMNavbarMenu : UIView

@property (copy, nonatomic, readonly) NSArray *items;
@property (assign, nonatomic, readonly) NSInteger maximumNumberInRow;
@property (assign, nonatomic, getter=isOpen) BOOL open;
@property (weak, nonatomic) id <JMNavbarMenuDelegate> delegate;

@property (strong, nonatomic) UIColor *textColor;
@property (strong, nonatomic) UIColor *separatarColor;

- (instancetype)initWithItems:(NSArray *)items
                        width:(CGFloat)width
           maximumNumberInRow:(NSInteger)max;

- (void)showInNavigationController:(UINavigationController *)nvc;
- (void)dismissWithAnimation:(BOOL)animation;

@end

//
//  CWTextUtils.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/10.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CWTextUtils : NSObject

//计算字符串高度
+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width;

//计算字符串高度
+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width textfontSize:(CGFloat)fontSize;

//计算字符串高度
+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width textfont:(id)font;

//判断id是否为空
+ (BOOL) isEmpty:(id)string;

@end

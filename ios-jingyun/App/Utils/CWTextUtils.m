//
//  CWTextUtils.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/10.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "CWTextUtils.h"
#import <UIKit/UIKit.h>

@implementation CWTextUtils

+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width{
    return [self textHeight:textStr textWidth:width textfontSize:17];
}

+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width textfontSize:(CGFloat)fontSize{
    return [self textHeight:textStr textWidth:width textfont:[UIFont systemFontOfSize:fontSize]];
}

//计算字符串高度
+ (CGFloat) textHeight:(NSString *)textStr textWidth:(float)width textfont:(id)font{
    NSDictionary * attribute = @{NSFontAttributeName : font};
    CGSize size = CGSizeMake(width, MAXFLOAT);
    CGRect rect = [textStr boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    return  rect.size.height;
}

@end

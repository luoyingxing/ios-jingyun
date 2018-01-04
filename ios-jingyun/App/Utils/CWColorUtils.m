//
//  CWColorUtils.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/11.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "CWColorUtils.h"

#define theme_color @"#3ec0fe"

@implementation CWColorUtils

+ (UIColor *) colorWithHexString:(NSString *)stringToConvert{
    return [CWColorUtils colorWithHexString:stringToConvert alpha:1.0f];
}

+ (UIColor *) colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha{
    if ([stringToConvert hasPrefix:@"#"]){
        stringToConvert = [stringToConvert substringFromIndex:1];
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    
    if (![scanner scanHexInt:&hexNum]){
        return nil;
    }
    
    int r = (hexNum >> 16) & 0xFF;
    int g = (hexNum >> 8) & 0xFF;
    int b = (hexNum) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                           blue:b / 255.0f
                           alpha:alpha];
}

+ (UIColor *) getThemeColor{
    return [CWColorUtils colorWithHexString:theme_color];
}

@end

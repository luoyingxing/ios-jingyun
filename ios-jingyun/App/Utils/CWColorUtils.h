//
//  CWColorUtils.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/11.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CWColorUtils : NSObject

+ (UIColor *) colorWithHexString:(NSString *)stringToConvert;
+ (UIColor *) colorWithHexString:(NSString *)stringToConvert alpha:(CGFloat)alpha;
+ (UIColor *) getThemeColor;

@end

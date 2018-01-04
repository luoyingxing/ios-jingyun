//
//  UIImage+OriginUIImage.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "UIImage+OriginUIImage.h"

@implementation UIImage (OriginUIImage)

+ (instancetype)imageWithOriginalName:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

@end

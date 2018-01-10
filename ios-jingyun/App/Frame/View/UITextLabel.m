//
//  UITextLabel.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/10.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "UITextLabel.h"

@implementation UITextLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (CGRect) textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    UIEdgeInsets insets = self.edgeInsets;
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets) limitedToNumberOfLines:numberOfLines];
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width  -= (insets.left + insets.right);
    rect.size.height -= (insets.top + insets.bottom);
    
    return rect;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end

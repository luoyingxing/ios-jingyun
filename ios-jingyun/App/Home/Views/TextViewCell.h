//
//  TextViewCell.h
//  ios-jingyun
//
//  Created by conwin on 2017/12/25.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;
@property (strong, nonatomic) UILabel *sourceLabel;

+ (CGFloat) getCellHeight;


@end

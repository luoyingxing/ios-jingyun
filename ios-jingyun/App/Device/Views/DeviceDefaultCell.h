//
//  DeviceDefaultCell.h
//  ios-jingyun
//
//  Created by conwin on 2017/12/28.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDefaultCell : UITableViewCell

@property (strong, nonatomic) UIImageView *statusImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *dataLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIView *tagView;

+ (CGFloat) getCellHeight;

@end

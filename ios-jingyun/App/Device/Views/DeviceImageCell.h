//
//  DeviceImageCell.h
//  ios-jingyun
//
//  Created by conwin on 2017/12/28.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceImageCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *videoImage;
@property (strong, nonatomic) UIImageView *logoImage;
@property (strong, nonatomic) UILabel *dataTimeLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UIView *tagView;

+ (CGFloat) getCellHeight;

@end

//
//  DeviceMessageLocalCell.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/5.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceMessageLocalCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UILabel *contentLabel;

+ (CGFloat) getCellHeight;

@end

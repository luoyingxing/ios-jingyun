//
//  DeviceMessageServerCell.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/9.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceMessageModel.h"
#import "UITextLabel.h"

@interface DeviceMessageServerCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UITextLabel *contentLabel;
@property (strong, nonatomic) UIImageView* photoImageView;

+ (CGFloat) getCellHeight:(DeviceMessageModel*) messageModel;

@end

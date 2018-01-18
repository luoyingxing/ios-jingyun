//
//  DeviceZoneViewCell.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/18.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZoneOnItemClickDelegate.h"

@interface DeviceZoneViewCell : UITableViewCell{
    
    id<ZoneOnItemClickDelegate> delegate;
    
}

@property (strong, nonatomic) UIImageView *statusImage;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *passLabel;

@property (assign, nonatomic) NSInteger *index;

- (void) setOnItemClickDelegate:(id) delegate;

+ (CGFloat) getCellHeight;

@end

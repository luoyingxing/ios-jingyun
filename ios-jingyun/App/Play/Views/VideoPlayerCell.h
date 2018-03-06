//
//  VideoPlayerCell.h
//  TYeung
//
//  Created by yeung on 16/5/4.
//  Copyright © 2016年 conwin. All rights reserved.
//



#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "ChannelInfoModel.h"

@class CWRecordModel;

@interface VideoPlayerCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLable;
@property (nonatomic, strong) UILabel *deviceLable;
@property (nonatomic, strong) UIImageView *menu_separator_image_view;

@property (nonatomic, strong) ChannelInfoModel *model;

@property (nonatomic, strong) CWRecordModel *recordModel;

-(void) didSelectedCell;

- (void) didDeselectedCell;

@end

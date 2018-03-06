//
//  VideoPlayerCell.m
//  TYeung
//
//  Created by yeung on 16/5/4.
//  Copyright © 2016年 conwin. All rights reserved.
//

#import "VideoPlayerCell.h"
#import "UIView+SDAutoLayout.h"
#import "CWRecordModel.h"

@implementation VideoPlayerCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupView];
    }
    return self;
}

- (void)setupView
{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    _iconImageView = [UIImageView new];
    [_iconImageView setImage:[UIImage imageNamed:@"C200tongdaotubiaodianji"]];
    
    _titleLable = [UILabel new];
    [_titleLable setTextColor:[UIColor whiteColor]];
    [_titleLable setTextAlignment:NSTextAlignmentLeft];
    [_titleLable setText:@"test"];
    
    _menu_separator_image_view = [UIImageView new];
    [_menu_separator_image_view setTag:20003];
    UIImage *separator_image = [UIImage imageNamed:@"C200jindutiaoditu"];
    [_menu_separator_image_view setImage:separator_image];
    
    [self sd_addSubviews:@[_iconImageView, _titleLable, _menu_separator_image_view]];
    
    _iconImageView.sd_layout
    .leftSpaceToView(self, 20)
    .topSpaceToView(self, 10)
    .bottomSpaceToView(self, 10)
    .widthEqualToHeight();
    
    _titleLable.sd_layout
    .leftSpaceToView(_iconImageView, 20)
    .topSpaceToView(self, 10)
    .bottomSpaceToView(self, 10)
    .rightSpaceToView(self, 10);
    
    _menu_separator_image_view.sd_layout
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .bottomSpaceToView(self, 0)
    .heightIs(1);
}

-(void) setModel:(ChannelInfoModel*)model
{
    [_titleLable setText:model.channelName];
}

- (void) setRecordModel:(CWRecordModel *)recordModel
{
    const NET_TIME& startTime = recordModel.net_recordfile_info.starttime;
    const NET_TIME&  endTime = recordModel.net_recordfile_info.endtime;
    NSString *record_name = [[NSString alloc] initWithFormat:@"%d-%d-%d %d:%d:%d - %d-%d-%d %d:%d:%d", startTime.dwYear, startTime.dwMonth, startTime.dwDay, startTime.dwHour, startTime.dwMinute, startTime.dwSecond, endTime.dwYear, endTime.dwMonth, endTime.dwDay, endTime.dwHour, endTime.dwMinute, endTime.dwSecond];
    [_titleLable setText:record_name];
}

-(void) didSelectedCell
{
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    //_container.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    //[_nameLabel setTextColor:[UIColor colorWithRed:0.043 green:0.314 blue:0.486 alpha:1.0]];
}

- (void) didDeselectedCell
{
    [self setBackgroundColor:[UIColor clearColor]];
    //[_nameLabel setTextColor:[UIColor colorWithRed:0.84 green:0.88 blue:0.9 alpha:1.0]];
}

@end

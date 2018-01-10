//
//  DeviceMessageLocalCell.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/5.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "DeviceMessageLocalCell.h"
#import "CWColorUtils.h"

@implementation DeviceMessageLocalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat cellheight = [DeviceMessageLocalCell getCellHeight] - 10;
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2 + 10, cellWidth, 16)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_timeLabel];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18 + 10, cellWidth - 40 - 14, cellheight - 16)];
        _contentLabel.textAlignment = NSTextAlignmentRight;
        _contentLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_contentLabel];
        
        UIImageView* avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth - 40, 18 + 10, 30, 30)];
        avatarView.image = [UIImage imageNamed:@"icon_device_detail_avatar.png"];
        avatarView.contentMode =  UIViewContentModeScaleAspectFill;
        [self addSubview:avatarView];
    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    return 70;
}

@end

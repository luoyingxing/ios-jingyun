//
//  DeviceDefaultCell.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/28.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "DeviceDefaultCell.h"
#import "CWColorUtils.h"

@implementation DeviceDefaultCell

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
        CGFloat cellheight = [DeviceDefaultCell getCellHeight];
        
        _statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_device_safety"]];
        _statusImage.frame = CGRectMake(8, cellheight / 2 - 23, 46, 46);
        _statusImage.contentMode =  UIViewContentModeScaleAspectFit;
        _statusImage.clipsToBounds  = YES;
        [self addSubview:_statusImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(66, cellheight / 2 - 20 - 4, cellWidth - 66 - 8 - 100 - 8, 30)];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_nameLabel];
        
        _dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 100 - 8, cellheight / 2 - 20, 100, 20)];
        _dataLabel.numberOfLines = 1;
        _dataLabel.textAlignment = NSTextAlignmentCenter;
        _dataLabel.font = [UIFont systemFontOfSize:15];
        _dataLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_dataLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 100 - 8, cellheight / 2 + 4, 100, 20)];
        _timeLabel.numberOfLines = 1;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_timeLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 32, cellheight / 2 - 10, 25, 25)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.backgroundColor = [CWColorUtils colorWithHexString:@"ff0000" alpha:0.7];
        // 按钮圆弧，以高度的一半为圆角，两边会形成完整的半圆
        _messageLabel.layer.masksToBounds = YES;
        _messageLabel.layer.cornerRadius = _messageLabel.frame.size.height / 2;
        [self addSubview:_messageLabel];
        
        _tagView = [[UILabel alloc] initWithFrame:CGRectMake(66, cellheight / 2 + 4, cellWidth - 66 - 8 - 100 - 8, 26)];
        [self addSubview:_tagView];

    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    return 70;
}

@end

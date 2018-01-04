//
//  DeviceImageCell.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/28.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "DeviceImageCell.h"
#import "CWColorUtils.h"

@implementation DeviceImageCell

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
        CGFloat cellheight = [DeviceImageCell getCellHeight] - 10;
        CGFloat videoImageWidth = cellWidth / 3;
        
        _videoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_empty_conwin"]];
        _videoImage.frame = CGRectMake(0, 0, videoImageWidth, cellheight);
        _videoImage.contentMode =  UIViewContentModeScaleAspectFill;
        _videoImage.clipsToBounds  = YES;
        [self addSubview:_videoImage];
        
        _logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_cw_logo"]];
        _logoImage.frame = CGRectMake(videoImageWidth / 3 * 2, cellheight - 10, videoImageWidth / 3, 10);
        _logoImage.contentMode =  UIViewContentModeScaleAspectFill;
        _logoImage.clipsToBounds  = YES;
        [self addSubview:_logoImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoImageWidth + 8, 0, cellWidth - videoImageWidth - 10, cellheight / 2)];
        _nameLabel.numberOfLines = 3;
        _nameLabel.textAlignment = NSTextAlignmentNatural;
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_nameLabel];
        
        _dataTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoImageWidth + 8, cellheight / 2, cellWidth - videoImageWidth - 10, 20)];
        _dataTimeLabel.numberOfLines = 1;
        _dataTimeLabel.textAlignment = NSTextAlignmentNatural;
        _dataTimeLabel.font = [UIFont systemFontOfSize:15];
        _dataTimeLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_dataTimeLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 32, cellheight / 2 - 10, 25, 25)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.backgroundColor = [CWColorUtils colorWithHexString:@"ff0000" alpha:0.7];
        // 按钮圆弧，以高度的一半为圆角，两边会形成完整的半圆
        _messageLabel.layer.masksToBounds = YES;
        _messageLabel.layer.cornerRadius = _messageLabel.frame.size.height / 2;
        [self addSubview:_messageLabel];
        
        _tagView = [[UILabel alloc] initWithFrame:CGRectMake(videoImageWidth + 8, cellheight / 2 + 20 + 2, cellWidth - videoImageWidth - 10, cellheight / 2 - 20 - 2 - 2)];
        [self addSubview:_tagView];

    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
    return cellWidth / 3 / 4 * 3 + 10;
}

@end

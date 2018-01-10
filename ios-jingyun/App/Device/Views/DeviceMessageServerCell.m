//
//  DeviceMessageServerCell.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/9.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "DeviceMessageServerCell.h"
#import "CWColorUtils.h"
#import "DeviceMessageModel.h"
#import "CWTextUtils.h"
#import "UITextLabel.h"

@implementation DeviceMessageServerCell

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
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, cellWidth, 16)];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_timeLabel];
        
        UIImageView* avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10 + 12 + 16 + 6, 30, 30)];
        avatarView.image = [UIImage imageNamed:@"icon_device_detail_system.png"];
        avatarView.contentMode =  UIViewContentModeScaleAspectFill;
        [self addSubview:avatarView];
        
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40 + 14, 10 + 12 + 16 + 8, 110, 56)];
        _photoImageView.contentMode =  UIViewContentModeScaleAspectFill;
        [self addSubview:_photoImageView];
        
        _contentLabel = [[UITextLabel alloc] init];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:17];
        _contentLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        //top, left, bottom, right
        _contentLabel.edgeInsets = UIEdgeInsetsMake(3, 4, 3, 4);
    
        [self addSubview:_contentLabel];
   
    }
    
    return self;
}

+ (CGFloat) getCellHeight:(DeviceMessageModel*) model{
    if (model.imageName || model.smallImage) {
        // 显示图片
        return 120;
    }else if(model.text){
        CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 40 - 14 - 40 - 14;
        NSString* contentText = model.text;
        contentText = [contentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        contentText = [contentText stringByReplacingOccurrencesOfString:@"\\\\r\\\\n" withString:@"\r"];
        contentText = [contentText stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
        CGFloat labelheight = [CWTextUtils textHeight:contentText textWidth:labelWidth];
        //单行文本
        if(labelheight < 40){
            labelheight = 40;
        }
        
        return labelheight + 8 + 16 + 2 + 8; //顶部间距、时间高度、间距、底部间距
    }
    
    return 60;
}

@end

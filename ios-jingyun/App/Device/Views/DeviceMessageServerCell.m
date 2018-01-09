//
//  DeviceMessageServerCell.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/9.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "DeviceMessageServerCell.h"
#import "CWColorUtils.h"

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
        CGFloat cellheight = [DeviceMessageServerCell getCellHeight];
        
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cellWidth, cellheight)];
        _contentLabel.text = @"请求布防";
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        _contentLabel.font = [UIFont systemFontOfSize:17];
        _contentLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_contentLabel];
        
        
    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    return 100;
}


@end

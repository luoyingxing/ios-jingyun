//
//  DeviceZoneViewCell.m
//  ios-jingyun
//
//  Created by conwin on 2018/1/18.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import "DeviceZoneViewCell.h"
#import "CWColorUtils.h"

@implementation DeviceZoneViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setOnItemClickDelegate:(id) delegate{
    self->delegate = delegate;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat cellheight = [DeviceZoneViewCell getCellHeight];
        CGFloat passWidth = 80;

        _statusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_item_zone_normal.png"]];
        _statusImage.frame = CGRectMake(10, 10, 30, 30);
        _statusImage.contentMode =  UIViewContentModeScaleAspectFill;
        _statusImage.clipsToBounds  = YES;
        [self addSubview:_statusImage];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, cellWidth - 10 - 30 - 10 - 10 - passWidth - 10, cellheight)];
        _nameLabel.numberOfLines = 1;
        _nameLabel.text = @"人生若只如初见，何事秋风悲画扇.人生若只如初见，何事秋风悲画扇";
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:17];
        _nameLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:_nameLabel];
        
        _passLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - passWidth - 10, 7, passWidth, 36)];
        _passLabel.backgroundColor =  [UIColor whiteColor];
        _passLabel.textColor = [UIColor grayColor];
        _passLabel.textAlignment = NSTextAlignmentCenter;
        _passLabel.text = @"旁路";
        _passLabel.font = [UIFont systemFontOfSize:16];
        _passLabel.layer.cornerRadius = 2;
        _passLabel.layer.borderColor = [CWColorUtils getThemeColor].CGColor;
        _passLabel.layer.borderWidth = 0.5;
        UITapGestureRecognizer *videoclickListener = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(passOnclickListener)];
        [_passLabel addGestureRecognizer:videoclickListener];
        _passLabel.userInteractionEnabled = YES;
        [self addSubview:_passLabel];
    }
    
    return self;
}

- (void) passOnclickListener{
    if ([self->delegate respondsToSelector:@selector(onItemClickListener:)]) {
        [self->delegate onItemClickListener:_index];
    }
}

+ (CGFloat) getCellHeight{
    return 50;
}

@end

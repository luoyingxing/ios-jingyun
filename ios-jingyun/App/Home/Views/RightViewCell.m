//
//  RightViewCell.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/25.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "RightViewCell.h"
#import "CWColorUtils.h"

@implementation RightViewCell

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
        
        self.maskView.backgroundColor = [UIColor whiteColor];
        
        //add label
        CGFloat imageWidth = (cellWidth - 20) / 3;
        CGFloat imageHeight = imageWidth / 4 * 3;
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, cellWidth - 20 - imageWidth - 8, imageHeight / 2)];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.textColor = [CWColorUtils colorWithHexString:@"#212121"];
        [self addSubview:self.titleLabel];
        
        self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 6 + imageHeight / 2, cellWidth - 20 - imageWidth - 8, imageHeight / 2)];
        self.sourceLabel.numberOfLines = 2;
        self.sourceLabel.textAlignment = NSTextAlignmentLeft;
        self.sourceLabel.font = [UIFont systemFontOfSize:14];
        self.sourceLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:self.sourceLabel];
        
        self.imageOne = [[UIImageView alloc] initWithFrame:CGRectMake(cellWidth - imageWidth - 10, 6, imageWidth, imageHeight)];
        [self addSubview:self.imageOne];
        
        
    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageWidth = (cellWidth - 20) / 3;
    CGFloat imageHeight = imageWidth / 4 * 3;
    
    return imageHeight + 12;
}

@end

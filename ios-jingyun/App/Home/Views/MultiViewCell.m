//
//  MultiViewCell.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/25.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "MultiViewCell.h"
#import "CWColorUtils.h"

@implementation MultiViewCell

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
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, cellWidth - 10, 30)];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [UIFont systemFontOfSize:17];
        self.titleLabel.textColor = [CWColorUtils colorWithHexString:@"#212121"];
        [self addSubview:self.titleLabel];
        
        //add label
        CGFloat imageWidth = (cellWidth - 20 - 4) / 3;
        CGFloat imageHeight = imageWidth / 4 * 3;
        
        self.imageOne = [[UIImageView alloc] initWithFrame:CGRectMake(10, 34, imageWidth, imageHeight)];
        [self addSubview:self.imageOne];
        
        self.imageTwo = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth + 10 + 2, 34, imageWidth, imageHeight)];
        [self addSubview:self.imageTwo];
        
        self.imageThree = [[UIImageView alloc] initWithFrame:CGRectMake(imageWidth * 2 + 10 + 4, 34, imageWidth, imageHeight)];
        [self addSubview:self.imageThree];
        
        self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, imageHeight + 30 + 4, cellWidth - 10, 30)];
        self.sourceLabel.numberOfLines = 1;
        self.sourceLabel.textAlignment = NSTextAlignmentLeft;
        self.sourceLabel.font = [UIFont systemFontOfSize:14];
        self.sourceLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:self.sourceLabel];
    }
    
    return self;
}

+ (CGFloat) getCellHeight{
    CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageWidth = (cellWidth - 20 - 4) / 3;
    CGFloat imageHeight = imageWidth / 4 * 3;
    
    return 30 + 4 + imageHeight + 30;
}

@end

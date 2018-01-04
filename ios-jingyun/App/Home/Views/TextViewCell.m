//
//  TextViewCell.m
//  ios-jingyun
//
//  Created by conwin on 2017/12/25.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "TextViewCell.h"
#import "CWColorUtils.h"

@implementation TextViewCell

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
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, cellWidth - 20, 70)];
        self.contentLabel.numberOfLines = 3;
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.font = [UIFont systemFontOfSize:16];
        self.contentLabel.textColor = [CWColorUtils colorWithHexString:@"#666666"];
        [self addSubview:self.contentLabel];
        
        self.sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, cellWidth - 20, 26)];
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
    
    return 12 + 30 + 70 + 26;
}

@end

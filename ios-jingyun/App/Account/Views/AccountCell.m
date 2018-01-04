//
//  AccountCell.m
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell

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
        CGFloat cellHeight = self.frame.size.height;
        CGFloat cellWidth = [UIScreen mainScreen].bounds.size.width;
        
        NSLog(@"cellWidth: %f - cellHeight: %f",cellWidth, cellHeight);
        
        
        self.maskView.backgroundColor = [UIColor redColor];
        
        //设置圆角边框
        
        self.maskView.layer.cornerRadius = 8;
        
        self.maskView.layer.masksToBounds = YES;
        
        //设置边框及边框颜色
        
        self.maskView.layer.borderWidth = 8;
        
        self.maskView.layer.borderColor =[ [UIColor blueColor] CGColor];
        
        
        //add label
        CGFloat labelWidth = cellWidth /3 *2;
        CGFloat labelHeight = 80;
        CGFloat labelLeft = 0;
        
        self.userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelLeft, 0, labelWidth, labelHeight)];
        
        
        [self addSubview:self.userNameLabel];
        
        
    }
    
    return self;
}


@end

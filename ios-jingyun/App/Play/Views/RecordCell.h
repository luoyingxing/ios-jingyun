//
//  RecordCell.h
//  ios-jingyun
//
//  Created by conwin on 2018/3/12.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dividerLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLable;

@property (weak, nonatomic) IBOutlet UILabel *titleLable;

@property (weak, nonatomic) IBOutlet UILabel *sizeLable;

@end

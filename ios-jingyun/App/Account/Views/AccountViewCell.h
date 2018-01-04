//
//  AccountViewCell.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/13.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@end

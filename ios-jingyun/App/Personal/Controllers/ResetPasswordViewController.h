//
//  ResetPasswordViewController.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResetPasswordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *oldTextField;

@property (weak, nonatomic) IBOutlet UITextField *newsTextField;

@property (weak, nonatomic) IBOutlet UITextField *newsAgainTextField;

- (IBAction)commitOnClick:(UIButton *)sender;

@end

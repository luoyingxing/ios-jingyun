//
//  VideoTypeViewController.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/15.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoTypeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *directButton;
@property (weak, nonatomic) IBOutlet UIImageView *directImageView;
@property (weak, nonatomic) IBOutlet UIButton *p2pButton;
@property (weak, nonatomic) IBOutlet UIImageView *p2pImageView;

- (IBAction)directOnClick:(UIButton *)sender;
- (IBAction)p2pOnClick:(UIButton *)sender;

@end

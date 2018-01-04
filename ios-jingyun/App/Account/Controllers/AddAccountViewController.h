//
//  AddAccountViewController.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface AddAccountViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic, strong) UserInfoModel* userInfoModel;

@end

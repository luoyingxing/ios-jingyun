//
//  AccountViewController.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/11.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserInfoModel.h"

@interface AccountViewController : UITableViewController <UIAlertViewDelegate>{
    //DDIndicator *_photoLoadingView;
//    JMActivityIndicator *_photoLoadingView;
    
    int connect_count_;
    NSTimer                 *loop_timer;
    
@public
    UserInfoModel *userInfo;
    BOOL login_ok;
}

@end

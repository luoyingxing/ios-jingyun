//
//  ZoneViewController.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/18.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceStatusModel.h"

@interface ZoneViewController : UITableViewController

@property (strong, nonatomic) DeviceStatusModel* deviceStatusModel;

@property (strong, nonatomic) NSString* cmd;

@property (strong, nonatomic) NSString* content;

@end

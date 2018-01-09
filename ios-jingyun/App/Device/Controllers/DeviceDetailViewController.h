//
//  DeviceDetailViewController.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/5.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceStatusModel.h"

@interface DeviceDetailViewController : UIViewController

@property (nonatomic, strong) NSMutableArray* dataArray;

@property (strong, nonatomic) DeviceStatusModel* deviceStatusModel;

@end

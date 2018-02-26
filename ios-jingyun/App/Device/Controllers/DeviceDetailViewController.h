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

@property (nonatomic, strong) NSMutableArray* imageArray;

@property (strong, nonatomic) DeviceStatusModel* deviceStatusModel;

//缓存布撤防的相关请求信息
@property (strong, nonatomic) NSString* cmd;
//缓存布撤防的相关请求信息
@property (strong, nonatomic) NSString* content;
//缓存布撤防的相关请求信息
@property (strong, nonatomic) NSString* type;

@end

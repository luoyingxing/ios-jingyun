//
//  PlayViewController.h
//  ios-jingyun
//
//  Created by conwin on 2018/3/1.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayViewController : UIViewController

@property (assign, nonatomic) NSInteger VideoPlayFormat;

@property (assign, nonatomic) NSInteger DeviceChannel;

@property (nonatomic, copy)  NSString  *tid;

@property (nonatomic, assign) NSInteger recordIndex;

@end

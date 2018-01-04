//
//  StatusMediaModel.h
//  StatusMediaModel
//
//  Created by yeung
//  Copyright (c) 2016年 yeung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceStatusModel : NSObject

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *tid;
@property (nonatomic, strong) NSString *partID;
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) UIImage *statusImage;
@property (nonatomic, strong) UIImage *backGroundImage;
@property (nonatomic, assign) NSUInteger zoneCount;
@property (nonatomic, assign) NSInteger videoPlayMode;
@property (nonatomic, assign) NSInteger tryP2PError;
@property (nonatomic, assign) NSInteger unread_count;
@property (nonatomic, assign) BOOL device_status;
@property (nonatomic, assign) BOOL on_off_line;
@property (nonatomic, strong) NSMutableArray *chnList;
@property (nonatomic, strong) NSMutableArray *tagArray;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *globalSatus;
@property (nonatomic, assign) BOOL isDeviceOpen;
@property (nonatomic, assign) BOOL isLeChangeDevice;
@property (nonatomic, assign) BOOL isHuaMaiDevice;
@property (nonatomic, assign) BOOL isEZDevice;

@end

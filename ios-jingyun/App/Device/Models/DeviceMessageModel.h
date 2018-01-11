//
//  DeviceMessageModel.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/9.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MessageTypeForServer,
    MessageTypeForLOCAL
} DeviceMessageType;

@interface DeviceMessageModel : NSObject

@property (nonatomic, assign) DeviceMessageType messageType;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *dateTime;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *iconName;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) UIImage *smallImage;
@property (nonatomic, copy) NSString *bgImageName;
@property (nonatomic, copy) NSString *tid;
@property (nonatomic, assign) NSInteger mid;
@property (nonatomic, assign) NSInteger messageStatusType;

//0 normal
//1 alarm
//5 pass
//8 away
//9 open
@property (nonatomic, assign) NSInteger backgroundType;

@property (nonatomic, assign) CGFloat cellHeight;

@end

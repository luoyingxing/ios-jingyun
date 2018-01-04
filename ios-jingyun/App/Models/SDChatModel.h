//
//  SDChatModel.h
//  TYeung
//
//  Created by yeung on 16/5/10.
//  Copyright © 2016年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SDMessageTypeSendToOthers,
    SDMessageTypeSendToMe
} SDMessageType;

@interface SDChatModel : NSObject

@property (nonatomic, assign) SDMessageType messageType;

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

@end

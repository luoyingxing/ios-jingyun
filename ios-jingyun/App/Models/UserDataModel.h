//
//  UserDataModel.h
//  TYeung
//
//  Created by yeung on 16/3/3.
//  Copyright © 2016年 conwin. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface UserDataModel : NSObject

@property (nonatomic, copy) NSString *id_;
@property (nonatomic, copy) NSString *clientType;
@property (nonatomic, copy) NSString *errCode;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userAddr;
@property (nonatomic, copy) NSString *leaderName;
@property (nonatomic, copy) NSString *leaderTel;
@property (nonatomic, copy) NSString *leaderTel2;
@property (nonatomic, copy) NSString *userTel;
@property (nonatomic, copy) NSString *userFax;
@property (nonatomic, copy) NSString *userArea;
@property (nonatomic, copy) NSString *mainTel;
@property (nonatomic, copy) NSString *mainType;
@property (nonatomic, copy) NSString *installTime;
@property (nonatomic, copy) NSString *finishTime;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) float userLat;
@property (nonatomic, assign) float userLog;
@property (nonatomic, copy) NSString *defaultContent1;
@property (nonatomic, copy) NSString *defaultContent2;
@property (nonatomic, copy) NSString *defaultContent3;
@property (nonatomic, strong) NSMutableArray *zoneDataArray;
@property (nonatomic, strong) NSMutableArray *contDataArray;

@end

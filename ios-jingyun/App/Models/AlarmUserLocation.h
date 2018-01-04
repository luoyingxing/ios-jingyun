//
//  AlarmUserLocation.h
//  TYeung
//
//  Created by yeung on 27/09/16.
//  Copyright © 2016年 TYeung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmUserLocation : NSObject
@property (nonatomic, strong) NSString  *tid;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, assign) float     lon;
@property (nonatomic, assign) float     lat;
@property (nonatomic, assign) BOOL      online;
@property (nonatomic, assign) NSInteger roleType;//1 gard, 2 worker, 3 mix
@property (nonatomic, strong) NSString  *roles;

@end

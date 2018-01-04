//
//  UserInfoDAO.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/12.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfoModel.h"

@interface UserInfoDAO : NSObject

+ (UserInfoDAO*) sharedInstance;

//插入UserInfoModel方法
-(int) create:(UserInfoModel*)model;

//删除UserInfoModel方法
-(int) remove:(UserInfoModel*)model;

//修改UserInfoModel方法
-(int) modify:(UserInfoModel*)model;

//查询所有数据方法
-(NSMutableArray*) findAll;

//按照主键查询数据方法
-(UserInfoModel*) findById:(UserInfoModel*)model;

@end

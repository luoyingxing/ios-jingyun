//
//  DeviceZoneOnItemClickDelegate.h
//  ios-jingyun
//
//  Created by conwin on 2018/1/18.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ZoneOnItemClickDelegate <NSObject>

//@required 表示必须要实现
//@optional 表示可以选择实现的方法
@optional

-(void) onItemClickListener:(NSInteger*) index;

@end

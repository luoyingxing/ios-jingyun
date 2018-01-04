//
//  ThingsResponseDelegate.h
//  ios-jingyun-test
//
//  Created by conwin on 2017/12/20.
//  Copyright © 2017年 conwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThingsResponseDelegate <NSObject>

@required//这个可以是required，也可以是optional

-(void)Entered:(NSInteger)amount;

-(void) onThingsResponse:(const char*)inReqID status:(int)inStatus header:(char*) inHeader body:(char*)inBody;

@end

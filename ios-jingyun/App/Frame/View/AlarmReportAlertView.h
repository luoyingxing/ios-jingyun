//
//  FilterAlertView.h
//  ios-jingyun

// use:
//FilterAlertView *filterAlertView = [[FilterAlertView alloc] initWithTitle:@"自定义UIAlertView" message:@"message" sureBtn:@"确认" cancleBtn:@"取消"];
//filterAlertView.resultIndex = ^(NSInteger index){
//    //回调---处理一系列动作
//    NSLog(@"回调---处理一系列动作 %lu", index);
//};
//[filterAlertView showXLAlertView];
//
//  Created by conwin on 2018/1/12.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSInteger index);

@interface AlarmReportAlertView : UIView

@property (nonatomic,copy) AlertResult resultIndex;

- (instancetype) initWithDefaultStyle;

- (void) show;

@end

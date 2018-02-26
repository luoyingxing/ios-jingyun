//
//  ChannelAlertView.h
//  ios-jingyun
//
//  Created by conwin on 2018/2/26.
//  Copyright © 2018年 conwin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSString* channel, NSInteger index);

@interface ChannelAlertView : UIView

@property (nonatomic,copy) AlertResult resultIndex;

- (instancetype) initWithDefaultStyle:(NSMutableArray*) array;

- (void) show;

@end

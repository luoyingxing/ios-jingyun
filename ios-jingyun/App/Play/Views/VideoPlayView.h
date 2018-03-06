//
//  VideoPlayView.h
//  ThingsIOSClient
//
//  Created by yeung on 05/01/16.
//  Copyright © 2016年 yeung . All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ColumnMenuView.h"
#import "JMNavbarMenu.h"

@class VideoWnd;

@protocol VideoPlayViewDelegate<NSObject>

@optional
- (void)didToFullVideoMode:(id)sender;
- (void)didStopVideoPlay:(id)sender;
@end

@interface VideoPlayView : UIView//<ColumnMenuViewDelegate>
{
    UIImageView     *background_image_view_;
    VideoWnd        *video_play_wnd;
    
    UIView          *full_header_view;
    UIView          *full_footer_view;
    
    UIView          *normal_footer_view;
    UIView          *normal_header_view;
    
    BOOL            is_full_mode;
    
    BOOL            show_tool_bar;
    
    UITapGestureRecognizer          *tapPress;
    
    BOOL            is_play_record;

@public
    id<VideoPlayViewDelegate>  delegate;
}

@property (assign, nonatomic) NSInteger numberOfItemsInRow;
@property (strong, nonatomic) JMNavbarMenu *menu;

- (void)layoutView:(BOOL)real_stream;

- (id)get_video_wnd;
@end

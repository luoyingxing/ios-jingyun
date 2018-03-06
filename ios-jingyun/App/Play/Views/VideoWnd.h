//
//  VideoWnd.h
//  netsdk_demo
//
//  Created by wu_pengzhou on 14-4-2.
//  Copyright (c) 2014年 wu_pengzhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoWnd : UIView
{
    UIActivityIndicatorView     *video_loading_view_;
    UILabel                     *video_text_view_;
}

-(void) stopLoading;

-(void) startLoading;

-(void) showErrFilter:(NSString*)sErr;

@end

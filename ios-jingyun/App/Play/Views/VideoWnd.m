//
//  VideoWnd.m
//  netsdk_demo
//
//  Created by wu_pengzhou on 14-4-2.
//  Copyright (c) 2014年 wu_pengzhou. All rights reserved.
//

#import "VideoWnd.h"
#import <QuartzCore/QuartzCore.h>
#import "NSObject+BAProgressHUD.h"
#import "UIView+SDAutoLayout.h"

@interface VideoWnd()<UIGestureRecognizerDelegate>

@end

@implementation VideoWnd

+ (Class) layerClass
{
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor lightGrayColor];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer*) self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:@NO, kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    }
    
    CGRect text_rc = CGRectMake(10, 10, frame.size.width, 30);
    [video_text_view_ setTextAlignment:NSTextAlignmentCenter];
    video_text_view_ = [[UILabel alloc] initWithFrame:text_rc];
    [video_text_view_ setTextColor:[UIColor whiteColor]];
    [self addSubview:video_text_view_];
    
    video_loading_view_ = [UIActivityIndicatorView new];
    [video_loading_view_ setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:video_loading_view_];
    video_loading_view_.sd_layout
    .centerXEqualToView(self)
    .centerYEqualToView(self)
    .widthIs(48)
    .heightEqualToWidth();
    

    return self;
}

-(void) stopLoading
{
    video_text_view_.hidden = YES;
    //[MBProgressHUD hideHUDForView:self animated:YES];
    [video_loading_view_ stopAnimating];
    //[self BA_hideProgress];
}

-(void) startLoading
{
    NSInteger iChannel = self.tag;
    NSString *filter_text = [[NSString alloc] initWithFormat:@"视频通道%02ld正在努力加载中...", (long)iChannel + 1];
    [video_text_view_ setText:filter_text];
    video_text_view_.hidden = NO;
    [video_loading_view_ startAnimating];
    //[self BA_showBusy];
    //[MBProgressHUD showHUDAddedTo:self animated:YES];
}

-(void) showErrFilter:(NSString*)sErr
{
    video_text_view_.hidden = NO;
    [video_text_view_ setText:sErr];
    //[self showErrFilter:sErr];
}
// DO NOT comment this!!!
// or only the lower-left corner of frame will be drawed
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //[self drawText:@"draw text on video playing" x:40 y:40];
}


@end

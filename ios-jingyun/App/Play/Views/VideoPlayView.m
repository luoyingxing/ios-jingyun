//
//  VideoPlayView.m
//  ThingsIOSClient
//
//  Created by yeung on 05/01/16.
//  Copyright © 2016年 yeung . All rights reserved.
//

#import "VideoPlayView.h"
#import "VideoWnd.h"



@implementation VideoPlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (JMNavbarMenu *)menu {
    if (_menu == nil) {
        JMNavbarMenuItem *item1 = [JMNavbarMenuItem ItemWithTitle:@"item" icon:[UIImage imageNamed:@"Image"]];
        _menu = [[JMNavbarMenu alloc] initWithItems:@[item1,item1,item1,item1,item1,item1,item1,item1,item1,item1,item1,item1] width:self.dop_width maximumNumberInRow:_numberOfItemsInRow];
        _menu.backgroundColor = [UIColor blackColor];
        _menu.separatarColor = [UIColor whiteColor];
        _menu.delegate = self;
    }
    return _menu;
}

- (void)layoutView:(BOOL)real_stream
{
    self.backgroundColor = [UIColor whiteColor];
    
    CGSize winSize = self.bounds.size;
    
    background_image_view_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    [background_image_view_ setImage:[UIImage imageNamed:@"login_beijing.png"]];
    [self addSubview:background_image_view_];
    
    
    /*UIView *video_play_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height - 48)];
    [video_play_view setBackgroundColor:[UIColor clearColor]];
    [self addSubview:video_play_view];
    
    CGSize videoSize = video_play_view.frame.size;
    CGFloat video_height = videoSize.width*288/352;
    VideoWnd *play_view = [[VideoWnd alloc] initWithFrame:CGRectMake(0, 0, videoSize.width, video_height)];
    [play_view setBackgroundColor:[UIColor blackColor]];
    [video_play_view addSubview:play_view];*/
    is_full_mode = NO;
    
    tapPress = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    show_tool_bar = YES;
    is_play_record = !real_stream;
    [self to_normal_mode];
    
}
//[back_ground_view addGestureRecognizer:tapPress];

//长按调用的方法
- (void)tapAction:(UITapGestureRecognizer *)recognizer
{
    if (is_full_mode) {
        if (show_tool_bar) {
            show_tool_bar = NO;
            full_footer_view.hidden = YES;
            full_header_view.hidden = YES;
        }
        else {
            show_tool_bar = YES;
            full_footer_view.hidden = NO;
            full_header_view.hidden = NO;
        }
    }
    else {
        if (show_tool_bar) {
            show_tool_bar = NO;
            normal_footer_view.hidden = YES;
            normal_footer_view.hidden = YES;
        }
        else {
            show_tool_bar = YES;
            normal_footer_view.hidden = NO;
            normal_header_view.hidden = NO;
        }
    }
}

- (id)get_video_wnd
{
    return video_play_wnd;
}

- (void) to_full_mode
{
    CGSize winSize = self.frame.size;
    CGFloat video_height = (winSize.width)*176/288;
    
    if (normal_footer_view) [normal_footer_view removeFromSuperview];
    if (normal_header_view) [normal_header_view removeFromSuperview];
    
    [background_image_view_ setFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    
    if (video_play_wnd == nil) {
        video_play_wnd = [[VideoWnd alloc] initWithFrame:CGRectMake(0, winSize.height/2-video_height, winSize.width, video_height*2)];
        [video_play_wnd setBackgroundColor:[UIColor blackColor]];
        [self addSubview:video_play_wnd];
        
        [video_play_wnd addGestureRecognizer:tapPress];
    }
    else {
        [video_play_wnd setFrame:CGRectMake(0, winSize.height/2-video_height, winSize.width , video_height*2)];
        //[video_play_wnd setFrame:CGRectMake(0, 0, winSize.width , winSize.height)];
    }
    
    UIImageView *image_video_source = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 10)];
    [video_play_wnd addSubview:image_video_source];
    if (is_play_record) {
        /*AMProgressView *playProgressView = [[AMProgressView alloc] initWithFrame:CGRectMake(0, winSize.height-52, winSize.width, 4)
                                                               andGradientColors:[NSArray arrayWithObjects:[UIColor orangeColor], nil]
                                                                andOutsideBorder:NO
                                                                     andVertical:YES];
        playProgressView.emptyPartAlpha = 0.8f;
        playProgressView.minimumValue = 0.0;
        playProgressView.maximumValue = 1.0;
        [playProgressView setProgress:0.3];
        [playProgressView setTag:100000];
        [video_play_wnd addSubview:playProgressView];*/
        [image_video_source setImage:[UIImage imageNamed:@"video_play_vcr.png"]];
    }
    else {
        [image_video_source setImage:[UIImage imageNamed:@"video_play_live.png"]];
    }
    
    CGAffineTransform rotate = CGAffineTransformMakeRotation( 90.0 / 180.0 * 3.14 );
    if (full_footer_view == nil) {
        full_footer_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, winSize.height)];
        [full_footer_view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        
        CGSize tool_view_size = full_footer_view.frame.size;
        UIButton *soundBtn = [[UIButton alloc] initWithFrame:CGRectMake(14, 16, 22, 22)];
        [soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        [soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        [full_footer_view addSubview:soundBtn];
        //UIProgressView *soundProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(24, 40, 47, 20)];
        /*AMProgressView *soundProgressView = [[AMProgressView alloc] initWithFrame:CGRectMake(24, 40, 4, 47)
                                                                andGradientColors:[NSArray arrayWithObjects:[UIColor orangeColor], nil]
                                                                 andOutsideBorder:NO
                                                                      andVertical:YES];
        [soundProgressView setProgress:0.3];
        [full_footer_view addSubview:soundProgressView];*/
        UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(7, tool_view_size.height / 2 - 60, 30, 30)];
        [lastBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaituibai"] forState:UIControlStateNormal];
        [lastBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaituillan"] forState:UIControlStateNormal];
        [full_footer_view addSubview:lastBtn];
        UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(4, tool_view_size.height / 2 - 20, 40, 40)];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"video_play_zhantingbai"] forState:UIControlStateNormal];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"video_play_zhantinglan"] forState:UIControlStateNormal];
        [full_footer_view addSubview:playBtn];
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(7, tool_view_size.height/2 + 30, 30, 30)];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaijinbai"] forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaijinlan"] forState:UIControlStateNormal];
        [full_footer_view addSubview:nextBtn];
        
        UIButton *fullBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, winSize.height - 48, 32, 32)];
        [fullBtn setBackgroundImage:[UIImage imageNamed:@"video_play_quanpingbai"] forState:UIControlStateNormal];
        [fullBtn setBackgroundImage:[UIImage imageNamed:@"video_play_quanpingbai"] forState:UIControlStateNormal];
        [fullBtn addTarget:self action:@selector(to_full_screen:) forControlEvents:UIControlEventTouchUpInside];
        [full_footer_view addSubview:fullBtn];
        
        
        [soundBtn setTransform:rotate];
        [fullBtn setTransform:rotate];
        [lastBtn setTransform:rotate];
        [playBtn setTransform:rotate];
        [nextBtn setTransform:rotate];
    }
    [self addSubview:full_footer_view];
    
    if (full_header_view == nil) {
        full_header_view = [[UIView alloc] initWithFrame:CGRectMake(winSize.width - 48, 0, 48, winSize.height)];
        [full_header_view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
        
        UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 16, 48, 48)];
        //[soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        //[soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        [backBtn setTitle:@"返回" forState:UIControlStateNormal];
        [backBtn setTransform:rotate];
        [backBtn addTarget:self action:@selector(go_back:) forControlEvents:UIControlEventTouchUpInside];
        [full_header_view addSubview:backBtn];
        
        UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, winSize.height - 48, 44, 44)];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_tongdaolan"] forState:UIControlStateNormal];
        [menuBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_tongdaobai"] forState:UIControlStateHighlighted];
        [menuBtn setTransform:rotate];
        [full_header_view addSubview:menuBtn];
        
        UIButton *captureBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, winSize.height - 48*2, 44, 44)];
        [captureBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_paizhaolan"] forState:UIControlStateNormal];
        [captureBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_paizhaobai"] forState:UIControlStateHighlighted];
        [captureBtn setTransform:rotate];
        [full_header_view addSubview:captureBtn];
        
        UIButton *resBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, winSize.height - 48*3, 44, 44)];
        [resBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_biaoqinglan"] forState:UIControlStateNormal];
        [resBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_biaoqingbai"] forState:UIControlStateHighlighted];
        [resBtn setTransform:rotate];
        [full_header_view addSubview:resBtn];
        
        UIButton *speekBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, winSize.height - 48*4, 44, 44)];
        [speekBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_guanbilan"] forState:UIControlStateNormal];
        [speekBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_guanbibai"] forState:UIControlStateHighlighted];
        [speekBtn setTransform:rotate];
        [full_header_view addSubview:speekBtn];
        
        UIButton *talkBtn = [[UIButton alloc] initWithFrame:CGRectMake(2, winSize.height - 48*5, 44, 44)];
        [talkBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_jiantinglan"] forState:UIControlStateNormal];
        [talkBtn setBackgroundImage:[UIImage imageNamed:@"full_video_play_jiantingbai"] forState:UIControlStateHighlighted];
        [talkBtn setTransform:rotate];
        [full_header_view addSubview:talkBtn];
        
    }
    [self addSubview:full_header_view];
}

- (void) to_normal_mode
{
    CGSize winSize = self.frame.size;
    if (full_footer_view) [full_footer_view removeFromSuperview];
    if (full_header_view) [full_header_view removeFromSuperview];
    
    [background_image_view_ setFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
    
    if (video_play_wnd == nil) {
        video_play_wnd = [[VideoWnd alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        //video_play_wnd = [[VideoWnd alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height - 52)];
        [video_play_wnd setBackgroundColor:[UIColor blackColor]];
        [self addSubview:video_play_wnd];
        
        [video_play_wnd addGestureRecognizer:tapPress];
    }
    else {
        [video_play_wnd setFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        //[video_play_wnd setFrame:CGRectMake(0, 0, winSize.width, winSize.height - 52)];
    }
    
    UIImageView *image_video_source = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 10)];
    [video_play_wnd addSubview:image_video_source];
    
    if (is_play_record) {
        /*AMProgressView *playProgressView = [[AMProgressView alloc] initWithFrame:CGRectMake(0, winSize.height-52, winSize.width, 4)
                                                               andGradientColors:[NSArray arrayWithObjects:[UIColor orangeColor], nil]
                                                                andOutsideBorder:NO
                                                                     andVertical:NO];
        playProgressView.emptyPartAlpha = 0.8f;
        playProgressView.minimumValue = 0.0;
        playProgressView.maximumValue = 1.0;
        [playProgressView setProgress:0.3];
        [playProgressView setTag:100000];
        [video_play_wnd addSubview:playProgressView];*/
        [image_video_source setImage:[UIImage imageNamed:@"video_play_vcr.png"]];
    }
    else {
        [image_video_source setImage:[UIImage imageNamed:@"video_play_live.png"]];
    }
    
    if (normal_footer_view == nil) {
        normal_footer_view = [[UIView alloc] initWithFrame:CGRectMake(0, winSize.height - 48, winSize.width, 48)];
        [normal_footer_view setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7]];
    
        CGSize tool_view_size = normal_footer_view.frame.size;
        UIButton *soundBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 14, 22, 22)];
        [soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        [soundBtn setBackgroundImage:[UIImage imageNamed:@"video_play_yinliangjian"] forState:UIControlStateNormal];
        //[normal_footer_view addSubview:soundBtn];
        //UIProgressView *soundProgressView = [[UIProgressView alloc] initWithFrame:CGRectMake(40, 24, 47, 20)];
        /*AMProgressView *soundProgressView = [[AMProgressView alloc] initWithFrame:CGRectMake(40, 24, 47, 4)
                                                  andGradientColors:[NSArray arrayWithObjects:[UIColor orangeColor], nil]
                                                   andOutsideBorder:NO
                                                        andVertical:NO];
        //[soundProgressView setProgressViewStyle:UIProgressViewStyleBar];
        //[soundProgressView setTrackImage:[UIImage imageNamed:@"video_play_yinliangtiao"]];
        //[soundProgressView setProgressImage:[UIImage imageNamed:@"video_play_yinliangtiao"]];
        soundProgressView.emptyPartAlpha = 0.8f;
        soundProgressView.minimumValue = 0.0;
        soundProgressView.maximumValue = 1.0;
        [soundProgressView setProgress:0.3];*/
        //[normal_footer_view addSubview:soundProgressView];
        UIButton *lastBtn = [[UIButton alloc] initWithFrame:CGRectMake(tool_view_size.width / 2 - 60, 7, 30, 30)];
        [lastBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaituibai"] forState:UIControlStateNormal];
        [lastBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaituillan"] forState:UIControlStateNormal];
        //[normal_footer_view addSubview:lastBtn];
        UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake(tool_view_size.width / 2 - 20, 4, 40, 40)];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"video_play_zhantingbai"] forState:UIControlStateNormal];
        [playBtn setBackgroundImage:[UIImage imageNamed:@"video_play_zhantinglan"] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(pauseVideoPlay:) forControlEvents:UIControlEventTouchUpInside];
        [normal_footer_view addSubview:playBtn];
        UIButton *nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(tool_view_size.width/2 + 30, 7, 30, 30)];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaijinbai"] forState:UIControlStateNormal];
        [nextBtn setBackgroundImage:[UIImage imageNamed:@"video_play_kuaijinlan"] forState:UIControlStateNormal];
        //[normal_footer_view addSubview:nextBtn];
        
        UIButton *fullBtn = [[UIButton alloc] initWithFrame:CGRectMake(tool_view_size.width - 48, 8, 32, 32)];
        [fullBtn setBackgroundImage:[UIImage imageNamed:@"video_play_quanpingbai"] forState:UIControlStateNormal];
        [fullBtn setBackgroundImage:[UIImage imageNamed:@"video_play_quanpingbai"] forState:UIControlStateNormal];
        [fullBtn addTarget:self action:@selector(to_full_screen:) forControlEvents:UIControlEventTouchUpInside];
        [normal_footer_view addSubview:fullBtn];
        
        
    }
    [self addSubview:normal_footer_view];
}

- (void) go_back:(id)sender
{
}

- (void) to_full_screen:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didToFullVideoMode:)]) {
        [delegate didToFullVideoMode:sender];
        if (is_full_mode == NO) {
            is_full_mode = YES;
            [self to_full_mode];
        }else {
            is_full_mode = NO;
            [self to_normal_mode];
        }
    }
}

- (void) pauseVideoPlay:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didStopVideoPlay:)]) {
        [delegate didStopVideoPlay:sender];
        is_play_record = !is_play_record;
    }
}

@end

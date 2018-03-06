//
//  ZFPlayerControlView.m
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ZFPlayerControlView.h"
#import "ZFPlayer.h"

@interface ZFPlayerControlView ()
/** 开始播放按钮 */
@property (nonatomic, strong) UIButton                *startBtn;
/** 当前播放时长label */
@property (nonatomic, strong) UILabel                 *currentTimeLabel;
/** 视频总时长label */
@property (nonatomic, strong) UILabel                 *totalTimeLabel;
/** 缓冲进度条 */
@property (nonatomic, strong) UIProgressView          *progressView;
/** 滑杆 */
@property (nonatomic, strong) UISlider                *videoSlider;
/** 全屏按钮 */
@property (nonatomic, strong) UIButton                *fullScreenBtn;
/** 锁定屏幕方向按钮 */
@property (nonatomic, strong) UIButton                *lockBtn;
/** 快进快退label */
@property (nonatomic, strong) UILabel                 *horizontalLabel;
/** 系统菊花 */
@property (nonatomic, strong) UIActivityIndicatorView *activity;
/** 返回按钮*/
@property (nonatomic, strong) UIButton                *backBtn;
/** 重播按钮 */
@property (nonatomic, strong) UIButton                *repeatBtn;
/** bottomView*/
@property (nonatomic, strong) UIImageView             *bottomImageView;
/** topView */
@property (nonatomic, strong) UIImageView             *topImageView;

@property (nonatomic, strong) UIImageView             *videoTypeImageView;

@property (nonatomic, assign) BOOL                    isFullScreen;

@end

@implementation ZFPlayerControlView

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _isFullScreen = NO;
        
        [self addSubview:self.videoWnd];
        [self addSubview:self.topImageView];
        [self addSubview:self.bottomImageView];
        [self.bottomImageView addSubview:self.startBtn];
        [self.bottomImageView addSubview:self.currentTimeLabel];
        [self.bottomImageView addSubview:self.progressView];
        [self.bottomImageView addSubview:self.videoSlider];
        [self.bottomImageView addSubview:self.fullScreenBtn];
        [self.bottomImageView addSubview:self.totalTimeLabel];
        
        [self.topImageView addSubview:self.videoTypeBtn];
        [self.topImageView addSubview:self.videoResBtn];
        [self.topImageView addSubview:self.videoCapBtn];
        [self.topImageView addSubview:self.videoTalkBtn];
        [self.topImageView addSubview:self.videoSoundBtn];
        
        [self.topImageView addSubview:self.recordDateBtn];
        [self.topImageView addSubview:self.recordTodayBtn];
        [self.topImageView addSubview:self.recordYesTodayBtn];
        [self.topImageView addSubview:self.recordNextDayBtn];
        
        [self addSubview:self.lockBtn];
        [self addSubview:self.backBtn];
        [self addSubview:self.activity];
        [self addSubview:self.repeatBtn];
        [self addSubview:self.horizontalLabel];
        
        [self addSubview:self.videoTypeImageView];
        
        //[self.topImageView addSubview:self.resolutionBtn];
        
        // 添加子控件的约束
        [self makeSubViewsConstraints];
        // 分辨率btn点击
        //[self.resolutionBtn addTarget:self action:@selector(resolutionAction:) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
        [self.videoSlider addGestureRecognizer:sliderTap];
        
        [self.activity stopAnimating];
        self.activity.hidden        = YES;
        //self.downLoadBtn.hidden     = YES;
        //self.resolutionBtn.hidden   = YES;
        // 初始化时重置controlView
        [self resetControlView];
    }
    return self;
}

- (void)makeSubViewsConstraints
{
    [_videoWnd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.equalTo(self);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.mas_top).offset(5);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.videoTypeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.topImageView.mas_trailing).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.videoResBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.videoTypeBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.videoCapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.videoResBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.videoTalkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.videoCapBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.videoSoundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.videoTalkBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    //
    
    [self.recordDateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.videoTypeBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.recordTodayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.recordDateBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.recordYesTodayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.recordTodayBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];
    
    [self.recordNextDayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.trailing.equalTo(self.recordYesTodayBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];

    /*[self.resolutionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(30);
        make.trailing.equalTo(self.downLoadBtn.mas_leading).offset(-10);
        make.centerY.equalTo(self.backBtn.mas_centerY);
    }];*/
    
    [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.bottomImageView.mas_leading).offset(5);
        make.bottom.equalTo(self.bottomImageView.mas_bottom).offset(-5);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(-3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30);
        make.trailing.equalTo(self.bottomImageView.mas_trailing).offset(-5);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.fullScreenBtn.mas_leading).offset(3);
        make.centerY.equalTo(self.startBtn.mas_centerY);
        make.width.mas_equalTo(43);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
        make.centerY.equalTo(self.startBtn.mas_centerY);
    }];
    
    [self.videoSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.currentTimeLabel.mas_trailing).offset(4);
        make.trailing.equalTo(self.totalTimeLabel.mas_leading).offset(-4);
        make.centerY.equalTo(self.currentTimeLabel.mas_centerY).offset(-1);
        make.height.mas_equalTo(30);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(15);
        make.centerY.equalTo(self.mas_centerY);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.horizontalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(160);
        make.height.mas_equalTo(40);
        make.center.equalTo(self);
    }];
    
    [self.activity mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [self.repeatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.center.equalTo(self);
    }];
    
    [self.videoTypeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.topImageView.mas_bottom).offset(4);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
    }];
}

#pragma mark - Action
/**
 *  点击切换分别率按钮
 */
- (void)changeResolution:(UIButton *)sender
{
    // 隐藏分辨率View
    //self.resolutionView.hidden  = YES;
    // 分辨率Btn改为normal状态
    //self.resolutionBtn.selected = NO;
    // topImageView上的按钮的文字
    //[self.resolutionBtn setTitle:sender.titleLabel.text forState:UIControlStateNormal];
    //if (self.resolutionBlock) { self.resolutionBlock(sender); }
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap
{
    if ([tap.view isKindOfClass:[UISlider class]] && self.tapBlock) {
        UISlider *slider = (UISlider *)tap.view;
        CGPoint point = [tap locationInView:slider];
        CGFloat length = slider.frame.size.width;
        // 视频跳转的value
        CGFloat tapValue = point.x / length;
        self.tapBlock(tapValue);
    }
}

#pragma mark - Public Method

/** 重置ControlView */
- (void)resetControlView
{
    self.videoSlider.value      = 0;
    self.progressView.progress  = 0;
    self.currentTimeLabel.text  = @"00:00";
    self.totalTimeLabel.text    = @"00:00";
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    //self.resolutionView.hidden  = YES;
    self.backgroundColor        = [UIColor clearColor];
    self.videoTypeBtn.enabled    = YES;
    
    self.videoResBtn.hidden     = YES;
    self.videoCapBtn.hidden     = YES;
    self.videoTalkBtn.hidden    = YES;
    self.videoSoundBtn.hidden   = YES;
    
    self.recordDateBtn.hidden       = YES;
    self.recordTodayBtn.hidden      = YES;
    self.recordYesTodayBtn.hidden   = YES;
    self.recordNextDayBtn.hidden    = YES;
    
    _isFullScreen                   = NO;
}

- (void)resetControlViewForResolution
{
    self.horizontalLabel.hidden = YES;
    self.repeatBtn.hidden       = YES;
    //self.resolutionView.hidden  = YES;
    self.videoTypeBtn.enabled    = YES;
    self.backgroundColor        = [UIColor clearColor];
}

- (void)showControlView
{
    self.topImageView.alpha    = 1;
    self.bottomImageView.alpha = 1;
    self.lockBtn.alpha         = 1;
    //self.videoTypeImageView.alpha = 1;
}

- (void)hideControlView
{
    self.topImageView.alpha    = 0;
    self.bottomImageView.alpha = 0;
    self.lockBtn.alpha         = 0;
    //self.videoTypeImageView.alpha = 0;
    // 隐藏resolutionView
    //self.resolutionBtn.selected = YES;
    //[self resolutionAction:self.resolutionBtn];
}

#pragma mark - setter

- (void) setVideoType:(NSInteger)videoType
{
    _videoType = videoType;
    _videoTypeBtn.hidden = YES;
    if (_videoType == 1) {
        [_videoTypeBtn setTitle:@"实时" forState:UIControlStateNormal];
        
        if (_isFullScreen) {
            self.videoResBtn.hidden         = NO;
            self.videoCapBtn.hidden         = NO;
            self.videoTalkBtn.hidden        = NO;
            self.videoSoundBtn.hidden       = NO;
            
            self.recordDateBtn.hidden       = YES;
            self.recordTodayBtn.hidden      = YES;
            self.recordYesTodayBtn.hidden   = YES;
            self.recordNextDayBtn.hidden    = YES;
            
            self.videoSlider.hidden         = YES;
            self.progressView.hidden        = YES;
            self.currentTimeLabel.hidden    = YES;
            self.totalTimeLabel.hidden      = YES;
        }
    }
    else {
        [_videoTypeBtn setTitle:@"录像" forState:UIControlStateNormal];
        
        if (_isFullScreen) {
            self.recordDateBtn.hidden       = NO;
            self.recordTodayBtn.hidden      = NO;
            self.recordYesTodayBtn.hidden   = NO;
            self.recordNextDayBtn.hidden    = NO;
            
            self.videoResBtn.hidden         = YES;
            self.videoCapBtn.hidden         = YES;
            self.videoTalkBtn.hidden        = YES;
            self.videoSoundBtn.hidden       = YES;
            
            self.videoSlider.hidden         = NO;
            self.progressView.hidden        = NO;
            self.currentTimeLabel.hidden    = NO;
            self.totalTimeLabel.hidden      = NO;
        }
    }
    
    
}

- (void) setVideoIsPlayingType:(NSInteger)videoIsPlayingType
{
    _videoIsPlayingType = videoIsPlayingType;
    [self setVideoType:videoIsPlayingType];
    if (videoIsPlayingType == 1) {
        [_videoTypeImageView setImage:[UIImage imageNamed:@"C200shishijiaobiao"]];
    }
    else if (videoIsPlayingType == 2) {
        [_videoTypeImageView setImage:[UIImage imageNamed:@"C200luxiangjiaobiao"]];
    }
}
#pragma mark - getter

- (UIImage*) createImageWithColor: (UIColor*) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"play_back_full")] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)topImageView
{
    if (!_topImageView) {
        _topImageView                        = [[UIImageView alloc] init];
        _topImageView.userInteractionEnabled = YES;
        //_topImageView.image                  = [UIImage imageNamed:ZFPlayerSrcName(@"top_shadow")];
        _topImageView.image                  = [self createImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    }
    return _topImageView;
}

- (UIImageView *)bottomImageView
{
    if (!_bottomImageView) {
        _bottomImageView                        = [[UIImageView alloc] init];
        _bottomImageView.userInteractionEnabled = YES;
        //_bottomImageView.image                  = [UIImage imageNamed:ZFPlayerSrcName(@"bottom_shadow")];
        _bottomImageView.image                  = [self createImageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    }
    return _bottomImageView;
}

- (UIButton *)lockBtn
{
    if (!_lockBtn) {
        _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"unlock-nor")] forState:UIControlStateNormal];
        [_lockBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"lock-nor")] forState:UIControlStateSelected];
    }
    return _lockBtn;
}

- (UIButton *)startBtn
{
    if (!_startBtn) {
        _startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_startBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-play")] forState:UIControlStateNormal];
        [_startBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-pause")] forState:UIControlStateSelected];
    }
    return _startBtn;
}

- (UILabel *)currentTimeLabel
{
    if (!_currentTimeLabel) {
        _currentTimeLabel               = [[UILabel alloc] init];
        _currentTimeLabel.textColor     = [UIColor whiteColor];
        _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _currentTimeLabel;
}

- (UIProgressView *)progressView
{
    if (!_progressView) {
        _progressView                   = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _progressView.trackTintColor    = [UIColor clearColor];
    }
    return _progressView;
}

- (UISlider *)videoSlider
{
    if (!_videoSlider) {
        _videoSlider                       = [[UISlider alloc] init];
        // 设置slider
        [_videoSlider setThumbImage:[UIImage imageNamed:ZFPlayerSrcName(@"slider")] forState:UIControlStateNormal];
        _videoSlider.maximumValue          = 1;
        _videoSlider.minimumTrackTintColor = [UIColor whiteColor];
        _videoSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    return _videoSlider;
}

- (UILabel *)totalTimeLabel
{
    if (!_totalTimeLabel) {
        _totalTimeLabel               = [[UILabel alloc] init];
        _totalTimeLabel.textColor     = [UIColor whiteColor];
        _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _totalTimeLabel;
}

- (UIButton *)fullScreenBtn
{
    if (!_fullScreenBtn) {
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-fullscreen")] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"kr-video-player-shrinkscreen")] forState:UIControlStateSelected];
    }
    return _fullScreenBtn;
}

- (UILabel *)horizontalLabel
{
    if (!_horizontalLabel) {
        _horizontalLabel                 = [[UILabel alloc] init];
        _horizontalLabel.textColor       = [UIColor whiteColor];
        _horizontalLabel.textAlignment   = NSTextAlignmentCenter;
        // 设置快进快退label
        _horizontalLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:ZFPlayerSrcName(@"Management_Mask")]];
    }
    return _horizontalLabel;
}

- (UIActivityIndicatorView *)activity
{
    if (!_activity) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    return _activity;
}

- (UIButton *)repeatBtn
{
    if (!_repeatBtn) {
        _repeatBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_repeatBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"repeat_video")] forState:UIControlStateNormal];
    }
    return _repeatBtn;
}

- (UIButton *)videoTypeBtn
{
    if (!_videoTypeBtn) {
        _videoTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_videoTypeBtn setTitle:@"录像" forState:UIControlStateNormal];
        [_videoTypeBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200luxiang")] forState:UIControlStateNormal];
        [_videoTypeBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _videoTypeBtn;
}

- (UIButton *)videoResBtn
{
    if (!_videoResBtn) {
        _videoResBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_videoResBtn setTitle:@"高清" forState:UIControlStateNormal];
        [_videoResBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200biaoqingbai")] forState:UIControlStateNormal];
        [_videoResBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _videoResBtn;
}

- (UIButton *)videoCapBtn
{
    if (!_videoCapBtn) {
        _videoCapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoCapBtn setTitle:@"抓图" forState:UIControlStateNormal];
        [_videoCapBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200paizhao")] forState:UIControlStateNormal];
        [_videoCapBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _videoCapBtn;
}

- (UIButton *)videoTalkBtn
{
    if (!_videoTalkBtn) {
        _videoTalkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoTalkBtn setTitle:@"监听" forState:UIControlStateNormal];
        [_videoTalkBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200jianting")] forState:UIControlStateNormal];
        [_videoTalkBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _videoTalkBtn;
}

- (UIButton *)videoSoundBtn
{
    if (!_videoSoundBtn) {
        _videoSoundBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoSoundBtn setTitle:@"说话" forState:UIControlStateNormal];
        [_videoSoundBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200quanpinganniu")] forState:UIControlStateNormal];
        [_videoSoundBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _videoSoundBtn;
}

- (UIButton *)recordDateBtn
{
    if (!_recordDateBtn) {
        _recordDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordDateBtn setTitle:@"选时" forState:UIControlStateNormal];
        [_recordDateBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200xuanshi")] forState:UIControlStateNormal];
        [_recordDateBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _recordDateBtn;
}

- (UIButton *)recordTodayBtn
{
    if (!_recordTodayBtn) {
        _recordTodayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordTodayBtn setTitle:@"今天" forState:UIControlStateNormal];
        [_recordTodayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200jintian")] forState:UIControlStateNormal];
        [_recordTodayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _recordTodayBtn;
}

- (UIButton *)recordYesTodayBtn
{
    if (!_recordYesTodayBtn) {
        _recordYesTodayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordYesTodayBtn setTitle:@"昨天" forState:UIControlStateNormal];
        [_recordYesTodayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200zuotian")] forState:UIControlStateNormal];
        [_recordYesTodayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _recordYesTodayBtn;
}

- (UIButton *)recordNextDayBtn
{
    if (!_recordNextDayBtn) {
        _recordNextDayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordNextDayBtn setTitle:@"前天" forState:UIControlStateNormal];
        [_recordNextDayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"C200qiantian")] forState:UIControlStateNormal];
        [_recordNextDayBtn setImage:[UIImage imageNamed:ZFPlayerSrcName(@"")] forState:UIControlStateDisabled];
    }
    return _recordNextDayBtn;
}

- (UIImageView*)videoTypeImageView
{
    if (!_videoTypeImageView) {
        _videoTypeImageView = [UIImageView new];
        [_videoTypeImageView setImage:[UIImage imageNamed:@"video_play_live"]];
    }
    return _videoTypeImageView;
}

/*- (UIButton *)resolutionBtn
{
    if (!_resolutionBtn) {
        _resolutionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _resolutionBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _resolutionBtn.backgroundColor = RGBA(0, 0, 0, 0.7);
    }
    return _resolutionBtn;
}*/



/**
 * 懒加载 控制层View
 *
 *  @return VideoWnd
 */
- (VideoWnd *)videoWnd
{
    if (!_videoWnd) {
        _videoWnd = [[VideoWnd alloc] init];
        [self addSubview:_videoWnd];
        //[_controlView setBackgroundColor:[UIColor greenColor]];
        
    }
    return _videoWnd;
}

- (void) fullScreen
{
    _isFullScreen = YES;
    
    [self.topImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(60);
    }];
    
    [self.videoTypeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.topImageView.mas_bottom).offset(4);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
    }];
    
    if (_videoType == 1) {
        self.videoResBtn.hidden         = NO;
        self.videoCapBtn.hidden         = NO;
        self.videoTalkBtn.hidden        = NO;
        self.videoSoundBtn.hidden       = NO;
    }
    else {
        self.recordDateBtn.hidden       = NO;
        self.recordTodayBtn.hidden      = NO;
        self.recordYesTodayBtn.hidden   = NO;
        self.recordNextDayBtn.hidden    = NO;
    }
}

- (void) normalScreen
{
    _isFullScreen = NO;
    
    [self.topImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.mas_equalTo(48);
    }];
    
    [self.videoTypeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(7);
        make.top.equalTo(self.topImageView.mas_bottom).offset(4);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(24);
    }];
    
    self.videoResBtn.hidden         = YES;
    self.videoCapBtn.hidden         = YES;
    self.videoTalkBtn.hidden        = YES;
    self.videoSoundBtn.hidden       = YES;
    
    self.recordDateBtn.hidden       = YES;
    self.recordTodayBtn.hidden      = YES;
    self.recordYesTodayBtn.hidden   = YES;
    self.recordNextDayBtn.hidden    = YES;
}

@end

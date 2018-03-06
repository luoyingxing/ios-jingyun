//
//  ZFPlayerView.h
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

#import <UIKit/UIKit.h>
#import "VideoWnd.h"

// 返回按钮的block
typedef void(^ZFPlayerGoBackBlock)(void);

typedef void(^TYChangeVideoTypeBlock)(NSInteger type);

typedef void(^TYFullScreenBlock)(BOOL isFullScreen);
// playerLayer的填充模式（默认：等比例填充，直到一个维度到达区域边界）
typedef NS_ENUM(NSInteger, ZFPlayerLayerGravity) {
     ZFPlayerLayerGravityResize,           // 非均匀模式。两个维度完全填充至整个视图区域
     ZFPlayerLayerGravityResizeAspect,     // 等比例填充，直到一个维度到达区域边界
     ZFPlayerLayerGravityResizeAspectFill  // 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
};

@interface ZFPlayerView : UIView

/** 视频URL */
@property (nonatomic, strong) NSURL                *videoURL;
/** 视频URL的数组 */
@property (nonatomic, strong) NSArray              *videoURLArray;
/** 返回按钮Block */
@property (nonatomic, copy  ) ZFPlayerGoBackBlock  goBackBlock;
/** 设置playerLayer的填充模式 */
@property (nonatomic, assign) ZFPlayerLayerGravity playerLayerGravity;
/** 从xx秒开始播放视频跳转 */
@property (nonatomic, assign) NSInteger            seekTime;

@property (nonatomic, assign) NSInteger            videoType;//1实时，2录像

@property (nonatomic, assign) NSInteger            videoIsPlayingType;

@property (nonatomic, strong) VideoWnd             *videoWnd;

/** 录像按钮Block */
@property (nonatomic, copy  ) TYChangeVideoTypeBlock  changeVideoBlock;

@property (nonatomic, copy  ) TYFullScreenBlock  fullScreenBlock;

/* 缩放--移动 */
@property (nonatomic, assign) BOOL                  canTranslateOrScroll;
@property (nonatomic, assign) CGPoint               startPoint;//开始移动位置
@property (nonatomic, assign) CGPoint               originPoint;//记录开始移动位置，有可能_imageLayer移除_baseLayer之外（如果之外需反弹回来）
@property (nonatomic, assign) CGFloat               currentScale;
@property (nonatomic, assign) double                startDisc;
@property (nonatomic, assign) CGSize                originSize;


/**
 *  取消延时隐藏controlView的方法,在ViewController的delloc方法中调用
 *  用于解决：刚打开视频播放器，就关闭该页面，maskView的延时隐藏还未执行。
 */
- (void)cancelAutoFadeOutControlBar;

/**
 *  单例，用于列表cell上多个视频
 *
 *  @return ZFPlayer
 */
+ (instancetype)sharedPlayerView;

/**
 *  player添加到cell上
 *
 *  @param cell 添加player的cellImageView
 */
- (void)addPlayerToCellImageView:(UIImageView *)imageView;

/**
 *  重置player
 */
- (void)resetPlayer;

/**
 *  在当前页面，设置新的Player的URL调用此方法
 */
- (void)resetToPlayNewURL;

/** 
 *  播放
 */
- (void)play;

/** 
  * 暂停 
 */
- (void)pause;

- (void) stop;

- (void) setSliderValue:(NSInteger)downLoadSize withTotal:(NSInteger)totalSize;

/**
 *  用于cell上播放player
 *
 *  @param videoURL  视频的URL
 *  @param tableView tableView
 *  @param indexPath indexPath 
 *  @param ImageViewTag ImageViewTag
 */
- (void)setVideoURL:(NSURL *)videoURL
      withTableView:(UITableView *)tableView
        AtIndexPath:(NSIndexPath *)indexPath
   withImageViewTag:(NSInteger)tag;

- (VideoWnd*)getVideoWnd;
@end

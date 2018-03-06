//
//  DHVideoDeviceHelper.h
//  ThingsIOSClient
//
//  Created by yeung on 05/01/16.
//  Copyright © 2016年 yeung . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class VideoWnd;

//struct NET_TIME;

@interface DHVideoDeviceHelper : NSObject
{
    long                fLoginHandle;
    long                fPlayHandle;
    long                audio_framesize;
    
    BOOL                video_is_loading;
    
    BOOL                video_device_connected;
    BOOL                video_stream_played;
    BOOL                video_record_search;
    BOOL                video_record_played;
    
    BOOL                p2p_connect_;
    BOOL                p2p_enable_;
    
    char                *p2p_server_ip_;
    
    long                avr_video_stream_size_;
    long                avr_video_stream_time_;
    long                pre_show_time_;
    
    int                 _P2pLocalPort;
    
    NSString            *relay_request_url;
    
    NSTimer             *video_mgr_timer;
    
    VideoWnd            *video_render_view;
    
    NSString            *image_path;
    
    
    
    NSString                    *pre_record_date_;
    int                         pre_record_hour_;
@public
    NSString            *to_tid;
    NSString            *node_to_tid;
    NSString            *part_id;
    NSString            *device_ip;
    NSString            *device_port;
    NSString            *device_user;
    NSString            *device_pass;
    NSInteger           device_channel;
    
    long                fTalkHandle;
    
    long                fPlayPort;
    long                fTalkSoundPort;
    
    int                 video_count_;
    
    NSMutableArray      *video_wnd_array_;
    NSMutableArray      *video_txt_array_;
    
    
    
    BOOL                            real_video_playing;
    BOOL                            record_video_playing;

@public
    NSMutableArray      *video_record_files_array;
}

@property (nonatomic, assign) BOOL isStartRealStreamFinished;
@property (nonatomic, assign) BOOL isFindRecordStreamFinished;
@property (nonatomic, assign) BOOL isStartRecordStreamFinished;
@property (nonatomic, assign) BOOL isUpdateRecordArray;

@property (nonatomic, assign) BOOL isPlayingSound;

@property (nonatomic, assign) BOOL isTalking;

+ (DHVideoDeviceHelper *) sharedInstance;

-(BOOL) ConnectDevice:(NSString*)tid withNodeTID:(NSString*)nodeTID withPartID:(NSString*)partID;

-(BOOL) StartRealStream:(NSInteger)channel withView:(VideoWnd*)wnd;

-(BOOL) StopRealStream:(NSInteger)channel;

-(BOOL) DisconnectDevice;

-(void) SetDisplayRotate:(BOOL)rotate;

-(BOOL) CaptureImage;

-(BOOL) OpenSound:(BOOL)open;

-(BOOL) OpenTalk:(BOOL)open;

-(BOOL) ChangeResType:(BOOL)sd;

-(BOOL) getVideoSearch;

-(BOOL) FindVideoRecord:(NSInteger)channel withStartTime:(NSString*)startTime withEndTime:(NSString*)endTime;

-(BOOL) StartRecordStream:(NSInteger)index withView:(VideoWnd*)wnd;

-(BOOL) StartRecordStream:(NSString*)startTime withWndTime:(NSString*)endTime withView:(VideoWnd*)wnd withChannel:(int)channel;

-(BOOL) StopRecordStream:(BOOL)isInterior;

- (BOOL) SetDisplayRegion:(CGRect) rc withEnable:(bool)enable;

- (BOOL) SetScale:(float)scale withEnable:(bool)enable;
- (BOOL) Translate:(float)x withY:(float)y;

-(NSString*) getStartRecordTime;
-(NSString*) getEndRecordTime;

- (void) PausePlayBack:(BOOL)pause;

- (void) SeekPlayBack:(NSInteger)offset;
@end

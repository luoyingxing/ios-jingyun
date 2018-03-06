//
//  DHVideoDeviceHelper.m
//  ThingsIOSClient
//
//  Created by yeung on 05/01/16.
//  Copyright © 2016年 yeung . All rights reserved.
//

#import "DHVideoDeviceHelper.h"
#import "CWDataManager.h"
#import "CWThings4Interface.h"
#import "P2PClient.h"
#import "playEx.h"
#import "netsdk.h"
#import "Alaw_encoder.h"
#import "VideoWnd.h"
#import "NSObject+BAProgressHUD.h"
#import <arpa/inet.h>
#import "CWRecordModel.h"
#import "DeviceStatusModel.h"
#import "ZFPlayerView.h"

extern ZFPlayerView *gTYPlayerView;

static DHDEV_TALKFORMAT_LIST dhTalkEncodeSupported;
static DHDEV_TALKDECODE_INFO& dhTalkEncode = dhTalkEncodeSupported.type[2];

@interface DHVideoDeviceHelper ()
{
    enum VIDEO_INDEX{
        VIDEO_DEFAULT       = 0,
        VIDEO_REAL_STREAM = 1,
        VIDEO_SEARCH_RECORD = 2,
        VIDEO_PLAY_RECORD = 3
    };
    
    VIDEO_INDEX                 video_handle_index;
    
    NSThread                    *handle_thread;
    NET_TIME                    record_start_net_time_;
    NET_TIME                    record_end_net_time_;
    
    NET_TIME                    start_play_record_time;
    NET_TIME                    end_play_record_time;
    
    LLONG                       video_record_play_handle;
    
    DeviceStatusModel           *deviceModel;
}

@property (nonatomic, assign) NSInteger videoResType;

@property (nonatomic, assign) NSInteger retryCount;

@property (nonatomic, assign) NSInteger dontReceiveRealStreamDataCount;

@property (nonatomic, assign) NSInteger dontReceiveRecordStreamDataCount;

@property (nonatomic, assign) BOOL isGetDeviceInfoErr;

@property (nonatomic, assign) NSInteger videoRecordIndex;

@property (nonatomic, assign) NSInteger retryLoginCount;

@property (nonatomic, assign) BOOL isHandleVideoDevice;

@property (nonatomic, assign) float fScale;

@property (nonatomic, assign) float fX;

@property (nonatomic, assign) float fY;

@end

@implementation DHVideoDeviceHelper

static DHVideoDeviceHelper *sharedInstance = nil;

+ (DHVideoDeviceHelper *) sharedInstance
{
    return ( sharedInstance ? sharedInstance : ( sharedInstance = [[self alloc] init] ) );
}

void JYDisConnect(LLONG lLoginID, char *pchDVRIP, LONG nDVRPort, LDWORD dwUser)
{
    lLoginID ++;
}

int DHCheckInternalIP(const unsigned int ip_addr)
{
    //检查3类地址
    if ((ip_addr >= 0x0A000000 && ip_addr <= 0x0AFFFFFF ) ||
        (ip_addr >= 0xAC100000 && ip_addr <= 0xAC1FFFFF ) ||
        (ip_addr >= 0xC0A80000 && ip_addr <= 0xC0A8FFFF )
        )
    {
        return 1;
    }
    
    return 0;
}

void DHHaveReConnect(LLONG lLoginID, char *pchDVRIP, LONG nDVRPort, LDWORD dwUser)
{
    NSString* ip = [[NSString alloc] initWithUTF8String:pchDVRIP];
    NSLog(@"Device %@ reconnected", ip);
}

void DHDrawCBFun(LONG nPort,HDC hDc, void* pUserData)
{
    NSLog(@"Device %d cbDrawCBFun", nPort);
    
}

void DHAudioDataCallBack(LLONG lTalkHandle, char *pDataBuf, DWORD dwBufSize, BYTE byAudioFlag, LDWORD dwUser)
{
    
    if (byAudioFlag == 1) {
        if (dhTalkEncode.encodeType == DH_TALK_DEFAULT) {
            for (int i = 0; i < dwBufSize; ++i) {
                pDataBuf[i] += 128;
            }
        }
        
        if (!PLAY_InputData([DHVideoDeviceHelper sharedInstance]->fTalkSoundPort, (BYTE*)pDataBuf, dwBufSize)) {
            NSLog(@"PLAY_InputData error");
        }
        else {
            //NSLog(@"PLAY_InputData2 %d", dwBufSize);
        }
        
    }
    else {
        
    }
    
}

void DHLocalAudioData(LPBYTE pDataBuffer, DWORD DataLength, void* pUserData)
{
    //NSLog(@"DH_TALK_G711a --- %d", DataLength);
    if (pUserData == NULL) return ;
    LLONG lTaskHandle = *(LLONG*)pUserData;
    char* pCbData = NULL;
    pCbData = new char[102400];
    if (NULL == pCbData)
    {
        return;
    }
    int  iCbLen = 0;
    
    if (dhTalkEncode.encodeType == DH_TALK_DEFAULT || dhTalkEncode.encodeType == DH_TALK_PCM)
    {
        if (dhTalkEncode.nAudioBit == 8)
        {
            for( int j = 0 ; j < DataLength; j++)
            {
                *(pDataBuffer + j) += 128;
            }
        }
        
        pCbData[0]=0x00;
        pCbData[1]=0x00;
        pCbData[2]=0x01;
        pCbData[3]=0xF0;
        
        pCbData[4]= dhTalkEncode.nAudioBit==8?0x07:0x0C;
        if( 8000 == dhTalkEncode.dwSampleRate )
        {
            pCbData[5]=0x02;//8k
        }
        else if(16000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x04;
        }
        else if(48000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x09;
        }
        
        *(DWORD*)(pCbData+6)=DataLength;
        memcpy(pCbData+8, pDataBuffer, DataLength);
        
        iCbLen = 8+DataLength;
        
        NSLog(@"DEFAULT");
    }
    else if (dhTalkEncode.encodeType == DH_TALK_G711a)
    {
        NSLog(@"DH_TALK_G711a --- %d", DataLength);
        if (g711a_Encode((char*)pDataBuffer, pCbData+8, DataLength, &iCbLen) != 1)
        {
            goto end;
        }
        
        // bit stream format frame head
        pCbData[0]=0x00;
        pCbData[1]=0x00;
        pCbData[2]=0x01;
        pCbData[3]=0xF0;
        
        pCbData[4]=0x0E; //G711A
        
        if( 8000 == dhTalkEncode.dwSampleRate )
        {
            pCbData[5]=0x02;//8k
        }
        else if(16000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x04;
        }
        else if(48000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x09;
        }
        
        pCbData[6]=(BYTE)(iCbLen&0xff);
        pCbData[7]=(BYTE)(iCbLen>>8);
        
        iCbLen += 8;
    }
    else if (dhTalkEncode.encodeType == DH_TALK_G711u)
    {
        NSLog(@"DH_TALK_G711u");
        if (g711u_Encode((char*)pDataBuffer, pCbData+8, DataLength, &iCbLen) != 1)
        {
            goto end;
        }
        
        // bit stream format frame head
        pCbData[0]=0x00;
        pCbData[1]=0x00;
        pCbData[2]=0x01;
        pCbData[3]=0xF0;
        
        pCbData[4]=0x0A; //G711u
        if( 8000 == dhTalkEncode.dwSampleRate )
        {
            pCbData[5]=0x02;//8k
        }
        else if(16000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x04;
        }
        else if(48000 == dhTalkEncode.dwSampleRate)
        {
            pCbData[5] = 0x09;
        }
        
        pCbData[6]=(BYTE)(iCbLen&0xff);
        pCbData[7]=(BYTE)(iCbLen>>8);
        
        iCbLen += 8;
    }
    else
    {
        NSLog(@"encode format unsupported");
        goto end;
    }
    
    // Send the data from the PC to DVR
    
    
    if (lTaskHandle > 0 && !CLIENT_TalkSendData(lTaskHandle, (char *)pCbData, iCbLen)) {
        NSLog(@"CLIENT_TalkSendData error");
    }
    
end:
    if (pCbData != NULL)
    {
        delete[] pCbData;
    }
}

void CALLBACK DHRealDataCallback(LLONG lRealHandle, DWORD dwDataType, BYTE *pBuffer, DWORD dwBufSize, LDWORD dwUser)
{
    if ([DHVideoDeviceHelper sharedInstance]->fPlayHandle != lRealHandle) {
        return ;
    }
    if ([DHVideoDeviceHelper sharedInstance]->video_is_loading == YES)
    {
        [DHVideoDeviceHelper sharedInstance]->video_is_loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            VideoWnd *wnd = [DHVideoDeviceHelper sharedInstance]->video_render_view;
            [wnd stopLoading];
            [DHVideoDeviceHelper sharedInstance]->_dontReceiveRealStreamDataCount = 0;//等于零，不表示 已经播放，不检测有没有收到流
            [gTYPlayerView play];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //[[DHVideoDeviceHelper sharedInstance] addStreamSize:dwBufSize];
    });
    NSLog(@"inputdata playport : %ld", [DHVideoDeviceHelper sharedInstance]->fPlayPort);
    BOOL bRet = PLAY_InputData([DHVideoDeviceHelper sharedInstance]->fPlayPort, pBuffer, dwBufSize);
    if (bRet == NO) {
        CLIENT_MakeKeyFrame([DHVideoDeviceHelper sharedInstance]->fLoginHandle, (int)[DHVideoDeviceHelper sharedInstance]->device_channel, (int)[DHVideoDeviceHelper sharedInstance]->_videoResType);
    }
    //NSLog(@"real play : %d", dwBufSize);
}

int CALLBACK DHPlaybackDataCallback(LLONG lRealHandle, DWORD dwDataType, BYTE *pBuffer, DWORD dwBufSize, LDWORD dwUser)
{
    if ([DHVideoDeviceHelper sharedInstance]->video_record_play_handle == 0) {
        //return 0;
    }
    if ([DHVideoDeviceHelper sharedInstance]->video_is_loading == YES)
    {
        [DHVideoDeviceHelper sharedInstance]->video_is_loading = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            VideoWnd *wnd = [DHVideoDeviceHelper sharedInstance]->video_render_view;
            [wnd stopLoading];
            [DHVideoDeviceHelper sharedInstance]->_dontReceiveRecordStreamDataCount = 0;//等于零，不表示 已经播放，不检测有没有收到流
            [gTYPlayerView play];
        });
    }
    long playPort = [DHVideoDeviceHelper sharedInstance]->fPlayPort;
    BOOL bRet = PLAY_InputData(playPort, pBuffer, dwBufSize);
    NSLog(@"PLAY_InputData : %d", bRet);
    if (bRet == NO) {
        //CLIENT_MakeKeyFrame([DHVideoDeviceHelper sharedInstance]->fLoginHandle, [DHVideoDeviceHelper sharedInstance]->device_channel, [DHVideoDeviceHelper sharedInstance]->_videoResType);
    }
    return bRet;
}

void CALLBACK DHDownLoadPosCallback(LLONG lPlayHandle, DWORD dwTotalSize, DWORD dwDownLoadSize, LDWORD dwUser)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (gTYPlayerView) {
            [gTYPlayerView setSliderValue:dwDownLoadSize withTotal:dwTotalSize];
        }
    });
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        CLIENT_Init(JYDisConnect, 0);
        //NETSDK_INIT_PARAM initParam;
        //initParam.nThreadNum    = 2;
        //CLIENT_InitEx(JYDisConnect, 0, &initParam);
        _isHandleVideoDevice = NO;
        fTalkSoundPort          = 99;
        device_channel          = -1;
    }
    return self;
}

- (BOOL) RecevieDeviceInfo
{
    if ([part_id isEqualToString:@"2000"]) {
        char *raddr = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"raddr" sessions:YES];
        char *node_addr = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"addr" sessions:YES];
        //char *name = [[CWThings4Interface sharedInstance] get_var_with_path_ex:[to_tid UTF8String] prepath:"zones" member:device_channel backpath:NULL];
        //char tid_path[256] = {0};
        //sprintf(tid_path, "zones.%s.dev.tid", name);
        //char* tid_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:tid_path sessions:YES];
        
        if (node_to_tid == nil) {
            char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.protocol" sessions:YES];
            video_count_ = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[to_tid UTF8String] path:"profile.devs.videos"];
            
            if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                video_count_--;
                char *ip_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.ip" sessions:YES];
                
                char *port_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.port" sessions:YES];
                char *port_upnp = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.upnp-port" sessions:YES];
                
                char *user_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.user" sessions:YES];
                
                char *pass_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.pass" sessions:YES];
                
                char *p2p_connected_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"flags.p2p-connected" sessions:YES];
                if (p2p_connected_value && strcmp(p2p_connected_value, "true") == 0) {
                    p2p_connect_ = YES;
                }
                char *p2p_enabled_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.p2p.enabled" sessions:YES];
                if (p2p_enabled_value && strcmp(p2p_enabled_value, "true") == 0) {
                    p2p_enable_ = YES;
                }
                p2p_server_ip_ = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.p2p.server" sessions:YES];
                //dh device
                struct in_addr addr;
                //unsigned int iAddr = inet_addr(raddr);
                int ret = 0;
                if (raddr) {
                    ret = inet_pton(AF_INET, raddr, (void *)&addr);   //IP字符串 ——》网络字节流
                    if(0 == ret){
                        printf("inet_pton error, return 0/n");
                        //return -1;
                    }else{
                        printf("inet_pton ip: %u/n", addr.s_addr);
                        printf("inet_pton ip: 0x%x/n", addr.s_addr);
                    }
                    unsigned int iAddr = addr.s_addr;//htonl(iAddr);
                    ret = DHCheckInternalIP(iAddr);
                }
                if (raddr && (strcmp(raddr, "localhost") == 0 || ret == 1) && ip_value) {
                    device_ip = [[NSString alloc] initWithUTF8String:ip_value];
                }
                else if (raddr) {
                    device_ip = [[NSString alloc] initWithUTF8String:raddr];
                }
                else {
                    device_ip = @"";
                }
                //device_ip = [[NSString alloc] initWithUTF8String:"192.168.2.51"];
                if (port_upnp && atoi(port_upnp) > 0) {
                    device_port = [[NSString alloc] initWithUTF8String:port_upnp];
                }
                else {
                    device_port = [[NSString alloc] initWithUTF8String:port_value];
                }
                device_user = [[NSString alloc] initWithUTF8String:user_value];
                device_pass = [[NSString alloc] initWithUTF8String:pass_value];
                
                char cmd[128] = {0};
                if ([CWDataManager sharedInstance]->relay_mode_right_ == YES && deviceModel.videoPlayMode == 2) {
                    memset(cmd, 128, 0);
                    sprintf(cmd, "/relay?via=%s&ip=%s&port=%s", node_addr, ip_value, port_value);
                    
                    relay_request_url = [[NSString alloc] initWithUTF8String:cmd];
                    [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"getRelayInfo"];
                }
                
            }
            else {
                char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.protocol" sessions:YES];
                video_count_ = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[to_tid UTF8String] path:"devs.videos"];
                video_count_--;
                if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                    
                    char *ip_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.ip" sessions:YES];
                    
                    char *port_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.port" sessions:YES];
                    char *port_upnp = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.upnp-port" sessions:YES];
                    
                    char *user_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.user" sessions:YES];
                    
                    char *pass_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.pass" sessions:YES];
                    
                    char *p2p_connected_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"flags.p2p-connected" sessions:YES];
                    if (p2p_connected_value && strcmp(p2p_connected_value, "true") == 0) {
                        p2p_connect_ = YES;
                    }
                    char *p2p_enabled_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.p2p.enabled" sessions:YES];
                    if (p2p_enabled_value && strcmp(p2p_enabled_value, "true") == 0) {
                        p2p_enable_ = YES;
                    }
                    p2p_server_ip_ = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.p2p.server" sessions:YES];
                    
                    //dh device
                    //unsigned int iAddr = inet_addr(raddr);
                    struct in_addr addr;
                    //unsigned int iAddr = inet_addr(raddr);
                    int ret = 0;
                    if (raddr) {
                        ret = inet_pton(AF_INET, raddr, (void *)&addr);   //IP字符串 ——》网络字节流
                        if(0 == ret){
                            printf("inet_pton error, return 0/n");
                            //return -1;
                        }else{
                            printf("inet_pton ip: %u/n", addr.s_addr);
                            printf("inet_pton ip: 0x%x/n", addr.s_addr);
                        }
                        unsigned int iAddr = addr.s_addr;//htonl(iAddr);
                        iAddr = htonl(iAddr);
                        ret = DHCheckInternalIP(iAddr);
                    }
                    if (raddr && (strcmp(raddr, "localhost") == 0 || ret == 1) && ip_value) {
                        device_ip = [[NSString alloc] initWithUTF8String:ip_value];
                    }
                    else if (raddr){
                        device_ip = [[NSString alloc] initWithUTF8String:raddr];
                    }
                    else {
                        device_ip = @"";
                    }
                    //device_ip = [[NSString alloc] initWithUTF8String:"192.168.2.51"];
                    if (port_upnp && atoi(port_upnp) > 0) {
                        device_port = [[NSString alloc] initWithUTF8String:port_upnp];
                    }
                    else {
                        device_port = [[NSString alloc] initWithUTF8String:port_value];
                    }
                    device_user = [[NSString alloc] initWithUTF8String:user_value];
                    device_pass = [[NSString alloc] initWithUTF8String:pass_value];
                    
                    char cmd[128] = {0};
                    if ([CWDataManager sharedInstance]->relay_mode_right_ == YES && deviceModel.videoPlayMode == 2) {
                        memset(cmd, 128, 0);
                        sprintf(cmd, "/relay?via=%s&ip=%s&port=%s", node_addr, ip_value, port_value);
                        relay_request_url = [[NSString alloc] initWithUTF8String:cmd];
                        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"getRelayInfo"];
                    }
                    
                }
            }
        }
        else {
            char protocol_path[256] = {0};
            char video_path[256] = {0};
            memset(protocol_path, 0, 256);
            sprintf(protocol_path, "parts.%s.profile.devs.videos.default.access.protocol", [node_to_tid UTF8String]);
            char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:protocol_path sessions:YES];
            sprintf(video_path, "parts.%s.profile.devs.videos", [node_to_tid UTF8String]);
            video_count_ = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[to_tid UTF8String] path:video_path];
            
            if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                video_count_--;
                char ip_path[256] = {0};
                sprintf(ip_path, "parts.%s.profile.devs.videos.default.access.ip", [node_to_tid UTF8String]);
                char *ip_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:ip_path sessions:YES];
                char port_path[256] = {0};
                sprintf(port_path, "parts.%s.profile.devs.videos.default.access.port", [node_to_tid UTF8String]);
                char *port_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:port_path sessions:YES];
                memset(port_path, 0, 256);
                sprintf(port_path, "parts.%s.profile.devs.videos.default.access.upnp-port", [node_to_tid UTF8String]);
                char *port_upnp = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:port_path sessions:YES];
                
                char user_path[256] = {0};
                sprintf(user_path, "parts.%s.profile.devs.videos.default.access.user", [node_to_tid UTF8String]);
                char *user_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:user_path sessions:YES];
                char pass_path[256] = {0};
                sprintf(pass_path, "parts.%s.profile.devs.videos.default.access.pass", [node_to_tid UTF8String]);
                char *pass_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:pass_path sessions:YES];
                
                char p2p_connected_path[256] = {0};
                sprintf(p2p_connected_path, "parts.%s.flags.p2p-connected", [node_to_tid UTF8String]);
                char *p2p_connected_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:p2p_connected_path sessions:YES];
                if (p2p_connected_value && strcmp(p2p_connected_value, "true") == 0) {
                    p2p_connect_ = YES;
                }
                char p2p_enabled_path[256] = {0};
                sprintf(p2p_enabled_path, "parts.%s.profile.devs.videos.default.access.p2p.enabled", [node_to_tid UTF8String]);
                char *p2p_enabled_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:p2p_enabled_path sessions:YES];
                if (p2p_enabled_value && strcmp(p2p_enabled_value, "true") == 0) {
                    p2p_enable_ = YES;
                }
                char p2p_server_path[256] = {0};
                sprintf(p2p_server_path, "parts.%s.profile.devs.videos.default.access.p2p.server", [node_to_tid UTF8String]);
                p2p_server_ip_ = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:p2p_server_path sessions:YES];
                
                //dh device
                //unsigned int iAddr = inet_addr(raddr);
                struct in_addr addr;
                //unsigned int iAddr = inet_addr(raddr);
                int ret = 0;
                if (raddr) {
                    ret = inet_pton(AF_INET, raddr, (void *)&addr);   //IP字符串 ——》网络字节流
                    if(0 == ret){
                        printf("inet_pton error, return 0/n");
                        //return -1;
                    }else{
                        printf("inet_pton ip: %u/n", addr.s_addr);
                        printf("inet_pton ip: 0x%x/n", addr.s_addr);
                    }
                    unsigned int iAddr = addr.s_addr;//htonl(iAddr);
                    iAddr = htonl(iAddr);
                    ret = DHCheckInternalIP(iAddr);
                }
                if (raddr && (strcmp(raddr, "localhost") == 0 || ret == 1) && ip_value) {
                    device_ip = [[NSString alloc] initWithUTF8String:ip_value];
                }
                else if (raddr) {
                    device_ip = [[NSString alloc] initWithUTF8String:raddr];
                }
                else {
                    device_ip = @"";
                }
                
                if (port_upnp && atoi(port_upnp) > 0) {
                    device_port = [[NSString alloc] initWithUTF8String:port_upnp];
                }
                else if (port_value) {
                    device_port = [[NSString alloc] initWithUTF8String:port_value];
                }
                else {
                    device_port = @"";
                }
                //device_port = [[NSString alloc] initWithUTF8String:port_value];
                device_user = [[NSString alloc] initWithUTF8String:user_value];
                device_pass = [[NSString alloc] initWithUTF8String:pass_value];
                
                char cmd[128] = {0};
                if ([CWDataManager sharedInstance]->relay_mode_right_ == YES && deviceModel.videoPlayMode == 2) {
                    memset(cmd, 128, 0);
                    sprintf(cmd, "/relay?via=%s&ip=%s&port=%s", node_addr, ip_value, port_value);
                    relay_request_url = [[NSString alloc] initWithUTF8String:cmd];
                    [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"getRelayInfo"];
                }
            }
            else {
                sprintf(protocol_path, "parts.%s.devs.videos.default.access.protocol", [node_to_tid UTF8String]);
                char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:protocol_path sessions:YES];
                memset(video_path, 0, 256);
                sprintf(video_path, "parts.%s.devs.videos", [node_to_tid UTF8String]);
                video_count_ = [[CWThings4Interface sharedInstance] get_var_nodes_with_tid:[to_tid UTF8String] path:video_path];
                video_count_--;
                
                if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                    char ip_path[256] = {0};
                    sprintf(ip_path, "parts.%s.devs.videos.default.access.ip", [node_to_tid UTF8String]);
                    char *ip_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:ip_path sessions:YES];
                    
                    char port_path[256] = {0};
                    sprintf(port_path, "parts.%s.devs.videos.default.access.port", [node_to_tid UTF8String]);
                    char *port_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:port_path sessions:YES];
                    memset(port_path, 0, 256);
                    sprintf(port_path, "parts.%s.devs.videos.default.access.upnp-port", [node_to_tid UTF8String]);
                    char *port_upnp = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:port_path sessions:YES];
                    
                    char user_path[256] = {0};
                    sprintf(user_path, "parts.%s.devs.videos.default.access.user", [node_to_tid UTF8String]);
                    char *user_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:user_path sessions:YES];
                    char pass_path[256] = {0};
                    sprintf(pass_path, "parts.%s.devs.videos.default.access.pass", [node_to_tid UTF8String]);
                    char *pass_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:pass_path sessions:YES];
                    
                    char p2p_connected_path[256] = {0};
                    sprintf(p2p_connected_path, "parts.%s.flags.p2p-connected", [node_to_tid UTF8String]);
                    char *p2p_connected_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"flags.p2p-connected" sessions:YES];
                    if (p2p_connected_value && strcmp(p2p_connected_value, "true") == 0) {
                        p2p_connect_ = YES;
                    }
                    char p2p_enabled_path[256] = {0};
                    sprintf(p2p_enabled_path, "parts.%s.devs.videos.default.access.p2p.enabled", [node_to_tid UTF8String]);
                    char *p2p_enabled_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:p2p_enabled_path sessions:YES];
                    if (p2p_enabled_value && strcmp(p2p_enabled_value, "true") == 0) {
                        p2p_enable_ = YES;
                    }
                    char p2p_server_path[256] = {0};
                    sprintf(p2p_server_path, "parts.%s.devs.videos.default.access.p2p.server", [node_to_tid UTF8String]);
                    p2p_server_ip_ = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:p2p_server_path sessions:YES];
                    
                    //dh device
                    //unsigned int iAddr = inet_addr(raddr);
                    struct in_addr addr;
                    //unsigned int iAddr = inet_addr(raddr);
                    int ret = 0;
                    if (raddr) {
                        ret = inet_pton(AF_INET, raddr, (void *)&addr);   //IP字符串 ——》网络字节流
                        if(0 == ret){
                            printf("inet_pton error, return 0/n");
                            //return -1;
                        }else{
                            printf("inet_pton ip: %u/n", addr.s_addr);
                            printf("inet_pton ip: 0x%x/n", addr.s_addr);
                        }
                        unsigned int iAddr = addr.s_addr;
                        iAddr = htonl(iAddr);
                        ret = DHCheckInternalIP(iAddr);
                    }
                    if (raddr && (strcmp(raddr, "localhost") == 0 || ret == 1) && ip_value) {
                        device_ip = [[NSString alloc] initWithUTF8String:ip_value];
                    }
                    else if (raddr) {
                        device_ip = [[NSString alloc] initWithUTF8String:raddr];
                    }
                    else {
                        device_ip = @"";
                    }
                    //device_ip = [[NSString alloc] initWithUTF8String:ip_value];
                    //device_ip = [[NSString alloc] initWithUTF8String:"192.168.2.51"];
                    if (port_upnp && atoi(port_upnp) > 0) {
                        device_port = [[NSString alloc] initWithUTF8String:port_upnp];
                    }
                    else if (port_value) {
                        device_port = [[NSString alloc] initWithUTF8String:port_value];
                    }
                    else {
                        device_port = @"";
                    }
                    
                    device_user = [[NSString alloc] initWithUTF8String:user_value ? user_value : ""];
                    device_pass = [[NSString alloc] initWithUTF8String:pass_value ? pass_value :""];
                    //device_user = [[NSString alloc] initWithUTF8String:"admin"];
                    //device_pass = [[NSString alloc] initWithUTF8String:"admin"];
                    
                    char cmd[128] = {0};
                    if ([CWDataManager sharedInstance]->relay_mode_right_ == YES && deviceModel.videoPlayMode == 2) {
                        memset(cmd, 128, 0);
                        sprintf(cmd, "/relay?via=%s&ip=%s&port=%s", node_addr, ip_value, port_value);
                        relay_request_url = [[NSString alloc] initWithUTF8String:cmd];
                        [[CWThings4Interface sharedInstance] request:"." URL:cmd UrlLen:(int)strlen(cmd) ReqID:"getRelayInfo"];
                    }
                }
            }
        }
    }
    else {
        
    }
    
    if (device_ip == nil || device_port == nil || device_user == nil || device_pass == nil) {
        _isGetDeviceInfoErr = YES;
        [self BA_showAlert:@"获取设备连接信息失败"];
        return NO;
    }
    return YES;
}

- (BOOL) startConnect
{
    if ([part_id isEqualToString:@"2000"]) {
        if (fLoginHandle <= 0) {
            int nSpecCap = 20;
            BOOL p2p_flag = [[CWDataManager sharedInstance] getDeviceP2P];
            if (deviceModel && deviceModel.tryP2PError == 0 && (deviceModel.videoPlayMode == 3 || (deviceModel.videoPlayMode == 0 && p2p_flag))) {//start p2p
                NSString *device_sid;
                if (node_to_tid) {
                    device_sid = node_to_tid;
                }
                else {
                    device_sid = to_tid;
                }
                if (p2p_enable_ == NO) {
                    NSString *sErr = [[NSString alloc] initWithFormat:@"设备未开启P2P 功能"];
                    [video_render_view showErrFilter:sErr];
                    //_isGetDeviceInfoErr = YES;
                    [video_render_view stopLoading];
                    deviceModel.tryP2PError = -3;
                    [self BA_showAlert:sErr];
                    return NO;
                }
                if (p2p_connect_ == NO) {
                    NSString *sErr = [[NSString alloc] initWithFormat:@"设备不在线[P2P]，请检查设备网络。"];
                    [video_render_view showErrFilter:sErr];
                    deviceModel.tryP2PError = -2;
                    [video_render_view stopLoading];
                    //_isGetDeviceInfoErr = YES;
                    [self BA_showAlert:sErr];
                    return NO;
                }
                
                if (_P2pLocalPort <= 0) {
                    if (p2p_server_ip_) {
                        if (strcmp(p2p_server_ip_, "p2p.conwin.cc") == 0) {
                            NSLog(@"p2p_connect start ......");
                            _P2pLocalPort = p2p_connect(p2p_server_ip_, 8800, "CONWIN-20151111-KHTK", "", [device_sid UTF8String], [device_port intValue], 15);
                            NSLog(@"p2p_connect end ......");
                        }
                        else {
                            _P2pLocalPort = p2p_connect(p2p_server_ip_, 8800, "dhp2ptest-20150421_ydfwkfb", "", [device_sid UTF8String], [device_port intValue], 100);
                        }
                    }
                    else {//testSDK.dahuap2p.com
                        _P2pLocalPort = p2p_connect("p2p.conwin.cc", 8800, "CONWIN-20151111-KHTK", "", [device_sid UTF8String], [device_port intValue], 100);
                    }
                }
                if (_P2pLocalPort < 0 || _P2pLocalPort > 65535) {
                    _P2pLocalPort = -1;
                    NSString *sErr = [[NSString alloc] initWithFormat:@"连接P2P服务失败,%x", _P2pLocalPort];
                    [video_render_view showErrFilter:sErr];
                    
                    [video_render_view stopLoading];
                    deviceModel.tryP2PError = -1;
                    [self BA_showAlert:sErr];
                    return NO;
                }
                //int _P2pLocalPort = p2p_connect("testSDK.dahuap2p.com", 8800, "dhp2ptest-20150421_ydfwkfb", "TEST-14D-GX-5WS", 37777, 5);
                device_port = [[NSString alloc] initWithFormat:@"%d", _P2pLocalPort ];
                device_ip = @"127.0.0.1";
                nSpecCap = 19;
            }
            //relay
            else if (deviceModel  && (deviceModel.videoPlayMode == 2/* || (deviceModel.videoPlayMode == 0 && [CWDataManager sharedInstance]->relay_mode_right_ == YES)*/)) {
                device_ip = [[CWDataManager sharedInstance] get_relay_server_ip];
                device_port = [[CWDataManager sharedInstance] get_relay_server_port];
                if (device_ip == nil && device_port == nil) {
                    NSString *sErr = [[NSString alloc] initWithFormat:@"取转发服务器信息失败。"];
                    [video_render_view showErrFilter:sErr];
                    _isGetDeviceInfoErr = YES;
                    [video_render_view stopLoading];
                    [self BA_showAlert:sErr];
                    return NO;
                }
                //nSpecCap = 20;
            }
            NET_DEVICEINFO deviceo_info;
            CLIENT_SetAutoReconnect(DHHaveReConnect, 0);
            CLIENT_SetConnectTime(5000, 5);
            
            //NET_PARAM netParam = {8000, 3000, 3, 100};
            //CLIENT_SetNetworkParam(&netParam);
            
            int iErrCode = 0;
            fLoginHandle = CLIENT_LoginEx((char*)[device_ip UTF8String], [device_port intValue], (char*)[device_user UTF8String], (char*)[device_pass UTF8String], nSpecCap, NULL, &deviceo_info, &iErrCode);
            
            NSLog(@"ip : %@, port : %@, user : %@, pwd : %@, err : %d", device_ip, device_port, device_user, device_pass, iErrCode);
            
            if (fLoginHandle <= 0) {
                int iErr = CLIENT_GetLastError();
                NSString *sErr = nil;
                switch (iErrCode) {
                    case 1:
                        sErr = @"密码不正确";
                        break;
                    case 2:
                        sErr = @"用户名不存在";
                        break;
                    case 3:
                        sErr = @"登录超时";
                        break;
                    case 4:
                        sErr = @"账号已登录";
                        break;
                    case 5:
                        sErr = @"账号已被锁定";
                        break;
                    case 6:
                        sErr = @"账号被列为黑名单";
                        break;
                    case 7:
                        sErr = @"资源不足，系统忙";
                        break;
                    case 8:
                        sErr = @"子连接失败";
                        break;
                    case 9:
                        sErr = @"主连接失败";
                        break;
                    case 10:
                        sErr = @"超过最大用户连接数";
                        break;
                        
                    default:
                        sErr = @"未知错误";
                        break;
                }
                NSString *strErr_ = [[NSString alloc] initWithFormat:@"%@,%x", sErr, iErr];
                
                
                [video_render_view stopLoading];
                
                [video_render_view showErrFilter:strErr_];
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL) startPlayVideo
{
    [self stopPlayVideo:NO withInterior:YES];
    [self StopRecordStream:YES];
    
    _dontReceiveRealStreamDataCount = 1;
    if ([part_id isEqualToString:@"2000"]) {
        PLAY_GetFreePort(&fPlayPort);
        
        NSLog(@"startPlayVideo playport : %ld", [DHVideoDeviceHelper sharedInstance]->fPlayPort);
        
        if (node_to_tid == nil) {
            char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"devs.videos.default.access.protocol" sessions:YES];
            
            if (protocol_value == NULL) {
                protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:"profile.devs.videos.default.access.protocol" sessions:YES];
            }
            if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                BOOL open_stream = PLAY_OpenStream(fPlayPort, nil, 0, 400*1024);
                if (open_stream) {
                    //PLAY_SetStreamOpenMode(fPlayPort, STREAME_REALTIME);
                    
                    
                    BOOL play_stream = PLAY_Play(fPlayPort, (__bridge void *)(video_render_view));
                    if (play_stream == NO) {
                        [video_render_view stopLoading];
                        return NO;
                    }
                    
                }
                
                NSLog(@"CLIENT_RealPlayEx start");
                LLONG lPlayHandle = CLIENT_RealPlayEx(fLoginHandle, (int)device_channel, NULL, DH_RType_Realplay_1);
                CLIENT_MakeKeyFrame(fLoginHandle, (int)device_channel, 1);
                NSLog(@"CLIENT_RealPlayEx ok");
                fPlayHandle = lPlayHandle;
                if (!lPlayHandle) {
                    int iErr = CLIENT_GetLastError();
                    NSString *sErr = [[NSString alloc] initWithFormat:@"播放失败,Err(%x), %ld", iErr,lPlayHandle];
                    [video_render_view showErrFilter:sErr];
                    
                    [video_render_view stopLoading];
                    [self BA_showAlert:sErr];
                    return NO;
                }
                
                CLIENT_SetRealDataCallBack(lPlayHandle, DHRealDataCallback, (LDWORD)self);
                NSLog(@"CLIENT_RealPlayEx call back");
                
                
            }
            
            real_video_playing = YES;
        }
        else {
            char protocol_path[256] = {0};
            memset(protocol_path, 0, 256);
            sprintf(protocol_path, "parts.%s.devs.videos.default.access.protocol", [node_to_tid UTF8String]);
            char *protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:protocol_path sessions:YES];
            if (protocol_value == NULL) {
                memset(protocol_path, 0, 256);
                sprintf(protocol_path, "parts.%s.profile.devs.videos.default.access.protocol", [node_to_tid UTF8String]);
                protocol_value = [[CWThings4Interface sharedInstance] get_var_with_path:[to_tid UTF8String] path:protocol_path sessions:YES];
            }
            if (protocol_value && strcmp(protocol_value, "dahua") == 0) {
                
                BOOL open_stream = PLAY_OpenStream(fPlayPort, nil, 0, 400*1024);
                if (open_stream) {
                    //PLAY_SetStreamOpenMode(fPlayPort, STREAME_REALTIME);
                    
                    BOOL play_stream = PLAY_Play(fPlayPort, (__bridge void *)(video_render_view));
                    if (play_stream == NO) {
                        return NO;
                    }
                }
                
                NSLog(@"CLIENT_RealPlayEx start");
                LLONG lPlayHandle = CLIENT_RealPlayEx(fLoginHandle, (int)device_channel, NULL, DH_RType_Realplay_1);
                CLIENT_MakeKeyFrame(fLoginHandle, (int)device_channel, 1);
                NSLog(@"CLIENT_RealPlayEx ok");
                fPlayHandle = lPlayHandle;
                if (!lPlayHandle) {
                    int iErr = CLIENT_GetLastError();
                    NSString *sErr = [[NSString alloc] initWithFormat:@"播放失败,Err(%x), %ld", iErr,lPlayHandle];
                    [video_render_view showErrFilter:sErr];
                    [self BA_showAlert:sErr];
                    
                    [video_render_view stopLoading];
                    return NO;
                }
                
                CLIENT_SetRealDataCallBack(lPlayHandle, DHRealDataCallback, (LDWORD)self);
                NSLog(@"CLIENT_RealPlayEx call back");
            }
        }
        
        if (dhTalkEncodeSupported.nSupportNum == 0) {
            int retLen = 0;
            BOOL bRet = CLIENT_QueryDevState(fLoginHandle, DH_DEVSTATE_TALK_ECTYPE, (char*)&dhTalkEncodeSupported, sizeof(dhTalkEncodeSupported), &retLen);
            
            if (!dhTalkEncodeSupported.nSupportNum || bRet == NO) {
                return NO;
            }
            
            switch(dhTalkEncode.encodeType)
            {
                case DH_TALK_DEFAULT:
                case DH_TALK_PCM:
                    audio_framesize = 1024;
                    break;
                case DH_TALK_G711a:
                    audio_framesize = 1280;
                    break;
                case DH_TALK_AMR:
                    audio_framesize = 320;
                    break;
                case DH_TALK_G711u:
                    audio_framesize = 320;
                    break;
                case DH_TALK_G726:
                    audio_framesize = 320;
                    break;
                case DH_TALK_AAC:
                    audio_framesize = 1024;
                default:
                    break;
            }
            
            if (!CLIENT_SetDeviceMode(fLoginHandle, DH_TALK_ENCODE_TYPE, &dhTalkEncode) ||
                !CLIENT_SetDeviceMode(fLoginHandle, DH_TALK_SERVER_MODE, NULL)) {
                
                return NO;
            }
        }
        
        //PLAY_RigisterDrawFun(fPlayPort, (fDrawCBFun)cbDrawCBFun, (__bridge void *)(_playVideoView));
        
        //PLAY_PlaySoundShare(fPlayPort);
        
        //fTalkHandle = CLIENT_StartTalkEx(fLoginHandle, cbAudioDataCallBack, NULL);
        if (fTalkHandle != 0) {
            //CLIENT_SetVolume(fPlayHandle, 99);
        }
    }
    else {
        
    }
    
    return YES;
}

-(BOOL) getVideoSearch
{
    return video_record_search;
}

- (BOOL) FindVideoRecord:(NSInteger)channel withStartTime:(NSString*)startTime withEndTime:(NSString*)endTime;
{
    if ([video_record_files_array count] > 0) {
        [video_record_files_array removeAllObjects];
    }
    else {
        video_record_files_array = [[NSMutableArray alloc] init];
    }
    
    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
    //实例化一个NSDateFormatter对象
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式
    NSDate *start_date = [dateFormat dateFromString:startTime];
    NSDate *end_date = [dateFormat dateFromString:endTime];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *start_dateComponent = [calendar components:unitFlags fromDate:start_date];
    NSDateComponents *end_dateComponent = [calendar components:unitFlags fromDate:end_date];
    
    record_start_net_time_.dwYear = (int)[start_dateComponent year];
    record_start_net_time_.dwMonth = (int)[start_dateComponent month];
    record_start_net_time_.dwDay = (int)[start_dateComponent day];
    record_start_net_time_.dwHour = (int)[start_dateComponent hour];
    record_start_net_time_.dwMinute = (int)[start_dateComponent minute];
    record_end_net_time_.dwYear = (int)[end_dateComponent year];
    record_end_net_time_.dwMonth = (int)[end_dateComponent month];
    record_end_net_time_.dwDay = (int)[end_dateComponent day];
    record_end_net_time_.dwHour = (int)[end_dateComponent hour];
    record_end_net_time_.dwMinute = (int)[end_dateComponent minute];
    
    video_record_search = NO;
    device_channel = channel;
    video_handle_index = VIDEO_SEARCH_RECORD;
    return YES;
}

- (BOOL) FindVideoRecord
{
    int fileCount = 0;
    NET_RECORDFILE_INFO _recordInfo[200];
    memset(&_recordInfo, 0, sizeof(_recordInfo));
    
    BOOL bFindRecord = CLIENT_QueryRecordFile(fLoginHandle, device_channel, 0, &record_start_net_time_, &record_end_net_time_, NULL, _recordInfo, sizeof(_recordInfo), &fileCount, 10000);
    
    // and initialize self.options
    if (bFindRecord && fileCount) {
        NSString *record_date;
        pre_record_hour_  = -1;
        pre_record_date_ = nil;
        _isUpdateRecordArray = YES;
        for (int i = 0; i < fileCount; ++i) {
            CWRecordModel *record_info = [[CWRecordModel alloc] init];
            record_info.show_date = YES;
            
            record_info.net_recordfile_info = _recordInfo[i];
            
            
            record_date = [[NSString alloc] initWithFormat:@"%04d-%02d-%02d", _recordInfo[i].starttime.dwYear, _recordInfo[i].starttime.dwMonth, _recordInfo[i].starttime.dwDay];
            
            
            if (pre_record_date_ == nil) {
                pre_record_date_ = record_date;
                
            }
            else {
                BOOL show_date = [record_date isEqualToString:pre_record_date_] ? NO : YES;
                if (show_date == YES) {
                    pre_record_date_ = record_date;
                }
                record_info.show_date = show_date;
            }
            
            BOOL show_time = (pre_record_hour_ == _recordInfo[i].starttime.dwHour) ? NO : YES;
            if (show_time == YES) {
                pre_record_hour_ = _recordInfo[i].starttime.dwHour;
            }
            record_info.show_time = show_time;
            
            [video_record_files_array addObject:record_info];
        }
    }
    else if (bFindRecord && fileCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *sErr = [[NSString alloc] initWithFormat:@"没有搜索到录像文件，请确认是否有存储功能"];
            [self BA_showAlert:sErr];
        });
        video_record_search = YES;
        return NO;
    }
    else {
        printf("error : %x\n", CLIENT_GetLastError());
        dispatch_async(dispatch_get_main_queue(), ^{
            int iErr = CLIENT_GetLastError();
            NSString *sErr = [[NSString alloc] initWithFormat:@"搜索录像失败,%x", iErr];
            [self BA_showAlert:sErr];
        });
        video_record_search = YES;
        return NO;
    }
    video_record_search = YES;
    return YES;
}

- (void) stopPlayVideo : (BOOL)complete withInterior:(BOOL)isInterior
{
    if (isInterior == NO) {
        video_handle_index = VIDEO_DEFAULT;
        _dontReceiveRealStreamDataCount = 0;
    }
    @try {
        if ([part_id isEqualToString:@"2000"]) {
            _isTalking = NO;
            _isPlayingSound = NO;
            PLAY_CloseAudioRecord();
            if (fPlayPort) {
                PLAY_StopSoundShare(fPlayPort);
            }
            
            if (fTalkHandle > 0) {
                CLIENT_StopTalkEx(fTalkHandle);
                fTalkHandle = 0;
            }
            if (fPlayHandle > 0) {
                CLIENT_StopRealPlayEx(fPlayHandle);
                fPlayHandle = 0;
            }
            
            if (fPlayPort > 0) {
                PLAY_Stop(fPlayPort);
                PLAY_CloseStream(fPlayPort);
                PLAY_ReleasePort(fPlayPort);
                fPlayPort = 0;
            }
            
            if (fTalkSoundPort > 0) {
                PLAY_CloseStream(fTalkSoundPort);
                PLAY_Stop(fTalkSoundPort);
                fTalkSoundPort = 0;
            }
            
            if (complete) {
                if (fLoginHandle > 0) {
                    CLIENT_Logout(fLoginHandle);
                    fLoginHandle = 0;
                }
            }
            
            //device_channel = -1;
        }
        else {
            
        }
        
    }
    @catch(NSException *exception) {
        
    }
}


//for interface
-(BOOL) ConnectDevice:(NSString*)tid withNodeTID:(NSString*)nodeTID withPartID:(NSString*)partID
{
    _isStartRecordStreamFinished    = YES;
    _isStartRealStreamFinished      = YES;
    _isFindRecordStreamFinished     = YES;
    _isUpdateRecordArray            = NO;
    _isGetDeviceInfoErr             = NO;
    _isHandleVideoDevice            = YES;
    
    _isTalking                      = NO;
    _isPlayingSound                 = NO;
    
    _retryLoginCount                = 0;
    
    to_tid                          = tid;
    node_to_tid                     = nodeTID;
    part_id                         = partID;
    _P2pLocalPort                   = 0;
    _retryCount                     = 0;
    device_channel                  = -1;
    _dontReceiveRealStreamDataCount = 0;
    _dontReceiveRecordStreamDataCount = 0;
    
    memset(&dhTalkEncodeSupported, 0, sizeof(dhTalkEncodeSupported));
    
    video_device_connected = NO;
    
    deviceModel = [[CWDataManager sharedInstance] ThingsMsgObjectForKey:tid];
    deviceModel.tryP2PError = 0;
    //float palFrame = 0.2;
    //video_mgr_timer = [NSTimer scheduledTimerWithTimeInterval:palFrame target:self selector:@selector(video_mgr_timer_func) userInfo:nil repeats:YES];
    
    if (handle_thread == nil) {
        handle_thread = [[NSThread alloc] initWithTarget:self selector:@selector(video_mgr_timer_func) object:nil];
        [handle_thread start];
    }
    //[self RecevieDeviceInfo];
    //[self startConnect];
    return YES;
}

-(BOOL) StartRealStream:(NSInteger)channel  withView:(VideoWnd*)wnd
{
    if (device_channel == channel && real_video_playing == YES) return YES;
    
    video_handle_index = VIDEO_REAL_STREAM;
    device_channel = channel;
    video_render_view = wnd;
    video_stream_played = NO;
    video_is_loading = YES;
    
    [video_render_view startLoading];
    
    return YES;
}

-(BOOL) StopRealStream:(NSInteger)channel
{
    if (real_video_playing == YES) {
        real_video_playing = NO;
        [self stopPlayVideo:NO withInterior:NO];
    }
    return YES;
}

-(BOOL) DisconnectDevice
{
    /*if (video_mgr_timer) {
        [video_mgr_timer invalidate];
        video_mgr_timer = nil;
    }*/
    video_handle_index = VIDEO_DEFAULT;
    _isHandleVideoDevice = NO;
    /*if (handle_thread) {
        [handle_thread cancel];
        handle_thread = nil;
    }*/
    
    [self close_device];
    return YES;
}

-(BOOL) close_device
{
    
    
    [self stopPlayVideo:YES withInterior:NO];
    
    if (_P2pLocalPort) {
        p2p_disconnect(_P2pLocalPort);
        _P2pLocalPort = 0;
    }
    
    return YES;
}

-(void) SetDisplayRotate:(BOOL)rotate
{
    if (rotate) {
        PLAY_SetRotateAngle(fPlayPort, 1);
    }
    else {
        PLAY_SetRotateAngle(fPlayPort, 0);
    }
}

-(BOOL) CaptureImage
{
    if (video_stream_played == NO) return NO;
    
    NSString* g_docFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString* _strNow = [NSDateFormatter localizedStringFromDate:[NSDate date] dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    NSString* strNow = [_strNow stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    image_path = [[NSString alloc] initWithFormat:@"%@/%@.jpg", g_docFolder, strNow];
    
    //NSLog("pic path : %@\n", image_path);
    BOOL bRet = PLAY_CatchPicEx(fPlayPort, (char*)[image_path UTF8String], PicFormat_JPEG_70);
    if (bRet == YES) {
        UIImage *aImage = [UIImage imageNamed:image_path];
        UIImageWriteToSavedPhotosAlbum(aImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        
    }
    return YES;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        //[MBProgressHUD showSuccess:@"拍照保存失败" toView:nil];
    } else {
        //[MBProgressHUD showSuccess:@"拍照成功保存到相册" toView:nil];
    }
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:image_path];
    if (bRet) {
        //
        NSError *err;
        [fileMgr removeItemAtPath:image_path error:&err];
    }
}

-(BOOL) OpenSound:(BOOL)open
{
    if (video_stream_played == NO) return NO;
    
    if (open) {
        if (_isTalking) {
            [self BA_showAlert:@"请先关闭对讲功能"];
            return NO;
        }
        _isPlayingSound = YES;
        
        BOOL bRet = PLAY_PlaySoundShare(fPlayPort);
        if (bRet == NO) {
            [self BA_showAlert:@"打开监听失败"];
        }
    }
    else {
        _isPlayingSound = NO;
        
        BOOL bRet = PLAY_StopSoundShare(fPlayPort);
        if (bRet == NO) {
            [self BA_showAlert:@"关闭监听失败"];
        }
        
    }
    
    return YES;
}

-(BOOL) OpenTalk:(BOOL)open
{
    if (video_stream_played == NO) return NO;
    
    if (open) {
        if (_isPlayingSound) {
            [self BA_showAlert:@"请先关闭监听功能"];
            return NO;
        }
        _isTalking = YES;
        PLAY_OpenStream(fTalkSoundPort, 0, 0, 100*1024);
        PLAY_Play(fTalkSoundPort, 0);
        PLAY_PlaySoundShare(fTalkSoundPort);
        if (fTalkHandle == 0) {
            fTalkHandle = CLIENT_StartTalkEx(fLoginHandle, DHAudioDataCallBack, NULL);
        }
        BOOL bRet = PLAY_OpenAudioRecord((pCallFunction)DHLocalAudioData, dhTalkEncode.nAudioBit, dhTalkEncode.dwSampleRate, audio_framesize, 0, &fTalkHandle);
        NSLog(@"bit : %d, samplerate : %d, framesize : %ld", dhTalkEncode.nAudioBit, dhTalkEncode.dwSampleRate, audio_framesize);
        //BOOL bRet = PLAY_OpenAudioRecord((pCallFunction)DHLocalAudioData, dhTalkEncode.nAudioBit, dhTalkEncode.dwSampleRate, audio_framesize, 0, /*&fTalkHandle*/0);
        if (bRet == NO) {
            printf("PLAY_OpenAudioRecord error : %u\n", PLAY_GetLastError(fTalkSoundPort));
            [self BA_showAlert:@"打开对讲失败"];
        }

    }
    else {
        _isTalking = NO;
        BOOL bRet = PLAY_CloseAudioRecord();
        if (bRet == NO) {
            [self BA_showAlert:@"关闭对讲失败"];
        }
        
        if (fTalkHandle) {
            CLIENT_StopTalkEx(fTalkHandle);
            fTalkHandle = 0;
        }
        
        PLAY_StopSoundShare(fTalkSoundPort);
        
        PLAY_CloseStream(fTalkSoundPort);
        PLAY_Stop(fTalkSoundPort);
        fTalkSoundPort = 0;
        
    }
    return YES;
}

-(BOOL) ChangeResType:(BOOL)sd
{
    if (video_stream_played == NO) return NO;
    if (sd) {
        _videoResType = 1;
        CLIENT_StopRealPlayEx(fPlayHandle);
        LLONG lPlayHandle = CLIENT_RealPlayEx(fLoginHandle, (unsigned int)device_channel, NULL, DH_RType_Realplay_1);
        if (lPlayHandle <= 0) {
            return NO;
        }
        //CLIENT_MakeKeyFrame(fLoginHandle, (int)device_channel, 0);
        fPlayHandle = lPlayHandle;
        CLIENT_SetRealDataCallBack(lPlayHandle, DHRealDataCallback, (LDWORD)self);
    }
    else {
        _videoResType = 0;
        CLIENT_StopRealPlayEx(fPlayHandle);
        LLONG lPlayHandle = CLIENT_RealPlayEx(fLoginHandle, (unsigned int)device_channel, NULL, DH_RType_Realplay_0);
        if (lPlayHandle <= 0) {
            return NO;
        }
        //CLIENT_MakeKeyFrame(fLoginHandle, (int)device_channel, 1);
        fPlayHandle = lPlayHandle;
        CLIENT_SetRealDataCallBack(lPlayHandle, DHRealDataCallback, (LDWORD)self);
    }
    return YES;
}

-(BOOL) StartRecordStream:(NSInteger)index withView:(VideoWnd*)wnd
{
    if (video_record_files_array == nil || index > [video_record_files_array count])
    {
        return NO;
    }
    CWRecordModel *recordModel = [video_record_files_array objectAtIndex:index];
    if (recordModel == nil) {
        return NO;
    }
    if (strlen(recordModel.net_recordfile_info.filename) > 0) {
        //record_name = [[NSString alloc] initWithUTF8String:record_info->net_recordfile_info.filename];
    }
    else {
        start_play_record_time = recordModel.net_recordfile_info.starttime;
        end_play_record_time = recordModel.net_recordfile_info.endtime;
    }
    video_handle_index = VIDEO_PLAY_RECORD;
    video_render_view = wnd;
    video_record_played = NO;
    video_is_loading = YES;
    _videoRecordIndex = index;
    
    [video_render_view startLoading];
    return YES;
}

-(BOOL) StartRecordStream:(NSString*)startTime withWndTime:(NSString*)endTime withView:(VideoWnd*)wnd withChannel:(int)channel
{
    if (startTime && endTime) {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        //实例化一个NSDateFormatter对象
        [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//设定时间格式
        NSDate *start_date = [dateFormat dateFromString:startTime];
        NSDate *end_date = [dateFormat dateFromString:endTime];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *start_dateComponent = [calendar components:unitFlags fromDate:start_date];
        NSDateComponents *end_dateComponent = [calendar components:unitFlags fromDate:end_date];
        
        start_play_record_time.dwYear = (int)[start_dateComponent year];
        start_play_record_time.dwMonth = (int)[start_dateComponent month];
        start_play_record_time.dwDay = (int)[start_dateComponent day];
        start_play_record_time.dwHour = (int)[start_dateComponent hour];
        start_play_record_time.dwMinute = (int)[start_dateComponent minute];
        start_play_record_time.dwSecond = (int)[start_dateComponent second];
        end_play_record_time.dwYear = (int)[end_dateComponent year];
        end_play_record_time.dwMonth = (int)[end_dateComponent month];
        end_play_record_time.dwDay = (int)[end_dateComponent day];
        end_play_record_time.dwHour = (int)[end_dateComponent hour];
        end_play_record_time.dwMinute = (int)[end_dateComponent minute];
        end_play_record_time.dwSecond = (int)[end_dateComponent second];
    }
    
    video_handle_index = VIDEO_PLAY_RECORD;
    video_render_view = wnd;
    video_record_played = NO;
    video_is_loading = YES;
    device_channel = channel;
    
    [video_render_view startLoading];
    
    return NO;
}

- (BOOL) PlayRecordVideoByFile
{
    [self stopPlayVideo:NO withInterior:YES];
    [self StopRecordStream:YES];
    
    _dontReceiveRecordStreamDataCount = 1;//1表示该标志有效果
    
    
    
    PLAY_GetFreePort(&fPlayPort);
    BOOL open_stream = PLAY_OpenStream(fPlayPort, nil, 0, 300*1024);
    if (open_stream) {
        PLAY_SetStreamOpenMode(fPlayPort, STREAME_FILE);
        
        BOOL play_stream = PLAY_Play(fPlayPort, (__bridge void *)(video_render_view));
        if (play_stream == NO) {
            //[[CWThings4Interface sharedInstance] showText:@"播放2000设备失败" inView:self.navigationController.view Timer:2.0];
            int iErr = CLIENT_GetLastError();
            NSString *sErr = [[NSString alloc] initWithFormat:@"PLAY_Play err, %x", iErr];
            [self BA_showAlert:sErr];
            return NO;
        }
    }
    
    if (video_record_files_array == nil || _videoRecordIndex > [video_record_files_array count])
    {
        return NO;
    }
    CWRecordModel *recordModel = [video_record_files_array objectAtIndex:_videoRecordIndex];
    if (recordModel == nil) {
        return NO;
    }
    NET_RECORDFILE_INFO record_file_info = recordModel.net_recordfile_info;
    
    LLONG play_handle_ = CLIENT_PlayBackByRecordFileEx(fLoginHandle, &record_file_info, NULL, DHDownLoadPosCallback, (LDWORD)self, DHPlaybackDataCallback, (LDWORD)self);
    //LLONG play_handle_ = CLIENT_PlayBackByRecordFile(fLoginHandle, &record_file_info, NULL, DHDownLoadPosCallback, DHPlaybackDataCallback);
    
    if (play_handle_ <= 0) {
        PLAY_CloseStream(fPlayPort);
        PLAY_ReleasePort(fPlayPort);
        
        NSString *sErr = [[NSString alloc] initWithFormat:@"CLIENT_PlayBackByRecordFileEx error, %d\n", play_handle_];
        [self BA_showAlert:sErr];
        return NO;
    }
    video_record_play_handle = play_handle_;
    
    record_video_playing = YES;
    
    [[ZFPlayerView sharedPlayerView] play];
    
    return YES;
}

-(BOOL) PlayRecordVideo
{
    [self stopPlayVideo:NO withInterior:YES];
    [self StopRecordStream:YES];
    
    _dontReceiveRecordStreamDataCount = 1;//1表示该标志有效果
    
    LONG play_handle_ = CLIENT_PlayBackByTimeEx(fLoginHandle, device_channel, &start_play_record_time, &end_play_record_time, NULL, DHDownLoadPosCallback, 0, DHPlaybackDataCallback, 0);
    if (play_handle_ <= 0) {
        //[[CWThings4Interface sharedInstance] showText:@"播放录像文件失败" inView:self.navigationController.view Timer:2.0];
        //int iErr = CLIENT_GetLastError();
        NSString *sErr = [[NSString alloc] initWithFormat:@"CLIENT_PlayBackByTimeEx error, %d\n", play_handle_];
        [self BA_showAlert:sErr];
        return NO;
    }
    video_record_play_handle = play_handle_;
    
    PLAY_GetFreePort(&fPlayPort);
    BOOL open_stream = PLAY_OpenStream(fPlayPort, nil, 0, 900*1024);
    if (open_stream) {
        PLAY_SetStreamOpenMode(fPlayPort, STREAME_FILE);
        
        BOOL play_stream = PLAY_Play(fPlayPort, (__bridge void *)(video_render_view));
        if (play_stream == NO) {
            //[[CWThings4Interface sharedInstance] showText:@"播放2000设备失败" inView:self.navigationController.view Timer:2.0];
            int iErr = CLIENT_GetLastError();
            NSString *sErr = [[NSString alloc] initWithFormat:@"PLAY_Play err, %x", iErr];
            [self BA_showAlert:sErr];
            return NO;
        }
    }
    record_video_playing = YES;
    
    [[ZFPlayerView sharedPlayerView] play];
    
    return YES;
}

-(NSString*) getStartRecordTime
{
    NSString *strTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", start_play_record_time.dwYear, start_play_record_time.dwMonth, start_play_record_time.dwDay, start_play_record_time.dwHour, start_play_record_time.dwMinute, start_play_record_time.dwSecond];
    return strTime;
}

-(NSString*) getEndRecordTime
{
    NSString *strTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", end_play_record_time.dwYear, end_play_record_time.dwMonth, end_play_record_time.dwDay, end_play_record_time.dwHour, end_play_record_time.dwMinute, end_play_record_time.dwSecond];
    return strTime;
}

- (BOOL) StopRecordStream:(BOOL)isInterior
{
    if (isInterior == NO) {
        video_handle_index = VIDEO_DEFAULT;
        _dontReceiveRealStreamDataCount = 0;
    }
    
    if (record_video_playing == YES) {
        record_video_playing = NO;
        if (video_record_play_handle) {
            BOOL bRet = CLIENT_StopPlayBack(video_record_play_handle);
            if (bRet == NO) {
                CLIENT_StopPlayBack(video_record_play_handle);
            }
            video_record_play_handle = 0;
        }
        
        if (fPlayPort > 0) {
            PLAY_Stop(fPlayPort);
            PLAY_CloseStream(fPlayPort);
            PLAY_ReleasePort(fPlayPort);
            fPlayPort = 0;
        }
        //video_handle_index = VIDEO_DEFAULT;
    }
    return YES;
}

- (BOOL) SetDisplayRegion:(CGRect) rc withEnable:(bool)enable
{
    DISPLAYRECT *rect = new DISPLAYRECT;
    
    rect->left      = 100;
    rect->top       = 100;
    rect->right     = 200;
    rect->bottom    = 200;
    bool bRet = NO;
    if (enable) {
        NSLog(@"displayregion start");
        PLAY_SetDisplayRegion(fPlayPort, 0, nil, (__bridge void *)(video_render_view), false);
        bRet = PLAY_SetDisplayRegion(fPlayPort, 0, rect, (__bridge void *)(video_render_view), true);
        
        NSLog(@"displayregion start----%d", bRet);
    }
    else {
        
        bRet = PLAY_SetDisplayRegion(fPlayPort, 0, nil, (__bridge void *)(video_render_view), false);
        NSLog(@"displayregion end----%d", bRet);
    }
    
    return bRet;
}

- (BOOL) SetScale:(float)scale withEnable:(bool)enable
{
    BOOL bRet = NO;
    if (enable) {
        bRet = PLAY_SetIdentity(fPlayPort, 0);
        bRet = PLAY_Scale(fPlayPort, scale, 0);
        bRet = PLAY_Translate(fPlayPort, _fX, _fY, 0);
        _fScale = scale;
    }
    else {
        bRet = PLAY_SetIdentity(fPlayPort, 0);
        _fScale = 0.0;
        _fX = 0.0;
        _fY = 0.0;
    }
    return bRet;
}

- (BOOL) Translate:(float)x withY:(float)y
{
    if (_fScale < 0.00001) return NO;
    
    BOOL bRet = NO;
    
    /*if (x < _fX) {
        _fX += x;
    }
    else {
        _fX = x;
    }
    
    if (y < _fY) {
        _fY += -y;
    }
    else {
        _fY = -y;
    }*/
    _fX += x;
    _fY += y;
    
    
    bRet = PLAY_SetIdentity(fPlayPort, 0);
    bRet = PLAY_Scale(fPlayPort, _fScale, 0);
    bRet = PLAY_Translate(fPlayPort, _fX, _fY, 0);
    NSLog(@"[Translate]------[%f]---[%f]------", _fX, _fY);
    return bRet;
}

-(void) video_mgr_timer_func
{
    do {
        if (_isHandleVideoDevice == YES) {
            if (video_device_connected == NO && _isGetDeviceInfoErr == NO) {
                if ([self RecevieDeviceInfo] && _retryLoginCount < 5) {
                    BOOL bRet = [self startConnect];
                    video_device_connected = bRet;
                    _retryLoginCount++;
                    if (bRet == NO) {
                        [NSThread sleepForTimeInterval:2];
                    }
                }
                else {
                    
                }
            }
            
            switch (video_handle_index) {
                case 1:
                    if (video_device_connected && video_stream_played == NO) {
                        _isStartRealStreamFinished = NO;
                        BOOL bRet = [self startPlayVideo];
                        _isStartRealStreamFinished = YES;
                        video_stream_played = bRet;
                        if (bRet) {
                            video_handle_index = VIDEO_DEFAULT;
                        }
                        else {
                            
                            [NSThread sleepForTimeInterval:2];
                        }
                        
                        if (_retryCount > 5) {
                            video_handle_index = VIDEO_DEFAULT;
                            [self StopRealStream:device_channel];
                            [self close_device];
                            video_device_connected = NO;
                            _retryCount = 0;
                        }
                        else {
                            _retryCount++;
                        }
                    }
                    break;
                case 2:
                    if (video_device_connected && video_record_search == NO) {
                        _isFindRecordStreamFinished = NO;
                        BOOL bRet = [self FindVideoRecord];
                        _isFindRecordStreamFinished = YES;
                        //video_record_search = bRet;
                        if (bRet) {
                            video_handle_index = VIDEO_DEFAULT;
                        }
                        else {
                            [NSThread sleepForTimeInterval:2];
                        }
                        
                        video_handle_index = VIDEO_DEFAULT;
                        _retryCount = 0;
                    }
                    break;
                case 3:
                    if (video_device_connected && video_record_played == NO) {
                        _isStartRecordStreamFinished = NO;
                        BOOL bRet = [self PlayRecordVideoByFile];
                        _isStartRecordStreamFinished = YES;
                        video_record_played = bRet;
                        if (bRet) {
                            video_handle_index = VIDEO_DEFAULT;
                        }
                        else {
                            
                            [NSThread sleepForTimeInterval:2];
                        }
                        
                        if (_retryCount > 5) {
                            [self StopRecordStream:YES];
                            video_handle_index = VIDEO_DEFAULT;
                            
                            [self close_device];
                            video_device_connected = NO;
                            _retryCount = 0;
                        }
                        else {
                            _retryCount++;
                        }
                    }
                    break;
                default:
                    break;
            }
            
            if (_dontReceiveRealStreamDataCount > 0) {
                if (_dontReceiveRealStreamDataCount > 500) {
                    video_handle_index = VIDEO_REAL_STREAM;
                    video_stream_played = NO;
                    _dontReceiveRealStreamDataCount = 0;
                    continue;
                }
                _dontReceiveRealStreamDataCount++;
            }
            
            if (_dontReceiveRecordStreamDataCount > 0) {
                if (_dontReceiveRecordStreamDataCount > 500) {
                    video_handle_index = VIDEO_PLAY_RECORD;
                    video_record_played = NO;
                    _dontReceiveRecordStreamDataCount = 0;
                    continue;
                }
                _dontReceiveRecordStreamDataCount++;
            }
        }
        [NSThread sleepForTimeInterval:0.2];
    } while(YES);
}

- (void) PausePlayBack:(BOOL)pause
{
    if (video_record_play_handle > 0) {
        if (pause) {
            CLIENT_PausePlayBack(video_record_play_handle, 1);
        }
        else {
            CLIENT_PausePlayBack(video_record_play_handle, 0);
        }
    }
}

- (void) SeekPlayBack:(NSInteger)offset
{
    if (video_record_play_handle) {
        CLIENT_SeekPlayBack(video_record_play_handle, 0, offset);
    }
}

@end



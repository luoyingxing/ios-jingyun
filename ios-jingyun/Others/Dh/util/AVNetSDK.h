//
//  AVNetSDK.h
//  常用功能头文件，功能有：登入、监视、云台、回放、报警、语音对讲。
//
//  Created by macuser on 11-12-5.
//  Copyright 2011 __dahua__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <webservice_pub.h>

/****************************************************************************
***常量定义
****************************************************************************/

// SDK内部数据类型定义
typedef int							AV_int32;
typedef unsigned int				AV_uint32;
typedef int							AV_BOOL;
typedef void*						AV_HANDLE;
typedef unsigned char				AV_BYTE;
typedef float						AV_float32;

// 错误码，对应AV_GetLastError接口的返回值
#define AV_EC(x)					(0x80000000 | x)
#define AV_OK						0				// 没有错误
#define AV_Error					-1				// 未知错误
#define AV_System_Error				AV_EC(1)		// 系统错误
#define AV_Invalid_Handle			AV_EC(2)		// 句柄无效
#define AV_Illegal_Param			AV_EC(3)		// 参数不合法
#define AV_Unsupport_Error			AV_EC(4)		// 设备不支持该功能
#define AV_Init_Error				AV_EC(5)		// 初始化失败
#define AV_Unit_Error				AV_EC(6)		// 清理失败
#define AV_Network_Error			AV_EC(7)		// 网络错误
#define AV_Connect_Error			AV_EC(8)		// 连接失败
#define AV_Connect_Used_Error		AV_EC(9)		// 已连接


#define AV_Login_Timeout			AV_EC(100)		// 登入超时
#define AV_Login_Password			AV_EC(101)		// 密码不正确
#define AV_Login_User				AV_EC(102)		// 用户名不存在
#define AV_Login_ReLogin			AV_EC(103)		// 重复登入
#define AV_Login_Locked				AV_EC(104)		// 帐号被锁定
#define AV_Login_BlackList			AV_EC(105)		// 帐号被列入黑名单
#define AV_Login_Busy				AV_EC(106)		// 设备系统忙，资源不足

#define AV_User_No_Right            AV_EC(107)		// 用户无权限

#define AV_ReturnData_Error			AV_EC(200)		// 对返回的数据校验出错
#define AV_GetSession_Error			AV_EC(201)		// 获取session信息失败
#define AV_QueryRecord_Error		AV_EC(202)		// 查询录像失败

typedef enum {
    AV_LOGIN_P2P = 0,
    AV_LOGIN_QUICK,
    AV_LOGIN_DAHUA  ,
    AV_LOGIN_IP_DOMAIN  ,
    AV_LOGIN_P2P_OVERSEA,
} AV_LOGIN_TYPE;

/****************************************************************************
 ***回调函数定义
 ****************************************************************************/

// 登入连接状态回调
@protocol IAV_LoginCallback <NSObject>

- (AV_int32) onLoginConnectStatus: (AV_HANDLE)hLoginID Status: (AV_BOOL)bOnline IP: (char *)szDevIp Port: (AV_int32)nDevPort Param: (void*)pUserParam;

@end

typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	void*				pEvent;
	char*				pFrameBodyBuf;
	AV_int32			nFrameBodyLen;
	AV_int32			nFrameTotalLen;
    AV_int32			nFrameHeadLen;
    AV_int32			nFrameType;
    AV_int32			nFrameSubType;
	AV_int32			nFrameID;
    AV_int32			nDateTime;
    AV_int32			nTimeStamp;
    AV_int32			nFrameRate;
    AV_int32			nWidth;
    AV_int32			nHeight;
	AV_int32			nEncodeType;
	AV_int32			nDeinterlace;
    AV_int32			nSamplesPerSecond;
    AV_int32			nBitsPerSample;
} AV_MediaInfo;

typedef struct
{
	AV_int32			nYear;
	AV_int32			nMonth;
	AV_int32			nDay;
	AV_int32			nHour;
	AV_int32			nMinute;
	AV_int32			nSecond;
	AV_int32			nMillisecond;
} AV_Time;

typedef struct
{
	AV_int32			nStructSize;
	AV_Time				stuCurTime;
} AV_PlayPosInfo;

// 实时监视回调
@protocol IAV_RealPlayCallback <NSObject>

@required
// 未经码流分析pMediaInfo＝NULL
- (AV_int32) onRealData: (AV_HANDLE)hRealHandle Data: (AV_BYTE *)pBuf Len: (AV_int32)nBufLen MediaInfo: (AV_MediaInfo *)pMediaInfo Param: (void*)pUserParam;

// pPlayPos为NULL表示播放结束
- (AV_int32) onRealPlayPos: (AV_HANDLE)hRealHandle Position: (AV_PlayPosInfo *)pPlayPos  Param: (void*)pUserParam;


- (AV_int32) onRealConnectStatus: (AV_HANDLE)hRealHandle Status: (AV_BOOL)bOnline LoginID: (AV_HANDLE)hLoginID Param: (void*)pUserParam;

- (AV_int32) onRealSolutionChanged: (AV_HANDLE)hRealHandle Width: (AV_int32)nWidth Height: (AV_int32)nHeight Param: (void*)pUserParam;

- (AV_int32) onRealUnsupportStream: (AV_HANDLE)hRealHandle  Param: (void*)pUserParam;

- (AV_int32) onRealUnsupportResolution: (AV_HANDLE)hRealHandle Param: (void*)pUserParam;

- (AV_int32) onRealLostFrame: (void*)pUserParam;

//- (AV_int32) onRealHaveNoRight:(int)result;

-(AV_int32) onRealResult:(int)result;

@end



@interface CAVRecordFileInfo : NSObject
{
@public
	AV_int32			m_nChnID;				// 通道号
	AV_uint32			m_nFileSize;			// 文件大小
	AV_Time				m_stuStartTime;			// 开始时间
	AV_Time				m_stuEndTime;			// 结束时间
	AV_uint32			m_nDriveNo;				// 磁盘号
	AV_uint32			m_nStartCluster;		// 起始簇号
	AV_int32			m_nRecordType;			// 录像类型（0：普通录像，1：报警录像）
	AV_int32			m_nImportantRecID;		// 0：普通录像，1：重要录像
	AV_uint32			m_nHint;				// 文件索引
	AV_int32			m_nStreamType;			// 0：主码流录像，1：辅码流1
}
@end

// 远程回放回调
@protocol IAV_PlayBackCallback <NSObject>

@required
// pMediaInfo=NULL要调用PLAY_InputData，否则调用PLAY_InputFrame.
- (AV_int32) onBackData: (AV_HANDLE)hPlayBackHandle Data: (AV_BYTE *)pBuf Len: (AV_int32)nBufLen MediaInfo: (AV_MediaInfo *)pMediaInfo Param: (void*)pUserParam;

// pPlayPos为NULL表示播放结束
- (AV_int32) onBackPlayPos: (AV_HANDLE)hPlayBackHandle Position: (AV_PlayPosInfo *)pPlayPos RecordInfo: (NSMutableArray *)pRecordFileArray Param: (void*)pUserParam;

- (AV_int32) onBackConnectStatus: (AV_HANDLE)hPlayBackHandle Status: (AV_BOOL)bOnline LoginID: (AV_HANDLE)hLoginID Param: (void*)pUserParam;

- (AV_int32) onBackSolutionChanged: (AV_HANDLE)hPlayBackHandle Width: (AV_int32)nWidth Height: (AV_int32)nHeight Param: (void*)pUserParam;

- (AV_int32) onBackUnsupportStream: (AV_HANDLE)hPlayBackHandle  Param: (void*)pUserParam;


- (AV_int32) onBackUnsupportResolution: (AV_HANDLE)hPlayBackHandle Param: (void*)pUserParam;


- (AV_int32) onBackLostFrame: (void*)pUserParam;

@end

// 录像、图片下载回调
@protocol IAV_DownloadCallback <NSObject>

- (AV_int32) onBackDownloadPos:(AV_HANDLE)hDownloadHandle Total:(AV_int32)nTotalSize DownloadSize:(AV_int32)nDownloadSize Param:(void*)pUserParam;

- (AV_int32) onBackConnectStatus: (AV_HANDLE)hDownloadHandle Status: (AV_BOOL)bOnline LoginID: (AV_HANDLE)hLoginID Param: (void*)pUserParam;


@end

// 语音对讲回调
@protocol IAV_TalkCallback <NSObject>

- (AV_int32) onTalkData: (AV_HANDLE)hTalkHandle Data: (AV_BYTE *)pBuf Len: (AV_int32)nBufLen MediaInfo: (AV_MediaInfo *)pMediaInfo Param: (void*)pUserParam;

- (AV_int32) onTalkConnectStatus: (AV_HANDLE)hTalkHandle Status: (AV_BOOL)bOnline LoginID: (AV_HANDLE)hLoginID Param: (void*)pUserParam;

@end


/****************************************************************************
***结构体定义
****************************************************************************/

///////////////////////////////////登入功能///////////////////////////////////

typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nWaitTime;					// 等待超时时间（毫秒），默认5000
	AV_int32			nConnTime;					// 连接超时时间（毫秒），默认3000
	AV_int32			nConnTryNum;				// 连接尝试次数，默认1次
} AV_IN_NetParam;


// 接口AV_Login输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	char*				szDevIp;					// 设备ip
	AV_int32			nDevPort;					// 设备端口
	char*				szDevUser;					// 用户名
	char*				szDevPwd;					// 密码
	AV_BOOL				bReconnect;					// 是否断线重连
	id<IAV_LoginCallback> pConnStatusCallback;		// 连接状态回调
	void*				pUserParam;					// 回调用户参数
    AV_int32            nClientType;                // 客户端类型
    AV_LOGIN_TYPE       emLoginType;                // 登录类型
} AV_IN_Login;

// 登入返回码
typedef enum 
{
	AV_Login_OK = 0,								// 成功
	AV_Login_Error,									// 未知错误
	AV_Login_Error_Password,						// 密码不正确
	AV_Login_Error_UserName,						// 帐号不存在
	AV_Login_Error_Timeout,							// 等待登入返回超时
	AV_Login_Error_ReLogin,							// 帐号已登入
	AV_Login_Error_Locked,							// 帐号已被锁定
	AV_Login_Error_Blacklist,						// 帐号已被列入黑名单
	AV_Login_Error_DeviceBusy,						// 资源不足，系统忙
	AV_Login_Error_ExceedMaxUserNum,				// 超出最大用户数
	AV_Login_Error_Connect,							// 连接设备失败
    AV_Login_Error_MacError,                        // mac地址验证失败
    AV_Login_Error_NotSupportedDevice  ,            // 不支持的设备
    AV_Login_Error_MD5  ,                           // 需要MD5鉴权
    AV_Login_Error_Get_Port_fail,
} AV_Login_ErrorCode;

// 设备系列类型
typedef enum 
{
	AV_Device_DVR = 0,								// 硬盘录像机
	AV_Device_NVS,									// 网络视频服务器
	AV_Device_IPC,									// 网络摄像机
	AV_Device_NVR,									// 网络录像机
	AV_Device_SVR,									// 存储服务器式录像机
	AV_Device_ITC,									// 智能交通摄像机
	AV_Device_ITS,									// 智能交通分析盒
	AV_Device_NVD,									// 网络解码器
	AV_Device_ATM,									// ATM
	AV_Device_Matrix,								// 视频矩阵
	AV_Device_IVS,									// 智能视频分析服务器
    AV_Device_N5,                                   // N5
    AV_Device_N51,                                  // N51
} AV_Device_SerialType;

#define AV_DeviceType_Len		128

// 设备详细类型
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	char				szDeviceType[AV_DeviceType_Len]; // 设备详细类型
} AV_Device_Type;

// 接口AV_Login输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_Login_ErrorCode	emErrorCode;				// 登入返回码
	AV_Device_SerialType emDeviceSerial;			// 设备系列类型
	AV_Device_Type		stuDeviceType;				// 设备详细类型
	AV_BOOL				abAnalogChnNum;				// 是否有模拟通道
	AV_int32			nAnalogChnNum;				// 模拟通道数
	AV_BOOL				abDigitalChnNum;			// 是否有数字通道
	AV_int32			nDigitalChnNum;				// 数字通道数
    AV_int32            nSessionID;                 // 会话
    AV_int32            nSequenceID;                // 序列号
    BOOL                m_bSupportZeroChannel;
    AV_LOGIN_TYPE       emActualLoginType;          // 设备实际登录类型，P2P情况下有效
} AV_OUT_Login;

/////////////////////////////////实时监视功能/////////////////////////////////

// 接口AV_RealPlay输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道号
	AV_int32			nSubType;					// 码流类型，0是主码流，1是辅码流1
	void*				pUIView;					// 窗口句柄，为（UIView*）
	AV_float32			fDisplayScale;				// iPhone3：1.0，iPhone4：2.0
	AV_int32			nDelayTime;					// 播放延时
	id<IAV_RealPlayCallback> pRealCallback;			// 实时监视回调
	void*				pUserParam;					// 回调用户参数
    AV_BOOL             bCheckRight;                // 是否检查权限
} AV_IN_RealPlay;

// 接口AV_RealPlay输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_RealPlay;

/////////////////////////////////云台控制功能/////////////////////////////////

// 云台命令
typedef enum 
{
	AV_PTZ_Up = 0,									// 上
	AV_PTZ_Down,									// 下
	AV_PTZ_Left,									// 左
	AV_PTZ_Right,									// 右
	AV_PTZ_Zoom_Add,								// 变倍＋
	AV_PTZ_Zoom_Dec,								// 变倍－
	AV_PTZ_Focus_Add = 0x07,						// 调焦＋
	AV_PTZ_Focus_Dec = 0x08,						// 调焦－
	AV_PTZ_Aperture_Add,							// 光圈＋
	AV_PTZ_Aperture_Dec,							// 光圈－
	AV_PTZ_Point_Move = 0x10,						// 转至预置点
	AV_PTZ_Point_Set,								// 设置预置点
	AV_PTZ_Point_Del,								// 删除预置点
    AV_PTZ_Lamp = 0x0E,                             // 灯光
	AV_PTZ_Point_Loop = 0x0F,						// 点间巡航
	AV_PTZ_Left_Top = 0x20,							// 左上
	AV_PTZ_Right_Top,								// 右上
	AV_PTZ_Left_Down,								// 左下
	AV_PTZ_Right_Down,								// 右下
    AV_PTZ_PATTEN_START = 0x2f,                     // 运行模式
    AV_PTZ_PATTEN_STOP,                             // 停止模式
	AV_PTZ_Goto_Position = 0x43,					// 三维精确定位
	AV_PTZ_Reset_Position,							// 三维定位重设零位
	AV_PTZ_TELE_Up = 0x70,							// 上＋TELE
	AV_PTZ_TELE_Down,								// 下＋TELE
	AV_PTZ_TELE_Left,								// 左＋TELE
	AV_PTZ_TELE_Right,								// 右＋TELE
	AV_PTZ_TELE_Left_Up,							// 左上＋TELE
	AV_PTZ_TELE_Left_Down,							// 左下＋TELE
	AV_PTZ_TELE_Right_Up,							// 右上＋TELE
	AV_PTZ_TELE_Right_Down,							// 右下＋TELE
	AV_PTZ_WIDE_Up,									// 上＋WIDE
	AV_PTZ_WIDE_Down,								// 下＋WIDE
	AV_PTZ_WIDE_Left,								// 左＋WIDE
	AV_PTZ_WIDE_Right,								// 右＋WIDE
	AV_PTZ_WIDE_Left_Up,							// 左上＋WIDE
	AV_PTZ_WIDE_Left_Down,							// 左下＋WIDE
	AV_PTZ_WIDE_Right_Up,							// 右上＋WIDE
	AV_PTZ_WIDE_Right_Down,							// 右下＋WIDE
} AV_PTZ_Type;

// 接口AV_ControlPTZ输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道号
	AV_PTZ_Type			emType;						// 命令
	AV_int32			nParam1;					// 参数1
	AV_int32			nParam2;					// 参数2
	AV_int32			nParam3;					// 参数3
	AV_BOOL				bOpen;						// 开始或停止
} AV_IN_PTZ;


// 接口AV_ControlPTZ输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_PTZ;

///////////////////////////////////回放功能///////////////////////////////////

// 接口AV_PlayBackByTime输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道号
	AV_int32			nSubType;					// 码流类型，0 兼容以前，主辅码流 1是主码流，2是辅码流1
	AV_int32			nRecordType;				// 录像类型，0是计划录像，1是外部报警录像，2是动态检测录像
	AV_Time				stuStartTime;				// 开始时间
	AV_Time				stuEndTime;					// 结束时间
	void*				pUIView;					// 窗口句柄，为（UIView*）
	AV_float32			fDisplayScale;				// iPhone3：1.0，iPhone4：2.0
	id<IAV_PlayBackCallback> pPlayBackCallback;		// 回放回调
	void*				pUserParam;					// 回调用户参数
    AV_BOOL             bCheckRight;                // 是否检查权限
} AV_IN_PlayBackByTime;

// 接口AV_PlayBackByTime输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_PlayBackByTime;

// 接口AV_SeekPlayBack输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_Time				stuPlayPos;					// 播放位置
} AV_IN_Seek;

// 接口AV_SeekPlayBack输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_Seek;

// 接口AV_PausePlayBack输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_BOOL				bPause;						// 暂停或继续
} AV_IN_Pause;

// 接口AV_PausePlayBack输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_Pause;


// 接口AV_SetPlayBackSpeed输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32            nPlaySpeed;				// 播放速度－1：当前基础上再慢放1倍，0：正常速度，1：当前基础上再快放1倍）
} AV_IN_Speed;

// 接口AV_SetPlayBackSpeed输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_Speed;

// 接口AV_SetPlayBackByGroup输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_Time				stuPlayPos;					// 播放位置
} AV_IN_SetGroup;

// 接口AV_PlayBackByTime输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_SetGroup;


// 接口AV_QueryPictureByTime输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道号
	AV_Time				stuStartTime;				// 开始时间
	AV_Time				stuEndTime;					// 结束时间
	void*				pUserParam;					// 回调用户参数
    AV_BOOL             bCheckRight;                // 是否检查权限
} AV_IN_QueryPictureByTime;

// 接口AV_QueryPictureByTime输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    NSMutableArray*     pRecordFileArray;           // 文件列表
} AV_OUT_QueryPictureByTime;

// 接口AV_DownloadByFile输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	CAVRecordFileInfo*	pRecordFileInfo;			// 文件信息
	char*				sSaveFileName;				// 保存文件名
	id<IAV_DownloadCallback> pDownloadCallback;		// 回放回调
	void*				pUserParam;					// 回调用户参数
} AV_IN_DownloadByFile;

// 接口AV_DownloadByFile输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_DownloadByFile;




// 接口AV_DownloadByTime输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道号
	AV_int32			nSubType;					// 码流类型，0是主码流，1是辅码流1
	AV_int32			nRecordType;				// 录像类型，0是计划录像，1是外部报警录像，2是动态检测录像
	AV_Time				stuStartTime;				// 开始时间
	AV_Time				stuEndTime;					// 结束时间
	char*				sSaveFileName;				// 保存文件名
	id<IAV_DownloadCallback> pDownloadCallback;		// 回放回调
	void*				pUserParam;					// 回调用户参数
} AV_IN_DownloadByTime;

// 接口AV_DownloadByTime输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_DownloadByTime;


typedef struct
{
	AV_int32			nStructSize;
	AV_int32			nChannelID;
    AV_int32			nSubType;
	AV_int32			nRecordType;
	AV_Time				stuStartTime;
	AV_Time				stuEndTime;
	NSMutableArray*     pRecordFileArray;           //
} AV_IN_QueryPlayBackFileByTime;

typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_QueryPlayBackFileByTime;



///////////////////////////////////报警功能///////////////////////////////////

// 接口AV_StartPushAlarmForIOS输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	char*				szAPNSIp;					// 苹果推送服务器ip
	AV_int32			nAPNSPort;					// 苹果推送服务器端口
    char*               szDevID;                   // DVR标识
    char*               szDevName;                   // DVR名称
	char*				szRegisterID;               // DeviceToken
	char*				szSSLCerCotent;				// SSL证书数据
    int                 nPeriodOfValidity;                    // 订阅周期
    NSMutableArray*     mapPushList;
} AV_IN_iOS_PushAlarm;

// 接口AV_StartPushAlarmForIOS输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_iOS_PushAlarm;

typedef struct
{
    char*				szRegisterID;               // DeviceToken              
}AV_IN_iOS_StopPush;

typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
}AV_OUT_iOS_StopPush;

/////////////////////////////////语音对讲功能/////////////////////////////////

// 接口AV_StartTalk输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道
	AV_int32			nEncodeType;				// 音频编码类型
    AV_int32			nSamplesPerSecond;			// 采样率
    AV_int32			nBitsPerSample;				// 位数
    AV_BOOL             bOpenAudio;                 // 是否直接播放
	id<IAV_TalkCallback> pTalkCallback;				// 回放回调
	void*				pUserParam;					// 回调用户参数
    BOOL                needTranspond;              // 是否需要转发
} AV_IN_Talk;

// 接口AV_StartTalk输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_Talk;

// 接口AV_SendTalkData输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_BYTE*            pAudioFrameData;            // 音频帧数据
    AV_int32            nFrameDataLen;              // 数据长度
} AV_IN_TalkData;

// 接口AV_SendTalkData输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_OUT_TalkData;

// 接口AV_QueryTalkFormat输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nChannelID;					// 通道
} AV_IN_TalkFormat;

typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nEncodeType;				// 音频编码类型；0：无头PCM，1：带头PCM，2：G711a，3：AMR，4：G711u，5：G726
    AV_int32			nSamplesPerSecond;			// 采样率
    AV_int32			nBitsPerSample;				// 位数
} AV_Audio_Format;

#define AV_Audio_Num	32

// 接口AV_QueryTalkFormat输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_int32            nSupportNum;                // 支持个数
	AV_Audio_Format		stuAudioFormat[AV_Audio_Num]; // 音频格式列表
} AV_OUT_TalkFormat;


// IO控制命令
typedef enum {
    AV_ALARMINPUT = 1,							// 控制报警输入
	AV_ALARMOUTPUT = 2,							// 控制报警输出
	AV_DECODER_ALARMOUT = 3,					// 控制报警解码器输出
	AV_WIRELESS_ALARMOUT = 5,					// 控制无线报警输出
	AV_ALARM_TRIGGER_MODE = 7,					// 报警触发方式（手动,自动,关闭），使用TRIGGER_MODE_CONTROL结构体
    
}AV_IOTYPE;

// 报警IO控制
typedef struct 
{
    AV_int32		nStructSize;				// 此结构体大小
	AV_uint32		uIndex;                     // 端口序号
	AV_uint32		uState;                     // 端口状态
} AV_ALARM_CONTROL;

// 报警解码器控制
typedef struct 
{
    AV_int32		nStructSize;				// 此结构体大小
	AV_int32		nDecoderNo;                 // 报警解码器号，从0开始
	AV_uint32		uAlarmChn;                  // 报警输出口，从0开始
	AV_uint32		uAlarmState;				// 报警输出状态；1：打开，0：关闭
} AV_DECODER_ALARM_CONTROL;

// 触发方式
typedef struct
{
    AV_int32		nStructSize;				// 此结构体大小
	AV_uint32		uIndex;                      // 端口序号
	AV_uint32		uMode;                       // 触发方式(0关闭1手动2自动);不设置的通道，sdk默认将保持原来的设置。
	AV_BYTE			bReserved[28];			
}  AV_TRIGGER_MODE_CONTROL;

// 接口AV_QueryIOControlState输入参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_IOTYPE           emType;                     // IO类型
}AV_IN_QueryIOControlState;


// 接口AV_QueryIOControlState输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    void*               pState;                     // 状态缓冲区
    AV_int32            nMaxlen;                    // 最大缓冲区字节数
    AV_int32*           nIOCount;                   // IO数量
    AV_BOOL             bSupportTriggerMode;        // 是否支持输出触发
}AV_OUT_QueryIOControlState;

// 接口AV_IOControl输入参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_IOTYPE           emType;                     // IO类型
    void*               pState;                     // 状态缓冲区
    AV_int32            nMaxlen;                    // 最大缓冲区字节数
}AV_IN_IOControl;


// 接口AV_IOControl输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_int32            nResulteCode;               // 错误码
}AV_OUT_IOControl;



/****************************************************************************
 ***接口定义
 ****************************************************************************/

@interface AVNetSDK : NSObject 
{

}

// 内部使用
+ (void*)			GetObject;

// 获取请求队列id
+ (int)             GetSequenceID;

// sdk初始化
+ (AV_BOOL)			AV_Startup;

// 程序从后台恢复到前台时调用
+ (void)			AV_ReInit;
//程序退到后台时调用
+ (void)            AV_Exit;
//程序进到前台的时候调用
+ (void)            AV_Init;
// sdk退出清理
+ (void)			AV_Cleanup;

// 获取sdk版本信息
+ (AV_int32)		AV_GetSDKVersion;

// 获取错误码
+ (AV_int32)		AV_GetLastError;

// 设置相关参数
+ (AV_BOOL)			AV_SetNetworkParam: (AV_IN_NetParam *)pInParam;

// 登入设备
+ (AV_HANDLE)		AV_Login: (AV_IN_Login *)pInParam Out: (AV_OUT_Login *)pOutParam;


// 登出设备
+ (void)			AV_Logout: (AV_HANDLE)hLoginID;


// 打开实时监视
+ (AV_HANDLE)		AV_RealPlay: (AV_HANDLE)hLoginID In: (AV_IN_RealPlay *)pInParam Out: (AV_OUT_RealPlay *)pOutParam;

// 关闭实时监视
+ (void)			AV_StopRealPlay: (AV_HANDLE)hRealHandle;

// 开始录像
+ (AV_BOOL)         AV_StartRecord:(AV_HANDLE)hPlayHandle Interface: (AV_int32)nType Path:(char*)sPath;
// 关闭渲染
+ (void)			AV_StopRender: (AV_HANDLE)hRealHandle;

// 重新打开窗口渲染，回调函数还是以前的
+ (BOOL)			AV_StartRender: (AV_HANDLE)hRealHandle  View:(void*)pUIView fDisplayScale:(float) Scale;

// 结束录像
+ (AV_BOOL)         AV_StopRecord:(AV_HANDLE)hPlayHandle Interface: (AV_int32)nType;

// 抓图，nType（0是监视，1是回放）
+ (AV_BOOL)			AV_SnapPicture: (AV_HANDLE)hPlayHandle Interface: (AV_int32)nType FileName: (char *)szFileName Quality: (AV_int32)nQuality;

// 打开音频，nType（0是监视，1是回放）
+ (AV_BOOL)			AV_OpenAudio: (AV_HANDLE)hPlayHandle Interface: (AV_int32)nType;

// 关闭音频，nType（0是监视，1是回放）
+ (AV_BOOL)			AV_CloseAudio: (AV_HANDLE)hPlayHandle Interface: (AV_int32)nType;

// 获取音量，0～100，nType（0是监视，1是回放，2是语音对讲）
+ (AV_BYTE)			AV_GetAudioVolume: (AV_HANDLE)hPlayHandle Interface: (AV_int32)nType;

// 设置音量，nType（0是监视，1是回放，2是语音对讲）
+ (AV_BOOL)			AV_SetAudioVolume: (AV_HANDLE)hPlayHandle Interface: (AV_int32)nType Volume: (AV_BYTE)nVolume;


// 云台控制
+ (AV_BOOL)			AV_ControlPTZ: (AV_HANDLE)hLoginID In: (AV_IN_PTZ *)pInParam Out: (AV_OUT_PTZ *)pOutParam;


// 开始按时间回放
+ (AV_HANDLE)		AV_PlayBackByTime: (AV_HANDLE)hLoginID In: (AV_IN_PlayBackByTime *)pInParam Out: (AV_OUT_PlayBackByTime *)pOutParam;

// 停止回放
+ (void)			AV_StopPlayBack: (AV_HANDLE)hPlayBackHandle;

// 拖动
+ (AV_BOOL)			AV_SeekPlayBack: (AV_HANDLE)hPlayBackHandle In: (AV_IN_Seek *)pInParam Out: (AV_OUT_Seek *)pOutParam;

// 暂停与继续
+ (AV_BOOL)			AV_PausePlayBack: (AV_HANDLE)hPlayBackHandle In: (AV_IN_Pause *)pInParam Out: (AV_OUT_Pause *)pOutParam;

// 快放与慢放
+ (AV_BOOL)			AV_SetPlayBackSpeed: (AV_HANDLE)hPlayBackHandle In: (AV_IN_Speed *)pInParam Out: (AV_OUT_Speed *)pOutParam;

// 快放与慢放
+ (AV_float32)			AV_GetPlayBackSpeed: (AV_HANDLE)hPlayBackHandle;

// 单帧播放
+ (AV_BOOL)			AV_StepPlayBack: (AV_HANDLE)hPlayBackHandle;


// 多路同步回放
+ (AV_BOOL)			AV_SetPlayBackByGroup: (AV_HANDLE)hPlayBackHandle In: (AV_IN_SetGroup *)pInParam Out: (AV_OUT_SetGroup *)pOutParam;

+ (AV_BOOL)         AV_QueryPictureByTime:(AV_HANDLE)hLoginID In:(AV_IN_QueryPictureByTime *)pInParam Out:(AV_OUT_QueryPictureByTime*)pOutParam;

+ (AV_HANDLE)         AV_DownloadByFile:(AV_HANDLE)hLoginID In:(AV_IN_DownloadByFile *)pInParam Out:(AV_OUT_DownloadByFile*)pOutParam;

+ (AV_HANDLE)         AV_DownloadByTime:(AV_HANDLE)hLoginID In:(AV_IN_DownloadByTime *)pInParam Out:(AV_OUT_DownloadByTime *)pOutParam;

+ (AV_BOOL)            AV_StopDownload:(AV_HANDLE)hDownloadHandle;

+ (AV_BOOL)         AV_QueryPlayBackFilesByTime: (AV_HANDLE)hLoginID In: (AV_IN_QueryPlayBackFileByTime *)pInParam Out: (AV_OUT_QueryPlayBackFileByTime *)pOutParam;

// 报警推送－布防
+ (AV_BOOL)			AV_StartPushAlarmForIOS: (AV_HANDLE)hLoginID In: (AV_IN_iOS_PushAlarm *)pInParam Out: (AV_OUT_iOS_PushAlarm *)pOutParam;

// 报警推送－撤防
+ (AV_BOOL)			AV_StopPushAlarmForIOS: (AV_HANDLE)hLoginID  In: (AV_IN_iOS_StopPush *)pInParam Out: (AV_OUT_iOS_StopPush *)pOutParam;


// 开启语音对讲
+ (AV_HANDLE)		AV_StartTalk: (AV_HANDLE)hLoginID In: (AV_IN_Talk *)pInParam Out: (AV_OUT_Talk *)pOutParam;

// 发送对讲数据
+ (AV_BOOL)			AV_SendTalkData: (AV_HANDLE)hTalkHandle In: (AV_IN_TalkData *)pInParam Out: (AV_OUT_TalkData *)pOutParam;

// 停止语音对讲
+ (void)			AV_StopTalk: (AV_HANDLE)hTalkHandle;

// 查询设备支持对讲格式
+ (AV_BOOL)			AV_QueryTalkFormat: (AV_HANDLE)hLoginID In: (AV_IN_TalkFormat *)pInParam Out: (AV_OUT_TalkFormat *)pOutParam;

// 查询设备IO状态 (先调用本接口，OutParam的pState为null获取IO个数，然后申请相应的内存再次调用本接口查询状态)
+ (AV_BOOL)         AV_QueryIOControlState:(AV_HANDLE)hLoginID In: (AV_IN_QueryIOControlState *)pInParam Out: (AV_OUT_QueryIOControlState *)pOutParam;

// 设置IO状态
+ (AV_BOOL)         AV_IOControl:(AV_HANDLE)hLoginID In:(AV_IN_IOControl *)pInParam Out:(AV_OUT_IOControl *)pOutParam;


+ (AV_BOOL) AV_UpdateWhiteList:(NSString*)strXMLFilePath;


+ (AV_BOOL) AV_IsValidLoginHandle:(AV_HANDLE)hLoginID;


+ (void*) initDHClient:(AV_LOGIN_TYPE)emLoginType;
@end





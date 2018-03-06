//
//  AVConfigSDK.h
//  配置功能头文件
//
//  Created by macuser on 11-12-6.
//  Copyright 2011 __dahua__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVNetSDK.h"

/****************************************************************************
 ***结构体定义
 ****************************************************************************/

///////////////////////////////////设备基本配置///////////////////////////////////


// 接口AV_CFG_GetDevGeneralInfo输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_IN_GetGeneralInfo;

// 接口AV_CFG_GetDevGeneralInfo输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_BYTE             pGenVersion[8];             // 版本号
	AV_uint32           nLocalNo;                   // 本机编号
	AV_uint32           nVideoFmt;                  // 制式 :NTSC,PAL等
	AV_uint32           nLanguage;                  // 语言选择
	AV_uint32           nOverWrite;                 // 盘满时　1　覆盖,　0　停止
	AV_uint32           nRecLen;                    // 录象段长度
	AV_BOOL             bShutPswEn;                 // 关机密码使能
	AV_uint32           nDateFmt;                   // 日期格式
	AV_uint32           nDateSprtr;                 // 日期分割符
	AV_uint32           nTimeFmt;                   // 时间格式
	AV_BOOL             bDST;                       // 是否实行夏令时 1-实行 0-不实行
	AV_uint32           nManualStart;               // 手动录像启动
	AV_uint32           nManualStop;                // 手动录像停止
} AV_CFG_OUT_GetGeneralInfo;


///////////////////////////////////通道配置///////////////////////////////////


// 接口AV_CFG_QueryChannelName输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_IN_QueryName;

#define MAX_ChnName_Len     64

// 通道名称
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    char                szChannelName[MAX_ChnName_Len];
} AV_CFG_ChannelName_;

// 接口AV_CFG_QueryChannelName输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    //AV_CFG_ChannelName* pstChnNameArray;            // 通道名称数组
    AV_int32            nArrayCount;                // 数组元素个数
    AV_int32            nChannelCount;              // 通道个数
} AV_CFG_OUT_QueryName;

// 接口AV_CFG_QueryChannelName输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    //AV_CFG_ChannelName* pstChnNameArray;            // 通道名称数组
    AV_int32            nChannelCount;              // 通道个数
} AV_CFG_IN_SetupName;

// 接口AV_CFG_SetupChannelName输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_OUT_SetupName;


// 时间段结构															    
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_BOOL				bEnable;                    // 当表示录像时间段时，按位表示四个使能，从低位到高位分别表示动检录象、报警录象、普通录象、动检和报警同时发生才录像
	AV_int32			nBeginHour;
	AV_int32			nBeginMin;
	AV_int32			nBeginSec;
	AV_int32			nEndHour;
	AV_int32			nEndMin;
	AV_int32			nEndSec;
} AV_CFG_TSECT;

// 区域；各边距按整长8192的比例
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nLeft;
	AV_int32			nTop;
	AV_int32			nRight;
	AV_int32			nBottom;
} AV_CFG_RECT;

// OSD属性结构
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_uint32			nRGBAFrontGround;           // 物件的前景；按字节表示，分别为红、绿、蓝和透明度
	AV_uint32			nRGBABackGround;            // 物件的背景；按字节表示，分别为红、绿、蓝和透明度
	AV_CFG_RECT			stuRect;                    // 位置
	AV_BOOL				bShow;                      // 显示使能
	AV_uint32           nExtFuncMask;               // 扩展使能，掩码 bit0 表示是否显示星期几，0-不显示 1-显示 
} AV_CFG_ENCODE_WIDGET;

#define AV_CAPTURE_D1           0x00000001
#define AV_CAPTURE_HD1          0x00000002
#define AV_CAPTURE_BCIF         0x00000004
#define AV_CAPTURE_CIF          0x00000008
#define AV_CAPTURE_QCIF         0x00000010
#define AV_CAPTURE_VGA          0x00000020
#define AV_CAPTURE_QVGA         0x00000040
#define AV_CAPTURE_SVCD         0x00000080
#define AV_CAPTURE_QQVGA        0x00000100
#define AV_CAPTURE_SVGA         0x00000200
#define AV_CAPTURE_XVGA         0x00000400
#define AV_CAPTURE_WXGA         0x00000800
#define AV_CAPTURE_SXGA         0x00001000
#define AV_CAPTURE_WSXGA        0x00002000
#define AV_CAPTURE_UXGA         0x00004000
#define AV_CAPTURE_WUXGA        0x00008000
#define AV_CAPTURE_LFT          0x00010000
#define AV_CAPTURE_720          0x00020000
#define AV_CAPTURE_1080         0x00040000
#define AV_CAPTURE_1_3M         0x00080000
#define AV_CAPTURE_2M           0x00100000
#define AV_CAPTURE_5M           0x00200000
#define AV_CAPTURE_3M           0x00400000
#define AV_CAPTURE_5_0M         0x00800000
#define AV_CAPTURE_1_2M         0x01000000
#define AV_CAPTURE_1408_1024    0x02000000
#define AV_CAPTURE_8M           0x04000000
#define AV_CAPTURE_2560_1920    0x08000000
#define AV_CAPTURE_960H         0x10000000
#define AV_CAPTURE_960_720      0x20000000

// 通道音视频属性
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	// 视频参数
	AV_BOOL				bVideoEnable;               // 视频使能；1：打开，0：关闭
	AV_int32            nBitRateControl;            // 码流控制；0：限定码流，1：可变码流
	AV_int32			nFramesPerSec;              // 帧率
	AV_int32			nEncodeMode;                // 编码模式；掩码，从低位开始分别为（1：DIVX MPEG4，2：MPEG4，3：MPEG2，4：MPEG1，5：H263，6：MJPG，7：FCC MPEG4，8：H264）
	AV_int32			nImageSize;                 // 分辨率；见分辨率宏定义
	AV_int32			nImageQlty;                 // 档次1-6
	AV_int32			nLimitStream;               // 限码流参数
	// 音频参数
	AV_BOOL				bAudioEnable;               // 音频使能；1：打开，0：关闭
	AV_int32			nFormatTag;                 // 音频编码类型: 0:G711A,1:PCM,2:G711U,3:AMR,4:AAC
	AV_int32			nChannels;                  // 声道数
	AV_int32			nBitsPerSample;             // 采样深度	
	AV_BOOL				bAudioOverlay;              // 音频叠加使能
    AV_int32            nIFrameInterval;            // I帧间隔帧数量，描述两个I帧之间的P帧个数，0-149
	AV_int32			nScanMode;                  // NSP
	AV_uint32			nSamplesPerSec;             // 采样率
    AV_int32            nH264Profile;
} AV_CFG_VIDEOENC_OPT;

// 画面颜色属性
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_CFG_TSECT		stuSect;
	AV_int32            nBrightness;                // 亮度；0-100
	AV_int32			nContrast;                  // 对比度；0-100
	AV_int32			nSaturation;                // 饱和度；0-100
	AV_int32			nHue;                       // 色度；0-100
	AV_BOOL             bGainEn;                    // 增益使能
	AV_int32			nGain;                      // 增益；0-100
} AV_CFG_COLOR_CFG;

#define AV_CFG_REC_TYPE_NUM         3
#define AV_CFG_ENCODE_AUX           3               // 扩展码流个数
#define AV_CFG_COL_TSECT            2               // 颜色时间段个数
#define AV_CFG_COVERS				1               // 遮挡区域个数

// 图像通道属性结构体
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
	AV_int32			nNoise;
	AV_int32			nMode;                      // (车载特殊需求)模式一(画质优先):录像分辨率采用4路D1，帧率2fps，码率128kbps(每小时225MB)
	// 模式二(流畅优先):录像分辨率采用4路CIF，帧率12fps，码率256kbps(每小时550MB)
	// 模式三(自定义)录像分辨率可以由用户自定义，限定最大能力为4CIF/25fps
	AV_CFG_VIDEOENC_OPT	stuMainVideoEncOpt[AV_CFG_REC_TYPE_NUM];
	AV_CFG_VIDEOENC_OPT	stuAssiVideoEncOpt[AV_CFG_ENCODE_AUX];		
	AV_CFG_COLOR_CFG	stuColorCfg[AV_CFG_COL_TSECT];
	AV_CFG_ENCODE_WIDGET stuTimeOSD;
	AV_CFG_ENCODE_WIDGET stuChannelOSD;
	AV_CFG_ENCODE_WIDGET stuBlindCover[AV_CFG_COVERS];	// 单区域遮挡
	AV_int32			nBlindEnable;               // 区域遮盖开关；0x00：不使能遮盖，0x01：仅遮盖设备本地预览，0x10：仅遮盖录像及网络预览，0x11：都遮盖
	AV_int32            nBlindMask;                 // 区域遮盖掩码；第一位：设备本地预览；第二位：录像(及网络预览) */
	AV_int32			nVolume;                    // 音量阀值(0~100可调)
	AV_BOOL				bVolumeEnable;              // 音量阀值使能
} AV_CFG_CHANNEL_CFG;


// 接口AV_CFG_ConfigF5Json输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pInBuf;                     // Json数据
    AV_int32            nBufLen;                    // 数据长度
} AV_CFG_IN_ConfigF5Json;

// 接口AV_CFG_ConfigF5Json输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pRecvBuf;                   // 接收缓冲
    AV_int32            nBufLen;                    // 缓冲长度
    AV_int32            nRetLen;                    // 返回字节个数
    AV_int32            nResultCode;                // 返回码
} AV_CFG_OUT_ConfigF5Json;

///////////////////////////////////DSP能力///////////////////////////////////


// DSP能力信息
typedef struct 
{
    AV_int32			nStructSize;				// 此结构体大小
	AV_uint32			nVideoStandardMask;         // 视频制式掩码
	AV_uint32			nImageSizeMask;             // 编码模式掩码，见上面分辨率宏定义
	AV_uint32			nEncodeModeMask;            // 编码模式掩码
	AV_uint32			nStreamCap;                 // 按位表示设备支持的码流类型；第一位：支持主码流，第二位：支持辅码流1，第三位：支持辅码流2
	AV_uint32			nImageSizeMask_Assi[32];    // 表示主码流为各分辨率时，支持的辅码流分辨率掩码
	AV_uint32			nMaxEncodePower;            // 最高编码能力
	AV_uint32			nMaxSupportChannel;         // 每块DSP支持最大输入通道数
	AV_uint32			nChannelMaxSetSync;         // 是否同步，0：不同步，1：同步
	AV_BYTE				bMaxFrameOfImageSize[32];   // 不同分辨率下的最大采集帧率
	AV_uint32			nEncodeCap;                 // 标志位
} AV_CFG_DSP_ENCODECAP;

// DSP能力查询，当DSP能力算法标识为2时使用。
typedef struct  
{
	AV_BYTE             bMainFrame[32];             // 以分辨率枚举值(CAPTURE_SIZE)为索引,主码流分辨率对应支持的最大帧率,如果不支持此分辨率,则值为0.
	AV_BYTE             bExtraFrame_1[32];          // 辅码流1,使用同bMainFrame
	AV_BYTE             bReserved[128];             // 预留给辅码流2和3.		
} AV_CFG_DSP_CFG_ITEM;

typedef struct  
{
	AV_int32			nItemNum;                   // DH_DSP_CFG_ITEM的有效个数,等于通道数
	AV_CFG_DSP_CFG_ITEM stuDspCfgItem[32];          // 主码流的信息
	AV_BYTE             bReserved[128];             // 保留
} AV_CFG_DSP_CFG; 


///////////////////////////////////F6配置///////////////////////////////////


// 接口AV_CFG_ConfigF6Json输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pJsonBuf;                   // Json数据
    AV_int32            nJsonLen;                   // Json数据长度
    AV_BYTE*            pBinaryBuf;                 // 二进制数据
    AV_int32            nBinaryLen;                 // 二进制数据长度
} AV_CFG_IN_ConfigF6Json;

// 接口AV_CFG_ConfigF6Json输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pRecvBuf;                   // 接收缓冲
    AV_int32            nBufLen;                    // 缓冲长度
    AV_int32            nRetLen;                    // 返回字节个数
    AV_BYTE*            pJsonBuf;                   // Json数据
    AV_int32            nJsonLen;                   // Json数据长度
    AV_BYTE*            pBinaryBuf;                 // 二进制数据
    AV_int32            nBinaryLen;                 // 二进制数据长度
    AV_int32            nResultCode;                // 返回码
} AV_CFG_OUT_ConfigF6Json;


///////////////////////////////////设备功能列表///////////////////////////////////


// 接口AV_CFG_QueryDevFuncList输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_IN_DevFuncList;

#define AV_CFG_MAX_FUNCLIST     512

typedef enum
{
    AV_CFG_EN_FTP = 0,                              // FTP 按位，1：传送录像文件 2：传送抓图文件
	AV_CFG_EN_SMTP,                                 // SMTP 按位，1：报警传送文本邮件 2：报警传送图片 3:支持健康邮件功能
	AV_CFG_EN_NTP,                                  // NTP	按位：1：调整系统时间
	AV_CFG_EN_AUTO_MAINTAIN,                        // 自动维护 按位：1：重启 2：关闭 3:删除文件
	AV_CFG_EN_VIDEO_COVER,                          // 区域遮挡 按位：1：多区域遮挡
	AV_CFG_EN_AUTO_REGISTER,                        // 主动注册	按位：1：注册后sdk主动登陆
	AV_CFG_EN_DHCP,                                 // DHCP	按位：1：DHCP
	AV_CFG_EN_UPNP,                                 // UPNP	按位：1：UPNP
	AV_CFG_EN_COMM_SNIFFER,                         // 串口抓包 按位：1:CommATM
	AV_CFG_EN_NET_SNIFFER,                          // 网络抓包 按位： 1：NetSniffer
	AV_CFG_EN_BURN,                                 // 刻录功能 按位：1：查询刻录状态
	AV_CFG_EN_VIDEO_MATRIX,                         // 视频矩阵 按位：1：是否支持视频矩阵 2:是否支持SPOT视频矩阵 3:是否支持HDMI视频矩阵
	AV_CFG_EN_AUDIO_DETECT,                         // 音频检测 按位：1：是否支持音频检测
	AV_CFG_EN_STORAGE_STATION,                      // 存储位置 按位：1：Ftp服务器(Ips) 2：SMB 3：NFS 4：ISCSI 16：DISK 17：U盘
	AV_CFG_EN_IPSSEARCH,                            // IPS存储查询 按位：1：IPS存储查询	
	AV_CFG_EN_SNAP,                                 // 抓图  按位：1：分辨率2：帧率3：抓图方式4：抓图文件格式5：图画质量
	AV_CFG_EN_DEFAULTNIC,                           // 支持默认网卡查询 按位 1：支持
	AV_CFG_EN_SHOWQUALITY,                          // CBR模式下显示画质配置项 按位 1:支持
	AV_CFG_EN_CONFIG_IMEXPORT,                      // 配置导入导出功能能力 按位 1:支持
	AV_CFG_EN_LOG,                                  // 是否支持分页方式的日志查询 按位 1：支持
	AV_CFG_EN_SCHEDULE,                             // 录像设置的一些能力 按位 1:冗余 2:预录 3:录像时间段
	AV_CFG_EN_NETWORK_TYPE,                         // 网络类型按位表示 1:以态网 2:无线局域 3:CDMA/GPRS 4:CDMA/GPRS多网卡配置
	AV_CFG_EN_MARK_IMPORTANTRECORD,                 // 标识重要录像 按位:1：设置重要录像标识
	AV_CFG_EN_ACFCONTROL,                           // 活动帧率控制 按位：1：支持活动帧率控制, 2:支持定时报警类型活动帧率控制(不支持动检),该能力与ACF能力互斥
	AV_CFG_EN_MULTIASSIOPTION,                      // 多路辅码流 按位：1：支持三路辅码流, 2:支持辅码流编码压缩格式独立设置
	AV_CFG_EN_DAVINCIMODULE,                        // 组件化模块 按位：1，时间表分开处理 2:标准I帧间隔设置
	AV_CFG_EN_GPS,                                  // GPS功能 按位：1：Gps定位功能
	AV_CFG_EN_MULTIETHERNET,                        // 支持多网卡查询 按位 1：支持
	AV_CFG_EN_LOGIN_ATTRIBUTE,                      // Login属性 按位：1：支持Login属性查询
	AV_CFG_EN_RECORD_GENERAL,                       // 录像相关 按位：1，普通录像；2：报警录像；3：动态检测录像；4：本地存储；5：远程存储；6：冗余存储；7：本地紧急存储
	AV_CFG_EN_JSON_CONFIG,                          // Json格式配置:按位：1支持Json格式
	AV_CFG_EN_HIDE_FUNCTION,                        // 屏蔽功能：按位：1，屏蔽PTZ云台功能
	AV_CFG_EN_DISK_DAMAGE,                          // 硬盘坏道信息支持能力: 按位：1，硬盘坏道信息查询支持能力
	AV_CFG_EN_PLAYBACK_SPEED_CTRL,                  // 支持回放网传速度控制:按位:1，支持回放加速
	AV_CFG_EN_HOLIDAYSCHEDULE,                      // 支持假期时间段配置:按位:1，支持假期时间段配置
	AV_CFG_EN_FETCH_MONEY_TIMEOUT,                  // ATM取钱超时
	AV_CFG_EN_BACKUP_VIDEO_FORMAT,                  // 备份支持的格式，按位：1:DAV, 2:ASF
	AV_CFG_EN_QUERY_DISK_TYPE,                      // 支持硬盘类型查询
	AV_CFG_EN_CONFIG_DISPLAY_OUTPUT,                // 支持设备显示输出（VGA等）配置,按位: 1:画面分割轮巡配置
	AV_CFG_EN_SUBBITRATE_RECORD_CTRL,               // 支持扩展码流录像控制设置, 按位：1-辅码流录像控制设置
	AV_CFG_EN_IPV6,                                 // 支持IPV6设置, 按位：1-IPV6配置
	AV_CFG_EN_SNMP,                                 // SNMP（简单网络管理协议）
	AV_CFG_EN_QUERY_URL,                            // 支持获取设备URL地址, 按位: 1-查询配置URL地址
	AV_CFG_EN_ISCSI,                                // ISCSI（Internet小型计算机系统接口配置）
	AV_CFG_EN_RAID,                                 // 支持Raid功能
	AV_CFG_EN_HARDDISK_INFO,                        // 支持磁盘信息F5查询
    AV_CFG_EN_PROTOCOLFRAMEWORK,                    // 三代协议框架
} AV_CFG_FuncList;

// 接口AV_CFG_QueryDevFuncList输出参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_uint32           nFuncEnable[AV_CFG_MAX_FUNCLIST]; // 功能列表能力集，下标对应上面的枚举值，按位表示子功能
} AV_CFG_OUT_DevFuncList;


// 接口AV_CFG_GetSystemInfo输入参数
typedef struct 
{
	AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_IN_GetSystemInfo;

#define MAX_DevVer_Len     32
#define MAX_DevID_Len       32

// 接口AV_CFG_GetSystemInfo输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
	char                szDevVer[MAX_DevVer_Len];   // 设备版本，字符串形式
    char                szDevID[MAX_DevID_Len];     // 设备序列号，字符串形式
} AV_CFG_OUT_GetSystemInfo;

// 接口AV_CFG_IN_SetDevPass输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    char                szName[64];
    char                szUpassword[64];
    char                szNpassword[64];
    char                szNpassword2[64];
} AV_CFG_IN_SetDevPass;

// 接口AV_CFG_IN_SetDevPass输出参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_int32            nErrorCode;
} AV_CFG_OUT_SetDevPass;


typedef struct 
{
	AV_BYTE iVerMaj;          // BOIS主版本号(软件)
	AV_BYTE iVerSub;          // BOIS次版本号(软件)
	AV_BYTE iVideoInCaps;     // 视频输入接口数量
	AV_BYTE iAudioInCaps;     // 音频输入接口数量
	AV_BYTE iAlarmInCaps;     // 报警输入接口数
	AV_BYTE iAlarmOutCaps;    // 报警输出接口数
	AV_BYTE iIdePortNum;      // IDE接口数
	AV_BYTE iAetherNetPortNum;// 网络接口数
	AV_BYTE iUsbPortNum;      // USB接口数
	AV_BYTE iComPortNum;      // 串口数
	AV_BYTE iParallelPortNum; // 并口口数
	AV_BYTE iMatrixOutNum;	// 视频矩阵输出端口数量 0表示不支持矩阵功能
	AV_BYTE year;            // 编译日期: 年
	AV_BYTE  month;           // 编译日期: 月
	AV_BYTE  day;             // 编译日期: 日
	AV_BYTE iVerUser;         // BOIS用户版本号(软件)
	AV_BYTE iVerModify;       // BOIS修改版本号(软件)
	AV_BYTE iWebVersion[4];   // WEB版本
	AV_BYTE WebYear;          // 预留
	AV_BYTE WebMonth;         // 预留
	AV_BYTE WebDay;           // 预留
	AV_BYTE iReserved_01;     // 预留
	AV_BYTE iReserved_02;     // 预留
	AV_BYTE iReserved_03;     // 预留
	AV_BYTE iReserved_04;     // 预留
	AV_BYTE iReserved_05;     // 预留
	AV_BYTE iIsMutiEthIf;     // 网卡支持情况，0：单网卡 1：多网卡（单网卡用之前旧的协议，后者用新的字符串协议）
	AV_BYTE iReserved_07;     // 预留
}AV_CFG_SYSATTR;


typedef enum
{
	AV_SYSTEM_INFO_GENERAL = 0,		/* 普通信息 */
	AV_SYSTEM_INFO_DEV_ATTR,			/* 设备属性信息 */
	AV_SYSTEM_INFO_DISK_DRIVER,		/* 硬盘信息 */
	AV_SYSTEM_INFO_FILE_SYSTEM,		/* 文件系统信息 */
	AV_SYSTEM_INFO_VIDEO_ATTR,			/* 视频属性 */
	AV_SYSTEM_INFO_CHARACTER_SET,		/* 字符集信息 */
	AV_SYSTEM_INFO_OPTICS_STORAGE,		/* 光存储设备信息 */
	AV_SYSTEM_INFO_DEV_ID,				/* 设备序列号(ID) */
	AV_SYSTEM_INFO_DEV_VER,			/* 设备版本，字符串形式 */
	AV_SYSTEM_INFO_LOGIN_ATTR,         /* 登陆特性*/
	AV_SYSTEM_INFO_TALK_ATTR = 10,		/* 语音对讲属性 */
	AV_SYSTEM_INFO_DEV_TYPE = 11,		/* 设备类型 */
	AV_SYSTEM_INFO_PLATFORM = 12,		/* 查询设备特殊协议(平台接入)支持信息 */
	AV_SYSTEM_INFO_SD_CARD = 13,		/* SD卡信息 */
	AV_SYSTEM_INFO_MOTIONDETECT = 14,	/* 设备视频动态检测属性信息 */
	AV_SYSTEM_INFO_VIDEOBLIND = 15,	/* 视频区域遮挡属性信息 */
	AV_SYSTEM_INFO_CAMERA = 16,		/* 摄像头属性信息 */
	AV_SYSTEM_INFO_WATERMARK = 17,		/* 查询图象水印能力 */
	AV_SYSTEM_INFO_WIRELESS = 18,		/* 查询Wireless能力 */
    AV_SYSTEM_INFO_Language = 20,		/* 查询支持的语言列表 */
	AV_SYSTEM_INFO_PICTURE = 25,		/* 是否支持新的录像及图片列表查询方式 */
	AV_SYSTEM_INFO_DEV_ALL = 26,		/* 设备功能列表 */
	AV_SYSTEM_INFO_INFRARED = 27,		/* 查询无线报警能力 */
	AV_SYSTEM_INFO_NEWLOGTYPE = 28,	/* 是否支持新的日志格式 */
	AV_SYSTEM_INFO_OEM_INFO = 29,		/* OEM信息 */
	AV_SYSTEM_INFO_NET_STATE=30,		/* 网络状态 */
	AV_SYSTEM_INFO_DEV_SNAP =31,		/* 设备抓图功能能力查询 */
	AV_SYSTEM_INFO_VIDEO_CAPTURE = 32,	/* 视频前端采集能力查询 */
	AV_SYSTEM_INFO_DISK_SUBAREA = 33,  /* 硬盘分区能力查询*/
	AV_SYSTEM_INFO_SMART_DISK =34,     /* 硬盘smart信息查询*/
	AV_SYSTEM_INFO_IPC = 35,           /* 设备支持的IPC能力*/
} AV_SYSTEM_INFO_TYPES;

typedef struct avtime
{
    unsigned int second:6;
    unsigned int minute:6;
    unsigned int hour:5;
    unsigned int day:5;
    unsigned int month:4;
    unsigned int year:6;
    
}AVTIME;

typedef struct {
	int		ide_num;   //硬盘数量
	int		ide_port;   //IDE口数量
	unsigned long	ide_msk;    //硬盘掩码
	unsigned long	ide_bad;    //坏盘掩码
	unsigned long	ide_cap[32];  //硬盘容量
} IDE_INFO, *pIDE_INFO;

typedef struct IDE_INFO64{
	/// 已挂载的硬盘的数量,，不包括坏盘。硬盘个数也等于ide_msk中置1的位个数减去
	/// ide_bad中置1的位个数. 应用程序访问硬盘时, 硬盘序号规则如下: 第一个被置1
	/// 的位对应的IDE通道上挂载的正常硬盘的硬盘序号为0，第二个被置1的位对应正常
	/// 硬盘的硬盘序号为1，依次类推。
	int		ide_num;//分区个数
	
	///< IDE通道的数目，包括扩展的IDE通道。
	int		ide_port;//ignore
	
	/// 指示各个IDE通道上是否挂载硬盘，包括坏盘。每一位对应IDE通道的主盘或从盘，
	/// 置位表示已挂载硬盘，否则没有。对应关系为bit0对应IDE0的主盘，bit1对应IDE0
	/// 的从盘，bit2对应IDE1的主盘，bit3对应IDE1的从盘，依次类推。
	unsigned long	ide_msk;//ignore
	
	/// 指示各个IDE通道上是否挂载了坏的硬盘。每一位对应IDE通道的主盘或从盘，置位
	/// 表示以有坏硬盘，否则没有。对应关系同ide_msk。
	unsigned long	ide_bad;//ignore
	
	/// 已挂载的正常硬盘的容量，以扇区为单位，扇区大小为IDE_SECTOR_SIZE。扇区数用
	/// 32位来表示，数组下标是正常硬盘的序号。
#ifdef WIN32
	unsigned __int64			ide_cap[32];
#else	//linux
	unsigned long long			ide_cap[32];
#endif
	AVTIME  start_time1;		//总的录像开始时间
	AVTIME	end_time1;			//总的录像结束时间
	unsigned long	total_space;		//总容量
	unsigned long	remain_space;		//剩余容量
} IDE_INFO64, *pIDE_INFO64;


//驱动器信息结构
typedef  struct  _DRIVER_INFO{
	unsigned long driver_type; //驱动器类型
	long is_current; //是否为当前工作盘
	unsigned long section_count; //时间段数
	AVTIME    start_time1; //录像时间段1开始时间
	AVTIME end_time1; //录像时间段1结束时间
	long two_part; //是否有第二段
	AVTIME start_time2; //录像时间段2开始时间
	AVTIME end_time2; //录像时间段2结束时间
	unsigned long total_space; //总容量
	unsigned long remain_space; //剩余容量
	unsigned long error_flag; //硬盘状态 0：normal 1：error
	unsigned long index; //唯一分区标识，0~3：磁盘号；4~6：分区号；7：标识0为本地 1为远程
}DRIVER_INFO,*pDRIVER_INFO;

// 组播数据结构
typedef struct
{
    AV_BOOL             bDHCPEnable;                // DHCP使能
    AV_BYTE*            pIPAddress;                 // ip地址
    AV_BYTE*            pSubnetMask;                // 子网掩码
    AV_BYTE*            pGateway;                   // 默认网关
}NetWorkInfo;

typedef struct
{
    AV_BYTE*            pMachineName;               // 设备名称
    AV_BYTE*            pDeviceClass;               // 设备类型
    AV_BYTE*            pDeviceType;                // 设备型号
    AV_BYTE*            pSerialNo;                  // 序列号
    AV_BYTE*            pHardwareID;                // 硬件编号
    AV_BYTE*            pVersion;                   // 设备版本号
    AV_BYTE*            pOnline;                    // 是否在线
    AV_BYTE*            pUUID;                      // 设备唯一编号
    AV_BYTE*            pMac;                       // 设备物理地址
    AV_BYTE*            pDefinition;                // 解析度，standard标清，hight高清
    AV_int32            nAudioInputChannels;        // 设备音频输入通道数
    AV_int32            nVideoInputChannels;        // 设备视频输入通道数
    AV_BYTE*            pMachineAddress;            // 设备部署地址
    AV_BYTE*            pMachineGroup;              // 设备组
    AV_BYTE*            pManufaturer;               // 制造厂商名， “dhhua”
    AV_int32            nPort;                      // 设备端口
    AV_BYTE*            pVendor;                    // 设备商
    AV_BYTE*            pManagedCMS;                // 中心管理服务器名称(DSS中的CMS名称)
    AV_BOOL             bCentralizationManager;     // 是否中心管理
    NetWorkInfo         IPV4;                       // IPV4网络信息
    NetWorkInfo         IPV6;                       // IPV6网络信息
}LanDevice;

@protocol IAV_MulticastDeviceCallback <NSObject>

- (AV_int32) onMulticastDevice: (LanDevice)device;

@end

typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_int32            nID;                        // 表示某次搜索的编号
    AV_int32            nTimeout;                   // 搜索超时时间
    id<IAV_MulticastDeviceCallback>                  delegate;                   // 监听器
}AV_CFG_IN_SearchLanDevice;

typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
}AV_CFG_OUT_SearchLanDevice;


// 接口AV_CFG_QuerySystemInfo输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_SYSTEM_INFO_TYPES    emType;                 // 查询类型
      
} AV_CFG_IN_QuerySystemInfo;

// 接口AV_CFG_QuerySystemInfo输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pRecvBuf;                   // 接收缓冲
    AV_int32            nBufLen;                    // 缓冲长度
    AV_int32            nRetLen;                    // 返回字节个数
} AV_CFG_OUT_QuerySystemInfo;


typedef enum
{
	AV_CONFIG_TYPE_GENERAL = 0,	/*普通配置*/
	AV_CONFIG_TYPE_SERIAL_COMM,	/*串口配置*/
	AV_CONFIG_TYPE_NET,			/*网络配置*/
	AV_CONFIG_TYPE_RECORD,			/*定时录象配置*/
	AV_CONFIG_TYPE_CAPTURE,		/*图像配置*/
	AV_CONFIG_TYPE_PTZ,			/*云台步长*/
	AV_CONFIG_TYPE_DETECT,			/*图像检测配置*/
	AV_CONFIG_TYPE_ALARM,			/*报警配置*/
	AV_CONFIG_TYPE_DISPLAY,		/*图像显示配置*/
	/*9 - /NULL*/
	AV_CONFIG_TYPE_TITLE = 10,		/*通道名称，设备2.4版本后不再支持*/
	AV_CONFIG_TYPE_MAIL,			/*邮件配置*/
	AV_CONFIG_TYPE_PREVIEW,		/*预览配置*/
	AV_CONFIG_TYPE_PPPOE,			/*PPPoE配置*/
	AV_CONFIG_TYPE_DDNS,			/*DDNS配置*/
	AV_CONFIG_TYPE_SNIFFER,		/*网络抓包配置*/
	AV_CONFIG_TYPE_DSPCAP,			/*编码能力信息*/
	//	AV_CONFIG_TYPE_FTP,			/*FTP配置*/
	AV_CONFIG_TYPE_AUTO_MT = 18,	/*自动维护配置*/
	AV_CONFIG_TYPE_NTP,			/*NTP配置*/
	AV_CONFIG_TYPE_LIMIT_BR,		/*限码流配置*/
	
	AV_CONFIG_TYPE_WATERMAKE = 29,		/*图象水印配置*/
	AV_CONFIG_TYPE_VIDEO_MATRIX = 30,	/*本地矩阵控制配置*/
	AV_CONFIG_TYPE_COVER = 34,			/*视频区域遮挡*/
	AV_CONFIG_TYPE_DHCP = 35,			/*DHCP配置*/
	AV_CONFIG_TYPE_WEB_URL = 36,		/*抓图保存web路径配置*/
	AV_CONFIG_TYPE_FTP_PRO = 37,		/*FTP配置*/
	AV_CONFIG_TYPE_CAMERA = 38,		/*摄像头属性配置*/
	AV_CONFIG_TYPE_ETHERNET = 39,		/*网卡配置*/
	AV_CONFIG_TYPE_DNS = 40,			/*DNS服务器配置*/
	AV_CONFIG_TYPE_STORSTATION = 41,   //存储位置
	AV_CONFIG_TYPE_DOWNLOAD_STRATEGY = 42,	//音频配置
	AV_CONFIG_TYPE_VIDEO_OSD = 44,			//视频OSD叠加配置
	AV_CONFIG_TYPE_MACHINE = 46,           //机器相关配置
	AV_CONFIG_TYPE_FTP_PRO_EX = 57,     // FTP扩展配置
	AV_CONFIG_TYPE_SYSLOG_RS = 58,		 //SYSLOG的远程服务器配置
	
	AV_CONFIG_TYPE_ALARM_CENTER_UP	= 120,  //报警中心上传配置。
	AV_CONFIG_TYPE_RECORD_NEW	= 123,		//新录象配置
	AV_CONFIG_TYPE_TIMESHEET = 125,		//获取工作表
	AV_CONFIG_TYPE_COLOR = 126,			// 颜色配置
	AV_CONFIG_TYPE_CAPTURE_127	= 127,		//双码流图像配置
	AV_CONFIG_TYPE_CAPTURE_128 = 128,		//新的编码配置
	AV_CONFIG_TYPE_AUDIO_CAPTURE = 129,	//音频配置
	AV_CONFIG_TYPE_WLAN = 131,				//查询无线配置
	AV_CONFIG_TYPE_TRANSFER_STRATEGY = 133,//网络传输策略配置
	AV_CONFIG_TYPE_WIRELESS_ADDR = 134,    //无线报警配置,主要是输出地址和遥控器地址
	AV_CONFIG_TYPE_WLAN_DEVICE = 135,		//搜索无线设备
	AV_CONFIG_TYPE_BACKUP_VIDEO_FORMAT = 136,//视频备份配置
	AV_CONFIG_TYPE_RTSP = 137,               // RTSP配置
	
	AV_CONFIG_TYPE_MULTI_DDNS = 140,		//多DDNS服务器配置
	AV_CONFIG_TYPE_SERIAL_COMM_EX = 152,    //扩展串口配置
	AV_CONFIG_TYPE_NETCARD = 153,           // 卡口配置
	AV_CONFIG_TYPE_INTERVIDEO = 190,		//平台接入配置
	AV_CONFIG_TYPE_OEM_INFO = 200,			//第三方接入信息
	AV_CONFIG_TYPE_AUTO_REGISTER = 241,	// 主动注册参数配置
	
	AV_CONFIG_TYPE_ALARM_BEGIN,
	AV_CONFIG_TYPE_ALARM_LOCALALM,
	AV_CONFIG_TYPE_ALARM_NETALM,
	AV_CONFIG_TYPE_ALARM_DECODER,
	AV_CONFIG_TYPE_ALARM_MOTION,
	AV_CONFIG_TYPE_ALARM_BLIND,
	AV_CONFIG_TYPE_ALARM_LOSS,
	AV_CONFIG_TYPE_ALARM_NODISK,
	AV_CONFIG_TYPE_ALARM_DISKERR,
	AV_CONFIG_TYPE_ALARM_DISKFULL,
	AV_CONFIG_TYPE_ALARM_NETBROKEN,
	AV_CONFIG_TYPE_ALARM_ENCODER,
	AV_CONFIG_TYPE_ALARM_WIRELESS,
	AV_CONFIG_TYPE_ALARM_AUDIODETECT,
	AV_CONFIG_TYPE_ALARM_DISKNUM,
	AV_CONFIG_TYPE_ALARM_PANORAMA,
	AV_CONFIG_TYPE_ALARM_LOSTFOCUS,
	AV_CONFIG_TYPE_ALARM_IPCOLLISION,
	AV_CONFIG_TYPE_ALARM_STATIC,               //(ly)
	AV_CONFIG_TYPE_ALARM_MACCOLLISION,
	AV_CONFIG_TYPE_ALARM_OPERATION_OVERTIME,
	AV_CONFIG_TYPE_ALARM_END,
	
} AV_CONFIG_TYPES;

typedef enum
{
    AV_CONFIG_NEW_TYPE_FLASHLIGHT = 1000,
    AV_CONFIG_NEW_TYPE_PIRALARM,
    AV_CONFIG_NEW_TYPE_ALARMLINKAGE,
    AV_CONFIG_NEW_TYPE_BLINDETECT,
    AV_CONFIG_NEW_TYPE_RECORD,
    AV_CONFIG_NEW_TYPE_MOTIONDETECT,
    AV_CONFIG_NEW_TYPE_ENCODE,
    AV_CONFIG_NEW_TYPE_VIDEOCOLOR,
} AV_CONFIG_NEW_TYPES;


typedef struct {    // 定时时段
    unsigned char    StartHour; // 开始时间
    unsigned char    StartMin;
    unsigned char    StartSec;
    unsigned char    EndHour;   // 结束时间
    unsigned char    EndMin;
    unsigned char    EndSec;
    unsigned char    State;     // 第二位是定时，第三位是动态检测，第四位是报警
    unsigned char    Reserve; // Reserve已经被使用，更改的话请通知录像模块
} TSECT;

//! 颜色设置内容
typedef struct
{
	TSECT 	Sector;				/*!< 对应的时间段*/
	AV_BYTE	Brightness;			/*!< 亮度	0-100		*/
	AV_BYTE	Contrast;			/*!< 对比度	0-100		*/
	AV_BYTE	Saturation;			/*!< 饱和度	0-100		*/
	AV_BYTE	Hue;				/*!< 色度	0-100		*/
	AV_BYTE	Gain;				/*!< 增益	0-100		*/
	AV_BYTE	Reserve[3];
} COLOR_PARAM;

#define N_COLOR_SECTION	2
typedef struct
{
	AV_BYTE ColorVersion[8];
	COLOR_PARAM Color[N_COLOR_SECTION];
} CONFIG_COLOR;

// 接口AV_CFG_QueryConfig输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_CONFIG_TYPES     emType;                 // 查询类型
    AV_int32            nParam;                 //查询参数
    
} AV_CFG_IN_QueryConfig;

// 接口AV_CFG_QueryConfig输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_BYTE*            pRecvBuf;                   // 接收缓冲
    AV_int32            nBufLen;                    // 缓冲长度
    AV_int32            nRetLen;                    // 返回字节个数
} AV_CFG_OUT_QueryConfig;


// 接口AV_CFG_SetupConfig输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_CONFIG_TYPES    emType;                      // 设置类型
    AV_int32            nParam;                 //设置参数
    AV_BYTE*            pBuf;                       // 接收缓冲
    AV_int32            nBufLen;                    // 缓冲长度

    
} AV_CFG_IN_SetupConfig;

// 接口AV_CFG_SetupConfig输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_OUT_SetupConfig;

// 接口AV_CFG_QueryEventMessage输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    
} AV_CFG_IN_QueryEventMessage;

// 接口AV_CFG_QueryEventMessage输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
    AV_BOOL*            bEnable;                    // 使能
    AV_int32            nType;                      // 类型
    char                szTitle[256];               // 标题
    NSMutableArray*     arrayReceivers;             // 接收者
} AV_CFG_OUT_QueryEventMessage;


// 接口AV_CFG_SetupEventMessage输入参数
typedef struct
{
	AV_int32			nStructSize;				// 此结构体大小
    AV_BOOL*            bEnable;                    // 使能
    AV_int32            nType;                      // 类型
    char                szTitle[256];               // 标题
    NSMutableArray*     arrayReceivers;             // 接收者
} AV_CFG_IN_SetupEventMessage;

// 接口AV_CFG_SetupEventMessage输出参数
typedef struct
{
    AV_int32			nStructSize;				// 此结构体大小
} AV_CFG_OUT_SetupEventMessage;


#define N_WEEKS 7
#define N_TSECT 6
//时间表
typedef struct tagTIMESECTION
{
	//!使能
	AV_int32    enable;
	//!开始时间:小时
	AV_int32    startHour;
	//!开始时间:分钟
	AV_int32	startMinute;
	//!开始时间:秒钟
	AV_int32	startSecond;
	//!结束时间:小时
	AV_int32	endHour;
	//!结束时间:分钟
	AV_int32	endMinute;
	//!结束时间:秒钟
	AV_int32	endSecond;
}TIMESECTION;

typedef struct
{
    TIMESECTION         tsSchedule[N_WEEKS][N_TSECT];
} AV_CONFIG_DAYS;

//工作表配置
typedef struct tagWORKSHEET
{
	AV_int32			iName;							/*!< 时间表名称 */
	TIMESECTION	tsSchedule[N_WEEKS][N_TSECT];	/*!< 时间段 */
}CONFIG_WORKSHEET;

typedef struct tagPTZ_LINK {
	AV_int32 iType;					/*! 联动类型 */
	AV_int32 iValue;					/*! 联动序号 */
}PTZ_LINK;

#define N_SYS_CH 16

//! 事件处理结构
typedef struct tagEVENT_HANDLER
{
	AV_uint32	dwRecord;			/*!< 录象掩码 */
	AV_int32		iRecordLatch;		/*!< 录像延时：10〜300 sec */
	AV_uint32	dwTour;					/*!< 轮巡掩码 */
	AV_uint32	dwSnapShot;				/*!< 抓图掩码 */
	AV_uint32	dwAlarmOut;				/*!< 报警输出通道掩码 */
	AV_int32		iAOLatch;			/*!< 报警输出延时：10〜300 sec */
	PTZ_LINK PtzLink[N_SYS_CH];		/*!< 云台联动项 */
    
	AV_int32	bRecordEn;				/*!< 录像使能 */
	AV_int32	bTourEn;				/*!< 轮巡使能 */
	AV_int32	bSnapEn;				/*!< 抓图使能 */
	AV_int32	bAlarmOutEn;			/*!< 报警使能 */
	AV_int32	bPtzEn;					/*!< 云台联动使能 */
	AV_int32	bTip;					/*!< 屏幕提示使能 */
	AV_int32	bMail;					/*!< 发送邮件 */
	AV_int32	bMessage;				/*!< 发送消息到报警中心 */
	AV_int32	bBeep;					/*!< 蜂鸣 */
	AV_int32	bVoice;					/*!< 语音提示 */
	AV_int32	bFTP;					/*!< 启动FTP传输 */
    
	AV_int32		dwWorkSheet;			/*!< 时间表的选择，由于时间表里使用数字做索引，且不会更改 */
	AV_int32 	dwMatrix;				/*!< 矩阵掩码 */
	AV_int32 	bMatrixEn;				/*!< 矩阵使能 */
	AV_int32 	bLog;					/*!< 日志使能，目前只有在WTN动态检测中使用 */
	AV_int32		iEventLatch;		/*!< 联动开始延时时间，s为单位 */
	AV_int32 	bMessagetoNet;			/*!< 消息上传给网络使能 */
	AV_int32     wiAlarmOut;				/*!< 无线报警输出掩码 */
	char    bMMSEn;                /*!< 短信报警使能  */
	AV_BYTE   SnapshotTimes;        /*!< 抓图张数 */
	AV_BYTE   SnapshotPeriod; //!<抓图帧间隔，每隔多少帧抓一张图片，一定时间内抓拍的张数还与抓图帧率有关。0表示不隔帧，连续抓拍。
	AV_BYTE dReserved2;             /*!< 保留字节,保持字节对齐*/
	AV_int32 dwTourhi;                   /*!< 轮巡32-64路掩码 */
    AV_BYTE email_type;         //0，图片附件，1，录像附件
    AV_BYTE email_max_length;   //附件录像时的最大长度，单位MB
    AV_BYTE email_max_time;     //附件是录像时最大时间长度，单位秒
    char dReserved[13]; 			/*!< 保留字节 */
} EVENT_HANDLER;

//!报警配置结构
typedef struct tagCONFIG_ALARM_X
{
	//!报警输入开关
	BOOL	bEnable;
	//!传感器类型常开 or 常闭
	AV_int32		iSensorType;
	//!报警联动
	EVENT_HANDLER hEvent;
} CONFIG_ALARM;

#define MD_REGION_ROW 32

//!动态检测设置
typedef struct tagCONFIG_MOTIONDETECT
{
	BOOL bEnable;					/*!< 动态检测开启 */
	int iLevel;						/*!< 灵敏度 */
	unsigned long mRegion[MD_REGION_ROW];	/*!< 区域，每一行使用一个二进制串 */
	EVENT_HANDLER hEvent;			/*!< 动态检测联动 */
} CONFIG_MOTIONDETECT;

typedef struct tagCONFIG_BLINDDETECT
{
    BOOL bEnable;
    AV_int32    iLevel;
    EVENT_HANDLER hEvent;
} CONFIG_BLINDDETECT;

typedef struct
{
    AV_int32		nStructSize;				// 此结构体大小
    AV_int32        ChannelID;
    AV_CONFIG_NEW_TYPES       emCfgType;
    AV_BYTE*        byBuffer;
    AV_int32        nBufferLen;
    AV_HANDLE       hReserved;
}AV_CFG_IN_NewConfig;

typedef struct
{
    AV_int32            nStructSize;				// 此结构体大小
    AV_int32            results;                    // 错误码

}AV_CFG_OUT_NewConfig;

typedef struct
{
    AV_BOOL     AudioEnable;
    AV_BOOL     VideoEnable;
    char        AudioCompression[16];
    AV_int32    AudioFrequency;
    AV_int32    AudioDepth;
    AV_int32    AudioPacketPeriod;
    AV_int32    AudioMode;
    char        AudioPack[16];
    
    char        VideoCompression[16];
    AV_int32    VideoWidth;
    AV_int32    VideoHeight;
    char        VideoCustomResolutionName[16];
    char        VideoBitRateControl[16];
    AV_int32    VideoBitRate;
    AV_int32    VideoSize;
    AV_int32    VideoFPS;
    AV_int32    VideoGOP;
    AV_int32    VideoQualityRange;
    AV_int32    VideoQuality;
    char        VideoPack[16];
    char        VideoProfile[16];
    int         Channels[8];
    AV_CFG_RECT Region;
}ENCODE_OPTION_NEW;

typedef struct
{
    ENCODE_OPTION_NEW mainFormat[4];
    ENCODE_OPTION_NEW extraFormat[3];
    ENCODE_OPTION_NEW snapFormat[3];
        
}ENCODE_NEW;


typedef struct
{
    NSArray*    AudioCompressionTypes;
    AV_int32    AudioMaxBufferTime;
    NSArray*    VideoCompressionTypes;
    NSArray*    VideoRelolutionTypes;
    AV_int32    BitRateMin;
    AV_int32    BitRateMax;
    AV_int32    FPSMax;
    AV_int32    MaxBufferTime;
    AV_int32    MaxROICount;
    NSString*   Channel;
    NSArray*   H264Profiles;
}ENCODE_CAP_OPTION_NEW;

typedef struct
{
    ENCODE_CAP_OPTION_NEW mainFormat[3];
    ENCODE_CAP_OPTION_NEW extraFormat[3];
    ENCODE_CAP_OPTION_NEW snapForamt[3];
    
}ENCODE_CAPABILITIES;

typedef struct
{
    AV_int32		nStructSize;				// 此结构体大小
    AV_int32        nChannelID;
    NSString*       StreamType;
    ENCODE_NEW*     pEncodeArray;
    int             nChannelCount;              // 总的通道数
    AV_HANDLE       hReserved;
}AV_CFG_IN_ConfigCaps;

typedef struct
{
    AV_int32	nStructSize;				// 此结构体大小
    ENCODE_CAPABILITIES* pCaps;
}AV_CFG_OUT_ConfigCaps;


typedef struct
{
    AV_int32            nBrightness;                // 亮度
    AV_BOOL             bEnable;                    // 是否开启
    AV_CONFIG_DAYS      pConfigDay;                 // 时间表
    
}CFG_FlashLightControl;


typedef struct
{
    AV_BOOL             bEnable;                    // 是否开启
    AV_BOOL             bSnapshot;                  // 是否拍照
    AV_int32            nDejitter;                  // 去抖动
    AV_BOOL             bRecord;                    // 是否录像
    AV_int32            nRecordLatch;               // 录像延时
    NSMutableArray *    pArrayRecordChannels;       // 录像多通道
    AV_BOOL             bFlashlight;                // 是否开启补光灯
    AV_int32            nFlashLatch;                // 补光延时
    AV_BOOL             bAlarmOut;                  // 报警输出
    AV_int32            nAlarmOutLatch;             // 报警输出延时
    NSMutableArray*     pArrayAlarmOutChannels;     // 报警输出多通道
    char                szSensorType[8];
    AV_CONFIG_DAYS      pConfigDay;                 // 时间表
    
}CFG_PIRAlarmControl;




typedef struct
{
    AV_int32            nLevel;                     // 灵敏度
    AV_BOOL             bEnable;                    // 是否开启
    AV_BOOL             bRecord;                    // 是否录像
    AV_int32            nRecordLatch;               // 录像延时
    NSMutableArray *    pArrayRecordChannels;       // 录像多通道
    AV_BOOL             bSnapshot;                  // 是否拍照
    AV_BOOL             bAlarmOut;                  // 报警输出
    AV_int32            nAlarmOutLatch;             // 报警输出延时
    NSMutableArray*     pArrayAlarmOutChannels;     // 报警输出多通道
    AV_CONFIG_DAYS      pConfigDay;                 // 时间表
    
}CFG_BlindDetect;


typedef struct
{
    AV_int32            nDejitter;                  // 防抖动
    AV_int32            nLevel;                     // 灵敏度
    AV_BOOL             bEnable;                    // 是否开启
    AV_BOOL             bRecord;                    // 是否录像
    AV_int32            nRecordLatch;               // 录像延时
    NSMutableArray *    pArrayRecordChannels;       // 录像多通道
    AV_BOOL             bFlash;                     // 是否闪光
    AV_int32            nFlashLatch;                // 闪光延时
    AV_BOOL             bSnapshot;                  // 是否拍照
    AV_BOOL             bAlarmOut;                  // 报警输出
    AV_int32            nAlarmOutLatch;             // 报警输出延时
    NSMutableArray*     pArrayAlarmOutChannels;     // 报警输出多通道
    AV_CONFIG_DAYS      pConfigDay;                 // 时间表
    unsigned long       pRegion[MD_REGION_ROW];     // 检测区域
}CFG_MotionDetect;

 

/****************************************************************************
 ***接口定义
 ****************************************************************************/


@interface AVConfigSDK : AVNetSDK 
{

}

// 查询系统信息
+ (AV_BOOL)         AV_CFG_GetDevGeneralInfo: (AV_HANDLE)hLoginID In: (AV_CFG_IN_GetGeneralInfo *)pInParam Out: (AV_CFG_OUT_GetGeneralInfo *)pOutParam;

// 查询通道名称
+ (AV_BOOL)			AV_CFG_QueryChannelName: (AV_HANDLE)hLoginID In: (AV_CFG_IN_QueryName *)pInParam Out: (AV_CFG_OUT_QueryName *)pOutParam;

// 设置通道名称
+ (AV_BOOL)			AV_CFG_SetupChannelName: (AV_HANDLE)hLoginID In: (AV_CFG_IN_SetupName *)pInParam Out: (AV_CFG_OUT_SetupName *)pOutParam;

// 获取通道配置
+ (AV_BOOL)         AV_CFG_GetChannelConfig: (AV_HANDLE)hLoginID OutBuffer: (AV_CFG_CHANNEL_CFG *)pOutBuffer OutBufSize:(AV_int32)nBufSize  RetBufSize: (AV_int32 *)pRetBufSize;

// 设置通道配置
+ (AV_BOOL)         AV_CFG_SetChannelConfig: (AV_HANDLE)hLoginID InBuffer: (AV_CFG_CHANNEL_CFG *)pInBuffer InBufSize:(AV_int32)nBufSize;

// 透传F5Json配置
+ (AV_BOOL)         AV_CFG_ConfigF5Json: (AV_HANDLE)hLoginID In: (AV_CFG_IN_ConfigF5Json *)pInParam Out: (AV_CFG_OUT_ConfigF5Json *)pOutParam;

// 透传F6Json配置
+ (AV_BOOL)         AV_CFG_ConfigF6Json: (AV_HANDLE)hLoginID In: (AV_CFG_IN_ConfigF6Json *)pInParam Out: (AV_CFG_OUT_ConfigF6Json *)pOutParam;

//+ (AV_BOOL)         AV_CFG_BroadcaseDevice:  (AV_CFG_IN_ConfigF6Json *)pInParam Out: (AV_CFG_OUT_ConfigF6Json *)pOutParam;

// 查询DSP信息
+ (AV_BOOL)         AV_CFG_QueryDSPInfo: (AV_HANDLE)hLoginID Out: (AV_CFG_DSP_ENCODECAP *)pOutParam;

+ (AV_BOOL)         AV_CFG_QueryDSPAbility: (AV_HANDLE)hLoginID Out: (AV_CFG_DSP_CFG *)pOutParam;

// 查询设备能力
+ (AV_BOOL)         AV_CFG_QueryDevFuncList: (AV_HANDLE)hLoginID In: (AV_CFG_IN_DevFuncList *)pInParam Out: (AV_CFG_OUT_DevFuncList *)pOutParam;




// 新的配置查询设置接口，兼容二代三代协议

+ (AV_BOOL)         AV_CFG_GetNewDeviceConfigEx:(AV_HANDLE)hLoginID In:(AV_CFG_IN_NewConfig*)pInParam Out:(AV_CFG_OUT_NewConfig*)pOutParam;


+ (AV_BOOL)         AV_CFG_SetNewDeviceConfigEx:(AV_HANDLE)hLoginID In:(AV_CFG_IN_NewConfig*)pInParam Out:(AV_CFG_OUT_NewConfig*)pOutParam;


+ (AV_BOOL)         AV_CFG_GetConfigCaps:(AV_HANDLE)hLoginID In:(AV_CFG_IN_ConfigCaps*)pInParam Out:(AV_CFG_OUT_ConfigCaps*)pOutParam;


+ (AV_BOOL)         AV_CFG_StartSearchLanDeviceIn:(AV_CFG_IN_SearchLanDevice*)pInParam Out:(AV_CFG_OUT_SearchLanDevice*)pOutParam;


+ (AV_BOOL)         AV_CFG_StopSearchLanDevice;


// 内部使用，提供外部使用时需删除

// 获取设备SessionID
+ (AV_int32)        AV_CFG_GetSessionID: (AV_HANDLE)hLoginID;

+ (AV_int32)        AV_CFG_GetProtocolVer: (AV_HANDLE)hLoginID;

+ (AV_BOOL)         AV_CFG_GetSystemInfo: (AV_HANDLE)hLoginID  In:(AV_CFG_IN_GetSystemInfo*)pInParam Out:(AV_CFG_OUT_GetSystemInfo*)pOutParam;

+ (AV_BOOL)         AV_CFG_QuerySystemInfo:(AV_HANDLE)hLoginID In:(AV_CFG_IN_QuerySystemInfo*)pInParam Out:(AV_CFG_OUT_QuerySystemInfo*)pOutParam;

+ (AV_BOOL)         AV_CFG_QueryConfig:(AV_HANDLE)hLoginID In:(AV_CFG_IN_QueryConfig*)pInParam Out:(AV_CFG_OUT_QueryConfig*)pOutParam;

+ (AV_BOOL)         AV_CFG_SetupConfig:(AV_HANDLE)hLoginID In:(AV_CFG_IN_SetupConfig*)pInParam Out:(AV_CFG_OUT_SetupConfig*)pOutParam;


+ (AV_BOOL)         AV_CFG_SetDevicePassword:(AV_HANDLE)hLoginID In: (AV_CFG_IN_SetDevPass *)pInParam Out: (AV_CFG_OUT_SetDevPass *)pOutParam;

+ (AV_BOOL)         AV_CFG_QueryEventMessage:(AV_HANDLE)hLoginID In:(AV_CFG_IN_QueryEventMessage*)pInParam Out:(AV_CFG_OUT_QueryEventMessage*)pOutParam;

+ (AV_BOOL)         AV_CFG_SetupEventMessage:(AV_HANDLE)hLoginID In:(AV_CFG_IN_SetupEventMessage*)pInParam Out:(AV_CFG_OUT_SetupEventMessage*)pOutParam;

+ (AV_BOOL)         AV_CFG_SupportFlashlight:(AV_HANDLE)hLoginID;

+ (AV_BOOL)         AV_CFG_HasRight:(AV_HANDLE)hLoginID on:(NSString*)strRight;

+ (int)         AV_CFG_HasRightEx:(AV_HANDLE)hLoginID on:(NSString*)strRight;

//获取设备是否支持该方法
+ (AV_BOOL)         AV_CFG_QueryDeviceSupportMethod:(AV_HANDLE)hLoginID  In:(NSString*)pMethodName;

+(AV_BOOL)QuerySysSupportConfigMember:(AV_HANDLE)hLoginID In:(NSString*)pMemberName;

@end






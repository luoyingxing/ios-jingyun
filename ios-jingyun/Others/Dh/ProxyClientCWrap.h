/*************************************************************************
 ** ��Ȩ����(C), 2001-2013, �㽭�󻪼����ɷ����޹�˾.
 ** ��Ȩ����.
 **
 ** $Id$
 **
 ** ��������   : Proxy Client C�����
 **
 ** �޸���ʷ     : 2013��12��23�� zhu_long Modification
*************************************************************************/

#ifndef _DAHUA_P2P_PROXY_CLIENT_CWRAP_H_
#define _DAHUA_P2P_PROXY_CLIENT_CWRAP_H_

#include "Defs.h"

#ifdef WIN32
	typedef unsigned __int64 UINT64;
#else
	typedef unsigned long long UINT64;
#endif

#ifdef  __cplusplus
extern "C" {
#endif

///\brief ����״̬
typedef enum
{
    DHProxyStateUnauthorized,           ///< ������֤ʧ�ܣ����кŷǷ�����Կ����
    DHProxyStateForbidden,              ///< �����ֹ��½���豸ID�ظ����������ܾ���
    DHProxyStateOffline,                ///< ��������
    DHProxyStateOnline,                 ///< ��������
} DHProxyClientProxyState;

///\brief P2Pͨ��״̬
typedef enum
{
    DHP2PChannelStateInit,              ///< P2Pͨ����ʼ����
    DHP2PChannelStateActive,            ///< P2Pͨ������ͨ
    DHP2PChannelStateNonExist,          ///< P2Pͨ��������
	DHP2PChannelStateUnauthorized,      ///< P2Pͨ����Ȩʧ��
} DHProxyClientP2PChannelState;

///\brief ӳ��˿�����ͳ��
typedef struct
{
    UINT64               recvBytes;     ///< �ܽ����ֽ�KB
    UINT64               sendBytes;     ///< �ܷ����ֽ�KB

    double               curRecvRate;   ///< ��ǰ��������Kb/s
    double               curSendRate;   ///< ��ǰ��������Kb/s

    double               lostRate;      ///< ������
    double               liveTime;      ///< ͨ���ʱ��(��S)
} DHProxyClientMapPortRate;

///\brief Զ�̴�����Ϣ
typedef struct
{
    char                remoteId[64];      ///< ������ID
    char                remoteIp[64];      ///< Զ�̴���IP
    int                 remotePort;        ///< Զ�̴����˿�
} DHProxyClientRemotePortInfo;

typedef enum
{
    DHP2POptionPortGuess,                 ///< �˿ڲ²�ѡ�� ����ֵ: 0 �ر� 1 ����
    DHP2POptionSetMTU,                    ///< MTUѡ��	  ����ֵ: ����ֵ
    DHP2POptionUPNP,                      ///< UPNPѡ��	  ����ֵ: 0 �ر� 1 ����
    DHP2POptionRelay,                     ///< Relayѡ��  ����ֵ: 0 ��֧����ת 1 ֧����ת
}DHProxyOption;

///\brief ���
typedef void*	ProxyClientHandler;

///\breif ��ʼ��
///\param[in]       svraddr  ������IP(�ݲ�֧������)
///\param[in]       svrport  �������˿�
///\param[in]       passwd   ��Կ
///\return 0ʧ��/������client���
TOU_API ProxyClientHandler DHProxyClientInit(const char* svrip, int svrport, const char* passwd);

///\breif �ͷ���Դ
///\param[in]       handler  ʵ��client���
TOU_API void DHProxyClientRelease(ProxyClientHandler handler);

///\brief ͨ��Զ�̴�����ӳ��
///\param[in]       handler  ʵ��client���
///\param[in]       deviceId    Զ�̴���ID
///\param[in]       targetPort  Ŀ��˿�
///\param[in,out]   localPort   ����ӳ��˿�,Ϊ0���ڲ��������һ���˿�
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientAddPort(ProxyClientHandler handler,
		const char* deviceId, int targetPort, int *localPort);

///\brief ɾ��һ��ӳ��
///\param[in]   handler  ʵ��client���
///\param[in]   port ����ӳ��˿�
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientDelPort(ProxyClientHandler handler, int port);

///\brief ��ѯӳ��˿�����
///\param[in]   handler  ʵ��client���
///\param[in]   port ����ӳ��˿�
///\param[out]  rate ��ǰӳ������
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientQueryRate(ProxyClientHandler handler,
		int port, DHProxyClientMapPortRate *rate);

///\brief ��ѯӳ��˿ڵ�P2Pͨ��״̬
///\param[in]   handler  ʵ��client���
///\param[in]   port ����ӳ��˿�
///\param[out]  state ��ǰӳ��˿�״̬�� @see DHProxyClientP2PChannelState
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientChannelstate(ProxyClientHandler handler, int port, int *state);

///\brief ��ȡ��ǰ�����ͻ���״̬
///\param[in]   handler  ʵ��client���
///\param[out] 	state  ��ǰ�����ͻ���״̬, @see DHProxyClientProxyState
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientState(ProxyClientHandler handler, int *state);

///\brief ��ѯԶ�̴�����������״̬
///\param[in]   handler  ʵ��client���
///\param[in]   deviceId Զ�̴���ID
///\param[out] 	state ��ǰ����������״̬, @see DHProxyClientProxyState
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientServerState(ProxyClientHandler handler, const char* deviceId, int *state);

///\brief ��ѯԶ�̴�������������Ϣ
///\param[in]   handler  ʵ��client���
///\param[in]   port  ��������˿�
///\param[out]  info  Զ�̴�����������Ϣ, @see DHProxyClientRemotePortInfo
///\return 0�ɹ�/-1ʧ��
TOU_API int DHProxyClientQueryRemoetInfo(ProxyClientHandler handler, int port, DHProxyClientRemotePortInfo *info);

///\breif ��ʼ��
///\param[in]       svraddr  ������IP(�ݲ�֧������)
///\param[in]       svrport  �������˿�
///\param[in]       passwd   ��Կ
///\param[in]       username   �û���
///\return 0ʧ��/������client���
TOU_API ProxyClientHandler DHProxyClientInitWtihName(const char* svrip, int svrport, const char* passwd, const char* username);

///\brief ����Proxyѡ��
///\param[in]   handler  ʵ��client���
///\param[in] option ProxyOptionö��
///\param[in] value ���ò���ֵ
///\return 0 �ɹ�; -1 ʧ��
///\note value���� @see ProxyOption
TOU_API	int DHProxySetOption(ProxyClientHandler handler, DHProxyOption option, int value);

///\brief ��ȡ��Ӧoption��ֵ
///\param[in] handler  ʵ��client���
///\param[in] option ProxyOptionö��
///\return �������õĲ���ֵ: -1 ʧ��; >=0 option��ֵ 
TOU_API int DHProxyGetOption(ProxyClientHandler handler, DHProxyOption option);

#ifdef  __cplusplus
}
#endif

#endif /* _DAHUA_P2P_PROXY_CLIENT_CWRAP_H_ */
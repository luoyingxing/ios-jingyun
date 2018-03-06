//
//  P2PClient.h
//  netsdk_demo
//
//  Created by wu_pengzhou on 9/25/14.
//  Copyright (c) 2014 wu_pengzhou. All rights reserved.
//

#ifndef netsdk_demo_P2PClient_h
#define netsdk_demo_P2PClient_h

int p2p_connect(const char* serverIp, int serverPort, const char* serverSecret, const char* serverUserName, const char* deviceId, int devicePort, int tryCount);
bool p2p_disconnect(int local_port);
#endif

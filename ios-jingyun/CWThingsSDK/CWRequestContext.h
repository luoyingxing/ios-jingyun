//
//  CWRequestContext.h
//  CWIOSClient
//
//  Created by yeung  on 14-3-28.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#ifndef _CW_REQUEST_CONTEXT_HEADER_
#define _CW_REQUEST_CONTEXT_HEADER_

class CWRequestContext
{
public:
    CWRequestContext();
    ~CWRequestContext();
public:
    void Initialize(void* inUserData, const char* inReqID, int msg_type);
    void *GetUserData();
    const char* GetRequestID();
    unsigned int GetMessageType() {
        return messageType;
    }
private:
    void*       fUserData;
    int         messageType;
    char*       fRequestID;
};
#endif

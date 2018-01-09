//
//  CWRequestContext.m
//  CWIOSClient
//
//  Created by yeung  on 14-3-28.
//  Copyright (c) 2014年 yangjiu. All rights reserved.
//

#include "CWRequestContext.h"
#include <stdio.h>
#include <assert.h>
#include <string>

CWRequestContext::CWRequestContext()
        :fUserData(NULL)
        ,fRequestID(0)
{

}

CWRequestContext::~CWRequestContext()
{
    if (fRequestID) {
        delete []fRequestID;
        fRequestID = NULL;
    }
}

void CWRequestContext::Initialize(void *inUserData, const char* inReqID, int msg_type)
{
    fUserData = inUserData;
    messageType = msg_type;
    fRequestID = new char[strlen(inReqID) + 2];
    memset(fRequestID, 0, strlen(inReqID) + 2);
    assert(fRequestID != NULL);
    strcpy(fRequestID, inReqID);
    //fRequestID = inReqID;
}

void* CWRequestContext::GetUserData()
{
    return fUserData;
}

const char* CWRequestContext::GetRequestID()
{
    return fRequestID;
}

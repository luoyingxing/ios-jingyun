//
//  CWStreamData.m
//  CWNetSDK
//
//  Created by yangjiu on 13-9-27.
//  Copyright (c) 2013年 yangjiu. All rights reserved.
//

#import "CWDataMgr.h"

@implementation CWDataMgr
- (BOOL) initWithStream : (const char*)inStreamData StreamLen :(UInt32)inDataLen DataType:(UInt16)inDataType MsgType:(const char*)inMsgType
{
    
    if (inDataLen <= 0 || inStreamData == NULL) {
        fStreamData = NULL;
        fStreamDataLen = 0;
        fDataType = 0;
        return NO;
    }
    memset(fRequestID, 0, 64);
    memset(sMsgType, 0, 64);
    strcpy(sMsgType, inMsgType);
    
    fStreamData = (char*)malloc(inDataLen + 1);
    assert(fStreamData != NULL);
    
    memset(fStreamData, 0, inDataLen);
    //memcpy(fStreamData, inStreamData, inDataLen);
    //NSLog(@"%s------%d-----%zu\r\n", inStreamData, (unsigned int)inDataLen, strlen(inStreamData));
    strcpy(fStreamData, inStreamData);
    fStreamDataLen = inDataLen;
    fDataType = inDataType;
    return YES;
}

- (char*)getStreamData
{
    return fStreamData;
}
- (UInt16)getStreamLen
{
    return fStreamDataLen;
}

- (unsigned int)getDataType
{
    return fDataType;
}

- (char*) getMessageType
{
    return sMsgType;
}

-(void)setSource:(const char*)inSrc
{
    int len = strlen(inSrc);
    if (len > 64) return ;
    //fSource = (char*)malloc(len+1);
    memset(fSource, 0, 64);
    assert(fSource != nil);
    memcpy(fSource, inSrc, len);
}
-(char*) getSource
{
    return fSource;
}
-(void)setRequestID:(const char *)inReqID
{
    //fRequestID = inReqID;
    int len = strlen(inReqID);
    if (len > 64) return ;
    //fRequestID = (char*)malloc(len+1);
    memset(fRequestID, 0, 64);
    assert(fRequestID != nil);
    
    memcpy(fRequestID, inReqID, len);
    //strcpy(fRequestID, inReqID);
    fRequestID[len] = '\0';
}
-(char *) getRequestID
{
    return fRequestID;
}

-(void) setStatus:(int)inStatus
{
    fStatus = inStatus;
}

-(int) getStatus
{
    return fStatus;
}

- (BOOL) UninitStream
{
    if (fStreamData) {
        free(fStreamData);
        fStreamData = nil;
    }
    fStreamDataLen = 0;
    
    if (fRequestID) {
        //free(fRequestID);
        //fRequestID = nil;
    }
    
    //if (fSource) {
    //    free(fSource);
    //    fSource = nil;
    //}
    return YES;
}

- (void) addErrCount
{
    fErrCount++;
}

- (UInt32) getErrCount
{
    return fErrCount;
}
@end

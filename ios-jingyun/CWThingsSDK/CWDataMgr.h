//
//  CWStreamData.h
//  CWNetSDK
//
//  Created by yangjiu on 13-9-27.
//  Copyright (c) 2013年 yangjiu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CWDataMgr : NSObject
{
    char *fStreamData;
    char fSource[64];
    char fRequestID[64];
    int fStatus;
    UInt32       fStreamDataLen;
    UInt16       fDataType;
    
    UInt32       fErrCount;
    
    char sMsgType[64];
}

- (BOOL) initWithStream : (const char*)inStreamData StreamLen :(UInt32)inDataLen DataType:(UInt16)inDataType MsgType:(const char*)inMsgType;
- (char*)getStreamData;
- (UInt16)getStreamLen;
- (unsigned int)getDataType;
- (char*) getMessageType;
-(void)setSource:(const char*)inSrc;
-(char*) getSource;
-(void)setRequestID:(const char*)inReqID;
-(char *) getRequestID;
-(void) setStatus:(int)inStatus;
-(int) getStatus;
- (BOOL) UninitStream;

- (void) addErrCount;;
- (UInt32) getErrCount;
@end

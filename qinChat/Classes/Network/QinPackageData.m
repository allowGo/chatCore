//协议封装工具类
// Created by LEI on 15/8/10.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinPackageData.h"
#import "QinByteUtil.h"
#import "QinCommonUtil.h"
#import "NSData+QinCrypto.h"
#import "QinParser.h"

static unsigned short ackId = 0;

@implementation QinPackageData {

    NSLock *acklock;  //ack状态锁
}

IMP_SINGLETON(QinPackageData)

- (instancetype)init {
    self = [super init];
    if (self) {
        acklock = [[NSLock alloc] init];
    }
    return self;
}


- (NSData *)packageData:(QinSocketProtocol *)socketProtocol {
    
    Byte dataBytes[2] = {0};
    
    NSData *contentData = [socketProtocol.data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *enData;
    //判断是否是8号协议，只有8号才发ack
    if (socketProtocol.oType == SOCKET_RECV_CHATSENDSUCESS) {
        if(socketProtocol.ackId==0 || socketProtocol.ackId==CLIENT_ACK){
            [acklock lock];
            ackId++;
            if (ackId == 255) {
                ackId = 1;
            }
            socketProtocol.ackId = ackId;
            [acklock unlock];

        }
        DDLogDebug(@"ackId===%d",ackId);
        Byte *a = malloc(sizeof(Byte) * (2));
        memset(a, 0, 2);
        memcpy(a, dataBytes, 2);
        
        a[0] = socketProtocol.ackId;
        a[1] = socketProtocol.routingKey;
        
        NSData *ackData = [NSData dataWithBytes:a length:2];
        
        free(a);
        NSMutableData * bodyMutablData = [[NSMutableData alloc] initWithData:ackData];
        
        [bodyMutablData appendData:contentData];
        enData = [bodyMutablData AES256ParmEncryptWithKey:CRYPTO_KEY];
        
    }else{

        if( socketProtocol.oType == SOCKET_RECV_ACK ){
            Byte *ackByte = malloc(sizeof(Byte) * (1));
            memset(ackByte, 0, 1);
            ackByte[0] = socketProtocol.ackId;
            enData =[NSData dataWithBytes: ackByte length: 1];
            free(ackByte);
        }else{

            if(contentData && contentData.length>0 )
            {
                enData=[contentData AES256ParmEncryptWithKey:CRYPTO_KEY];
            } else{
                enData=contentData;
            }


        }
    }
    //协议追加长度
    int addNum = 1;
    
    if (socketProtocol.oType == SOCKET_RECV_CONNECT) {
        
        addNum = 2;
    }
    
    NSInteger sendLength = enData.length + addNum;
    NSInteger packetLength = [QinByteUtil length2Bytes:dataBytes length:sendLength];
    Byte *a = malloc(sizeof(Byte) * (packetLength + addNum));
    memset(a, 0, packetLength + addNum);
    memcpy(a, dataBytes, packetLength);
    a[packetLength] = (Byte) socketProtocol.oType;
    //协议版本不为空时，增加版本号到协议包
    if (socketProtocol.oType == SOCKET_RECV_CONNECT) {
        a[packetLength + 1] = (Byte) 4;
    }
    
    NSData *headerData = [NSData dataWithBytes:a length:(NSUInteger) (packetLength + addNum)];
    
    free(a);
    NSMutableData *sendMutablData = [[NSMutableData alloc] initWithData:headerData];
    
    [sendMutablData appendData:enData];
    
    NSLog(@"sendLength==%lu", (unsigned long)[sendMutablData length]);
    return sendMutablData;
}
@end

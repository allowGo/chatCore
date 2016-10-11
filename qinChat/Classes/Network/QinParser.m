//
// Created by LEI on 15/8/9.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinParser.h"
#import "QinByteUtil.h"
#import "QinSocketProtocol.h"
#import "QinPackageData.h"
#import "NSData+QinCrypto.h"


@implementation QinParser {
    id _parserDelegateQueue;
    dispatch_queue_t parserQueue;
}

- (id)initWithParserDelegate:(id <QinParserDelegate>)parserDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    self = [super init];
    if (self) {
        receiveBuffer = nil;
        receiveBufferLength = 0;
        self.parserDelegate = parserDelegate;
        _parserDelegateQueue = delegateQueue;
        parserQueue = dispatch_queue_create("parser.json", NULL);
        parserQueue = dispatch_get_main_queue();
    }

    return self;
}

+ (id)parserWithDelegate:(id <QinParserDelegate>)parserDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    return [[self alloc] initWithParserDelegate:parserDelegate delegateQueue:delegateQueue];
}

- (void)parse:(NSData *)data {
    dispatch_block_t block = ^{
        @autoreleasepool {
            [self parseData:data];

        }
    };
    dispatch_async(parserQueue, block);
}

- (void)parseData:(NSData *)data {

    NSMutableArray *protocolArray = [self parseData2Object:data];

    for (int i = 0; i < [protocolArray count]; i++) {
        QinSocketProtocol *socketProtocol = [protocolArray objectAtIndex:i];
        [self.parserDelegate reciveProtocol:socketProtocol];

    }

}

/**
* 解析socket协议包
* @param 	packetInfo 	包字节数据
* @param    length 数据长度
* @param    protocolArray 协议对象数组
*/
- (void)parseSocketData:(Byte *)packetInfo Datalength:(NSInteger)length protocolArray:(NSMutableArray *)protocolArray {

    //统计包大小(字节)
    NSInteger dataLength = [QinByteUtil bytes2Length:packetInfo];

    DDLogDebug(@"parseSocketData.dataLength=%ld", (long)dataLength);

    DDLogDebug(@"parseSocketData.NSDataLength=%ld", (long)length);


    Byte dataBytes[4] = {0};
    //包长度大小
    NSInteger packetLength = [QinByteUtil length2Bytes:dataBytes length:dataLength];

    DDLogDebug(@"parseSocketData.packetLength=%ld", (long)packetLength);

    if (length >= dataLength + packetLength) {

        for(int i=0;i<dataLength + packetLength;i++)
        {
//            if(i == packetLength+1) {
            if(i == packetLength) {

                QinSocketProtocol *socketProtocol = [QinSocketProtocol new];

                //  socketProtocol.ackId = packetInfo[packetLength];
                socketProtocol.ackId = packetInfo[packetLength + 1];
                socketProtocol.oType = packetInfo[packetLength];

                /**获取消息体*/
                Byte *newBytes = (Byte *) malloc(sizeof(Byte) * (dataLength - 1));

                memset(newBytes, 0, dataLength - 1);
                memcpy(newBytes, &packetInfo[packetLength + 1], dataLength - 1);
                NSData * secBodyData = [[NSData alloc] initWithBytes:newBytes length:dataLength - 1];

                free(newBytes);

                NSData *data = [secBodyData AES256ParmDecryptWithKey:CRYPTO_KEY];

                /**8号协议需要解析ack 和 routingKey*/
                if(socketProtocol.oType == SOCKET_RECV_CHATSENDSUCESS){


                    Byte *packetInfo = (Byte *) [data bytes];
                    socketProtocol.ackId  =  packetInfo[0];
                    socketProtocol.routingKey =  packetInfo[1];
                    /**获取消息体*/
                    Byte *newBytes = (Byte *) malloc(sizeof(Byte) * (data.length - 2));

                    memset(newBytes, 0, data.length - 2);
                    memcpy(newBytes, &packetInfo[2], data.length - 2);
                    NSData *bodyData = [[NSData alloc] initWithBytes:newBytes length:data.length - 2];


                    free(newBytes);
                    NSString *jsonStr = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];

                    socketProtocol.data = jsonStr;


                }else{

                    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

                    socketProtocol.data = jsonStr;
                }

                //DDLogDebug(@"parseSocketData.socketProtocol=%@", socketProtocol.description);



//                NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//                socketProtocol.data = jsonStr;

                DDLogDebug(@"socketProtocol desc:%@", [socketProtocol description]);


                [protocolArray addObject:socketProtocol];

            }

        }

        /** 判断数据包是否还有剩余包数据，有则 递归解析 */
        if ((length - dataLength - packetLength) > 0) {
            DDLogDebug(@"parseSocketData.newPacket");
            Byte *newParseInfo = &packetInfo[dataLength + packetLength];
            [self parseSocketData:newParseInfo Datalength:length - dataLength - packetLength protocolArray:protocolArray];
        }
    } else {

        if(length >0)
        {
            receiveBuffer = malloc(sizeof(Byte)*(dataLength));
            memset(receiveBuffer, 0, dataLength);
            memcpy(receiveBuffer, packetInfo, length);
            receiveBufferLength = length;
        }

        return;
    }

}

- (NSMutableArray *)parseData2Object:(NSData *)data {

    Byte *dataByte = (Byte *) [data bytes];

    NSInteger length = data.length;

    NSMutableArray *protocolArray = [[NSMutableArray alloc] init];

    /**
    * 判断buffer中是否有剩余数据包，如果有则拼包处理
    */
    if (receiveBuffer != nil) {

        DDLogDebug(@"receiveBufferLength==%ld",(long)receiveBufferLength);
        NSInteger newLength = length + receiveBufferLength;
        Byte *newParseInfo = malloc((sizeof(Byte)) * newLength);
        memset(newParseInfo, 0, newLength);
        memcpy(newParseInfo, receiveBuffer, receiveBufferLength);
        memcpy(&newParseInfo[receiveBufferLength], dataByte, length);
        free(receiveBuffer);
        receiveBuffer = nil;
        receiveBufferLength = 0;
        [self parseSocketData:newParseInfo Datalength:newLength protocolArray:protocolArray];

    } else{

        [self parseSocketData:dataByte Datalength:length protocolArray:protocolArray];
    }

    return protocolArray;
}


@end

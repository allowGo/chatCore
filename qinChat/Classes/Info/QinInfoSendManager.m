//
// Created by DengHua on 15/8/9.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinInfoSendManager.h"
#import "QinSocketProtocol.h"
#import "QinCommonUtil.h"
#import "QinPackageData.h"
#import <JSONKit-NoWarning/JSONKit.h>


@interface QinInfoSendManager () {

    dispatch_queue_t _msgBlockQueue;

    NSLock *sendlock;  //ack状态锁
}
@end

@implementation QinInfoSendManager {

}

IMP_SINGLETON(QinInfoSendManager)

- (id)init {
    self = [super init];
    if (self) {

        _msgBlockQueue = dispatch_queue_create("com.qinjian.net.msg.block", DISPATCH_QUEUE_SERIAL);
    }

    return self;
}

- (void)sendInfo:(NSDictionary *)message success:(infoSendSuccessBlock)success failer:(infoSendFailBlock)error {

    if ([message count] != 0) {
       DDLogDebug(@"QinInfoSendManager:message==%@", message);
        QinSocketProtocol *socketProtocol = [[QinSocketProtocol alloc] init];

        socketProtocol.oType = SOCKET_RECV_CHATSENDSUCESS;
        socketProtocol.ackId = CLIENT_ACK;
        socketProtocol.routingKey=CHAT_ROUTING_KEY;

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];

        socketProtocol.data = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];


        NSData *socketData = [[QinPackageData sharedInstance] packageData:socketProtocol];

        self.successblock = success;
        self.failblock = error;

        [[QinNetManager sharedInstance] sendData:socketData];
    }

}

/** 消息发送成功通知 */
- (void)sendInfoSuccess:(NSDictionary *)mesage {

    DDLogDebug(@"消息发送成功通知::%@",mesage);
    if (mesage[@"c"]) {
        int c = [mesage[@"c"] intValue];
        if (REQ_SUCCESS == c) {

            NSDictionary *data = mesage[@"d"];
            if (self.successblock) {
                dispatch_async(_msgBlockQueue, ^{
                    self.successblock(data);
                });
            }
        }
        else {
            dispatch_async(_msgBlockQueue, ^{
                self.failblock(mesage);
            });
        }
    }

}
- (void)receiveLoginSuccess:(NSDictionary *)dic {

}

- (void)receiveTokenError {

}

- (void)receiveChatProtocol:(QinChatProtocol *)chatProtocol {

}

- (void)receiveAppNotify:(QinChatProtocol *)chatProtocol {

}

@end
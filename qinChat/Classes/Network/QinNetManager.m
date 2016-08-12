//
// Created by 祥龙 on 15/9/10
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <MulticastDelegate/GCDMulticastDelegate.h>
#import <JSONKit-NoWarning/JSONKit.h>
#import <netinet/in.h>
#include <netinet/tcp.h>
#import "QinNetManager.h"
#import "QinNetConfig.h"

#import "QinSocketProtocol.h"
#import "QinPackageData.h"
#import "QinSocketPing.h"
#import "QinCommonUtil.h"
#import "QinConfigInfo.h"
#import "QinGCDTimer.h"
#import "MsgModel.h"

#define ACK_TIMEOUT 10

@interface QinNetManager () {

    GCDAsyncSocket *asyncSocket;
    GOState status;
    id _statusMulticastDelegate;

    dispatch_queue_t _netMsgQueue;
    dispatch_queue_t _socketQueue;
    QinParser *_parse;

    NSLock *socketOperatelock;  //socket状态锁
    NSMutableArray *sendArray;  //发送消息列表
    NSInteger _pingCount;//ping次数
}

@property(nonatomic, strong) QinSocketPing *ping;

@end

@implementation QinNetManager {

}

IMP_SINGLETON(QinNetManager)


- (id)init {
    self = [super init];
    if (self) {
        _pingCount = 0;
        status = GODisconnect;
        _multicastDelegate = [[GCDMulticastDelegate alloc] init];
        _statusMulticastDelegate = [[GCDMulticastDelegate alloc] init];


        _netMsgQueue = dispatch_queue_create("com.qinjian.net.msg", DISPATCH_QUEUE_SERIAL);
        _socketQueue = dispatch_queue_create("qinjian.socket", NULL);

        _parse = [QinParser parserWithDelegate:self delegateQueue:_netMsgQueue];
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_netMsgQueue socketQueue:_socketQueue];

        [asyncSocket setIPv4PreferredOverIPv6:NO];

        sendArray = [[NSMutableArray alloc] init];

        [[QinGCDTimer sharedInstance] cancelTimerWithName:@"checkACK"];
        __weak typeof(self) weakSelf = self;
        [[QinGCDTimer sharedInstance] scheduledDispatchTimerWithName:@"checkACK"
                                                        timeInterval:10
                                                               queue:nil
                                                             repeats:YES
                                                        actionOption:AbandonPreviousAction
                                                              action:^{
                                                                  [weakSelf checkTimeOut];
                                                              }];
    }

    return self;
}

- (void)initWithConfig:(QinNetConfig *)config {
    self.config = config;
}

- (BOOL)connect {
    [socketOperatelock lock];
    @try {
        DDLogInfo(@"connect start");
        NSError *error = nil;

        if (GODisconnect != status) {
            DDLogInfo(@"已连接");
            return YES;
        }

        if ([QinConfigInfo getChatServerIP] == nil || [@"" isEqualToString:[QinConfigInfo getChatServerIP]]) {
            DDLogError(@"config.address is nil");
            return NO;
        }


        if ([QinConfigInfo getChatServerPort] <= 0) {
            DDLogError(@"config.port <=0");
            return NO;
        }


        [self changeStatus:GOConnecting];

        if (asyncSocket) {
            [asyncSocket disconnect];
            asyncSocket.delegate = nil;
            asyncSocket.delegateQueue = nil;
            asyncSocket = nil;
        }
        DDLogInfo(@"reinit asyncSocket!");
        asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_netMsgQueue socketQueue:_socketQueue];
        [asyncSocket setIPv4PreferredOverIPv6:NO];

        NSString *ipAddress = [self convertHostToAddress:[QinConfigInfo getChatServerIP] port:[QinConfigInfo getChatServerPort] ];

        if (![asyncSocket connectToHost:ipAddress onPort:[QinConfigInfo getChatServerPort] error:&error]) {
            [self changeStatus:GODisconnect];
            DDLogError(@"Could not connet to %@:%d", self.config.address, self.config.port);
            return NO;
        }

        if (error) {

            DDLogError(@"socketConnectError::%@", error);
            return NO;
        }


        DDLogInfo(@"connected to server! start read.");
        [asyncSocket readDataWithTimeout:socket_timeout tag:socketTag];
    }
    @catch (NSException *e){
        DDLogError(@"QinNetManager.connect.error::%@",e);
    }
    [socketOperatelock unlock];

    return YES;
}

- (BOOL)disconnect {

    DDLogWarn(@"disconnect!");

    [socketOperatelock lock];
    [_ping killPing];
    _ping=nil;
    status = GODisconnect;
    [socketOperatelock unlock];

    dispatch_async(dispatch_get_main_queue(), ^{

        [asyncSocket disconnect];
    });
    return NO;
}

-(NSString *)convertHostToAddress:(NSString *)host port:(UInt16)port {

    NSError *err = nil;

    NSMutableArray *addresses = [GCDAsyncSocket lookupHost:host port:port error:&err];

    NSData *address4 = nil;
    NSData *address6 = nil;

    for (NSData *address in addresses)
    {
        if (!address4 && [GCDAsyncSocket isIPv4Address:address])
        {
            address4 = address;
        }
        else if (!address6 && [GCDAsyncSocket isIPv6Address:address])
        {
            address6 = address;
        }
    }

    NSString *ip;

    if (address6) {
        NSLog(@"ipv6%@",[GCDAsyncSocket hostFromAddress:address6]);
        ip = [GCDAsyncSocket hostFromAddress:address6];
    }else {
        NSLog(@"ipv4%@",[GCDAsyncSocket hostFromAddress:address4]);
        ip = [GCDAsyncSocket hostFromAddress:address4];
    }

    return ip;

}

- (BOOL)isConnected {

    return GOConnected == status;
//    return GOAuthenticated == status || GOConnected == status;
}

- (BOOL)isDisconnected {
    return GODisconnect == status;
}

- (BOOL)isAuthenticated {
    return GOAuthenticated == status;
}

- (BOOL)isConnecting {

    return GOConnecting == status;
}


- (void)addStatusDelegate:(id <QinNetManagerStatusDelegate>)statusDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_statusMulticastDelegate addDelegate:statusDelegate delegateQueue:delegateQueue];
}

- (void)removeStatusDelegate:(id <QinNetManagerStatusDelegate>)statusDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_statusMulticastDelegate removeDelegate:statusDelegate delegateQueue:delegateQueue];
}

- (void)addDataDelegate:(id <QinNetManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_multicastDelegate addDelegate:dataDelegate delegateQueue:delegateQueue];
}

- (void)removeInfoDelegate:(id <QinNetManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_multicastDelegate removeDelegate:dataDelegate delegateQueue:delegateQueue];
}

- (BOOL)sendData:(NSData *)data {
    if ([self isDisconnected]) {

        DDLogError(@"sendData.socket disconnected...");
        //这块因为reconnect不生效. 连网非常慢.加上的. 去掉再试试
        return NO;
//        [self connect];
    }
    @try {
        [socketOperatelock lock];
        MsgModel *item = [[MsgModel alloc] init];
        item.data = data;
        item.insert_time = @([QinCommonUtil makeTimestamp]);
        [sendArray addObject:item];
        [socketOperatelock unlock];
        [asyncSocket writeData:data withTimeout:sendTimeout tag:socketTag];
    }
    @catch (NSException *e){
        DDLogError(@"sendData.error::%@",e);
    }


    return YES;
}

- (void)connectSuccess:(QinSocketProtocol *)qinSocketProtocol {

    //fixme send ping
    [self sendPing:qinSocketProtocol.data];
}

- (void)sendPing:(NSString *)jsonStr {
    if (jsonStr.length <= 0)
        return;

    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *packetDict = [jsonData objectFromJSONData];
    NSInteger pt = 10;//[packetDict[@"keep_alive"] integerValue];

    if (pt <= 0)
        return;

    if (_ping == nil) {
        _ping = [[QinSocketPing alloc] init];
    }

    [_ping setupTimer:pt];

    [_ping sendPing];


}

#pragma mark - gcdAsyncSocket delegate
- (void)onSocket:(GCDAsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [socketOperatelock lock];
    status = GODisconnect;
    [socketOperatelock unlock];
    DDLogError(@"Socket disconnect with error:\n%@\n", err);
}

- (void)onSocketDidDisconnect:(GCDAsyncSocket *)sock
{
    [socketOperatelock lock];
    status = GODisconnect;
    [socketOperatelock unlock];
    DDLogError(@"Socket onSocketDidDisconnect!");
}

- (void)onSocket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{

    DDLogInfo(@"Accept new socket: %@:%u", newSocket.connectedHost, newSocket.connectedPort);
}

- (BOOL)onSocketWillConnect:(GCDAsyncSocket *)sock {

    DDLogInfo(@"onSocketWillConnect: %@:%u", sock.connectedHost, sock.connectedPort);

    return YES;
}

//连接成功
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    DDLogInfo(@"onSocket didConnectToHost:%@:%u", host,port);
    [sock performBlock:^{

        int fd = [asyncSocket socketFD];
        int on = 1;
        if (setsockopt(fd, IPPROTO_TCP, TCP_NODELAY, (char*)&on, sizeof(on)) == -1) {
            /* handle error */
            DDLogWarn(@"set TCP_NODELAY on socket");
        }

        if ([sock enableBackgroundingOnSocket])
            DDLogInfo(@"Enabled backgrounding on socket");
        else
            DDLogWarn(@"Enabling backgrounding failed!");
    }];
    [self changeStatus:(GOConnected)];

    [self login];


}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    DDLogInfo(@"didWriteDataWithTag,tag:%ld", tag);
}


//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    NSString *aStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogDebug(@"received datas is :%@", aStr);
    [_parse parse:data];
    [asyncSocket readDataWithTimeout:socket_timeout tag:socketTag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    DDLogWarn(@"socket disconnect! error:%@", err.localizedDescription);
    [self changeStatus:(GODisconnect)];
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag
                 elapsed:(NSTimeInterval)elapsed
               bytesDone:(NSUInteger)length{

    DDLogWarn(@"socket shouldTimeoutWriteWithTag! error");

}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock{

    DDLogWarn(@"socket socketDidCloseReadStream! error");
}

- (void)changeStatus:(GOState)stat {

    if (stat == GOAuthenticated && status == GODisconnect) {
        DDLogInfo(@"gostate GOAuthenticated,socket disconnect!");
        return;
    }
    [_statusMulticastDelegate GOStateChanged:stat oldState:status];
    DDLogInfo(@"gostate change to %d, oldstat:%d", stat, status);
    status = stat;
}


- (void)login {
    if(self.config.uId)
    {
        QinSocketProtocol *loginProtocol = [QinSocketProtocol new];
        loginProtocol.oType = SOCKET_RECV_CONNECT;
        loginProtocol.tag = 1;
        loginProtocol.ackId = CLIENT_ACK;
        loginProtocol.oTypeVersion = 1;

        NSDictionary *dict = @{@"userid" : self.config.uId, @"devid" : self.config.deviceId,
                @"token" : self.config.token};
        loginProtocol.data = [dict JSONString];
        DDLogInfo(@"login protocol json:%@", [dict JSONString]);
        NSData *loginData = [[QinPackageData sharedInstance] packageData:loginProtocol];

        [self sendData:loginData];
    }
}

#pragma mark - parse delegate

- (void)reciveProtocol:(QinSocketProtocol *)socketProtocol {

    if(sendArray && sendArray.count > 0){
        DDLogInfo(@" reciveProtocol sendCount==%d",sendArray.count);
        [sendArray removeObjectAtIndex:0];
    }
    switch (socketProtocol.oType) {
        case SOCKET_RECV_ACK: { //ACK

            DDLogInfo(@" reciveProtocol ACK==%d",socketProtocol.ackId);


            //            dispatch_async(_netMsgQueue, ^{
            //                [_multicastDelegate receiveAck:socketProtocol.ackId];
            //            });
        }
            break;
        case SOCKET_RECV_CONNRESP: {  //连接响应

            DDLogInfo(@"socket连接成功响应");
            if(sendArray && sendArray.count > 0){
                DDLogInfo(@" reciveProtocol sendCount==%d",sendArray.count);
                [sendArray removeAllObjects];
            }
            if(socketProtocol.data!=nil){
                NSDictionary *dictData = [socketProtocol.data objectFromJSONString];

                DDLogInfo(@"socket连接成功响应 内容::%@",dictData);
                id  stat = dictData[@"stat"];
                if(stat && [stat isKindOfClass:[NSNumber class]]){

                    NSNumber *nstat = stat;
                    if([nstat integerValue]==0){
                        [self changeStatus:GOAuthenticated];
                        //连接成功处理 重新获取配置信息、发ping包
                        [self connectSuccess:socketProtocol];

                        dispatch_async(_netMsgQueue, ^{
                            [_multicastDelegate connectAndLoginSuccess];
                        });

                    } else  if([nstat integerValue]==1){

                        [_multicastDelegate receiveTokenError:dictData];
                    }
                }else{

                    [_multicastDelegate receiveTokenError:dictData];
                }


            }else{
                [_multicastDelegate receiveTokenError:nil];
            }




        }
            break;
        case SOCKET_RECV_DISCONNECT: { //断开链接
            DDLogInfo(@"服务器通知断开Socket");

            if(socketProtocol.data!=nil){
                NSDictionary *dictData = [socketProtocol.data objectFromJSONString];
                id  stat = dictData[@"reason"];
                if(stat && [stat isKindOfClass:[NSNumber class]]){

                    NSNumber *nstat = stat;
                    if([nstat integerValue]==SOCKET_RECV_TOKEN_ERROR){
                        [_multicastDelegate receiveTokenError:dictData];
                    }
                    if([nstat integerValue]==SOCKET_RECV_OTHER_LOGIN){
                        [_multicastDelegate receiveTokenError:dictData];
                    }
                }

            }else{
                [_multicastDelegate receiveTokenError:nil];
            }

        }
            break;

        case SOCKET_RECV_PONG:  //pong
        {


            DDLogDebug(@"收到pong包...");

        }
            break;
        case SOCKET_RECV_CHATSENDSUCESS:  // 发消息
        {

            [self ackSend:socketProtocol];

            DDLogDebug(@"收到8号协议");

            DDLogDebug(@"SOCKET_RECV_CHATSENDSUCESS==%@", socketProtocol.data);

            GCDMulticastDelegateEnumerator *delegates = [_multicastDelegate delegateEnumerator];
            id cDelegate;
            while ([delegates getNextDelegate:&cDelegate delegateQueue:nil]) {

                if ([cDelegate registerRoutingKey] == socketProtocol.routingKey) {

                    dispatch_async(_netMsgQueue, ^{

                        [cDelegate receiveSocketProtocol:socketProtocol];

                    });
                } else {
                }
            }


        }
            break;

        default: {
            DDLogDebug(@"收到未处理的包  %d %@", socketProtocol.oType, socketProtocol.data);
        }
            break;
    };

}


- (void)ackSend:(QinSocketProtocol *)packetProtocol {
    /** oType为 8号协议才回ack包*/
    if (packetProtocol.oType != SOCKET_RECV_CHATSENDSUCESS) {
        return;
    }
    QinSocketProtocol *ackProtocol = [[QinSocketProtocol alloc] init];
    ackProtocol.ackId = packetProtocol.ackId;
    ackProtocol.oType = SOCKET_RECV_ACK;
    ackProtocol.data = nil;//@"ackData"; //[NSString stringWithFormat:packetProtocol.ackId];    //[[NSString alloc] init];

    NSData *packetData = [[QinPackageData sharedInstance] packageData:ackProtocol];
    [self sendData:packetData];

}

-(GCDAsyncSocket *)asyncSocket{
    return asyncSocket;
}

- (void)reconnect {

    /**断开socket*/
    [self disconnect];

    /**重新连接socket*/
    [self connect];
}

-(void)checkTimeOut{

    NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);
    NSArray *sendingArray = [NSArray arrayWithArray:sendArray];
    if(sendingArray.count > 0){
        for(MsgModel *item in sendingArray ){
            NSNumber *insertTime = item.insert_time;
            int timeOut = ([nowTime intValue] - [insertTime intValue]) / 1000;

            if (timeOut >= ACK_TIMEOUT ) {
                DDLogDebug(@"ack 超时:  %d", timeOut);
                [self reconnect];
                [sendArray removeObject:item];
                break;
            }
        }
    }

}

@end
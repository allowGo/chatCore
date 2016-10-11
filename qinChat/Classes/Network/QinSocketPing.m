//
// Created by LEI on 15/8/11.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinSocketPing.h"
#import "QinSocketProtocol.h"
#import "QinParser.h"
#import "QinCommonUtil.h"
#import "QinNetManager.h"
#import "QinPackageData.h"

#define MAX_PING_COUNT 10

@interface QinSocketPing(){

    NSInteger _pingCount;
    Boolean isTest;
}

@end
@implementation QinSocketPing
- (id)init {
    self = [super init];
    if (self) {

        _pingCount=1;
        isTest = NO;
    }

    return self;
}
//初始化timer;
- (void)setupTimer:(NSInteger)keeptime {
    if (_sendTimer) {
        [self killPing];
    }

    _keepTime = keeptime;
    _sendTimer = [NSTimer scheduledTimerWithTimeInterval:keeptime
                                                  target:self
                                                selector:@selector(sendPing)
                                                userInfo:nil
                                                 repeats:YES];
}

- (id)initWithKeepTime:(NSInteger)keeptime {
    self = [self init];
    if (self) {
        [self setupTimer:keeptime];

    }
    return self;
}

- (void)dealloc {
}


- (void)fire {
    [_sendTimer fire];
}

- (void)killPing {
    [_sendTimer invalidate];
    _sendTimer = nil;
    _keepTime = 0;
}

- (void)sendPing {
    if(_pingCount > MAX_PING_COUNT && !isTest){

        DDLogDebug(@"调整心跳包步长为30s");
        [self killPing];

        [self setupTimer:30];

        isTest = YES;
        return;
    }
    if ([QinNetManager sharedInstance].isAuthenticated) {

        DDLogDebug(@"发送心跳包[qincore]");
        QinSocketProtocol *pingProtocol = [[QinSocketProtocol alloc] init];

        pingProtocol.oType = SOCKET_SEND_PING;
        pingProtocol.data = [[NSString alloc] init];

        pingProtocol.ackId = CLIENT_ACK;
        DDLogDebug(@"%@--1", pingProtocol);
        NSData *sendData = [[QinPackageData sharedInstance] packageData:pingProtocol];
        [[QinNetManager sharedInstance] sendData:sendData];

        _pingCount++;
    }else{

        [self killPing];
    }



}
@end

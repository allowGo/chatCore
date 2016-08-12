//
// Created by DengHua on 15/8/12.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinNetReconnect.h"
#import "QinNetConfig.h"
#import "QinConfigInfo.h"


@interface QinNetReconnect () {
    dispatch_source_t reconnectTimer;
    dispatch_queue_t _netReconnectQueue;

    SCNetworkStatus _scNetworkStatus;
    
    BOOL _needNetworkMoniter;
}

@end

@implementation QinNetReconnect {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        _netReconnectQueue = dispatch_queue_create("com.kinstalk.net.reconnect", NULL);
        _reconnectDelay = DEFAULT_SOCKET_RECONNECT_DELAY;
        _reconnectTimerInterval = DEFAULT_SOCKET_RECONNECT_TIMER_INTERVAL;
    }

    return self;
}


- (void)start {
    [self setupReconnectTimer];
    [self setupNetworkMonitoring];
}

- (void)stop {
    [self teardownReconnectTimer];
    [self teardownNetworkMonitoring];
}


- (void)setupNetworkMonitoring {
    _needNetworkMoniter=true;
    if (reachability == NULL) {
        NSString *domain =@"http://www.baidu.com";  //[QinNetManager sharedInstance].config.address;
        if (domain == nil) {
            DDLogError(@"domain not exist,can't start network moniter,please check config");
        }

        reachability = [[SCNetworkReachability alloc] initWithHost:domain];
        [reachability observeReachability:^(SCNetworkStatus status) {
            DDLogDebug(@"change network status:%lu",(unsigned long)status);
            _scNetworkStatus = status;
            if(SCNetworkStatusNotReachable!=status){
                [self maybeAttemptReconnectWithSCNetworkStatus:status];
            }else{
                [[QinNetManager sharedInstance] disconnect];
            }
        }];

    }

}

- (void)teardownNetworkMonitoring {
    // 这个监控停止方法不知道怎么停下来. 用个变量表示吧. 监控就不停了.
    if (reachability) {
        _needNetworkMoniter=false;
    }
}


- (void)maybeAttemptReconnect {
    [self maybeAttemptReconnectWithSCNetworkStatus:_scNetworkStatus];
}

- (void)maybeAttemptReconnectWithSCNetworkStatus:(SCNetworkStatus)status {
    if(!_needNetworkMoniter){
        DDLogInfo(@"_needNetworkMoniter is false. stop.");
        return ;
    }
    
    if ([QinNetManager sharedInstance].isDisconnected) {

        [[QinNetManager sharedInstance] connect];

    }
//    else if(![[QinNetManager sharedInstance] isAuthenticated]){
//        DDLogInfo(@"QinNetReconnect monitoring,isAuthenticated=%d,reconnectSocket...",[[QinNetManager sharedInstance] isAuthenticated]);
//        [[QinNetManager sharedInstance] reconnect];
//    }
    else{

        DDLogInfo(@"QinNetReconnect monitoring, is connected");
    }
}

#pragma mark - reconnectTimer

- (void)setupReconnectTimer {

    if (reconnectTimer == NULL) {
        if ((_reconnectDelay <= 0.0) && (_reconnectTimerInterval <= 0.0)) {
            return;
        }
        reconnectTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _netReconnectQueue);

        dispatch_source_set_event_handler(reconnectTimer, ^{
            @autoreleasepool {

                [self maybeAttemptReconnect];

            }
        });

        dispatch_time_t startTime;
        if (_reconnectDelay > 0.0)
            startTime = dispatch_time(DISPATCH_TIME_NOW, (_reconnectDelay * NSEC_PER_SEC));
        else
            startTime = dispatch_time(DISPATCH_TIME_NOW, (_reconnectTimerInterval * NSEC_PER_SEC));

        uint64_t intervalTime;
        if (_reconnectTimerInterval > 0.0)
            intervalTime = _reconnectTimerInterval * NSEC_PER_SEC;
        else
            intervalTime = 0.0;

        dispatch_source_set_timer(reconnectTimer, startTime, intervalTime, 0.25);
        dispatch_resume(reconnectTimer);
    }
}


- (void)teardownReconnectTimer {

    if (reconnectTimer) {
        dispatch_source_cancel(reconnectTimer);
        reconnectTimer = NULL;
    }
}

#pragma mark - netmanager status delegate

- (void)GOStateChanged:(GOState)newState oldState:(GOState)oldState {


}




@end
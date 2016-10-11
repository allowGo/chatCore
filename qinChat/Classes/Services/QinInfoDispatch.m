//
// Created by LEI on 15/8/5.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinInfoDispatch.h"
#import "QinHttpProtocol.h"
#import "QinInfo.h"
#import "QinCommonUtil.h"
#import "QinInfoDispatchDelegate.h"
#import "QinChatProtocol.h"
#import "YYKit.h"
#import "MsgModel.h"
@implementation QinInfoDispatch {

}
IMP_SINGLETON(QinInfoDispatch)


- (void)dealloc {
}

- (void)receiveChatProtocol:(QinChatProtocol *)socketProtocol {
    QinInfo *info = [[QinInfo alloc] init];
    info.infoType = INFO_CHAT;
    id msg = socketProtocol.data[@"msg"];
    if (msg != nil) {
        DDLogDebug(@"QinfoDispatch ,msg:%@", msg);
        info.data = msg;
        
        MsgModel *msgModel = [MsgModel modelWithJSON:msg];
        [multicastDelegate didReceiveInfo:msgModel];
    }
}


- (void)addDelegate:(id)delegate {
    [super addDelegate:delegate];
}

#pragma mark - connect error

- (void)receiveLoginSuccess:(NSDictionary *)dic {
    DDLogDebug(@"QinCore socket 登录成功");
    [multicastDelegate didReceiveSocketLoginSuccess:nil];
}

- (void)receiveTokenError:(NSString *)msg {

    DDLogError(@"socket error::%@",msg);
    [multicastDelegate didReceiveTokenError:msg];
}

- (void)receiveAppNotify:(QinChatProtocol *)chatProtocol {

    QinInfo *info = [[QinInfo alloc] init];
    info.infoType = INFO_NOTIFY;
    info.data = chatProtocol.data;
    [multicastDelegate qinDidReceiveAppNotify:info];
}

- (void)sendInfoSuccess:(NSDictionary *)dict {

}

@end

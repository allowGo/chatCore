//
// Created by 祥龙 on 15/9/22.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinNetManager.h"
#import "QinBaseService.h"

@class QinInfo;
@class QinChatProtocol;

@protocol QinChatProcessorDelegate

/**
*  socket连接成功
*/
- (void)receiveLoginSuccess:(NSDictionary *)dic;

/**
* token错误
*/
-(void)receiveTokenError:(NSString *)msg;

/**
*收到消息返回QinChatProtocol
*/
- (void)receiveChatProtocol:(QinChatProtocol *)chatProtocol;

/**
* 消息发送成功回包
*/
- (void)sendInfoSuccess:(NSDictionary *)dict;

/**
* 应用内通知消息处理
*/
- (void)receiveAppNotify:(QinChatProtocol *)chatProtocol;


@end
@interface QinChatProcessor : QinBaseService <QinNetManagerDataDelegate>

DEF_SINGLETON(QinChatProcessor)
@end
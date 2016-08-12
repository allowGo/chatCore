//
// Created by 祥龙 on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinBaseService.h"
#import "QinServiceConstants.h"
#import "QinChatArg.h"
#import "QinInfoDispatchDelegate.h"
#import "QinCoreEnum.h"

@class QinMessage;

@protocol QinMessageDelegate

//@optional
/**
*  登录成功
*
*/
@optional
- (void)didSocketLoginSuccess:(NSDictionary *)dic;

/**
* token失效
*/
@optional
-(void)didTokenError:(NSString *)msg;


/**
*  拉取新消息通知
*dispatch_get_main_queue
*/
@optional
- (void)didNewsMessageNotify:(NSDictionary *)dic;

/**
*  收到应用内通知
*dispatch_get_main_queue
*/
@optional
- (void)didSocketAppNotify:(NSDictionary *)info;

/**
* 收到消息
 * dispatch_get_main_queue
*/
@optional
- (void)didReceiveMessage:(QinMessage *)message;

/**
 * 历史消息列表
 * dispatch_get_main_queue
 */
@optional
- (void)didReceiveOldMessages:(NSArray *)qinMessageArray;
/**
 * 历史消息列表 第一次
 * dispatch_get_main_queue
 */
@optional
- (void)didReceiveFristOldMessages:(NSArray*)qinMessageArray;

/**
* 发送成功，收到ci回包
*/
@optional
- (void)didSendSuccess:(NSNumber *)ci seq:(NSNumber *)seq;

/**
* 发送失败，收到ci回包
*/
@optional
- (void)didSendError:(NSNumber *)ci seq:(NSNumber *)seq;

/**
* 非好友提示通知消息
*/
@optional
- (void)didSendErrorNotFriend:(QinMessage *)message;

@end

@class QinMessage;
@class QinHttpProtocol;
@class QinChatConfig;
@class MsgModel;
@class RecentMsgUserModel;
@class QinNetReconnect;

@interface QinChatService : QinBaseService <QinInfoDispatchDelegate>

DEF_SINGLETON(QinChatService)

/** 发送消息Array*/
@property(strong, nonatomic) NSMutableArray *sendMessageArray;
@property(strong, nonatomic)QinChatConfig *chatConfig;
#pragma mark - 初始化方法

/**
* init chat.
*/
- (void)initWithConfig:(QinChatConfig *)chatConfig reConnect:(QinNetReconnect *)reConnect;

#pragma mark - 消息

/**
* 发消息
*/
- (int)sendMessage:(QinMessage *)message;

/**
* 发送临时消息
*/
- (int)sendTempMessage:(QinMessage *)message;


/**
* 重新发消息. 用于界面失败时,点击重新发送,调用的接口
*/
- (void)reSendMessage:(QinChatArg *)arg mesageSeq:(NSInteger)seq;

/**
* 获取聊天记录
*/
- (void)getOldMessage:(QinChatArg *)chatArg messageSeq:(NSInteger)seq count:(NSInteger)count;
/**
* 删除消息
*/
- (void)deleteMessage:(QinChatArg *)arg messageSeq:(NSInteger)seq;

/**
 * 保存草稿消息,msgDel=QinMessage_TMP 为草稿
 */
-(NSInteger)saveTempMessage:(QinMessage *)message;
/**
 * 保存本地消息
 */
-(void)saveLocalMessage:(QinMessage *)message;

#pragma mark - 最近联系人 群组列表、未读数处理

/**
* 获取最近的联系人与未读数
*/
- (void)getRecentMsgUser:(void (^)(NSArray *groupArray))success;

/**
* 修改联系人status 状态
*/
-(void)updateRecentMsgUserStatus:(QinChatArg *)arg status:(RECENTUSER_STATUS)status;


/**
* 清除未读数
*/
- (void)removeUnRead:(QinChatArg *)arg;

/**
* 删除最新联系人
*/
- (void)delRecentMsgUser:(QinChatArg *)arg;

/**
*根据gid,toid,to_type获取未读数
*/
- (int)getUnRead:(QinChatArg *)arg;

/**
 *所有消息未读数
 */
- (int)getUnReadSumCount;
/**
* 更新未读数，有则更新，无则添加(测试使用)
*/
-(void) saveRecentUser:(RecentMsgUserModel *)msgModel status:(UNREAD_TYPE)status;
/**
 * 获取最新历史消息
 */
- (void)getNewMessagesVersion2;

#pragma mark - socket disconnect

/**
 * 断开socket连接
 */
-(void) socketDisconnect;
/**
 * 连接socket  socketConnect
 */
- (void)socketConnect;

- (int)makeMessageToRead:(QinChatArg *)arg messageSeq:(NSInteger)seq bigType:(NSInteger)bigType ;

@end
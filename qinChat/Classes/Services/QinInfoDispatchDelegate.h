/*!
 @header QinInfoDispatchDelegate.h
 @abstract 
 @author kinstalk.com
 @version 1.00 15/8/16
 Created by DengHua on 15/8/16.
*/

#import <Foundation/Foundation.h>

@class QinInfo;
@class MsgModel;

@protocol QinInfoDispatchDelegate

/**
*  socket连接成功
*/
- (void)didReceiveSocketLoginSuccess:(NSDictionary *)dic;

/**
* token错误
*/
-(void)didReceiveTokenError:(NSString *)msg;

/**
* 收到聊天消息
*/
- (void)didReceiveInfo:(MsgModel *)msg;

/**
* 应用内通知消息处理
*/
- (void)qinDidReceiveAppNotify:(QinInfo *)info;


@end
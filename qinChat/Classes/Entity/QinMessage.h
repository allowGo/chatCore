//消息实体类，用来包装消息
// Created by DengHua on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinMessageBody.h"
#import "QinCoreEnum.h"

@interface QinMessage : NSObject

/**
* 用户id，或者群组ID， 代表发出去的消息是个人聊天 还是群组聊天
*/
@property(nonatomic, strong) NSNumber *toId;
@property(nonatomic, strong) NSNumber* gid;

/**
* 是否群组， 如果为YES， 则ID属性为群组ID。 如果为NO，ID属性为用户ID
*/
@property(nonatomic, assign) QinMessage_TYPE toType;
/**
 *  大类型,普通、阅后即焚
 */
@property(nonatomic,assign) QinMessage_BIGTYPE bigType;
/**
 *  消息的投放状态
 */
@property(nonatomic,assign) QinMessage_SendStateTYPE msgState;
/**
 *  消息体
 */
@property(nonatomic, strong) QinMessageBody *messageBody;




@end
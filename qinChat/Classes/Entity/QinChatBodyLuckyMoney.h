//
// Created by LEI on 16/4/8.
//

#import <Foundation/Foundation.h>
#import "QinChatBody.h"


@interface QinChatBodyLuckyMoney : NSObject
/**
 *  消息内容
 */
@property(nonatomic, strong) NSString *content;
/**
 * 红包id
 */
@property(nonatomic, strong) NSString *transNo;
/**
 * 红包发送人Id
 */
@property(nonatomic, strong) NSNumber *senderUid;
/**
 * 红包状态
 */
@property(nonatomic, assign) Boolean luckyMoneyStatus;
@end

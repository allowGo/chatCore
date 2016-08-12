//
// Created by DengHua on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinChatBody.h"

#import "QinCoreEnum.h"

@interface QinChatBodyText : NSObject <QinChatBody>

/**
 *  消息内容
 */
@property(nonatomic, strong) NSString *text;
/**
 * 红包id
 */
//@property(nonatomic, strong) NSString *luckyMoneyId;
/**
 *  at到的人
 */
@property(nonatomic,strong)NSArray* at;

@end
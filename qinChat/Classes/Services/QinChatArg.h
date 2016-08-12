//
// Created by DengHua on 15/8/15.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "QinCoreEnum.h"
#import "QinServiceConstants.h"
@interface QinChatArg : NSObject

@property(nonatomic, assign) NSInteger toId;
@property(nonatomic, assign) NSInteger groupId;
@property(nonatomic, assign) NSInteger toType;
@property(nonatomic, assign) NSInteger myId;
@property(nonatomic, assign) NSInteger isDelLocal;
@property(nonatomic, assign) getOldMessage_TYPE getType;
@property (nonatomic, assign) RECENT_CONTACTS_BUSINESS_TYPE businessType; //业务类型

+ (QinChatArg *)buildSingle:(NSInteger)toId;

+ (QinChatArg *)buildGroup:(NSInteger)groupId;

+ (QinChatArg *)buildSingleGroup:(NSInteger)groupId toId:(NSInteger)toId;
@end


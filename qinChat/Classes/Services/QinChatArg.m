//
// Created by DengHua on 15/8/15.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinChatArg.h"
#import "QinServiceConstants.h"
#import "QinCommonUtil.h"

@implementation QinChatArg

+ (QinChatArg *)buildSingle:(NSInteger)toId {
    QinChatArg *arg = [QinChatArg new];
    arg.toId = toId;
//    arg.groupId = STEWARD_GROUP_ID;
    arg.toType = MESSAGE_TO_TYPE_P2P_STEWARD;
    return arg;
}


+ (QinChatArg *)buildGroup:(NSInteger)groupId {

    QinChatArg *arg = [QinChatArg new];
    arg.toType = MESSAGE_TO_TYPE_GROUP_TYPE;
    arg.groupId = groupId;
    arg.toId = groupId;
    return arg;
}

+ (QinChatArg *)buildSingleGroup:(NSInteger)groupId toId:(NSInteger)toId {

    QinChatArg *arg = [QinChatArg new];
    arg.toType = MESSAGE_TO_TYPE_P2P_TYPE;
    arg.groupId = groupId;
    arg.toId = toId;
    return arg;
}

@end

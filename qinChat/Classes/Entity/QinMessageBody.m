//
// Created by DengHua on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinMessageBody.h"
#import "QinChatBodyLuckyMoney.h"
#import "QinChatBodyNotify.h"


@implementation QinMessageBody

- (id)init
{
    self = [super init];
    if( self )
    {
        
        _chatBodyText = [[QinChatBodyText alloc] init];
        _chatBodyHandWrite = [[QinChatBodyHandWrite alloc] init];
        _chatBodyAudio = [[QinChatBodyAudio alloc] init];
        _chatBodyImage = [[QinChatBodyImage alloc] init];
        _chatBodyGps = [[QinChatBodyGps alloc] init];
        _chatBodySmailVideo = [[QinChatBodySmallVideo alloc] init];
        _chatBodyLuckyMoney = [[QinChatBodyLuckyMoney alloc] init];

    }
    return self;
}

@end
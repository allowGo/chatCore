//
//  QinChatBodySmallVideo.m
//  QinCore
//
//  Created by LEI on 15/12/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import "QinChatBodySmallVideo.h"

@implementation QinChatBodySmallVideo
- (id)init
{
    self = [super init];
    if( self )
    {

        _videoContent = [[QinChatSmallVideoContent alloc] init];
    }
    return self;
}
@end

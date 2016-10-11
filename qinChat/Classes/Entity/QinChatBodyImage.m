//
//  QinChatBodyImage.m
//  QinCore
//
//  Created by LEI on 15/8/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import "QinChatBodyImage.h"

@implementation QinChatBodyImage

- (id)init
{
    self = [super init];
    if( self )
    {
        _imageInfo = [[QinChatBodyHandWrite alloc] init];
        _audioInfo  = [[QinChatBodyAudio alloc] init];
    }
    
    return self;
}

@end

//
// Created by DengHua on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <objc/runtime.h>
#import "QinMessage.h"
#import "QinMessageBody.h"


@implementation QinMessage

- (id)init
{
    self = [super init];
    if( self )
    {
        _toType = QinMessage_TYPE_UNDEF;
        
        _messageBody = [[QinMessageBody alloc] init];
    }
    return self;
}


@end
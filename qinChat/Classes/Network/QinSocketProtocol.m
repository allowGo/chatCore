//
// Created by LEI on 15/8/10.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinSocketProtocol.h"


@implementation QinSocketProtocol {

}

- (id)init {
    self = [super init];
    if (self) {

    }

    _oTypeVersion = 0;
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    NSString *printStr = [NSString stringWithFormat:@"\nvalue: ackId = %d\n routingKey = %d\n oType = %d\n oTypeVersion=%d\n data=%@",
                                                    _ackId,_routingKey, _oType, _oTypeVersion, _data];
    [description appendString:printStr];
    [description appendString:@"\n>"];
    return description;
}


@end

//协议封装工具类
// Created by LEI on 15/8/10.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinSocketProtocol.h"
#import "QinServiceConstants.h"


@interface QinPackageData : NSObject

DEF_SINGLETON(QinPackageData)

/**
* 协议包封装
*
*/
- (NSData *)packageData:(QinSocketProtocol *)socketProtocol;
@end

//
// Created by LEI on 15/9/22.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinParser.h"


@interface QinChatProtocol : NSObject

//业务协议类型
@property(nonatomic, assign) ChatReceiveTYPE type;

//数据
@property(nonatomic, strong) NSDictionary *data;

//tag socketTag
@property(nonatomic, assign) int c;

@property(nonatomic, strong) NSString * msg;

@end

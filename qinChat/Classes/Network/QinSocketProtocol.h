//
// Created by LEI on 15/8/10.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QinSocketProtocol : NSObject
@property(nonatomic, assign) int ackId;
//ack序号
@property(nonatomic, assign) int oType;
//协议名称
@property(nonatomic, assign) int oTypeVersion;
//协议版本
@property(nonatomic, strong) NSString *data; //数据

//tag socketTag
@property(nonatomic, assign) int tag;


//routingKey
@property(nonatomic, assign) int routingKey;


@end

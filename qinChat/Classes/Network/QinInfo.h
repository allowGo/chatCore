//
// Created by 祥龙 on 15/8/13.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QinInfo : NSObject


@property(nonatomic, strong) NSDictionary *data;

//时间戳，服务端返回本次拉取实际开始的时间戳
@property(nonatomic, strong) NSNumber *lastpos;


//信息类型
@property(nonatomic, assign) int infoType;
@end
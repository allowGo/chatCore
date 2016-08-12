//
// Created by 祥龙 on 15/8/11.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QinSocketPing : NSObject
//等待时间
@property(readonly, nonatomic) NSInteger keepTime;
//等待时间
@property(strong, nonatomic) NSTimer *sendTimer;

//初始化
- (id)initWithKeepTime:(NSInteger)keepTime;

- (void)sendPing;

//停止Ping包
- (void)killPing;

//设置timer的时长
- (void)setupTimer:(NSInteger)keepTime;

//立即发送Ping包
- (void)fire;
@end
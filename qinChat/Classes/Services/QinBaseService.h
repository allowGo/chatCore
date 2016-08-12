//
// Created by DengHua on 15/8/5.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QinChatConfig;


@interface QinBaseService : NSObject {
    id multicastDelegate;
    dispatch_queue_t serviceQueue;

     void *queueKey;

}


// 添加代理指定的queue
- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

// 添加代理到dispatch_get_main_queue，即回调函数在主线程执行
- (void)addDelegate:(id)delegate;

// 清除指定的代理对象
- (void)removeDelegate:(id)delegate;

-(id)getServiceQueue;

//TODO 进入后台

//TODO 进入前台



@end
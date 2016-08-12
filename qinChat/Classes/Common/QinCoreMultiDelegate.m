//
// Created by DengHua on 15/8/9.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "MulticastDelegate/GCDMulticastDelegate.h"
#import "QinCoreMultiDelegate.h"

@implementation QinCoreMultiDelegate

- (id)init {
    if (self = [super init]) {
        _multicastDelegate = [[GCDMulticastDelegate alloc] init];
    }
    return self;
}

- (void)addDelegate:(id)delegate {
    [_multicastDelegate addDelegate:delegate
                      delegateQueue:dispatch_get_main_queue()];
}

- (void)addDelegate:(id)delegate
      delegateQueue:(dispatch_queue_t)delegateQueue; {
    [_multicastDelegate addDelegate:delegate
                      delegateQueue:delegateQueue];
}

- (void)removeDelegate:(id)delegate
         delegateQueue:(dispatch_queue_t)delegateQueue {
    [_multicastDelegate removeDelegate:delegate
                         delegateQueue:delegateQueue];
}

- (void)removeDelegate:(id)delegate {
    [_multicastDelegate removeDelegate:delegate];
}

- (void)removeAllDelegates {
    [_multicastDelegate removeAllDelegates];
}

@end
//
// Created by DengHua on 15/8/5.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "MulticastDelegate/GCDMulticastDelegate.h"
#import "QinBaseService.h"
#import "QinChatConfig.h"


@implementation QinBaseService {

}

- (id)init {
    if ((self = [super init])) {


        multicastDelegate = [[GCDMulticastDelegate alloc] init];

        NSString *queueName = NSStringFromClass([self class]);

        queueKey= (void *) [queueName UTF8String];


#if isUnitTest
        serviceQueue = dispatch_get_main_queue();
#else
        serviceQueue = dispatch_queue_create([queueName UTF8String], NULL);
        dispatch_queue_set_specific(serviceQueue, queueKey, &queueKey, NULL);

#endif

    }
    return self;
}

- (void)dealloc {
#if NEEDS_DISPATCH_RETAIN_RELEASE
    dispatch_release(serviceQueue);
#endif
}


#pragma mark - add and remove delegate

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {

    if (delegate == nil)return;

    if (delegateQueue == nil) {
        delegateQueue = serviceQueue;
    }

    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };


    dispatch_async(delegateQueue, block);
}

- (void)addDelegate:(id)delegate {
    [self addDelegate:delegate delegateQueue:serviceQueue];
}

- (void)removeDelegate:(id)delegate {
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate];
    };

    dispatch_sync(serviceQueue, block);
}
-(id)getServiceQueue{

    return serviceQueue;
}

@end
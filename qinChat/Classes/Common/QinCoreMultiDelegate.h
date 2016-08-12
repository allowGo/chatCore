/*!
 @header QinCoreMultiDelegate.h
 @abstract 客户端的mutligate
 @author kinstalk.com
 @version 1.00 15/8/9
 Created by DengHua on 15/8/9.
*/

#import <Foundation/Foundation.h>


@interface QinCoreMultiDelegate : NSObject
{
    id _multicastDelegate;
}

- (void)addDelegate:(id)delegate;

- (void)addDelegate:(id)delegate
      delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate
         delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeDelegate:(id)delegate;

- (void)removeAllDelegates;

@end
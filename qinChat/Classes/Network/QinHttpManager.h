//
// Created by LEI on 15/8/13.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinServiceConstants.h"

@class QinHttpProtocol;

@protocol AFURLRequestSerialization;
@class AFHTTPRequestSerializer;
@class AFURLSessionManager;

/**
 * 信息处理相关
 */
@protocol QinHttpManagerDataDelegate


//收到http协议实体
- (void)receiveHttpProtocol:(QinHttpProtocol *)httpData;

@end

@interface QinHttpManager : NSObject

DEF_SINGLETON(QinHttpManager)


- (void)addDataDelegate:(id <QinHttpManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeInfoDelegate:(id <QinHttpManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue;


@property(nonatomic, strong) dispatch_queue_t upProtolQueue;

//@property(nonatomic, strong) NSMutableURLRequest *request;
@property(nonatomic, strong) AFURLSessionManager *manager;
@property(nonatomic, strong) AFHTTPRequestSerializer <AFURLRequestSerialization> *requestSerializer;


//http请求
- (void )getHttpRequest:(QinHttpProtocol *)httpProtocol success:(void (^)(id *operation, QinHttpProtocol *httpProtocol))success
                failure:(void (^)(id *operation, NSString *error))failure;

/**
 * 上传文件
 */
-(void) uploadFie:(QinHttpProtocol *)httpProtocol success:(void (^)(QinHttpProtocol *aProtocol))success
          failure:(void (^)( NSError *error))failure;
@end

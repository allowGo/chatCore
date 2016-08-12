//
// Created by 祥龙 on 15/8/13.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <AFNetworking/AFURLSessionManager.h>
//#import <HappyDNS/QNDnsManager.h>
//#import <HappyDNS/QNDnspodFree.h>
#import "QinChatConfig.h"
#import "QinHttpManager.h"
#import "QinHttpProtocol.h"
#import "GCDMulticastDelegate.h"
#import "JSONKit.h"
#import "NSObject+MJKeyValue.h"
//#import "QJNSURLProtocol.h"
#import "QinChatService.h"
#import "AFHTTPSessionManager.h"


#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
#define APP_CODE_WITHU @"10002"

@interface QinHttpManager () {

    id _multicastDelegate;

    QinHttpProtocol *_httpProtocol;
}
@end

@implementation QinHttpManager {

}
//重试3次
#define knumberOfRetryAttempts 3
#define OBJ_IS_NIL(s) (s==nil || [NSNull isEqual:s] || [s class]==nil || [@"<null>" isEqualToString:[s description]] ||[@"(null)" isEqualToString:[s description]])

IMP_SINGLETON(QinHttpManager)

- (void)initHttps {

    //init https
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    _manager.securityPolicy = securityPolicy;
}

- (id)init {
    self = [super init];
    if (self) {
        _multicastDelegate = [[GCDMulticastDelegate alloc] init];
//        _manager = [AFHTTPSessionManager manager];
        //设置配置信息
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];

        //统一设置请求超时
        config.timeoutIntervalForRequest = 15.0;
        config.timeoutIntervalForResource=20.0;
        config.HTTPMaximumConnectionsPerHost=5;

        _manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:config];

        _requestSerializer = [AFHTTPRequestSerializer serializer];

        _upProtolQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

        //        _request = nil;

        [self initHttps];
    }
    return self;
}


- (void)addDataDelegate:(id <QinHttpManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_multicastDelegate addDelegate:dataDelegate delegateQueue:delegateQueue];
}

- (void)removeInfoDelegate:(id <QinHttpManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue {
    [_multicastDelegate removeDelegate:dataDelegate delegateQueue:delegateQueue];
}
//static QNDnsManager *dns=nil;
//BOOL useIpAddress;
- (NSMutableURLRequest *)createRequest:(QinHttpProtocol *)httpProtocol {
    _httpProtocol = httpProtocol;
    NSString *method = httpProtocol.method;
    NSString *url = httpProtocol.requestUrl;
    NSMutableURLRequest *_request = [self.requestSerializer requestWithMethod:method
                                                                    URLString:url
                                                                   parameters:httpProtocol.param
                                                                        error:nil];
    if ([QinChatService sharedInstance].chatConfig && [[QinChatService sharedInstance].chatConfig.token isKindOfClass:[NSString class]]) {

        [_request setValue:[QinChatService sharedInstance].chatConfig.token forHTTPHeaderField:@"token"];
    }

    if ([QinChatService sharedInstance].chatConfig && [[QinChatService sharedInstance].chatConfig.deviceId isKindOfClass:[NSString class]]) {

        [_request setValue:[QinChatService sharedInstance].chatConfig.deviceId forHTTPHeaderField:@"deviceId"];
    }

    [_request addValue:@"sapp.0100.160402" forHTTPHeaderField:@"channelId"];
    [_request addValue:APP_CODE_WITHU forHTTPHeaderField:@"appid"];
    [_request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    
    if(httpProtocol.formType && httpProtocol.formType == QinHttpProtocol_FROMTYPE_BATCH){
        
        if(httpProtocol.param && [httpProtocol.param isKindOfClass:[NSString class]])
        {
             [_request setHTTPBody:[httpProtocol.param dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    


    return _request;
}


- (void)getHttpRequest:(QinHttpProtocol *)httpProtocol success:(void (^)(id *operation, QinHttpProtocol *httpProtocol))success failure:(void (^)(id *operation, NSString *error))failure {

    NSURLRequest *request = [self createRequest:httpProtocol];

    [[_manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {

        if (!OBJ_IS_NIL(responseObject)) {

            if ([responseObject isKindOfClass:[NSDictionary class]]) {

                if (!OBJ_IS_NIL([responseObject objectForKey:@"c"]) && [[responseObject objectForKey:@"c"] integerValue] == 0) {
                    DDLogDebug(@"Request获取成功");

                    id obj = [responseObject objectForKey:@"d"];
                    if (obj && [obj isKindOfClass:[NSDictionary class]]) {

                        _httpProtocol.data = obj;
                        if(success)
                            success(nil, _httpProtocol);
                    } else if ([[responseObject objectForKey:@"c"] intValue] == 0) {

                        _httpProtocol.data = nil;
                        if(success)
                            success(nil, _httpProtocol);
                    } else {
                        if(failure)
                            failure(nil, [responseObject objectForKey:@"m"]);
                    }


                }else{
                    if(failure)
                        failure(nil, [responseObject objectForKey:@"m"]);
                }

            }else{
                if([responseObject isKindOfClass:[NSData class]])
                {
                    if(success)
                        success(nil, _httpProtocol);
                }else{
                    if(failure)
                        failure(nil, @"请求解析失败");
                }
            }

        }else if(error){

            if (error.code == -1005) {

            } else {
                DDLogDebug(@"Error during connection: %@", error.description);
                if(failure)
                    failure(nil, @"请求失败");
            }

            if (failure)
                failure(nil, @"请求失败");
        }


    }] resume];

}

- (void)uploadFie:(QinHttpProtocol *)httpProtocol success:(void (^)(QinHttpProtocol *aProtocol))success failure:(void (^)(NSError *error))failure {
    dispatch_block_t uploadBlock = ^{

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        if (iOS8) {
//            config.protocolClasses = @[[QJNSURLProtocol class]];
//        }
        // formData是遵守了AFMultipartFormData的对象
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy.validatesDomainName = NO;

        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        ((AFHTTPResponseSerializer *) manager.responseSerializer).acceptableContentTypes = [NSSet setWithObject:@"text/html"];

        [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession *session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing *credential) {
            return NSURLSessionAuthChallengePerformDefaultHandling;
        }];
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:httpProtocol.requestUrl parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData> formData) {


            if([httpProtocol.filePath rangeOfString:@"HDW_CH_3001_"].location == NSNotFound)
            {
                if(![[httpProtocol.filePath lowercaseString] hasSuffix:@"gif"])
                {
                    UIImage *image = [UIImage imageWithContentsOfFile:httpProtocol.filePath];
                    //图片压缩至100kb以内
                    NSData * data = nil;
                    NSString *filePath = httpProtocol.filePath;
                    if(image && [image isKindOfClass:[UIImage class]])
                    {
                        data = UIImageJPEGRepresentation(image, 1.0);
                        for (float i = 1.0; [data length] > 202400 && i > 0.0; i = i-0.1) {
                            data = UIImageJPEGRepresentation(image, i);
                        }

                        [data writeToFile:filePath atomically:YES];
                    }
                }
            }

            [formData appendPartWithFileURL:[NSURL fileURLWithPath:httpProtocol.filePath] name:@"file1" error:nil];
        }                                                                                             error:nil];


        if ([QinChatService sharedInstance].chatConfig && [[QinChatService sharedInstance].chatConfig.token isKindOfClass:[NSString class]]) {

            [request setValue:[QinChatService sharedInstance].chatConfig.token forHTTPHeaderField:@"token"];
        }

        if(!OBJ_IS_NIL(httpProtocol.param)){

            if([httpProtocol.param isKindOfClass:[NSDictionary class]]){

                NSDictionary *dict=httpProtocol.param;
                if(!OBJ_IS_NIL([dict objectForKey:@"gid"])){
                    [request addValue:[[dict objectForKey:@"gid"] stringValue] forHTTPHeaderField:@"gid"];
                }
            }
        }

        if ([QinChatService sharedInstance].chatConfig && [[QinChatService sharedInstance].chatConfig.deviceId isKindOfClass:[NSString class]]) {

            [request addValue:[QinChatService sharedInstance].chatConfig.deviceId forHTTPHeaderField:@"deviceId"];
        }else{

            [request addValue:httpProtocol.token forHTTPHeaderField:@"token"];
            [request addValue:httpProtocol.deviceId forHTTPHeaderField:@"deviceId"];
        }
        [request addValue:@"sapp.0100.160402" forHTTPHeaderField:@"channelId"];
        [request addValue:APP_CODE_WITHU forHTTPHeaderField:@"appid"];
        [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];


        NSProgress *progress = nil;


        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            DDLogDebug(@"[%@]%@\nHeader:%@\nBody:%@", request.HTTPMethod, request.URL, request.allHTTPHeaderFields, [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
            if (error) {
                DDLogError(@"error : %@", error);
                if (failure) {
                    if (httpProtocol.ci) {

                        NSMutableDictionary *reasonDict = nil;

                        if (error.userInfo && [error.userInfo isKindOfClass:[NSDictionary class]]) {
                            reasonDict = [NSMutableDictionary dictionaryWithDictionary:error.userInfo];
                        }
                        else {
                            reasonDict = [NSMutableDictionary new];
                        }

                        reasonDict[@"ci"] = @(httpProtocol.ci);
                        if (httpProtocol.seq)
                            reasonDict[@"seq"] = httpProtocol.seq;

                        NSError *errorr = [NSError errorWithDomain:@"" code:error.code userInfo:@{@"reason" : reasonDict}];
                        failure(errorr);

                    } else {
                        failure(error);
                    }
                }

            } else {
                if (success) {
                    //去皮
                    id object = [self transitionData:responseObject httpProtocol:httpProtocol];

                    if (object) {
                        if ([object isKindOfClass:[NSError class]]) {
                            failure(error);
                        } else {
                            httpProtocol.data = object;
                            DDLogDebug(@"uploadFie.ci===%ld", httpProtocol.ci);
                            success(httpProtocol);
                        }
                    }
#pragma clang diagnostic pop
                }
            }
        }];

        [uploadTask resume];

    };
    dispatch_async(_upProtolQueue, uploadBlock);
}


- (id)transitionData:(NSData *)data httpProtocol:(QinHttpProtocol *)httpProtocol {
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonString = [self removeUnescapedCharacter:jsonString];

    if (jsonString.length > 0) {

        NSDictionary *dict = [jsonString objectFromJSONString];

        NSString *code = [dict objectForKey:@"c"];
        if (code && 20020 == [code intValue]) {
            //FIXME token失效
            //  [[NSNotificationCenter defaultCenter] postNotificationName:AgainLoginNotification object:nil];
        }
        else if (code && 0 == [code intValue]) {
            id responseObject = [dict objectForKey:@"d"];
            if (responseObject && [responseObject isKindOfClass:[NSNull class]]) {
                responseObject = [NSMutableDictionary new];
            }

            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *reasonDictionary = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                return reasonDictionary;
            }

            if (httpProtocol.ci && httpProtocol.ci > 0) {
                if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
                    NSMutableDictionary *mutableDictionary = [NSMutableDictionary new];
                    {
                        //                        mutableDictionary[@"ci"] = [NSValue valueWithPointer:httpProtocol.ci];
                        mutableDictionary[@"d"] = responseObject;
                    }
                    return mutableDictionary;

                }

            }


            return responseObject;
        } else {

            if (httpProtocol.ci) {
                NSMutableDictionary *reasonDictionary = [NSMutableDictionary dictionaryWithDictionary:dict];
                if (httpProtocol.ci && reasonDictionary && [reasonDictionary isKindOfClass:[NSDictionary class]]) {
                    reasonDictionary[@"ci"] = [NSNumber numberWithInteger:httpProtocol.ci];
                }

                NSError *error = [NSError errorWithDomain:@"" code:[code intValue] userInfo:[NSDictionary dictionaryWithObject:reasonDictionary forKey:@"reason"]];

                return error;
            }


            NSError *error = [NSError errorWithDomain:@"" code:[code intValue] userInfo:[NSDictionary dictionaryWithObject:[dict objectForKey:@"m"] forKey:@"reason"]];

            return error;

        }

    }

    return nil;
}

- (NSString *)removeUnescapedCharacter:(NSString *)inputStr {
    NSCharacterSet *controlChars = [NSCharacterSet controlCharacterSet];
    //获取那些特殊字符
    NSRange range = [inputStr rangeOfCharacterFromSet:controlChars];
    //寻找字符串中有没有这些特殊字符
    if (range.location != NSNotFound) {
        NSMutableString *mutable = [NSMutableString stringWithString:inputStr];
        while (range.location != NSNotFound) {
            [mutable deleteCharactersInRange:range];
            //去掉这些特殊字符
            range = [mutable rangeOfCharacterFromSet:controlChars];
        }
        return mutable;
    }
    return inputStr;
}

- (void)dealloc {

    _upProtolQueue = nil;

}


@end
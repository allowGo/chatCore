//
// Created by 祥龙 on 15/9/22.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <JSONKit-NoWarning/JSONKit.h>
#import "QinChatProcessor.h"
#import "QinSocketProtocol.h"
#import "QinChatProtocol.h"


@implementation QinChatProcessor {

}

IMP_SINGLETON(QinChatProcessor)
#pragma mark - netManagerDelegate
- (void)connectAndLoginSuccess {

    DDLogDebug(@"QinCore socket 登录成功");
    [multicastDelegate receiveLoginSuccess:nil];

}

- (void)sendInfoSuccess:(NSDictionary *)dict {

}

- (void)receiveTokenError:(NSDictionary *)dict {

    DDLogError(@"socketError::dict=%@",dict);
    
    if(dict){
        
        NSString *msg = dict[@"msg"];
        [[QinNetManager sharedInstance] disconnect];
        [multicastDelegate receiveTokenError:msg];
    }

   
}

- (int)registerRoutingKey {
    return CHAT_ROUTING_KEY;
}

- (void)receiveSocketProtocol:(QinSocketProtocol *)socketProtocol {

    DDLogDebug(@"receiveSocketProtocol::protocol.data==%@",socketProtocol.data);
    if (socketProtocol.data != nil) {

        NSDictionary *dictData = [socketProtocol.data objectFromJSONString];

        if([dictData isKindOfClass:[NSDictionary class]]){


            NSNumber *  t= dictData[@"t"];
            NSNumber* c = dictData[@"c"];
            NSString * m = dictData[@"m"];

            NSDictionary *d = dictData[@"d"];


            if([c intValue]==REQ_SUCCESS){

                QinChatProtocol *chatProtocol= [[QinChatProtocol alloc] init];
                chatProtocol.c=[c intValue];
                chatProtocol.type= (ChatReceiveTYPE) [t intValue] ;
                chatProtocol.data=d;
                chatProtocol.msg=m;

                DDLogDebug(@"chatProtocol::type=%d,data=%@",chatProtocol.type,chatProtocol.data);
                switch (chatProtocol.type){

                    case CHAT_SEND:
                    {

                    };
                        break;
                    case CHAT_RECEIVE_RESP:  //消息回包
                    {
                        DDLogInfo(@"消息回包：%@",dictData);
                        dispatch_async(serviceQueue, ^{
                            [multicastDelegate sendInfoSuccess:dictData];
                             });

                    };
                        break;
                    case CHAT_RECEIVE_PUSH:  //收到推送
                    {
                        DDLogDebug(@"收到推送....");
                        dispatch_async(serviceQueue, ^{

                            [multicastDelegate receiveChatProtocol:chatProtocol];

                        });
                    };
                        break;
                    case CHAT_RECEIVE_NOTICE: //应用内通知
                    {

                        chatProtocol.data=dictData;
                        dispatch_async(serviceQueue, ^{

                            [multicastDelegate receiveAppNotify:chatProtocol];

                        });

                    };
                        break;
//                    case HTTP_RESP: //http消息回包
//                    {
//
////                        chatProtocol.data=dictData;
//                        dispatch_async(serviceQueue, ^{
//
//                            [multicastDelegate httpSendInfoSuccess:chatProtocol.data];
//
//                        });
//
//                    };
//                        break;
                    case CHAT_CI:
                    {

                    };
                        break;

                }

            }else {//error
                DDLogInfo(@"错误消息回包 ：%@",dictData);
                dispatch_async(serviceQueue, ^{
                    [multicastDelegate sendInfoSuccess:dictData];
                });
            }


        }

    }


}


@end
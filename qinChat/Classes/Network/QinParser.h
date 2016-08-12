/*
 协议封包工具类
 Created by 祥龙 on 15/8/9.
*/

#import <Foundation/Foundation.h>

typedef enum ScoketRecvieTYPE {
    SOCKET_RECV_ACK = 0,
    SOCKET_RECV_CONNECT = 1,
    SOCKET_RECV_CONNRESP = 2,
    SOCKET_SEND_PING = 3,
    SOCKET_RECV_PONG = 4,
    SOCKET_RECV_DISCONNECT = 5,  //断开连接
    SOCKET_RECV_CHATSENDSUCESS = 8, //发送时,是聊天消息发送.  接收时,是消息发送成功.

} ScoketRecvieTYPE;

typedef enum SCOKET_RECEIVE_ERROR_TYPE {
    SOCKET_RECV_TOKEN_ERROR = 1,//token
    SOCKET_RECV_BLACKLIST = 2,//黑名单
    SOCKET_RECV_OTHER_LOGIN = 4,//其它设备登陆

    
} SCOKET_RECEIVE_ERROR_TYPE;


typedef enum ChatReceiveTYPE {
    CHAT_SEND = 1, //消息发送
    CHAT_RECEIVE_RESP = 2, //消息回包
    CHAT_RECEIVE_PUSH = 3, //消息推送
    CHAT_RECEIVE_NOTICE = 4, //应用内通知
    CHAT_CI = 5,//ci确认
    HTTP_REQUREST = 7,//http消息发送
    HTTP_RESP = 8,//http 消息回包

} ChatReceiveTYPE;

typedef enum LIVE_RECEIVE_TYPE {
    LIVE_ADD_NOTICE = 42,   //加入通知
    LIVE_QUIT_NOTICE = 45,  //退出通知
    LIVE_SEND_DANMUKU = 46, //发送弹幕消息
    LIVE_DANMUKU_NOTICE = 47,//弹幕通知
    LIVE_SEND_STATUS = 48,        //直播心跳\直播状态上报
    LIVE_END_NOTICE = 49,   //直播结束通知
    LIVE_LUCKY_NOTICE = 50,   //直播红包通知
    LIVE_LUCKY_REWARD_NOTICE = 51,//直播红包打赏通知

} LIVE_RECEIVE_TYPE;


@class QinParser;
@class QinSocketProtocol;

@protocol QinParserDelegate
@required
- (void)reciveProtocol:(QinSocketProtocol *)socketProtocol;

//-(void)
@end

@interface QinParser : NSObject {
    Byte *receiveBuffer;
    NSInteger receiveBufferLength;
}
@property(nonatomic, weak) id <QinParserDelegate> parserDelegate;

+ (id)parserWithDelegate:(id <QinParserDelegate>)parserDelegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)parse:(NSData *)data;

@end
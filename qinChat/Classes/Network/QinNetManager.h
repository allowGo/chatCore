/*!
 @header QinNetManager.h
 @abstract 网络管理类. 进行长连接的相关管理.以及输出网络数据,网络状态
 @author kinstalk.com
 @version 1.00 15/8/9
 Created by LEI on 15/9/10
*/

#import <Foundation/Foundation.h>
//#import <CocoaAsyncSocket/AsyncSocket.h>
#import "QinServiceConstants.h"
#import "QinCoreMultiDelegate.h"
#import "QinParser.h"
#import "QinServiceConstants.h"
#import "GCDAsyncSocket.h"


@class QinNetConfig;
@class QinSocketProtocol;

static const int socket_timeout = -1;
static const int sendTimeout = 30;
static const int socketTag = 201;
/**
* 连接状态
*/
typedef enum {
    GOConnecting = 1,
    GOConnected,
    GODisconnect,
    GOAuthFailed,
    GOAuthenticated,
    GOLoginOtherPlace,
} GOState;

@interface SocketItem : NSObject
@property (nonatomic, strong) NSNumber * createTime;
@property (nonatomic, strong) NSData * data;

@end
/**
* 网络,相关状态
*/
@protocol QinNetManagerStatusDelegate
- (void)GOStateChanged:(GOState)newState oldState:(GOState)oldState;
@end


/**
* 信息处理相关
*/
@protocol QinNetManagerDataDelegate

@optional
//- (void)receiveAck:(int)ack;

//@required
//routingKey
-(int)registerRoutingKey;
- (void)connectAndLoginSuccess;

- (void)sendInfoSuccess:(NSDictionary *)dict;

/**
* token失效、链接错误等处理
*/
- (void)receiveTokenError:(NSDictionary *)dict;

//收到二进制消息.用来处理
- (void)receiveSocketProtocol:(QinSocketProtocol *)socketProtocol;


@end

@interface QinNetManager : NSObject <GCDAsyncSocketDelegate, QinParserDelegate>

DEF_SINGLETON(QinNetManager)

@property(nonatomic, strong) QinNetConfig *config;
@property(nonatomic, strong)id multicastDelegate;

- (void)initWithConfig:(QinNetConfig *)config;

- (void)addStatusDelegate:(id <QinNetManagerStatusDelegate>)statusDelegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeStatusDelegate:(id <QinNetManagerStatusDelegate>)statusDelegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)addDataDelegate:(id <QinNetManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue;

- (void)removeInfoDelegate:(id <QinNetManagerDataDelegate>)dataDelegate delegateQueue:(dispatch_queue_t)delegateQueue;


/**
* 连接
* FIXME 这里因为没有在线等状态，连接成功即代表在线，理论上还需要online和offline
*/
- (BOOL)connect;

/**
* 断开连接
*/
- (BOOL)disconnect;


/**
* 发送数据
*/
- (BOOL)sendData:(NSData *)data;

/**
*
*/
- (BOOL)isConnected;

/**
* 连接是否断开
*/
- (BOOL)isDisconnected;

/**
* 是否已验证
*/
- (BOOL)isAuthenticated;

- (BOOL)isConnecting;

-(GCDAsyncSocket *)asyncSocket;

/**
 * 重新连接socket
 */
-(void)reconnect;

@end

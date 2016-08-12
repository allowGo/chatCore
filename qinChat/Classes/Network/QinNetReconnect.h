/*!
 @header QinNetReconnect.h
 @abstract 
 @author kinstalk.com
 @version 1.00 15/8/12
 Created by DengHua on 15/8/12.
*/

#import <Foundation/Foundation.h>
#import "QinNetManager.h"
#import "SCNetworkReachability.h"


#define DEFAULT_SOCKET_RECONNECT_DELAY 2.0
#define DEFAULT_SOCKET_RECONNECT_TIMER_INTERVAL 20.0

@interface QinNetReconnect : NSObject <QinNetManagerStatusDelegate> {
    SCNetworkReachability *reachability;

    NSTimeInterval _reconnectDelay; //重新连接的延时

    NSTimeInterval _reconnectTimerInterval;

    int reconnectTicket; //重试次数
}


@property(nonatomic, assign) NSTimeInterval reconnectDelay;
@property(nonatomic, assign) NSTimeInterval reconnectTimerInterval;

- (void)start;

- (void)stop;


@end
/*!
 @header QinInfoDispatch.h
 @abstract 信息分配。 用来接收socket长连接或者http长连接，推送过来的数据分配
 @author kinstalk.com
 @version 1.00 15/8/5
 Created by DengHua on 15/8/5.
 update by 祥龙 on 15/8/17
*/

#import <Foundation/Foundation.h>
#import "QinNetManager.h"
#import "QinBaseService.h"
#import "QinHttpManager.h"
#import "QinChatProcessor.h"

@class QinInfo;
@class QinChatConfig;


@interface QinInfoDispatch : QinBaseService <QinChatProcessorDelegate, QinHttpManagerDataDelegate>

DEF_SINGLETON(QinInfoDispatch);

@end
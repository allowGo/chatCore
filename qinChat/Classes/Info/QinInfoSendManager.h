/*!
 @header QinInfoSendManager.h
 @abstract 信息发送管理类
 @author kinstalk.com
 @version 1.00 15/8/9
 Created by DengHua on 15/8/9.
*/

#import <Foundation/Foundation.h>
#import "QinServiceConstants.h"
#import "QinBaseService.h"
#import "QinNetManager.h"
#import "QinChatProcessor.h"

@class QinSocketProtocol;

@interface QinInfoSendManager : QinBaseService<QinChatProcessorDelegate>
DEF_SINGLETON(QinInfoSendManager);

@property(strong,nonatomic)infoSendSuccessBlock successblock;
@property(strong,nonatomic)infoSendFailBlock failblock;

-(void) sendInfo:(NSDictionary *)message success:(infoSendSuccessBlock)success failer:(infoSendFailBlock)error;

@end
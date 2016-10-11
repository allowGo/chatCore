//17号协议 实体
// Created by LEI on 16/6/6.
//

#import <Foundation/Foundation.h>
#import "QinCoreEnum.h"


@interface QinChatBodyNotify : NSObject
/**
 *  昵称
 */
@property(nonatomic, strong) NSString *nickname;
/**
 * type 1.入群 2.退群 3. 添加好友
 */
@property(nonatomic, assign) MESSAGE_NOTIFY_TYPE type;
/**
 * uid
 */
@property(nonatomic, strong) NSNumber *uid;
@end

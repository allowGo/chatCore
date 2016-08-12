//
//  QinRecentContacts.h
//  QinCore
//  最近联系人
//  Created by 王晔 on 15/8/15.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinMessage.h"
#import "QinCoreEnum.h"
#import "QinServiceConstants.h"

@interface QinRecentContacts : NSObject

/**
 *  群或者用户id
 */
@property (nonatomic, strong) NSNumber* to_id;
/**
 *  消息类型
 */
@property (nonatomic, assign) QinMessage_TYPE to_type;
/**
 *  群id
 */
@property (nonatomic, strong) NSNumber* gid;
/**
 *  未读数
 */
@property (nonatomic, strong) NSNumber* unReadCount;
/**
 *  消息实体
 */
@property (nonatomic, strong) QinMessage* qinMessage;

@property (nonatomic, assign) NSInteger status;

@property (nonatomic,assign)BOOL isAdim;

@property (nonatomic, assign) RECENT_CONTACTS_BUSINESS_TYPE businessType; //业务类型

/**
 *  群id
 */
@property (nonatomic, strong) NSNumber* insertTime;


@end

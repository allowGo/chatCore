//
//  RecentMsgUserModel.h
//  QinCore
//
//  Created by LEI on 15/8/14.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinRecentContacts.h"
#import "QinServiceConstants.h"

@interface RecentMsgUserModel :NSObject

@property (nonatomic, strong) NSNumber* gid;
@property (nonatomic, strong) NSNumber* to_id;
@property (nonatomic, strong) NSNumber* to_type;
@property (nonatomic, strong) NSNumber* unReadCount;
@property (nonatomic, assign) NSInteger msg_seq;
@property (nonatomic, strong) NSNumber* insert_time;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) RECENT_CONTACTS_BUSINESS_TYPE businessType; //业务类型

//模型装换
+ (QinRecentContacts*)rMsgUserModel2QinRContacts:(RecentMsgUserModel*)model;

@end


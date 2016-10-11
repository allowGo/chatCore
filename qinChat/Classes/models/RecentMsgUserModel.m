//
//  RecentMsgUserModel.m
//  QinCore
//
//  Created by LEI on 15/8/14.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import "RecentMsgUserModel.h"

@implementation RecentMsgUserModel


- (void)loadWithJSONDictionary:(NSDictionary *)dict {
    
}


//主键
+(NSArray*) getPrimaryKeyUnionArray
{
    return @[@"to_id"];
}
//表名
+(NSString *)getTableName
{
    return @"recent_msg_user_table";
}

+ (QinRecentContacts*)rMsgUserModel2QinRContacts:(RecentMsgUserModel*)model
{
    QinRecentContacts* qinRecentContacts = [[QinRecentContacts alloc] init];

    qinRecentContacts.to_id = model.to_id;
    qinRecentContacts.to_type = [model.to_type integerValue];
    qinRecentContacts.unReadCount = model.unReadCount;
    qinRecentContacts.gid = model.gid;
    qinRecentContacts.status=model.status;
    qinRecentContacts.businessType = model.businessType;
    qinRecentContacts.insertTime = model.insert_time;
    return qinRecentContacts;
}


@end


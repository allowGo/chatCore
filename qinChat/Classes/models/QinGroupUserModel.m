//
// Created by LEI on 15/9/23.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinGroupUserModel.h"


@implementation QinGroupUserModel {

}

+ (NSArray *)getPrimaryKeyUnionArray {

    return  @[@"uid",@"gid"];
}

+ (NSString *)getTableName {

    return @"t_qin_group_member";
}

@end

//
// Created by 祥龙 on 15/9/19.
// Copyright (c) 2015 shuzijiayuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinBaseService.h"
#import "QinServiceConstants.h"

@class QinUserModel;


@interface QinUserService : QinBaseService
DEF_SINGLETON(QinUserService)


-(QinUserModel *)getUserInfo:(NSNumber *)uId;

-(BOOL)saveOrUpdateUser:(QinUserModel *)userModel;

-(void)getBatchUserInfo:(NSArray *)uIdArray;

/**
 * 获取小管家用户信息
 */
- (void)getStewardInfo;
/**
 * 获取世界中用户信息
 */
- (void)getWorldUser:(NSNumber *)uId localSuccess:(void (^)(QinUserModel *user))localSuccess httpSuccess:(void (^)(QinUserModel *httpUser))httpSuccess;
@end
//
// Created by 祥龙 on 15/9/19.
// Copyright (c) 2015 shuzijiayuan. All rights reserved.
//

#import <LKDBHelper/LKDBHelper.h>
#import "QinUserService.h"
#import "QinUserModel.h"
#import "QinHttpManager.h"
#import "QinHttpProtocol.h"
#import "QinCoreMain.h"
#import "NSObject+MJKeyValue.h"
#import "QinCommonUtil.h"
#import "QinConfigInfo.h"

@implementation QinUserService {

}
IMP_SINGLETON(QinUserService)

- (QinUserModel *)getUserInfo:(NSNumber *)uId {

    QinUserModel* userModel  = [[QinCoreMain sharedInstance].dbHelper searchSingle:[QinUserModel class] where:[NSString stringWithFormat:@"uid=%@",uId]  orderBy:nil];
    return userModel;
}

- (BOOL)saveOrUpdateUser:(QinUserModel *)userModel {
    //FIXME 需讨论是否需要请求网络接口
    [[QinCoreMain sharedInstance].dbHelper insertToDB:userModel];

    return YES;
}

- (void)getBatchUserInfo:(NSArray *)uIdArray {

    dispatch_block_t block = ^{
        DDLogDebug(@"getBatchUserInfo uIds==%lu", (unsigned long) [uIdArray count]);
        NSString *uidAndUpdateTimes = nil;

        //获取群用户详情信息
        for (NSNumber *uId in uIdArray) {
            if ([uId longLongValue] <= 0)
                continue;

            //获取时间戳
            NSNumber *updateTimeStamp = @0;
            QinUserModel *userModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[QinUserModel class] where:[NSString stringWithFormat:@"uid=%@", uId] orderBy:nil];
            if (userModel) {
                updateTimeStamp = userModel.updateTime;
            }

            if (uidAndUpdateTimes) {
                uidAndUpdateTimes = [NSString stringWithFormat:@"%@,%@_%@", uidAndUpdateTimes, uId, updateTimeStamp];
            }
            else {
                uidAndUpdateTimes = [NSString stringWithFormat:@"%@_%@", uId, updateTimeStamp];
            }
        }

        if (nil == uidAndUpdateTimes || uidAndUpdateTimes.length <= 0) {
            DDLogDebug(@"uidAndUpdateTimes::empty...");
            return;
        }

        QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
        httpProtocol.requestUrl = [[QinConfigInfo getApiServerUrl] stringByAppendingString:GET_USER_INFOS];
        httpProtocol.method = @"POST";
        httpProtocol.param = @{@"uids" : uidAndUpdateTimes};

        [[QinHttpManager sharedInstance] getHttpRequest:httpProtocol success:^(id *operation, QinHttpProtocol *qinHttpProtocol) {

            if (qinHttpProtocol.data != nil) {

                NSArray *userArray = [QinUserModel mj_objectArrayWithKeyValuesArray:qinHttpProtocol.data[@"list"]];

                if (userArray && userArray.count > 0) {
                    [QinUserModel insertArrayByAsyncToDB:userArray];
                }

            }

        }                                       failure:^(id *operation, NSString *error) {

            DDLogError(@"getGroupUserList error::%@", error);
        }];

    };
   QUEUE_CHECK
    NSLog(@" 当前线程是: %@, 当前队列是: %@ 。", [NSThread currentThread], dispatch_get_current_queue());
}

/**
 * 获取小管家用户信息
 */
- (void)getStewardInfo {
dispatch_block_t block = ^{
    NSString* uidAndUpdateTimes = nil;

    //获取时间戳
    NSNumber* updateTimeStamp = @0;
    QinUserModel* userModel  = [[QinCoreMain sharedInstance].dbHelper searchSingle:[QinUserModel class] where:[NSString stringWithFormat:@"uid=%ld",(long)STEWARD_ID]  orderBy:nil];
    if( userModel )
    {
        updateTimeStamp = userModel.updateTime;
    }
    uidAndUpdateTimes = [NSString stringWithFormat:@"%ld_%@",(long)STEWARD_ID,updateTimeStamp];

    QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
    httpProtocol.requestUrl = [ [QinConfigInfo getApiServerUrl] stringByAppendingString:GET_USER_INFOS];
    httpProtocol.method = @"POST";
    httpProtocol.param=@{@"uids":uidAndUpdateTimes};


    [[QinHttpManager sharedInstance] getHttpRequest:httpProtocol success:^(id *operation, QinHttpProtocol *qinHttpProtocol) {

        DDLogDebug(@"getStewardInfo.data=%@",qinHttpProtocol.data);
        if(qinHttpProtocol.data!=nil){

            NSArray *userArray = [QinUserModel mj_objectArrayWithKeyValuesArray:qinHttpProtocol.data[@"list"]];

            if(userArray && userArray.count>0){
                [QinUserModel insertArrayByAsyncToDB:userArray];
            }

        }

    } failure:^(id *operation, NSString *error) {

        DDLogError(@"getGroupUserList error::%@",error);
    }];
};
     QUEUE_CHECK

}

/**
 * 获取世界用户信息
 */
- (void)getWorldUser:(NSNumber *)uId localSuccess:(void (^)(QinUserModel *user))localSuccess httpSuccess:(void (^)(QinUserModel *httpUser))httpSuccess {
dispatch_block_t block = ^{
    NSString* uidAndUpdateTimes = nil;
    //获取时间戳
    NSNumber* updateTimeStamp = @0;
    QinUserModel* userModel  = [[QinCoreMain sharedInstance].dbHelper searchSingle:[QinUserModel class] where:[NSString stringWithFormat:@"uid=%@",uId]  orderBy:nil];
    if( userModel )
    {
        if(localSuccess){
            localSuccess(userModel);
        }
        return;
    }
    uidAndUpdateTimes = [NSString stringWithFormat:@"%@_%@",uId,updateTimeStamp];

    QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
    httpProtocol.requestUrl = [ [QinConfigInfo getApiServerUrl] stringByAppendingString:GET_USER_INFOS];
    httpProtocol.method = @"POST";
    httpProtocol.param=@{@"uids":uidAndUpdateTimes};

    [[QinHttpManager sharedInstance] getHttpRequest:httpProtocol success:^(id *operation, QinHttpProtocol *qinHttpProtocol) {

        DDLogDebug(@"getWorldUser.data=%@",qinHttpProtocol.data);
        if(qinHttpProtocol.data!=nil){

            NSArray *userArray = [QinUserModel mj_objectArrayWithKeyValuesArray:qinHttpProtocol.data[@"list"]];

            if(userArray && userArray.count>0){
                [QinUserModel insertArrayByAsyncToDB:userArray];

                if(httpSuccess){

                    httpSuccess(userArray[0]);
                }
            }

        }

    } failure:^(id *operation, NSString *error) {

        DDLogError(@"getWorldUser error::%@",error);
    }];
};
    QUEUE_CHECK
}


@end
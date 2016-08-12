//
// Created by 祥龙 on 15/9/25.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <LKDBHelper/LKDBHelper.h>
#import "QinCoreMain.h"
#import "QinChatConfig.h"
#import "QinHttpProtocol.h"
#import "QinUserModel.h"
#import "QinGroupUserModel.h"
#import "QinGroupModel.h"
#import "RecentMsgUserModel.h"
#import "MsgModel.h"
#import "QinChatService.h"
#import "UnreadModel.h"
#import "QinInfoDispatch.h"
#import "QinInfoSendManager.h"
#import "QinChatProcessor.h"
#import "QinNetReconnect.h"

@implementation QinCoreMain {
    
   
}
IMP_SINGLETON(QinCoreMain)


- (void)initWithConfig:(QinChatConfig *)chatConfig {
    dispatch_block_t block = ^{
        
        _httpProtocol = [[QinHttpProtocol alloc] init];
        _httpProtocol.apiUrl = chatConfig.apiServerUrl;
        _httpProtocol.token = chatConfig.token;
        _httpProtocol.deviceId = chatConfig.deviceId;
        if(nil !=chatConfig)
        {
            _dbHelper = [MsgModel getUsingLKDBHelper];
            [_dbHelper setDBName:[NSString stringWithFormat:@"%@",chatConfig.uId]];
            NSString *fileName = [NSString stringWithFormat:@"%@.db", chatConfig.uId];
            NSString *filePath = [LKDBUtils getPathForDocuments:fileName inDir:@"db"];
            DDLogDebug(@"dbPath ==%@",filePath);
            [_dbHelper createTableWithModelClass:[MsgModel class]];
            [_dbHelper createTableWithModelClass:[RecentMsgUserModel class]];
            
            [_dbHelper createTableWithModelClass:[QinGroupModel class]];
            [_dbHelper createTableWithModelClass:[QinGroupUserModel class]];
            [_dbHelper createTableWithModelClass:[QinUserModel class]];
            [_dbHelper createTableWithModelClass:[UnReadModel class]];
            
            
            QinChatService *chatService = [QinChatService sharedInstance];
            /** 聊天 start*/
            [[QinInfoDispatch sharedInstance] addDelegate:chatService];
            [[QinInfoSendManager sharedInstance] addDelegate:chatService];
            QinChatProcessor *chatProcessor = [QinChatProcessor sharedInstance];
            [chatProcessor addDelegate:[QinInfoDispatch sharedInstance] delegateQueue:[chatService getServiceQueue]];
            [chatProcessor addDelegate:[QinInfoSendManager sharedInstance] delegateQueue:[chatService getServiceQueue]];
            /** 聊天 end*/
            
            QinNetReconnect *reconnect = [QinNetReconnect new];
            QinNetManager *netManager = [QinNetManager sharedInstance];
            [netManager addDataDelegate:chatProcessor delegateQueue:[chatService getServiceQueue]];
            [netManager addStatusDelegate:reconnect delegateQueue:[chatService getServiceQueue]];
            
            [chatService initWithConfig:chatConfig reConnect:reconnect];
            [[QinChatService sharedInstance] getNewMessagesVersion2 ];
            
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
   
}

@end
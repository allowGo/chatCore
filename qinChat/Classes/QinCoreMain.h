//
// Created by LEI on 15/9/25.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinServiceConstants.h"

@class QinChatConfig;
@class QinHttpProtocol;
@class LKDBHelper;

@interface QinCoreMain : NSObject

DEF_SINGLETON(QinCoreMain)

@property(strong, nonatomic)QinHttpProtocol *httpProtocol;
@property(nonatomic,strong)LKDBHelper *dbHelper;
/**
* init chat.
*/
- (void)initWithConfig:(QinChatConfig *)chatConfig;
@end

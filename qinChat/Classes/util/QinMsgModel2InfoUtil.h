//
//  QinMsgModel2InfoUtil.h
//  QinCore
//
//  Created by LEI on 15/8/13.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MsgModel.h"

@interface QinMsgModel2InfoUtil : NSObject

//msgModel转化为发送类型
+ (NSDictionary*)QinMsgModel2InfoDic:(MsgModel*)msgModel;

+ (NSDictionary*)toProtocol:(NSDictionary *)dict;
@end

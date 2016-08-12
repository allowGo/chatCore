//
//  QinChatBodyGps.h
//  QinCore
//
//  Created by 王晔 on 15/8/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QinChatBodyGps : NSObject

/**
 *  位置
 */
@property(nonatomic,strong) NSString* imgaddr;
@property(nonatomic,strong) NSNumber* lon;
@property(nonatomic,strong) NSNumber* lat;

@end

//
//  QinChatBodySmallVideo
//  QinCore
//
//  Created by LEI on 15/12/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**************************************************************
 *  content定义
 **************************************************************/
@interface QinChatSmallVideoContent : NSObject
/**
 *  视频url
 */
@property (nonatomic, strong) NSString* fileurl;

@property (nonatomic, strong) NSString* filelocalurl;
/**
 *  视频文件大小
 */
@property (nonatomic, strong) NSNumber* filesize;
/**
 *  视频时长
 */
@property (nonatomic, strong) NSNumber* filelen;

@end

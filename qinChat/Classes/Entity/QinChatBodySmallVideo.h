//
//  QinChatBodySmallVideo
//  QinCore
//
//  Created by 祥龙 on 15/12/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinChatSmallVideoContent.h"

@interface QinChatBodySmallVideo : NSObject

/**
 *  图片地址
 */
@property (nonatomic, strong) NSString* imgurl;

/**
 *  本地图片地址
 */
@property (nonatomic, strong) NSString* imglocalurl;
/**
 *  图片大小
 */
@property (nonatomic, strong) NSString* imgsize;
/**
 *  content文件信息
 */
@property(nonatomic,strong) QinChatSmallVideoContent * videoContent;

@end
//
//  QinChatBodyHandWrite.h
//  QinCore
//
//  Created by 王晔 on 15/8/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QinChatBodyHandWrite : NSObject

/**
 *  图片URL,大小
 */
@property(nonatomic,strong) NSString* imgurl;
@property(nonatomic,strong) NSString* imgsize;

/**
 *  本地图片路径
 */
@property(nonatomic,strong) NSString* imglocalurl;

@end

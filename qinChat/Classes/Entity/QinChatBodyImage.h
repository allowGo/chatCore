//
//  QinChatBodyImage.h
//  QinCore
//
//  Created by LEI on 15/8/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinChatBodyHandWrite.h"
#import "QinChatBodyAudio.h"

@interface QinChatBodyImage : NSObject

/**
 *  图片
 */
@property(nonatomic,strong)QinChatBodyHandWrite* imageInfo;
/**
 *  声音
 */
@property(nonatomic,strong)QinChatBodyAudio*     audioInfo;

@end

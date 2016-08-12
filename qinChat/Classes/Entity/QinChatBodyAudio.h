//
//  QinChatBodyAudio.h
//  QinCore
//
//  Created by 王晔 on 15/8/19.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QinChatBodyAudio : NSObject

/**
 *  声音
 */
@property(nonatomic,strong) NSString* soundurl;
@property(nonatomic,assign) NSInteger soundlen;
@property(nonatomic,strong) NSString* soundlocalurl;


@end

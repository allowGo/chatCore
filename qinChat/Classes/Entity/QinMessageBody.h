//
// Created by DengHua on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinChatBodyText.h"
#import "QinChatBodyImage.h"
#import "QinChatBodyHandWrite.h"
#import "QinChatBodyGps.h"
#import "QinChatBodyAudio.h"
#import "QinChatBodySmallVideo.h"
#import "QinChatBodyNotify.h"
#import "QinChatBodyLuckyMoney.h"

@interface QinMessageBody : NSObject

/**
 *  客户端生成唯一标示
 */
@property(nonatomic, assign) NSInteger ci;
/**
 *  消息是不是已经删除
 */
@property(nonatomic, assign) NSInteger msgDel;
/**
 *  转发的消息
 */
@property(nonatomic, assign) NSInteger forward;
/**
 * 视频通话 消息状态
 */
@property(nonatomic, assign) NSInteger videoStatus;
/**
 *  发送者id
 */
@property(nonatomic, strong) NSNumber *senderId;
/**
 *  消息发送者者id(源消息)
 */
@property(nonatomic, strong) NSNumber *sourceSenderId;

/**
 *  序列
 */
@property(nonatomic, strong) NSNumber *msgSeq;
/**
 *  发送时间 可选
 */
@property(nonatomic, strong) NSNumber *insertTime;
/**
 *  修改时间 可选
 */
@property(nonatomic, strong) NSNumber *updateTime;
/**
 *  消息类型 必填
 */
@property(nonatomic, assign) QinChatBodyMsg_TYPE msgType;
/**
 *  消息是不是已读0:未读,1:已读
 */
@property(nonatomic, assign) NSInteger isRead;

@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* avatar;

/*************************************消息体**************************************/
/**
 *  文本消息内容
 */
@property(nonatomic, strong) QinChatBodyText *chatBodyText;
/**
 *  手写图片
 */
@property(nonatomic, strong) QinChatBodyHandWrite *chatBodyHandWrite;
/**
 *  图片消息内容
 */
@property(nonatomic, strong) QinChatBodyImage *chatBodyImage;
/**
 *  声音消息内容
 */
@property(nonatomic, strong) QinChatBodyAudio *chatBodyAudio;
/**
 *  GPS消息内容
 */
@property(nonatomic, strong) QinChatBodyGps *chatBodyGps;

/**
 *  小视频消息内容
 */
@property(nonatomic, strong) QinChatBodySmallVideo *chatBodySmailVideo;

/**
 *  红包消息体
 */
@property(nonatomic, strong) QinChatBodyLuckyMoney *chatBodyLuckyMoney;

/**
 * 通知消息
 */
@property(nonatomic, strong) QinChatBodyNotify *chatBodyNotify;

@end
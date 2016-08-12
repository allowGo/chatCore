//
//  MsgModel.h
//  QinCore
//
//  Created by 王晔 on 15/8/12.
//  update by liuxianglong on 16/3/13
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "QinMessage.h"

#define MSG_DELETED 1


@interface MsgModel:NSObject
@property (nonatomic, strong) NSNumber * msg_seq;              //主键
@property (nonatomic, strong) NSNumber * ci;                   //客户端生成唯一标识
@property (nonatomic, assign) NSInteger type;                 //消息类型,QinChatBodyMsg_TYPE
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* imgurl;
@property (nonatomic, strong) NSString* image_local_url;//本地图片路径
@property (nonatomic, strong) NSString* imgsize;        //width x height
@property (nonatomic, strong) NSString* imgaddr;        //图片位置信息
@property (nonatomic, strong) NSString* soundurl;
@property (nonatomic, strong) NSString* sound_local_url;//本地声音路径
@property (nonatomic, assign) NSInteger soundlen;             //声音长度
@property (nonatomic, strong) NSNumber* lon;
@property (nonatomic, strong) NSNumber* lat;
@property (nonatomic, strong) NSNumber* gid;
@property (nonatomic, strong) NSNumber* to_id;          //消息发送目标
@property (nonatomic, strong) NSNumber* to_type;        //消息类型  1:群消息  2:点对点 3:小秘书 4:qLove
@property (nonatomic, strong) NSNumber* uid;
@property (nonatomic, strong) NSNumber* insert_time;
@property (nonatomic, strong) NSNumber* update_time;
@property (nonatomic, assign) NSInteger btype;                //QinMessage_BIGTYPE
@property (nonatomic, assign) NSInteger is_read;              //服务器使用字段
@property (nonatomic, strong) NSNumber* source;         //消息来源uid
@property (nonatomic, assign) NSInteger is_msgdel;            //是不是删除 0正常 1已删除
@property (nonatomic, assign) NSInteger forward;              //是不是转发
@property (nonatomic, assign) NSInteger msg_state;            //消息发送状态，QinMessage_SendStateTYPE
@property (nonatomic, assign) NSInteger video_status;         //视频通话状态 0
@property (nonatomic, assign) NSInteger isLocal;         //是否是本地插入数据0 不是,1 是
@property (nonatomic, strong) NSArray* at;        //at人
@property (nonatomic, strong) NSData * data;
@property (nonatomic, strong) NSString* nickname;
@property (nonatomic, strong) NSString* avatar;

//类型装换
- (void)checkModel;
+ (QinMessage*)msgModelToQinMessage:(MsgModel*)msgModel;
+ (MsgModel*)QinMessageToMsgModel:(QinMessage*)QinMessage;
+ (NSNumber *)makeCId;
@end




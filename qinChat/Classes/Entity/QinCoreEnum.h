//
//  QinDefine.h
//  QinCore
//
//  Created by LEI on 15/8/12.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#ifndef QinCore_QinDefine_h
#define QinCore_QinDefine_h

//消息类型
typedef  NS_ENUM(NSInteger, QinMessage_TYPE)
{
    QinMessage_TYPE_UNDEF = -1, //未定义
    
    QinMessage_TYPE_GROUP = 1,  //群
    QinMessage_TYPE_P2P   ,     //分群点对点
    QinMessage_TYPE_P2P_PERSON, //点对点
    QinMessage_TYPE_P2P_QLOVE, //qLove 点对点消息
    QinMessage_TYPE_P2P_FRIEND, //好友 点对点消息
    
};

//消息类型
typedef  NS_ENUM(NSInteger, getOldMessage_TYPE)
{
    getMessage_TYPE_Pro = 0, //之前消息
    
    getMessage_TYPE_Next = 1,  //之后消息
};

//大消息类型
typedef  NS_ENUM(NSInteger, QinMessage_BIGTYPE)
{
    QinMessage_BIGTYPE_NORMAL = 0,  //普通
    QinMessage_BIGTYPE_TIMEMACH,    //时光机
    QinMessage_BIGTYPE_CAPSULE,     //时间胶囊
    QinMessage_BIGTYPE_BURNAFTERREAD,//阅后即焚
    
};

//消息状态类型
typedef  NS_ENUM(NSInteger, QinMessage_STATUSTYPE)
{
    QinMessage_TMP=-1,     //草稿状态
    QinMessage_NORMAL=0,    //正常状态
    QinMessage_DEL = 1,  //删除状态
};

//消息状态类型
typedef  NS_ENUM(NSInteger, RECENTUSER_STATUS)
{
    RECENTUSER_TOP=1,     //置顶状态
    RECENTUSER_NORMAL=0,    //正常状态
};
//消息状态类型
typedef  NS_ENUM(NSInteger, MESSAGE_NOTIFY_TYPE)
{
    IN_GROUP_TYPE=1,     //入群
    QUIT_GROUP_TYPE=0,    //退群
    ADD_FRIEND_TYPE=0,    //添加好友
};
//消息内容类型
typedef  NS_ENUM(NSInteger, QinChatBodyMsg_TYPE)
{
    QinChatBodyText_TEXT        = 1,//文本
    QinChatBodyText_IMAGE       = 2,//图片
    QinChatBodyText_HANDWRITE   = 3,//手写
    QinChatBodyText_AUDIO       = 4,//声音
    QinChatBodyText_FACE        = 5,//表情
    QinChatBodyText_CARD        = 6,//贺卡
    QinChatBodyText_LOCATION    = 7,//地点
    QinChatBodyText_SHARE       = 8,//分享
    QinChatBodyText_IMAGETAG    = 9,//标签
    QinChatBodyText_EVENT       = 10,//事件
    QinChatBodyText_SMAlL_VIDEO = 11,//小视频
    QinChatBodyText_TEMP_TIMEMACHINE = 12,//小卡片
    QinChatBodyText_VIDEO_FILE = 13,//视频文件
    QinChatBodyText_VIDEO = 14,//视频通话
    QINCHATBODYTEXT_LUCKY = 15,//红包消息
    QINCHATBODYTEXT_LUCKY_GRAB = 16,//红包领取消息
    QINCHATBODYTEXT_NOTIFY = 17,//新版本通知消息 add 2016-06-06

    QinChatBodyText_SNAP_CHAT   = 101,  //阅后即焚消息
    QinChatBodyText_DELTAG      = 102,  //删除标签
    QinChatBodyText_CHGTAG      = 103,  //修改标签

    QinChatBodyText_TRANSFER    = 1000, //转发类型
    QinChatBodyText_TEMP_AUDIO  = 1001, //语音临时类型

    
};

//消息的发送状态
typedef  NS_ENUM(NSInteger, QinMessage_SendStateTYPE)
{
    QinMessage_SendStateTYPE_SUCCESS = 0, ///** 消息发送成功 */
    QinMessage_SendStateTYPE_PROGRESS,    ///** 消息发送进行中 */
    QinMessage_SendStateTYPE_FAILED,      ///** 消息发送失败 */
//    QinMessage_SendStateTYPE_TEMP,      ///** 临时消息 */
    
};


#endif

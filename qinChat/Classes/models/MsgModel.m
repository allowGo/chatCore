//
//  MsgModel.m
//  QinCore
//
//  Created by 王晔 on 15/8/12.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import "MsgModel.h"
#import "JSONKit.h"
#import "QinCommonUtil.h"
#import "QinChatService.h"
#import "NSObject+MJKeyValue.h"
#import "QinChatConfig.h"

@implementation MsgModel

- (instancetype)init {
    self = [super init];
    if (self) {

        self.is_msgdel = 0;
        self.video_status = 0;

    }
    return self;
}


- (void)checkModel {

     if ([self.to_type intValue] == QinMessage_TYPE_P2P_PERSON || [self.to_type intValue] == QinMessage_TYPE_P2P_FRIEND) {

        NSNumber *sourceId = self.source;
        if (sourceId && [[[QinChatService sharedInstance].chatConfig uId] integerValue] != [sourceId integerValue]) {
            self.to_id = sourceId;
        }
    }
    [self setIs_msgdel:0];
    [self setVideo_status:0];

    }

//主键
+ (NSArray *)getPrimaryKeyUnionArray {
    return @[@"to_id", @"msg_seq"];
}

//表名
+ (NSString *)getTableName {
    return @"msg_table";
}

+ (QinMessage *)msgModelToQinMessage:(MsgModel *)msgModel {
    if (nil == msgModel)
        return nil;

    QinMessage *resultQinMessage = [[QinMessage alloc] init];
    if (resultQinMessage) {
        resultQinMessage.toType = (QinMessage_TYPE) [msgModel.to_type intValue];

        if (nil == msgModel.source || [msgModel.source intValue] == 0)
            msgModel.source = @([msgModel.to_id intValue]);

        resultQinMessage.toId = msgModel.to_id;
        resultQinMessage.gid = msgModel.gid;
        resultQinMessage.bigType = (QinMessage_BIGTYPE) msgModel.btype;
        resultQinMessage.msgState = (QinMessage_SendStateTYPE) msgModel.msg_state;
       
        QinMessageBody *msgBody = [[QinMessageBody alloc] init];
        msgBody.ci = [msgModel.ci intValue];
        msgBody.msgDel = msgModel.is_msgdel;
        msgBody.forward = msgModel.forward;
        msgBody.senderId = msgModel.to_id;
        msgBody.sourceSenderId = msgModel.source;
        msgBody.msgSeq = msgModel.msg_seq;
        msgBody.insertTime = msgModel.insert_time;
        msgBody.updateTime = msgModel.update_time;
        msgBody.msgType = (QinChatBodyMsg_TYPE) msgModel.type;
        msgBody.isRead = msgModel.is_read;
        msgBody.nickname = msgModel.nickname;
        msgBody.avatar = msgModel.avatar;
        QinChatBodyText *bodyText = [[QinChatBodyText alloc] init];
        bodyText.text = msgModel.content;
        // bodyText.at   = msgModel.at;
        msgBody.chatBodyText = bodyText;
        QinChatBodyHandWrite *bodyHandWrite = [[QinChatBodyHandWrite alloc] init];
        bodyHandWrite.imgurl = msgModel.imgurl;
        bodyHandWrite.imglocalurl = msgModel.image_local_url;
        bodyHandWrite.imgsize = msgModel.imgsize;
        msgBody.chatBodyHandWrite = bodyHandWrite;
        QinChatBodyAudio *bodyAudio = [[QinChatBodyAudio alloc] init];
        bodyAudio.soundurl = msgModel.soundurl;
        bodyAudio.soundlocalurl = msgModel.sound_local_url;
        bodyAudio.soundlen = msgModel.soundlen;
        msgBody.chatBodyAudio = bodyAudio;
        QinChatBodyImage *bodyImage = [[QinChatBodyImage alloc] init];
        bodyImage.audioInfo = bodyAudio;
        bodyImage.imageInfo = bodyHandWrite;
        msgBody.chatBodyImage = bodyImage;
        msgBody.videoStatus = msgModel.video_status;
        
        /**小视频*/
        QinChatBodySmallVideo *bodySmailVideo = [[QinChatBodySmallVideo alloc] init];
        bodySmailVideo.imglocalurl = msgModel.image_local_url;
        bodySmailVideo.imgurl = msgModel.imgurl;
        bodySmailVideo.imgsize = msgModel.imgsize;

       if (QINCHATBODYTEXT_NOTIFY == msgModel.type) {
            if (msgModel.content) {
                NSDictionary *dict = [msgModel.content objectFromJSONString];
                if (dict && [dict count] > 0) {
                    QinChatBodyNotify *chatBodyNotify = [QinChatBodyNotify mj_objectWithKeyValues:dict];
                    msgBody.chatBodyNotify = chatBodyNotify;
                }

            }
        }
        resultQinMessage.messageBody = msgBody;
    }
    return resultQinMessage;

}

+ (MsgModel *)QinMessageToMsgModel:(QinMessage *)QinMessage {
    if (nil == QinMessage)
        return nil;

    MsgModel *resultMsgModel = [[MsgModel alloc] init];

    if (resultMsgModel) {
        resultMsgModel.to_type = @(QinMessage.toType);
        resultMsgModel.gid = QinMessage.gid;
        resultMsgModel.btype = QinMessage.bigType;
        resultMsgModel.msg_state = QinMessage.msgState;

        switch (QinMessage.toType) {
            case QinMessage_TYPE_GROUP:
                resultMsgModel.to_id = QinMessage.gid;
                break;
            default:
                resultMsgModel.to_id = QinMessage.toId;
                break;
        }
        resultMsgModel.ci = @(QinMessage.messageBody.ci);
        resultMsgModel.is_msgdel = QinMessage.messageBody.msgDel;
        resultMsgModel.forward = QinMessage.messageBody.forward;
        //        resultMsgModel.to_id        =  QinMessage.messageBody.senderId;
        resultMsgModel.source = QinMessage.messageBody.sourceSenderId;
        resultMsgModel.msg_seq = QinMessage.messageBody.msgSeq;
        resultMsgModel.insert_time = QinMessage.messageBody.insertTime;
        resultMsgModel.update_time = QinMessage.messageBody.updateTime;
        resultMsgModel.type = QinMessage.messageBody.msgType;
        resultMsgModel.is_read = QinMessage.messageBody.isRead;

        resultMsgModel.content = QinMessage.messageBody.chatBodyText.text;
        if (QinMessage.messageBody.chatBodyText.at)
            resultMsgModel.at = QinMessage.messageBody.chatBodyText.at;

        if (QinChatBodyText_IMAGE == resultMsgModel.type) {
            resultMsgModel.imgurl = QinMessage.messageBody.chatBodyImage.imageInfo.imgurl;
            resultMsgModel.image_local_url = QinMessage.messageBody.chatBodyImage.imageInfo.imglocalurl;
            resultMsgModel.imgsize = QinMessage.messageBody.chatBodyImage.imageInfo.imgsize;

            resultMsgModel.soundurl = QinMessage.messageBody.chatBodyImage.audioInfo.soundurl;
            resultMsgModel.sound_local_url = QinMessage.messageBody.chatBodyImage.audioInfo.soundlocalurl;
            resultMsgModel.soundlen = QinMessage.messageBody.chatBodyImage.audioInfo.soundlen;
        }
       
        else if (QinChatBodyText_AUDIO == resultMsgModel.type) {
            resultMsgModel.soundurl = QinMessage.messageBody.chatBodyAudio.soundurl;
            resultMsgModel.sound_local_url = QinMessage.messageBody.chatBodyAudio.soundlocalurl;
            resultMsgModel.soundlen = QinMessage.messageBody.chatBodyAudio.soundlen;
        }
        else {

            resultMsgModel.imgurl = QinMessage.messageBody.chatBodyImage.imageInfo.imgurl;
            resultMsgModel.image_local_url = QinMessage.messageBody.chatBodyImage.imageInfo.imglocalurl;
            resultMsgModel.imgsize = QinMessage.messageBody.chatBodyImage.imageInfo.imgsize;

            resultMsgModel.soundurl = QinMessage.messageBody.chatBodyImage.audioInfo.soundurl;
            resultMsgModel.sound_local_url = QinMessage.messageBody.chatBodyImage.audioInfo.soundlocalurl;
            resultMsgModel.soundlen = QinMessage.messageBody.chatBodyImage.audioInfo.soundlen;
        }

        resultMsgModel.imgaddr = QinMessage.messageBody.chatBodyGps.imgaddr;
        resultMsgModel.lon = QinMessage.messageBody.chatBodyGps.lon;
        resultMsgModel.lat = QinMessage.messageBody.chatBodyGps.lat;

        NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);
        resultMsgModel.insert_time = nowTime;
    }
    return resultMsgModel;
}

+ (NSNumber *)makeCId {
    static int i = 0;
    i++;
    if (i >= 1000) {
        i = 1;
    }
    NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);
    NSString *newTimeStr = [NSString stringWithFormat:@"%@", nowTime.stringValue];
    NSString *move = [NSString stringWithFormat:@"%d%@", i, [newTimeStr substringFromIndex:8]];

    return @([move intValue]);
}

@end



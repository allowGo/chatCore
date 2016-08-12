//
// Created by 祥龙 on 15/8/4.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//
#import "QinMessage.h"
#import "MsgModel.h"
#import "RecentMsgUserModel.h"
#import "LKDBHelper.h"
#import "QinHttpProtocol.h"
#import "QinInfoSendManager.h"
#import "QinMsgModel2InfoUtil.h"
#import "QinInfo.h"
#import "QinChatConfig.h"
#import "QinNetConfig.h"
#import "QinNetReconnect.h"
#import "QinInfoDispatch.h"
#import "QinCommonUtil.h"
#import "QinCoreMain.h"
#import "JSONKit.h"
#import "QinConfigInfo.h"
#import "NSObject+MJKeyValue.h"
#import "QinGCDTimer.h"
#import "QinGroupModel.h"
#import "QinChatService.h"
#import "QinUserModel.h"

#define TIME_OUT 120  //发送中超时失败时间 默认为2分钟
#define OLD_MSG_TIME_OUT 5  //重发队列检测时长 默认为5秒
#define SOCKET_MSG_TIME_OUT 20  //socket重连超时 默认为20秒
#define TIMER_NAME @"msgTimer"

/**
*  用来查询数据库的必填数据
 *
*/
#define MESSAGE_WHERE [NSString stringWithFormat:@"to_id= %ld and to_type = %ld and msg_seq = %d",(long)arg.toId, (long)arg.toType, seq]
@interface QinChatService () {

    NSLock *_sendmessageLock;    //发送消息的锁

    NSNumber *uId;//用户id

    QinNetReconnect *reconnect;

    NSMutableDictionary *_receiveTempDict; //临时接收数组,防止收到重复消息

    BOOL httpLoadSuccess; //批量拉取是否完成
    BOOL httpSending; //拉取历史
    NSMutableArray *tempReceiveArrary;//临时接收消息数组

    NSMutableArray *resendArrary;//重发消息数组

    dispatch_queue_t sendMsgSerialQueue;//消息发送队列

    NSNumber *messageLastUpdate;

    NSInteger reConnectCount;
    BOOL reConnect; //是否需要重连

}

- (void)initSendMessage;

- (void)removeOneSendMessage:(id)msgModel;

- (void)addOneSendMessage:(id)msgModel;
@end

@implementation QinChatService {
    void *msgQueueKey;
}

IMP_SINGLETON(QinChatService)

- (instancetype)init {
    self = [super init];
    if (self) {

        httpSending = NO;
        _sendmessageLock = [[NSLock alloc] init];
        reConnect = YES;
        reConnectCount = 1;
        sendMsgSerialQueue = dispatch_queue_create("kinstalk.com.qinjian.msg", DISPATCH_QUEUE_SERIAL);

        msgQueueKey = "msgQueueKey";
        dispatch_queue_set_specific(sendMsgSerialQueue, msgQueueKey, &msgQueueKey, NULL);
        [self initSendMessage];
    }

    return self;
}

- (void)initSendMessage {
    _sendMessageArray = [[NSMutableArray alloc] init];
    resendArrary = [[NSMutableArray alloc] init];
    _receiveTempDict = [[NSMutableDictionary alloc] init];
    tempReceiveArrary = [[NSMutableArray alloc] init];
    httpLoadSuccess = YES;
}

- (void)removeOneSendMessage:(id)msgModel {
    [_sendmessageLock lock];
    [_sendMessageArray removeObject:msgModel];
    [_sendmessageLock unlock];
}

- (void)addOneSendMessage:(id)msgModel {
    [_sendmessageLock lock];
    if (![self isSendError:msgModel]) {
        [_sendMessageArray addObject:msgModel];
    }

    [_sendmessageLock unlock];
}

- (void)initWithConfig:(QinChatConfig *)chatConfig reConnect:(QinNetReconnect *)reConnect{

    _chatConfig = chatConfig;
    reconnect = reConnect;
    QinNetConfig *netConfig = [QinNetConfig new];

    netConfig.address = [QinConfigInfo getChatServerIP];
    netConfig.port = [QinConfigInfo getChatServerPort];
    netConfig.token = chatConfig.token;
    netConfig.deviceId = chatConfig.deviceId;
    netConfig.uId = chatConfig.uId;
    uId = chatConfig.uId;

    QinNetManager *netManager = [QinNetManager sharedInstance];
    [netManager initWithConfig:netConfig];

    [netManager connect];

    //登录成功后开始重连检测
    [reconnect start];
    
    [[QinGCDTimer sharedInstance] cancelTimerWithName:TIMER_NAME];
    __weak typeof(self) weakSelf = self;
    [[QinGCDTimer sharedInstance] scheduledDispatchTimerWithName:TIMER_NAME
                                                    timeInterval:OLD_MSG_TIME_OUT
                                                           queue:nil
                                                         repeats:YES
                                                    actionOption:AbandonPreviousAction
                                                          action:^{
                                                              [weakSelf checkTimeOut];
                                                          }];

}


- (void)dealloc {
    [[QinInfoDispatch sharedInstance] removeDelegate:self];

}

- (NSArray *)registerInfoDispatch {
    return nil;
}

#pragma socket QinInfoDispatchDelegate

- (void)didReceiveSocketLoginSuccess:(NSDictionary *)dic {

    reConnectCount = 1;
    reConnect = YES;


    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        [weakSelf getNewMessagesVersion2];
        DDLogDebug(@"didReceiveSocketLoginSuccess::%@", dic);
        if (multicastDelegate) {
            [multicastDelegate didSocketLoginSuccess:nil];
        }
    };
    QUEUE_CHECK
    [self checkTimeOut];
    [self createPullMessageTimer];

}

- (void)didReceiveTokenError:(NSString *)msg {

    [reconnect stop];
    dispatch_block_t block = ^{

        if (multicastDelegate) {
            [multicastDelegate didTokenError:msg];
        }
    };

    QUEUE_CHECK
}


- (void)qinDidReceiveAppNotify:(QinInfo *)info {
    dispatch_block_t block = ^{
        DDLogDebug(@"qinDidReceiveAppNotify :接收到应用内消息,%@", info);
        if (multicastDelegate) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [multicastDelegate didSocketAppNotify:info.data];

            });
        }
    };

    QUEUE_CHECK
}

- (void)didReceiveInfo:(MsgModel *)msgInfo {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        if (msgInfo != nil) {
            
            DDLogDebug(@"didReceiveInfo httpLoadSuccess=%d", httpLoadSuccess);
            //等待http拉取成功后再入库
            if (httpLoadSuccess) {

                DDLogDebug(@"didReceiveInfo :接收到消息,%@", [msgInfo mj_JSONString]);
                //解析json
                [msgInfo checkModel];
                
                if(msgInfo.nickname){
                    QinUserModel *user = [QinUserModel new];
                    user.name = msgInfo.nickname;
                    user.uid = msgInfo.source;
                    user.avatar = msgInfo.avatar;
                    
                    [[QinCoreMain sharedInstance].dbHelper insertToDB:user callback:nil];
                    
                }
                //最近联系人、未读数处理
                [weakSelf updateUnreadCountVersion2:msgInfo];
                //转化实体
                QinMessage *receiveMsg = [MsgModel msgModelToQinMessage:msgInfo];
                //入库
                if (receiveMsg && [[QinCoreMain sharedInstance].dbHelper insertToDB:msgInfo]) {

                    DDLogDebug(@"save message to db.msg seq:%d", [msgInfo.msg_seq intValue]);
                    //回调
                    if (multicastDelegate) {

                        if (!_receiveTempDict[[NSString stringWithFormat:@"%@", msgInfo.msg_seq]]) {
                            [_receiveTempDict setValue:msgInfo forKey:[NSString stringWithFormat:@"%@", msgInfo.msg_seq]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [multicastDelegate didReceiveMessage:receiveMsg];

                            });
                        }
                        //1000条清空临时数据
                        if ([_receiveTempDict count] >= 1000) {

                            [_receiveTempDict removeAllObjects];
                        }


                    }
                }
            } else { //先保存到临时数组

                [tempReceiveArrary addObject:msgInfo];
            }


        }
    };

    QUEUE_CHECK

}

- (void)didReceiveHttpInfoVersion2:(NSArray *)infoArray {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        if (infoArray && [infoArray count] > 0) {

            for (MsgModel *qinInfo in infoArray) {
                [weakSelf saveMsgVersion2:qinInfo];
            }
            //回调
            if (multicastDelegate) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [multicastDelegate didNewsMessageNotify:[[NSDictionary alloc] init]];
                });
            }
        }
        httpLoadSuccess = YES;
        if (messageLastUpdate) {
            [QinCommonUtil saveLastPullTime:MESSAGE_PULL_KEY time:messageLastUpdate];
        }
        if (tempReceiveArrary.count > 0) {
            DDLogDebug(@"tempReceiveArrary::arrayCount==%lu", (unsigned long) tempReceiveArrary.count);
            for (MsgModel *qinInfo in tempReceiveArrary) {
                //保存离线消息
                [weakSelf saveMsgVersion2:qinInfo];
            }
        }
    };

    QUEUE_CHECK
}


#pragma mark  chatService method

- (void)getNewMessagesVersion2 {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        [_sendmessageLock lock];
        if (!httpSending) {
            httpSending = YES;
            NSNumber *lastTime = @0;
            id obj = [QinCommonUtil getLastPullTime:MESSAGE_PULL_KEY];
            if (obj && [obj isKindOfClass:[NSNumber class]]) {
                lastTime = obj;
            }
            NSDictionary *paramDict = @{@"timestamp" : lastTime, @"limit" : @(500)};
            QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
            httpProtocol.requestUrl = [[QinConfigInfo getApiServerUrl] stringByAppendingString:NEW_MESSAGES_URL];
            httpProtocol.method = @"post";
            httpProtocol.param = paramDict;
            httpProtocol.token = _chatConfig.token;
            httpProtocol.deviceId = _chatConfig.deviceId;
            httpProtocol.formType = QinHttpProtocol_FROMTYPE_PULLMSG;
            [[QinHttpManager sharedInstance] getHttpRequest:httpProtocol success:^(id *operation, QinHttpProtocol *resProtocol) {
                httpSending = NO;
                httpLoadSuccess = YES;

                [weakSelf cancelPullMessageTimer];

                NSDictionary *d = resProtocol.data;
                if (d && d.count > 0) {

                    if (([d isKindOfClass:[NSDictionary class]])) {
                        id res = d[@"res"];
                        if ([res isKindOfClass:[NSDictionary class]]) {

                            id msgs = [res objectForKey:@"msgs"];
                            if ([msgs isKindOfClass:[NSArray class]]) {

                                NSMutableArray *infoArray = [MsgModel mj_objectArrayWithKeyValuesArray:msgs];
                                [weakSelf didReceiveHttpInfoVersion2:infoArray];

                            }

                            id lastpos = [res objectForKey:@"lastpos"];
                            if (lastpos) {
                                messageLastUpdate = lastpos;
                            }
                        }
                    }

                }

            } failure:^(id *operation, NSString *error) {
                httpSending = NO;
                httpLoadSuccess = NO;

            }];
        }
        [_sendmessageLock unlock];


    };

    QUEUE_CHECK
}

- (int)sendMessage:(QinMessage *)message {

    __block NSNumber *ci = [MsgModel makeCId];
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        //转化
        MsgModel *msgModel = [MsgModel QinMessageToMsgModel:message];
        if (msgModel) {
            msgModel.ci = ci;
            //生成临时seq
            msgModel.msg_seq = [QinCommonUtil makeLocalSeq];
            //检查socket是否断开
            if ([[QinNetManager sharedInstance] isAuthenticated]) {
                msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;//发送中

               
                [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
                RecentMsgUserModel *recentMsgUserModel = [weakSelf createRecentUser:msgModel];
                [weakSelf saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];

                [weakSelf addOneSendMessage:msgModel];
                //转换发送类
                NSDictionary *sendMsgDic = [QinMsgModel2InfoUtil QinMsgModel2InfoDic:msgModel];

                [[QinInfoSendManager sharedInstance] sendInfo:sendMsgDic success:^(NSDictionary *dict) {
                    [weakSelf sendSuccess:dict];

                }                                      failer:^(NSDictionary *dict) {

                    [weakSelf sendError:msgModel errorData:dict];

                }];
            } else {

                DDLogError(@"sendMessage socket isAuthenticated....");
               
                [weakSelf checkSendSuccess:msgModel];
                RecentMsgUserModel *recentMsgUserModel = [weakSelf createRecentUser:msgModel];
                [weakSelf saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];
            }
        }

    };

    if (dispatch_get_specific(msgQueueKey)) {

        block();
    }
    else {

        dispatch_async(sendMsgSerialQueue, block);
    }
//    NSLog(@" 当前线程是: %@, 当前队列是: %@ 。", [NSThread currentThread], dispatch_get_current_queue());
    return [ci intValue];
}


- (NSInteger)saveTempMessage:(QinMessage *)message {

    NSInteger result = 0;
    //转化
    MsgModel *msgModel = [MsgModel QinMessageToMsgModel:message];
    if (msgModel) {
        msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;//临时消息
        msgModel.ci = [MsgModel makeCId];
        //生成临时seq
        msgModel.msg_seq = [QinCommonUtil makeLocalSeq];
        [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
        RecentMsgUserModel *recentMsgUserModel = [self createRecentUser:msgModel];
        [self saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];
        result = [msgModel.msg_seq integerValue];
    }
    return result;
}

- (void)saveLocalMessage:(QinMessage *)message {
    //转化
    MsgModel *msgModel = [MsgModel QinMessageToMsgModel:message];
    if (msgModel) {
        msgModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;
        msgModel.msg_seq = @(1);
        msgModel.ci = [MsgModel makeCId];
        [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
        RecentMsgUserModel *recentMsgUserModel = [self createRecentUser:msgModel];
        [self saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_PLUS];
    }
}

- (int)sendTempMessage:(QinMessage *)message {

    __block NSNumber *ci = [MsgModel makeCId];
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        //转化
        MsgModel *msgModel = [MsgModel QinMessageToMsgModel:message];
        if (msgModel) {

            msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;//临时消息
            msgModel.ci = ci;
            //生成临时seq
            msgModel.msg_seq = [QinCommonUtil makeLocalSeq];
            [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
            RecentMsgUserModel *recentMsgUserModel = [weakSelf createRecentUser:msgModel];
            [weakSelf saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];
        }

        NSString *filePath = nil;
        /**上传媒体文件*/
        if (msgModel.type == QinChatBodyText_IMAGE || msgModel.type == QinChatBodyText_HANDWRITE || msgModel.type == QinChatBodyText_SMAlL_VIDEO) {
            filePath = [QinCommonUtil getPhotoPathWithFileName:msgModel.image_local_url];

        } else if (msgModel.type == QinChatBodyText_LOCATION) {
            filePath = [QinCommonUtil getPhotoPathWithFileName:msgModel.imgaddr];
        } else if (msgModel.type == QinChatBodyText_AUDIO) {
            filePath = [QinCommonUtil getAudioPathWithFileName:msgModel.sound_local_url];
        }

        if ((filePath != nil && ![filePath isEqualToString:@""] && msgModel.imgurl == nil) || (filePath != nil && ![filePath isEqualToString:@""] && msgModel.soundurl == nil)) {

            [weakSelf uploadFile:msgModel filePath:filePath];
        }

    };

    QUEUE_CHECK
    return [ci intValue];
}

/**
 * 确认发送
 * ci 消息唯一标识
 * url 媒体文件地址
 * isAudio 是否是图片音频消息 1是 0否
 */
- (void)confirmSendMessage:(NSInteger)ci url:(NSString *)url isAudio:(int)isAudio audioUrl:(NSString *)audioUrl {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        DDLogDebug(@"confirmSendMessage::ci=%ld,url=%@", ci, url);
        NSString *whereStr = [NSString stringWithFormat:@"ci=%d", ci];
        MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:whereStr orderBy:@""];
        //检查socket是否断开
        if ([[QinNetManager sharedInstance] isAuthenticated]) {
            if (msgModel != nil) {

                DDLogDebug(@"confirmSendMessage::msgModel==%@", [msgModel printAllPropertys]);
                if (isAudio == 1) {
                    msgModel.imgurl = url;
                    msgModel.soundurl = audioUrl;

                } else {

                    if (msgModel.type == QinChatBodyText_IMAGE || msgModel.type == QinChatBodyText_HANDWRITE) {
                        msgModel.imgurl = url;
                    } else if (msgModel.type == QinChatBodyText_AUDIO) {

                        msgModel.soundurl = url;
                    } else if (msgModel.type == QinChatBodyText_LOCATION) {
                        msgModel.imgaddr = url;
                        msgModel.imgurl = url;
                    }
                }


                msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;//发送中 QinMessage_SendStateTYPE_PROGRESS;
                [weakSelf addOneSendMessage:msgModel];
                //转换发送类
                NSDictionary *sendMsgDic = [QinMsgModel2InfoUtil QinMsgModel2InfoDic:msgModel];
                [[QinInfoSendManager sharedInstance] sendInfo:sendMsgDic success:^(NSDictionary *dict) {

                    [weakSelf sendSuccess:dict];

                }failer:^(NSDictionary *dict) {

                    [weakSelf sendError:msgModel errorData:dict];
                }];

            }
        } else {

            DDLogError(@"confirmSendMessage socket isAuthenticated....");
            if (![weakSelf isSending:msgModel]) {
                [resendArrary addObject:msgModel];
            }
        }

    };
    QUEUE_CHECK
}


/**
* 重发消息
*/
- (void)reSendMessage:(QinChatArg *)arg mesageSeq:(NSInteger)seq {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        if (QinMessage_TYPE_GROUP == arg.toType) {
            arg.toId = arg.groupId;
        }
        DDLogDebug(@"reSendMessage  to_type=%d,gid=%d,to_id=%d,seq=%d", arg.toType, arg.groupId, arg.toId, seq);
        NSString *whereStr = [NSString stringWithFormat:
                @"to_id = %d and to_type = %d and msg_seq = %d",arg.toId, arg.toType, seq];
        MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:whereStr orderBy:@""];
        if (msgModel != nil) {
            //检查socket是否断开
            if ([[QinNetManager sharedInstance] isAuthenticated]) {
                [weakSelf addOneSendMessage:msgModel];
                NSString *filePath = nil;
                /**上传媒体文件*/
                if (msgModel.type == QinChatBodyText_IMAGE || msgModel.type == QinChatBodyText_HANDWRITE || msgModel.type == QinChatBodyText_SMAlL_VIDEO) {
                    filePath = [QinCommonUtil getPhotoPathWithFileName:msgModel.image_local_url];

                } else if (msgModel.type == QinChatBodyText_LOCATION) {
                    filePath = [QinCommonUtil getPhotoPathWithFileName:msgModel.imgaddr];
                } else if (msgModel.type == QinChatBodyText_AUDIO) {
                    filePath = [QinCommonUtil getAudioPathWithFileName:msgModel.sound_local_url];
                }

                if ((filePath != nil && ![filePath isEqualToString:@""] && msgModel.imgurl.length == 0) || (filePath != nil && ![filePath isEqualToString:@""] && msgModel.soundurl.length == 0)) {

                    [weakSelf uploadFile:msgModel filePath:filePath];
                }
                else {

                    NSLog(@"sendingArray.count==%lu", (unsigned long) _sendMessageArray.count);
                    msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;//发送中 QinMessage_SendStateTYPE_PROGRESS;
                    //转换发送类
                    NSDictionary *sendMsgDic = [QinMsgModel2InfoUtil QinMsgModel2InfoDic:msgModel];
                    [[QinInfoSendManager sharedInstance] sendInfo:sendMsgDic success:^(NSDictionary *dict) {

                        [weakSelf sendSuccess:dict];

                    }failer:^(NSDictionary *dict) {

                        [weakSelf sendError:msgModel errorData:dict];
                    }];

                }
            } else {
                DDLogError(@"reSendMessage socket isAuthenticated....");
                if (![weakSelf isSending:msgModel]) {
                    [resendArrary addObject:msgModel];
                }
            }

        }

    };

    QUEUE_CHECK

}

- (RecentMsgUserModel *)getRecentMsgUserByBusinessType:(RECENT_CONTACTS_BUSINESS_TYPE)businessType {

    NSString *where = [NSString stringWithFormat:@"businessType=%d ", businessType];
    return [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];
}

- (void)getRecentMsgUser:(void (^)(NSArray *groupArray))success {

    dispatch_block_t block = ^{
        NSMutableArray *listEntity = [NSMutableArray array];
        NSArray *listModel = [[QinCoreMain sharedInstance].dbHelper search:[RecentMsgUserModel class] where:[NSString stringWithFormat:@"to_id!=%d", [uId integerValue]] orderBy:@"CAST(status as integer) desc,CAST(insert_time as integer) desc" offset:0 count:0];


        for (RecentMsgUserModel *model in listModel) {

            //转换实体
            QinRecentContacts *entity = [RecentMsgUserModel rMsgUserModel2QinRContacts:model];

            if (entity.businessType == 0 || entity.businessType == BUSINESS_TYPE_MESSAGE) {
                //先获取草稿消息
                NSString *delWhereStr = @"is_msgdel=-1 and type!=101 and type!=102 and type!=103  and to_id=%@ and  to_type=%ld";
                NSString *tempWhere = [NSString stringWithFormat:delWhereStr, model.to_id, (long) [model.to_type integerValue]];
                MsgModel *tempMsgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:tempWhere orderBy:@"CAST(insert_time as integer) desc"];
                if (tempMsgModel != nil) {
                    entity.qinMessage = [MsgModel msgModelToQinMessage:tempMsgModel];
                } else {

                    NSString *oneWhereStr = @"is_msgdel!=1 and type!=101 and type!=102 and type!=103  and to_id=%@";
                    NSString *where = [NSString stringWithFormat:oneWhereStr,model.to_id];
                    MsgModel *nextMsgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:where orderBy:@"CAST(insert_time as integer) desc"];
                    if (nextMsgModel != nil) {
                        entity.qinMessage = [MsgModel msgModelToQinMessage:nextMsgModel];
                    }

                }
            }

            [listEntity addObject:entity];
        }

        if (success) {
            success(listEntity);
        }

    };
    QUEUE_CHECK
}

- (void)saveRecentUser:(RecentMsgUserModel *)recentMsgUser status:(UNREAD_TYPE)status {

    if (recentMsgUser) {
        NSString *where = [NSString stringWithFormat:@"to_id=%d  and to_type=%d ", [recentMsgUser.to_id integerValue], [recentMsgUser.to_type integerValue]];
        
        RecentMsgUserModel *recentMsgUserModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];
        if (recentMsgUserModel != nil) {

            if (status != UNREAD_TYPE_NORMAL) {
                if (0 != [recentMsgUserModel.unReadCount intValue]) {

                    if (status == UNREAD_TYPE_NOTIFY) {
                        recentMsgUserModel.unReadCount = recentMsgUser.unReadCount;
                    } else {
                        recentMsgUserModel.unReadCount = @([recentMsgUserModel.unReadCount intValue] + [recentMsgUser.unReadCount intValue]);
                    }


                } else {
                    recentMsgUserModel.unReadCount = recentMsgUser.unReadCount;
                }
            } else {
                recentMsgUserModel.unReadCount = @(0);
            }
            recentMsgUserModel.msg_seq = recentMsgUser.msg_seq;
            recentMsgUserModel.insert_time = recentMsgUser.insert_time;

            [[QinCoreMain sharedInstance].dbHelper updateToDB:recentMsgUserModel where:where];
        } else {
            recentMsgUserModel = recentMsgUser;
            if (status != UNREAD_TYPE_NORMAL) {
                recentMsgUserModel.unReadCount = recentMsgUser.unReadCount;
            } else {
                recentMsgUserModel.unReadCount = @0;
            }
            recentMsgUserModel.status = 0;

            [[QinCoreMain sharedInstance].dbHelper insertToDB:recentMsgUserModel];
        }


        //插入未读消息


    }
}

- (RecentMsgUserModel *)createRecentUser:(MsgModel *)msgModel {

    RecentMsgUserModel *recentMsgUserModel = [[RecentMsgUserModel alloc] init];
    if (msgModel) {

        recentMsgUserModel.msg_seq = [msgModel.msg_seq integerValue];
        recentMsgUserModel.insert_time = msgModel.insert_time;
        recentMsgUserModel.unReadCount = @1;
        recentMsgUserModel.status = 0;
        recentMsgUserModel.businessType = BUSINESS_TYPE_MESSAGE;
        recentMsgUserModel.to_type = msgModel.to_type;
        recentMsgUserModel.gid = msgModel.gid;
        recentMsgUserModel.to_id = msgModel.to_id;
    }
    return recentMsgUserModel;
}

#pragma mark 消息

- (void)getOldMessage:(QinChatArg *)chatArg messageSeq:(NSInteger)seq count:(NSInteger)count {

    chatArg.toType = chatArg.toType;
    DDLogDebug(@"QinChatService.getOldMessage::to_type=%ld,to_id=%ld,seq=%ld", (long) chatArg.toType, (long) chatArg.toId, (long) seq);
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        LKDBHelper *helper = [QinCoreMain sharedInstance].dbHelper;
        NSString *where = nil;
        NSString *proWhereStr = @"to_id=%ld and is_msgdel=0  and type!=101 and type!=102 and type!=103 and to_type=%ld and  CAST(msg_seq as integer)<%ld";
        NSString *nextWhereStr = @"to_id=%ld and is_msgdel=0  and type!=101 and type!=102 and type!=103 and to_type=%ld and  CAST(msg_seq as integer)>%ld";
        NSString *firstPageWhereStr = @"to_id=%ld  and is_msgdel=0 and  type!=101 and type!=102 and type!=103 and  to_type=%ld";
        NSString *orderBy = @"CAST(msg_seq as integer) desc";
        
        if (seq == 0) {
            where = [NSString stringWithFormat:firstPageWhereStr, chatArg.toId, chatArg.toType];
            
        } else {

            if (chatArg.getType == getMessage_TYPE_Next) {
                where = [NSString stringWithFormat:nextWhereStr,chatArg.toId, chatArg.toType, seq];
            } else {
                
                where = [NSString stringWithFormat:proWhereStr, chatArg.toId, chatArg.toType, seq];
            }
            
        }
        NSMutableArray *msgModelArray = [helper search:[MsgModel class] where:where orderBy:orderBy offset:0 count:count];

        NSMutableArray *qinMessageArray = [[NSMutableArray alloc] init];

        for (int i = 0; i < [msgModelArray count]; i++) {
            MsgModel *msgModel = msgModelArray[i];
            //            //校正发送状态
            if (msgModel.msg_state == QinMessage_SendStateTYPE_PROGRESS) {
                
                if(msgModel.msg_seq && [msgModel.msg_seq integerValue] >= LOCAL_SEQ){
                    NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);
                    
                    NSNumber *msgTime = msgModel.insert_time;
                    if (msgTime) {
                        int timeOut = ([nowTime intValue] - [msgTime intValue]) / 1000;
                        if (timeOut > SOCKET_MSG_TIME_OUT  && timeOut < TIME_OUT) {
                            if (![weakSelf isSending:msgModel]) {
                                [resendArrary addObject:msgModel];
                            }
                            
                        }else{
                            msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                        }
                    }
                }else{
                    msgModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;
                }
                
                
            }
            
            /**发送失败的消息逻辑处理*/
            if (msgModel.msg_state == QinMessage_SendStateTYPE_FAILED) {
                
                NSString *delWhere = [NSString stringWithFormat:@"ci=%@ and msg_state=0",msgModel.ci];
                MsgModel *dbModel =  [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:delWhere orderBy:nil];
                
                if(dbModel ){
                    
                    [[QinCoreMain sharedInstance].dbHelper deleteToDB:msgModel];
                    continue;
                }
                
                
                if(msgModel.msg_seq && [msgModel.msg_seq integerValue] >= LOCAL_SEQ){
                    NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);
                    
                    NSNumber *msgTime = msgModel.insert_time;
                    if (msgTime) {
                        int timeOut = ([nowTime intValue] - [msgTime intValue]) / 1000;
                        if ( timeOut < TIME_OUT) {
                            msgModel.msg_state = QinMessage_SendStateTYPE_PROGRESS;
                            if (![weakSelf isSending:msgModel]) {
                                [resendArrary addObject:msgModel];
                            }
                            
                        }else{
                            msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                        }
                    }
                }
                
                
            }
            //增量更新时 踢出正在发送 和 发送失败的消息
            if (seq > 0 && chatArg.getType == getMessage_TYPE_Next){
                
                if(msgModel.msg_state == QinMessage_SendStateTYPE_FAILED || msgModel.msg_state == QinMessage_SendStateTYPE_PROGRESS){
                    
                    continue;
                }
            }
            //转化实体
            QinMessage *qinMessage = [MsgModel msgModelToQinMessage:msgModel];
            [qinMessageArray addObject:qinMessage];
            
        }

        if (seq > 0 && chatArg.getType != getMessage_TYPE_Next) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [multicastDelegate didReceiveOldMessages:qinMessageArray];

            });
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [multicastDelegate didReceiveFristOldMessages:qinMessageArray];

            });
        }


    };
    QUEUE_CHECK
}

- (int)makeMessageToRead:(QinChatArg *)arg messageSeq:(NSInteger)seq bigType:(NSInteger)bigType {

    DDLogDebug(@"makeMessageToRead  to_type=%ld,to_id=%ld,seq=%ld", (long) arg.toType, (long) arg.toId, (long) seq);
    //修改消息状态
    NSDictionary *whereDic = @{@"to_id" : @(arg.toId), @"to_type" : @(arg.toType), @"msg_seq" : @(seq)};

    //阅后即焚消息
    if (bigType == QinMessage_BIGTYPE_BURNAFTERREAD) {

        NSString *strSet = [NSString stringWithFormat:@"is_msgdel = \'%d\'", 1];
        [[QinCoreMain sharedInstance].dbHelper updateToDB:[MsgModel class] set:strSet where:whereDic];

        //调用服务器接口发送 已读状态
        QinMessage *message = [[QinMessage alloc] init];
        message.bigType = QinMessage_BIGTYPE_BURNAFTERREAD;
        message.toId = (id) @(arg.toId);
        message.toType = (QinMessage_TYPE) arg.toType;
        message.gid = @(0);
        QinMessageBody *messageBody = [[QinMessageBody alloc] init];
        messageBody.msgType = QinChatBodyText_SNAP_CHAT;

        QinChatBodyText *text = [[QinChatBodyText alloc] init];
        text.text = (id) @(seq);
        messageBody.chatBodyText = text;
        message.messageBody = messageBody;

        return [self sendMessage:message];
    } else {

        NSString *strSet = [NSString stringWithFormat:@"is_read = \'%d\'", 1];
        [[QinCoreMain sharedInstance].dbHelper updateToDB:[MsgModel class] set:strSet where:whereDic];

        return 1;
    }


}

- (void)deleteMessage:(QinChatArg *)arg messageSeq:(NSInteger)seq {

    dispatch_block_t block = ^{
        
        DDLogDebug(@"deleteMessage  to_type=%d,to_id=%d,seq=%d", arg.toType,arg.toId, seq);

        if (seq >= LOCAL_SEQ) { //本地发送的消息物理删除

            //删除临时消息
            NSString *whereStrDel = [NSString stringWithFormat:@"msg_seq = %d", seq];
            [[QinCoreMain sharedInstance].dbHelper deleteWithClass:[MsgModel class] where:whereStrDel];
        } else {

            //删除临时消息
            NSString *whereStrDel = [NSString stringWithFormat:
                    @"to_id = %d and msg_seq = %d",arg.toId,seq];

            NSString *strSet = [NSString stringWithFormat:@"is_msgdel = \'%d\'", MSG_DELETED];
            [[QinCoreMain sharedInstance].dbHelper updateToDB:[MsgModel class] set:strSet where:whereStrDel];
        }
    };

    QUEUE_CHECK
}


- (void)checkTimeOut {
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        NSNumber *nowTime = @([QinCommonUtil makeTimestamp]);

        /**
         * 发送中数据检查,超过30秒至成失败状态,通知UI
         */
        if (_sendMessageArray.count > 0) {

            BOOL isConnected = NO;
            NSArray *sendingArray = [NSArray arrayWithArray:_sendMessageArray];


            NSLog(@"sendingArray.count=%lu", (unsigned long) sendingArray.count);
            for (MsgModel *sendingMsg in sendingArray) {

                NSNumber *insertTime = sendingMsg.insert_time;

                int timeOut = ([nowTime intValue] - [insertTime intValue]) / 1000;

                if (timeOut >= (SOCKET_MSG_TIME_OUT* reConnectCount) ) {

                    if(!isConnected && reConnect){

                        reconnect = NO;
                        DDLogDebug(@"sendingArray,socket.timeOut==%d,msgSeq==%@", timeOut, sendingMsg.msg_seq);
                        [[QinNetManager sharedInstance] reconnect];
                    }

                    isConnected = YES;
                    reConnectCount++;
                    [_sendMessageArray removeObject:sendingMsg];

                    if (![weakSelf isSending:sendingMsg]) {
                        [resendArrary addObject:sendingMsg];
                    }

                }
//                超过120秒 认为是超时，通知 UI显示
                if (timeOut >= TIME_OUT) {

                    DDLogDebug(@"sendingArray,timeOut==%d,msgSeq==%@", timeOut, sendingMsg.msg_seq);
                    [_sendMessageArray removeObject:sendingMsg];
                    sendingMsg.msg_state = QinMessage_SendStateTYPE_FAILED;
                    NSString *where = [NSString stringWithFormat:@"ci=%@ and gid=%@",sendingMsg.ci,sendingMsg.gid];
                    MsgModel *dbModel =  [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:where orderBy:nil];

                    if(dbModel && [dbModel.msg_seq integerValue] >= LOCAL_SEQ){

                        dbModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                        [[QinCoreMain sharedInstance].dbHelper updateToDB:dbModel where:where];
                        [multicastDelegate didSendError:sendingMsg.ci seq:sendingMsg.msg_seq];
                    }else{
                        dbModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;
                        [[QinCoreMain sharedInstance].dbHelper updateToDB:dbModel where:where];
                        [multicastDelegate didSendSuccess:dbModel.ci seq:dbModel.msg_seq];
                    }

                }
            }
        }
        /**检测socket是否可用,可用则进行重发*/
        [weakSelf resendArrayCheck:nowTime];
    };
    QUEUE_CHECK
}


- (void)resendArrayCheck:(NSNumber *)nowTime {


    if ([resendArrary count] > 0) {
        __weak __typeof(self) weakSelf = self;
        NSArray *fakeSendMessageArray = [NSArray arrayWithArray:resendArrary];

        NSLog(@"fakeSendMessageArray.count=%lu", (unsigned long) fakeSendMessageArray.count);
        for (int i = 0; i < (int) fakeSendMessageArray.count; i++) {
            MsgModel *receiveMsgModel = fakeSendMessageArray[i];

            NSNumber *insertTime = receiveMsgModel.insert_time;

            int timeOut = ([nowTime intValue] - [insertTime intValue]) / 1000;

            DDLogDebug(@"checkTimeOut,timeOut==%d", timeOut);
            //超过120秒 认为是超时，通知 UI显示
            if (timeOut >= TIME_OUT) {

                DDLogDebug(@"removeSendArray,timeOut==%d", timeOut);
                [resendArrary removeObject:receiveMsgModel];

                NSString *where = [NSString stringWithFormat:@"ci=%@ and gid=%@",receiveMsgModel.ci,receiveMsgModel.gid];
                MsgModel *dbModel =  [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:where orderBy:nil];

                if(dbModel && [dbModel.msg_seq integerValue] >= LOCAL_SEQ){

                    dbModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                    [[QinCoreMain sharedInstance].dbHelper updateToDB:dbModel where:where];
                    [multicastDelegate didSendError:dbModel.ci seq:dbModel.msg_seq];
                }else{
                    dbModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;
                    [[QinCoreMain sharedInstance].dbHelper updateToDB:dbModel where:where];
                    [multicastDelegate didSendSuccess:dbModel.ci seq:dbModel.msg_seq];
                }

            } else {

//                dispatch_block_t block = ^{
                DDLogDebug(@"reSendArray start,timeOut==%d,msgSeq==%@", timeOut, receiveMsgModel.msg_seq);
                [resendArrary removeObject:receiveMsgModel];
                QinChatArg *args = [QinChatArg new];
                args.groupId = [receiveMsgModel.gid intValue];
                args.toType = [receiveMsgModel.to_type intValue];
                args.toId = [receiveMsgModel.to_id intValue];
                [weakSelf reSendMessage:args mesageSeq:[receiveMsgModel.msg_seq intValue]];
//                };
//
//                dispatch_async(sendMsgSerialQueue, block);

            }

        }
    }
}

- (void)sendSuccess:(id)dict {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        if (dict && [dict isKindOfClass:[NSDictionary class]]) {
            NSNumber *receiveCi = @([dict[@"ci"] intValue]);
            NSArray *fakeSendMessageArray = [NSArray arrayWithArray:_sendMessageArray];
            for (MsgModel *receiveMsgModel in fakeSendMessageArray) {
                if (receiveMsgModel != nil) {

                    if ([receiveMsgModel.ci intValue] == [receiveCi intValue]) {
                        DDLogDebug(@"sendMessage.removeTempMsg.ci::%@", receiveCi);
                        [weakSelf removeOneSendMessage:receiveMsgModel];

                        receiveMsgModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;//发送成功
                        receiveMsgModel.msg_seq = dict[@"msg_seq"];
                        receiveMsgModel.insert_time = dict[@"time"];
                        if (dict[@"img_url"] != nil) {

                            receiveMsgModel.imgurl = dict[@"img_url"];
                        }
                        if (dict[@"soundurl"] != nil) {
                            receiveMsgModel.soundurl = dict[@"soundurl"];
                        }

                        NSString *where = [NSString stringWithFormat:@"ci=%@",receiveMsgModel.ci];
                        MsgModel *dbModel =  [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:where orderBy:nil];

                        if(dbModel && [dbModel.msg_seq integerValue] >= LOCAL_SEQ){

                            
                            [[QinCoreMain sharedInstance].dbHelper updateToDB:receiveMsgModel where:[NSString stringWithFormat:@"ci=%@",receiveMsgModel.ci]];
                            RecentMsgUserModel *recentMsgUserModel = [weakSelf createRecentUser:receiveMsgModel];
                            [weakSelf saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];
                        }else{

                            [[QinCoreMain sharedInstance].dbHelper updateToDB:receiveMsgModel where:[NSString stringWithFormat:@"ci=%@",receiveMsgModel.ci]];
                        }
                        //通知UI发送成功
                        [multicastDelegate didSendSuccess:receiveCi seq:receiveMsgModel.msg_seq];

                    }

                }

            }


        }
    };
    QUEUE_CHECK
}
- (void)sendError:(MsgModel *)msgModel errorData:(id)dict {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        DDLogError(@"send msg Error:%@", dict);
        [weakSelf removeOneSendMessage:msgModel];
        msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;
        if (dict && [dict isKindOfClass:[NSDictionary class]]) {

            if (dict[@"c"]) {
                int c = [dict[@"c"] intValue];
                if (REQ_NOT_FRIEND == c) {
                    MsgModel *newMsg = [[MsgModel alloc] init];
                    newMsg.msg_seq = [QinCommonUtil makeLocalSeq];
                    newMsg.type = QinChatBodyText_EVENT;
                    newMsg.msg_state = QinMessage_SendStateTYPE_SUCCESS;

                    if ([msgModel.to_type integerValue] == QinMessage_TYPE_GROUP) {
                        newMsg.content = @"你已被移出本群，不能发送消息";

                    } else if ([msgModel.to_type integerValue] == QinMessage_TYPE_P2P) {
                        newMsg.content = @"你们不是群友了，只能发起好友对话";
                    } else {
                        newMsg.content = @"你还不是Ta的好友，暂不能发起好友聊天";
                        
//                        [[QinFriendService sharedInstance] updateFriendByUid:msgModel.to_id];
                    }

                    newMsg.gid = msgModel.gid;
                    newMsg.to_id = msgModel.to_id;
                    newMsg.to_type = msgModel.to_type;
                    newMsg.isLocal=1;

                    newMsg.insert_time = @([QinCommonUtil makeTimestamp]);
                    [[QinCoreMain sharedInstance].dbHelper insertToDB:newMsg];
                    QinMessage *receiveMsg = [MsgModel msgModelToQinMessage:newMsg];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [multicastDelegate didSendErrorNotFriend:receiveMsg];
                    });

                }
            }
        }
        if(msgModel){
            NSString *where = [NSString stringWithFormat:@"ci=%@",msgModel.ci];
            MsgModel *dbModel =  [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:where orderBy:nil];

            if(dbModel && [dbModel.msg_seq integerValue] >= LOCAL_SEQ){

                [[QinCoreMain sharedInstance].dbHelper updateToDB:msgModel where:where];
                [multicastDelegate didSendError:msgModel.ci seq:msgModel.msg_seq];
            }else{
                msgModel.msg_state = QinMessage_SendStateTYPE_SUCCESS;
                [[QinCoreMain sharedInstance].dbHelper updateToDB:msgModel where:where];
                [multicastDelegate didSendSuccess:msgModel.ci seq:msgModel.msg_seq];
            }
        }
    };
    QUEUE_CHECK
}

#pragma mark 消息未读数处理

- (int)getUnRead:(QinChatArg *)arg {
   
    DDLogDebug(@"getUnRead  to_type=%d,gid=%d,to_id=%d", arg.toType, arg.groupId, arg.toId);
    NSString *where = [NSString stringWithFormat:@"to_id=%d ", arg.toId];
    RecentMsgUserModel *recentMsgUserModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];
    if (recentMsgUserModel != nil) {
        return [recentMsgUserModel.unReadCount intValue];
    }
    return 0;
}

- (void)updateRecentMsgUserStatus:(QinChatArg *)arg status:(RECENTUSER_STATUS)status {
    if (QinMessage_TYPE_GROUP == arg.toType) {
        arg.toId = arg.groupId;
    }
    DDLogDebug(@"updateRecentMsgUserStatus  to_id=%ld,status=%ld", (long) arg.toId, (long) status);
    NSString *where = [NSString stringWithFormat:@"to_id=%ld ", (long) arg.toId];
   
    RecentMsgUserModel *recentMsgUserModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];


    if (recentMsgUserModel) {
        recentMsgUserModel.status = status;
        //插入未读消息
        [[QinCoreMain sharedInstance].dbHelper updateToDB:recentMsgUserModel where:where];
    }
}

- (void)removeUnRead:(QinChatArg *)arg {

    if (!arg) {
        return;
    }

    dispatch_block_t block = ^{

        NSString *where = [NSString stringWithFormat:@"to_id=%d", arg.toId];
        RecentMsgUserModel *recentMsgUserModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];

        if (recentMsgUserModel) {
            recentMsgUserModel.unReadCount = @(0);
            //插入未读消息
            [[QinCoreMain sharedInstance].dbHelper updateToDB:recentMsgUserModel where:where];
        }

    };
    if (dispatch_get_specific(queueKey)) {
        block();
    }
    else {
        dispatch_sync(serviceQueue, block);
    }
}

- (void)delRecentMsgUser:(QinChatArg *)arg {
   
    DDLogDebug(@"delRecentMsgUser to_id=%ld",  (long) arg.toId);

    dispatch_block_t block = ^{
        NSString *where = [NSString stringWithFormat:@"to_id=%d ", arg.toId];

        if ([[QinCoreMain sharedInstance].dbHelper deleteWithClass:[RecentMsgUserModel class] where:where]) {
            
            [[QinCoreMain sharedInstance].dbHelper deleteWithClass:[MsgModel class] where:where];
            DDLogDebug(@"delRecentMsgUser.to_id==%ld", (long) arg.toId);
        };


    };
    QUEUE_CHECK
}

/**
* 更新未读数，有则更新，无则添加
*/
- (void)updateUnreadCountVersion2:(MsgModel *)msgModel {

    dispatch_block_t block = ^{

        BOOL isMy = NO;
        if (msgModel.source && [msgModel.source integerValue] == [[[QinChatService sharedInstance].chatConfig uId] integerValue]) {

            isMy = YES;
        }
            NSInteger toId = 0;
            NSNumber *sourceId = msgModel.source;
            if (sourceId && [[[QinChatService sharedInstance].chatConfig uId] integerValue] != [sourceId integerValue]) {
                toId = intValueFromAnyObject(msgModel.source);
            } else {
                toId = intValueFromAnyObject(msgModel.to_id);
            }

        NSInteger gId = 0;
        NSInteger toType = intValueFromAnyObject(msgModel.to_type);


        NSString *where = [NSString stringWithFormat:@"to_id=%d", toId];
        RecentMsgUserModel *recentMsgUserModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[RecentMsgUserModel class] where:where orderBy:nil];

        if (recentMsgUserModel != nil) {

            if(!isMy){

                if (0 != [recentMsgUserModel.unReadCount intValue]) {


                    recentMsgUserModel.unReadCount = @([recentMsgUserModel.unReadCount intValue] + 1);

                } else {

                    recentMsgUserModel.unReadCount = @(1);

                }
            }


            recentMsgUserModel.msg_seq = [msgModel.msg_seq integerValue];
            recentMsgUserModel.insert_time = msgModel.insert_time;
            recentMsgUserModel.to_type = @(toType);
            [[QinCoreMain sharedInstance].dbHelper updateToDB:recentMsgUserModel where:where];
        } else {

            recentMsgUserModel = [[RecentMsgUserModel alloc] init];
            if(isMy){
                recentMsgUserModel.unReadCount = @(0);
            }else{

                recentMsgUserModel.unReadCount = @(1);
            }
            recentMsgUserModel.insert_time = msgModel.insert_time;
            recentMsgUserModel.to_id = @(toId);
            recentMsgUserModel.status = 0;
            recentMsgUserModel.to_type = @(toType);
            recentMsgUserModel.msg_seq = [msgModel.msg_seq integerValue];
            [[QinCoreMain sharedInstance].dbHelper insertToDB:recentMsgUserModel];
        }

    };
    QUEUE_CHECK
}


- (void)saveMsgVersion2:(MsgModel *)msgModel {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{

        [msgModel checkModel];
        
        QinChatArg *arg = [QinChatArg new];
        if (msgModel.to_type)
            arg.toType = [msgModel.to_type integerValue];
        if (msgModel.to_id)
            arg.toId = [msgModel.to_id integerValue];
        if (msgModel.gid)
            arg.groupId = [msgModel.gid integerValue];

        if ([weakSelf findMessage:arg messageSeq:[msgModel.msg_seq integerValue]]) {
            return;
        }
        
        if(msgModel.nickname){
            QinUserModel *user = [QinUserModel new];
            user.name = msgModel.nickname;
            user.uid = msgModel.source;
            user.avatar = msgModel.avatar;
            
            [[QinCoreMain sharedInstance].dbHelper insertToDB:user callback:nil];
            
        }
            [weakSelf updateUnreadCountVersion2:msgModel];
            //入库
            [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
    };
    QUEUE_CHECK
}


- (BOOL)findMessage:(QinChatArg *)arg messageSeq:(NSInteger)seq {
    if (QinMessage_TYPE_GROUP == arg.toType) {
        arg.toId = arg.groupId;
    }

    DDLogDebug(@"findMessage  to_type=%d,to_id=%d,seq=%d", arg.toType,arg.toId, seq);
    MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:MESSAGE_WHERE orderBy:nil];

    if (msgModel && msgModel != nil) {
        return YES;
    }
    return NO;
}

- (void)updateVideoMessage:(QinChatArg *)arg messageSeq:(int)seq videoStatus:(NSInteger)videoStatus content:(NSString *)content {
    if (QinMessage_TYPE_GROUP == arg.toType) {
        arg.toId = arg.groupId;
    }
    dispatch_block_t block = ^{

        DDLogDebug(@"updateVideoMessage  to_type=%ld,to_id=%ld,seq=%d", (long) arg.toType, (long) arg.toId, seq);

        MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:MESSAGE_WHERE orderBy:nil];

        if (msgModel != nil) {
            msgModel.video_status = videoStatus;
            msgModel.content = content;

            [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
        }

    };

    QUEUE_CHECK
}

- (void)socketDisconnect {

    [reconnect stop];
    [[QinNetManager sharedInstance] disconnect];
}

- (void)socketConnect {

    [reconnect start];
    [[QinNetManager sharedInstance] connect];
}


/**
 * 判断消息是否在发送中
 */
- (BOOL)isSending:(MsgModel *)msgModel {
    if (resendArrary.count > 0) {

        NSArray *sendingArray = [NSArray arrayWithArray:resendArrary];

        for (MsgModel *sendingMsg in sendingArray) {
            if ([sendingMsg.ci integerValue] == [msgModel.ci integerValue])
                return YES;
        }
    }
    return NO;
}

/**
 * 判断消息是否在失败队列中
 */
- (BOOL)isSendError:(MsgModel *)msgModel {
    if (_sendMessageArray.count > 0) {

        NSArray *sendingArray = [NSArray arrayWithArray:_sendMessageArray];

        for (MsgModel *sendingMsg in sendingArray) {
            if ([sendingMsg.ci integerValue] == [msgModel.ci integerValue])
                return YES;
        }
    }
    return NO;
}

/**
 * 判断消息是否是已发送成功
 */
- (void)checkSendSuccess:(MsgModel *)msgModel {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        if (msgModel) {
            NSString *whereStr = [NSString stringWithFormat:@"ci=%@ ", msgModel.ci];
            NSArray *msgModelArray = [[QinCoreMain sharedInstance].dbHelper search:[MsgModel class] where:whereStr orderBy:@"" offset:0 count:0];

            if (msgModelArray && msgModelArray.count > 1) {

                for (MsgModel *msg in msgModelArray) {

                    if ([msg.msg_seq integerValue] > LOCAL_SEQ) {

                        /**删除临时消息 start*/
                        QinChatArg *arg = [[QinChatArg alloc] init];
                        arg.groupId = [msg.gid intValue];
                        arg.toType = [msg.to_type intValue];
                        arg.toId = [msg.to_id intValue];
                        [weakSelf deleteMessage:arg messageSeq:[msg.msg_seq integerValue]];
                        /**删除临时消息 end*/
                    }
                }
            } else {
                msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                if (![weakSelf isSending:msgModel]) {
                    [resendArrary addObject:msgModel];
                }
                [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
                RecentMsgUserModel *recentMsgUserModel = [weakSelf createRecentUser:msgModel];
                [weakSelf saveRecentUser:recentMsgUserModel status:UNREAD_TYPE_NORMAL];
            }
        }
    };
    QUEUE_CHECK
}


/**
 * 上传文件
 */
- (void)uploadFile:(MsgModel *)msgModel filePath:(NSString *)filePath {

    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        DDLogDebug(@"uploadFile.uploading..  ci=%@, seq=%@,filePath=%@", msgModel.ci, msgModel.msg_seq, filePath);

        QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
        if (msgModel.type == QinChatBodyText_SMAlL_VIDEO) {
            httpProtocol.requestUrl = [[QinConfigInfo getUploadServerUrl] stringByAppendingString:[QinCommonUtil setUpLoadUrlStr:QinChatBodyText_IMAGE]];
        } else {
            httpProtocol.requestUrl = [[QinConfigInfo getUploadServerUrl] stringByAppendingString:[QinCommonUtil setUpLoadUrlStr:(QinChatBodyMsg_TYPE) msgModel.type]];
        }

        httpProtocol.method = @"post";
        httpProtocol.token = _chatConfig.token;
        httpProtocol.deviceId = _chatConfig.deviceId;
        httpProtocol.formType = QinHttpProtocol_FROMTYPE_NORMAL;
        httpProtocol.ci = [msgModel.ci integerValue];
        httpProtocol.filePath = filePath;
        httpProtocol.seq = msgModel.msg_seq;
        [[QinHttpManager sharedInstance] uploadFie:httpProtocol success:^(QinHttpProtocol *aProtocol) {

            if (aProtocol.data && [aProtocol.data isKindOfClass:[NSDictionary class]]) {
                id obj = aProtocol.data[@"u"];
                if (obj) {
                    //图片消息,判断是否有音频文件需要上传
                    if (msgModel.type == QinChatBodyText_IMAGE) {
                        if (msgModel.sound_local_url && ![msgModel.sound_local_url isEqualToString:@""]) {

                            msgModel.imgurl = obj;

                            NSString *audioUrl = [QinCommonUtil getAudioPathWithFileName:msgModel.sound_local_url];
                            if (audioUrl && ![audioUrl isEqualToString:@""]) {
                                [weakSelf uploadAudioFile:msgModel filePath:audioUrl type:QinChatBodyText_AUDIO];
                            }
                        } else {
                            [weakSelf confirmSendMessage:aProtocol.ci url:obj isAudio:0 audioUrl:nil];
                        }
                    } else if (msgModel.type == QinChatBodyText_SMAlL_VIDEO) {

                        msgModel.imgurl = obj;
                        if (msgModel.content) {
                            QinChatSmallVideoContent *videoContent = [QinChatSmallVideoContent new];

                            NSDictionary *dict = [msgModel.content objectFromJSONString];
                            videoContent.filelen = dict[@"filelen"];
                            videoContent.filelocalurl = dict[@"filelocalurl"];
                            videoContent.filesize = dict[@"filesize"];
                            if (videoContent.filelocalurl) {
                                NSString *videoUrl = [QinCommonUtil getVideoPathWithFileName:videoContent.filelocalurl];
                                [weakSelf uploadAudioFile:msgModel filePath:videoUrl type:QinChatBodyText_SMAlL_VIDEO];
                            }

                        }
                    } else {

                        [weakSelf confirmSendMessage:aProtocol.ci url:obj isAudio:0 audioUrl:nil];
                    }
                }
            }


        }                                  failure:^(NSError *error) {
            NSDictionary *dict = error.userInfo;
            DDLogDebug(@"uploadFile.uploadfail errorDict::%@", dict);
            id resion = dict[@"reason"];

            if (resion && [resion isKindOfClass:[NSDictionary class]]) {

                NSNumber *ci = [resion objectForKey:@"ci"];
                NSNumber *seq = [resion objectForKey:@"seq"];
                if (ci && seq) {
                    NSString *whereStr = [NSString stringWithFormat:@"ci=%@", ci];
                    MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:whereStr orderBy:@""];

                    if (msgModel) {
                        msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;

                        if (![weakSelf isSending:msgModel]) {
                            [resendArrary addObject:msgModel];
                        }
                        [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
                    }
                }
            }
        }];
    };
    QUEUE_CHECK
}

/**
 * 上传文件
 */
- (void)uploadAudioFile:(MsgModel *)msgModel filePath:(NSString *)filePath type:(QinChatBodyMsg_TYPE)type {
    __weak __typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        DDLogDebug(@"uploadAudioFile.uploading.. seq=%@,filePath=%@", msgModel.msg_seq, filePath);
        QinHttpProtocol *httpProtocol = [[QinHttpProtocol alloc] init];
        httpProtocol.requestUrl = [[QinConfigInfo getUploadServerUrl] stringByAppendingString:[QinCommonUtil setUpLoadUrlStr:type]];
        httpProtocol.method = @"post";
        httpProtocol.token = _chatConfig.token;
        httpProtocol.deviceId = _chatConfig.deviceId;
        httpProtocol.formType = QinHttpProtocol_FROMTYPE_NORMAL;
        httpProtocol.ci = [msgModel.ci integerValue];
        httpProtocol.filePath = filePath;
        httpProtocol.seq = msgModel.msg_seq;
//        httpProtocol.param = @{@"gid" : msgModel.gid};

        [[QinHttpManager sharedInstance] uploadFie:httpProtocol success:^(QinHttpProtocol *aProtocol) {

            DDLogDebug(@"uploadAudioFile.uploadSuccess dict::%@", aProtocol.data);

            if (aProtocol.data && [aProtocol.data isKindOfClass:[NSDictionary class]]) {
                id obj = [aProtocol.data objectForKey:@"u"];
                if (obj) {

                    if (type == QinChatBodyText_SMAlL_VIDEO) {

                        QinChatSmallVideoContent *videoContent = [QinChatSmallVideoContent new];

                        NSDictionary *dict = [msgModel.content objectFromJSONString];
                        videoContent.filelen = dict[@"filelen"];
                        videoContent.filelocalurl = dict[@"filelocalurl"];
                        videoContent.filesize = dict[@"filesize"];

                        NSRange range = [obj rangeOfString:@"/" options:NSBackwardsSearch];
                        if (range.location != NSNotFound) {

                            NSString *newName = [obj substringFromIndex:range.location + 1];
                            if (newName)
                                [QinCommonUtil moveItemToDir:[QinCommonUtil getVideoPathWithFileName:videoContent.filelocalurl] dir:[QinCommonUtil getVideoPathWithFileName:newName]];
                        }

                        videoContent.fileurl = obj;
                        msgModel.content = [videoContent mj_JSONString];
                        [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];

                    }

                    [weakSelf confirmSendMessage:aProtocol.ci url:msgModel.imgurl isAudio:0 audioUrl:nil];
                }
            }


        }                                  failure:^(NSError *error) {
            NSDictionary *dict = error.userInfo;
            DDLogDebug(@"uploadAudioFile.uploadfail errorDict::%@", dict);
            id resion = [dict objectForKey:@"reason"];

            if (resion && [resion isKindOfClass:[NSDictionary class]]) {

                NSNumber *ci = [resion objectForKey:@"ci"];
                NSNumber *seq = [resion objectForKey:@"seq"];
                if (ci && seq) {
                    NSString *whereStr = [NSString stringWithFormat:@"ci=%@ ", ci];
                    MsgModel *msgModel = [[QinCoreMain sharedInstance].dbHelper searchSingle:[MsgModel class] where:whereStr orderBy:@""];
                    if (msgModel) {
                        msgModel.msg_state = QinMessage_SendStateTYPE_FAILED;
                        if (![weakSelf isSending:msgModel]) {
                            [resendArrary addObject:msgModel];
                        }

                        [[QinCoreMain sharedInstance].dbHelper insertToDB:msgModel];
                    }

                }
            }
        }];
    };

    QUEUE_CHECK
}
- (int)getUnReadSumCount{

    NSArray *listModel = [[QinCoreMain sharedInstance].dbHelper search:[RecentMsgUserModel class] where:[NSString stringWithFormat:@"to_id!=%d", [uId integerValue]] orderBy:@"CAST(status as integer) desc,CAST(insert_time as integer) desc" offset:0 count:0];
    int sumCount = 0;
    if(listModel && listModel.count > 0){
    
        for(RecentMsgUserModel *recentUser in listModel){
        
            sumCount += [recentUser.unReadCount integerValue];
        }
    }
    return sumCount;
}

-(void)createPullMessageTimer{

    [[QinGCDTimer sharedInstance] cancelTimerWithName:@"msgPullTimer"];
    __weak typeof(self) weakSelf = self;
    [[QinGCDTimer sharedInstance] scheduledDispatchTimerWithName:@"msgPullTimer"
                                                    timeInterval:10
                                                           queue:nil
                                                         repeats:YES
                                                    actionOption:AbandonPreviousAction
                                                          action:^{
                                                              [weakSelf getNewMessagesVersion2];
                                                          }];
}

-(void)cancelPullMessageTimer{

    [[QinGCDTimer sharedInstance] cancelTimerWithName:@"msgPullTimer"];
}

@end

//
//  QinMsgModel2InfoUtil.m
//  QinCore
//
//  Created by LEI on 15/8/13.
//  Copyright (c) 2015年 kinstalk.com. All rights reserved.
//

#import "QinMsgModel2InfoUtil.h"
#import "JSONKit.h"
#import "QinParser.h"
#import "NSObject+MJKeyValue.h"

@implementation QinMsgModel2InfoUtil

/**
 *  从新字典中组合出需要的字典
 *
 *  @param useArray 需要字段的key值
 *  @param allDic   源字典库
 *
 *  @return 新组合的字典
 */
+ (NSDictionary*)exceptNoUseDic:(NSArray*)useArray dic:(NSDictionary*)allDic
{
    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
    
    //只保留需要的字段
    for( id keyname in useArray)
    {
        if( nil == [allDic objectForKey:keyname] )
        {
            DDLogDebug(@"发送时候没有%@参数",keyname);
            continue;
        }
        
        [resultDic setObject:[allDic objectForKey:keyname] forKey:keyname];
    }
    
    return resultDic;
}

+ (NSDictionary*)toProtocol:(NSDictionary *)dict{

    NSDictionary* newResultDic = @{@"t": @(HTTP_REQUREST),@"v":@1,@"d":dict};
    return newResultDic;
}

+ (NSDictionary*)QinMsgModel2InfoDic:(MsgModel*)msgModel
{
    NSDictionary* resultDic = nil;
    
    if( nil == msgModel)
        return nil;
    
    NSMutableDictionary* modelDic = [msgModel mj_keyValues];
    
    if( nil == modelDic )
        return nil;
    
    DDLogDebug(@"QinMsgModel2InfoDic:%@",modelDic);
    
    switch (msgModel.type) {
        case QinChatBodyText_TEXT:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_TEXT");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_IMAGE:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_IMAGE");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"btype",@"forward",
                                 @"imgurl",@"imgsize",@"imgaddr",@"lon",@"lat",@"soundurl",@"soundlen"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_HANDWRITE:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_HANDWRITE");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"imgurl",@"imgsize",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_AUDIO:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_AUDIO");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"forward",@"soundurl",@"soundlen",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_FACE:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_FACE");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_CARD:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_CARD");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"ci",@"type",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_LOCATION:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_LOCATION");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype",@"imgurl",@"imgsize",@"imgaddr",@"lon",@"lat"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_SHARE:
            break;
        case QinChatBodyText_IMAGETAG:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_IMAGETAG");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_DELTAG:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_DELTAG");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_CHGTAG:
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_CHGTAG");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"content",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_EVENT:
            break;
        case QinChatBodyText_TEMP_TIMEMACHINE:
            break;
        case QinChatBodyText_TRANSFER:
            break;
        case QinChatBodyText_TEMP_AUDIO:
            break;
        case QinChatBodyText_SNAP_CHAT:  //阅后即焚
        {
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"content",@"ci",@"btype"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        };
            break;
        case QinChatBodyText_SMAlL_VIDEO://小视频
        {

            /**
             *  content json 格式说明
              {
                    "fileurl":string, //视频url
                    "filesize":int, //视频文件大小
                    "filelen":int, //视频时长
                }
             * */
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_SMAlL_VIDEO");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"btype",@"forward",
                    @"imgurl",@"imgsize",@"content"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        };
            break;
        case QinChatBodyText_VIDEO_FILE://视频文件
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_VIDEO_FILE");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"btype",@"forward",
                    @"imgurl",@"imgsize",@"content"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        case QinChatBodyText_VIDEO: //视频通话
        {
            DDLogDebug(@"QinMsgModel2InfoDic:QinChatBodyText_VIDEO_FILE");
            NSArray* reserve = @[@"to_type",@"to_id",@"gid",@"type",@"ci",@"btype",@"content"];
            resultDic = [QinMsgModel2InfoUtil exceptNoUseDic:reserve dic:modelDic];
        }
            break;
        default:
        {
            DDLogError(@"不认识的msgType:%ld",(long)msgModel.type);
            break;
        }
    }
    //加入at
    if (msgModel.at) {
        NSMutableDictionary *atdic = [NSMutableDictionary dictionaryWithDictionary:resultDic];
        atdic[@"at"] = msgModel.at;
        
        resultDic = [NSDictionary dictionaryWithDictionary:atdic];
    }
    
    /**新协议发送格式组装
     * {
     "t":int,//消息业务类型
     "v":int,//业务协议版本号
     "d":{//业务层协议}
     }
     * */
    NSDictionary* newResultDic = @{@"t": @1,@"v":@1,@"d":resultDic};
    
    return newResultDic;
}

@end

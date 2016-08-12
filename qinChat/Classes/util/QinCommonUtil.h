//
// Created by 祥龙 on 15/8/11.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinCoreEnum.h"


typedef NS_ENUM(NSInteger,ConstantsV)
{
    CLIENT_ACK = 300, //clientack
    STEWARD_ID=9998,
    STEWARD_GROUP_ID=-1,
    
    
};

#define STEWARD_NAME @"奇技客服"

typedef enum INFO_TYPE
{
    INFO_CHAT = 1, //clientack
    INFO_NOTIFY=2, //应用内通知消息
    
    
} INFO_TYPE;
@interface QinCommonUtil : NSObject
{
    Byte* v;
}
-(NSData*)MakeJson: (NSDictionary *)dictData;
-(void)setVersion:(Byte*)v;
-(NSString *)Decode:(NSString *)str;
-(NSString*)getJSon:(NSDictionary *)dictData;
-(Byte *)getVersion;

///////////////////////////////时间相关///////////////////////////////
//生成当前时间戳
+(UInt64)makeTimestamp;

//转换时间戳字符
+(NSDate*)praseTimestamp:(NSString *)timestampstr;
//时间戳转换成字符串 //YYYY-MM-DD
+(NSString*)convertDateToString:(UInt64)btime;
//时间戳转换成字符串 //YYYY.MM.DD
+(NSString*)convertDatePointToString:(UInt64)btime;
//时间戳转换成字符串 //MM-DD:HH:mm
+(NSString*)convertCollectDateToString:(UInt64)btime;
+(NSString*)convertHanDateToString:(UInt64)btime;
+(NSString*)convertHMDateToString:(UInt64)btime;
+(NSString*)convertCollectDateToStringForDiscovery:(UInt64)btime;
//NSDate转换成时间戳
+ (UInt64)convertTimeStampByDate:(NSDate*)ndate;
//距离当前时间－剩余时间
+ (NSString *)intervalSinceNow:(NSNumber *)timeStamp;
//几分钟／几小时／几天前
+ (NSString *)intervalMinSinceNow:(NSNumber *)theDate_t;
//时间处理
+(NSString*)handleDateToString:(UInt64)btime;

+(double) MachTimeToSecs:(uint64_t) time;


+(NSString*)convertCollectDateToString1:(NSNumber *)btime;

//最后拉取时间
+(void) saveLastPullTime:(NSString *)time;

//获取最后拉取时间
+(NSString *) getLastPullTime;

//最后拉取时间
+(void) saveLastPullTime:(NSString *)key time:(NSNumber *)time;

//获取最后拉取时间
+(NSNumber *) getLastPullTime:(NSString *)key;
/**
 * 保存本地最大临时seq
 */
+(void) saveLocalMaxSeq:(NSNumber *)seq;
/**
 * 删除本地时间
 */
+(void) removeLastPullTime:(NSString *)key;
/**
 * 获取本地最大临时seq
 */
+(NSNumber *) getLocalMaxSeq;

+(NSNumber *) makeLocalSeq;


+(void)savPushToken:(NSString*)pushtoken;

//服务器VOIPPUsh需要的token
+(void)saveVoipPushToken:(NSString*)pushtoken;
+(NSString*)getVoipPushToken;

/**
 *  保存Voip离线推送的VOIP_PAYLOAD_DIC
 *
 */
+ (void)saveVoipPayLoadDic:(NSDictionary*)dicwithPayLoad;
+ (NSDictionary*)getVoipPayLoadDic;
+ (void)clearVoipPayLoadDic;

-(BOOL)addNetUrl:(NSString *)url time:(NSNumber *)time;
+ (NSString *)setUpLoadUrlStr:(QinChatBodyMsg_TYPE)msgType;
+ (NSString *)getAudioPath;
+ (NSString *)getAudioPathWithFileName:(NSString *)file;
+ (NSString *)getPhotoPath;
+ (NSString *)getPhotoPathWithFileName:(NSString *)file;
+ (NSString *)getVideoPathWithFileName:(NSString *)file;
+ (NSString *)getHttpServerPath;
+ (BOOL)isExist:(NSString *)file;
+ (void)moveItemToDir:(NSString*)file_path dir:(NSString*)dirPath;
+ (void)moveDB:(NSString *)dbName;
@end
//
// Created by LEI on 15/8/11.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <MacTypes.h>
#import "QinCommonUtil.h"
#import "JSONKit.h"
#import "NSData+CommonCrypto.h"
#import "QinServiceConstants.h"
#import "QinCoreEnum.h"

@implementation QinCommonUtil {
    
    NSMutableDictionary *_urlDict;
}

+ (NSString *)convertCollectDateToString:(UInt64)btime {
    return nil;
}

+ (NSString *)convertHanDateToString:(UInt64)btime {
    return nil;
}

+ (NSString *)convertCollectDateToStringForDiscovery:(UInt64)btime {
    return nil;
}

+ (NSString *)handleDateToString:(UInt64)btime {
    return nil;
}

+ (double)MachTimeToSecs:(uint64_t)time {
    return 0;
}

+ (NSString *)convertCollectDateToString1:(NSNumber *)btime {
    return nil;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        v = nil;
        _urlDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSString*)getJSon:(NSDictionary *)dictData
{
    return [dictData JSONString];
}
-(NSData*)MakeJson:(NSDictionary *)dictData
{
    NSData *jsonDataresult = [dictData JSONData];
    return [self Encode:jsonDataresult];
    
}
-(NSData *)Encode:(NSData *)data
{
    NSError* error=nil;
    NSData *endata = [data AES256EncryptedDataUsingKey:@"sfe023f_9fd&fwfl" error:&error];
    
    
    return endata;
}
-(NSString *)Decode:(NSString *)str
{
    return str;
}
-(void)setVersion:(Byte*)Version
{
    v = malloc(sizeof(Byte)*3);
    memset(v, 0, 3);
    memcpy(v, Version, 2);
}

- (Byte *)getVersion {
    return v;
}

//生成当前时间戳 毫秒
+(UInt64)makeTimestamp
{
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    //    DDLogDebug( @"%lld", recordTime);
    return recordTime;
}
//生成当前时间戳秒
+(UInt64)makeTimestampold
{
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970];
    //    DDLogDebug(@"=== %lld", recordTime);
    return recordTime;
}
//转换时间戳字符
+(NSDate*)praseTimestamp:(NSString *)timestampstr
{
    double timeNum = [timestampstr doubleValue];
    NSDate *date =  [NSDate dateWithTimeIntervalSince1970:timeNum];
    return date;
}
+ (UInt64)convertTimeStampByDate:(NSDate*)ndate
{
    //减去120的原因是因为本地时间可能会比服务器快
    UInt64 result = (ndate.timeIntervalSince1970 ) * 1000;
    
    return result;
}

+ (NSString *)intervalSinceNow:(NSNumber *)theDate_t
{
    /*
     NSArray *timeArray=[theDate componentsSeparatedByString:@"."];
     theDate=[timeArray objectAtIndex:0];
     
     NSDateFormatter *date=[[NSDateFormatter alloc] init];
     [date setDateFormat:@"yyyy-MM-dd"];
     NSDate *d=[date dateFromString:theDate];
     */
    NSTimeInterval late=[theDate_t  longLongValue]/1000;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late-now;
    NSString * titleStr = @"还有";
    if (late<now) {
        titleStr = @"已过";
        cha = now - late;
    }
    //    if (cha/3600<1) {
    //        timeString = [NSString stringWithFormat:@"%f", cha/60];
    //        timeString = [timeString substringToIndex:timeString.length-7];
    //        timeString=[NSString stringWithFormat:@"%@%@分", titleStr,timeString];
    //
    //    }
    //    if (cha/3600>1&&cha/86400<1) {
    //        timeString = [NSString stringWithFormat:@"%f", cha/3600];
    //        timeString = [timeString substringToIndex:timeString.length-7];
    //        timeString=[NSString stringWithFormat:@"%@%@小时",titleStr,timeString];
    //    }
    if (cha/86400>1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@ %@", titleStr,timeString];
        
    }else{
        timeString = [NSString stringWithFormat:@"%@ 1",titleStr];
        if (late<now) {
            timeString = [NSString stringWithFormat:@"%@ 0",titleStr];
        }
        
    }
    return timeString;
}

+ (NSString *)intervalMinSinceNow:(NSNumber *)theDate_t
{
    NSTimeInterval late=[theDate_t  longLongValue]/1000;
    
    NSDate* dat = [NSDate date];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha = 0.0;
    
    if (late<now) {
        cha = now - late;
    }
    if (cha/3600<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
        return timeString;
        
    }
    if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前",timeString];
        return timeString;
    }
    if (cha/86400>1 && cha/86400<2)
    {
        //        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        //        timeString = [timeString substringToIndex:timeString.length-7];
        //        timeString=[NSString stringWithFormat:@"%@ %@", titleStr,timeString];
        
        timeString = @"昨天";
        return timeString;
        
    }
    if (cha/86400>2) {
        timeString = [NSString stringWithFormat:@"%f",cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前",timeString];
        return timeString;
    }
    return timeString;
}



+(NSString*)convertDateToString:(UInt64)btime
{
    NSDate* birdate = [NSDate dateWithTimeIntervalSince1970:btime/1000];
    
    //NSLog(@"%@",birdate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:birdate];
}

+(NSString*)convertDatePointToString:(UInt64)btime {
    
    NSDate* birdate = [NSDate dateWithTimeIntervalSince1970:btime/1000];
    
    //NSLog(@"%@",birdate);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    
    return [dateFormatter stringFromDate:birdate];
}



+(NSString*)convertHMDateToString:(UInt64)btime {
    
    if( btime <= 0 )
        return @"";
    
    NSDate* creteDate = [NSDate dateWithTimeIntervalSince1970:btime/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    formatter.dateFormat = @"HH:mm";
    return [formatter stringFromDate:creteDate];
}


+(void) saveLastPullTime:(NSString *)time
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setValue:time forKey:@"lastPullTime"];
    [user synchronize];
}
+(NSString *) getLastPullTime
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:@"lastPullTime"];
}

+(void) saveLastPullTime:(NSString *)key time:(NSNumber *)time
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setValue:time forKey:key];
    [user synchronize];
}
+(NSNumber *) getLastPullTime:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    return [user objectForKey:key];
}
+(void) removeLastPullTime:(NSString *)key
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:key];
    [user synchronize];
}
/**
 * 保存本地最大临时seq
 */
+(void) saveLocalMaxSeq:(NSNumber *)seq
{
    NSUserDefaults *maxSeq = [NSUserDefaults standardUserDefaults];
    [maxSeq setValue:seq forKey:@"localMaxSeq"];
    [maxSeq synchronize];
}
/**
 * 获取本地最大临时seq
 */
+(NSNumber *) getLocalMaxSeq
{
    NSUserDefaults *maxSeq = [NSUserDefaults standardUserDefaults];
    return [maxSeq objectForKey:@"localMaxSeq"];
}

+ (NSNumber *)makeLocalSeq {
    
    NSNumber *seq = [self getLocalMaxSeq];
    if(seq== nil){
        
        [self saveLocalMaxSeq:[NSNumber numberWithInt:LOCAL_SEQ]];
        return [NSNumber numberWithInt:LOCAL_SEQ];
    } else{
        
        seq =  @([seq intValue] + 1);
        
        
        [self saveLocalMaxSeq:seq];
        
        return seq;
    }
    
    //    return nil;
}

+(void)savPushToken:(NSString*)pushtoken {
    
    [[NSUserDefaults standardUserDefaults] setObject:pushtoken forKey:@"pushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)saveVoipPushToken:(NSString*)pushtoken
{
    
    [[NSUserDefaults standardUserDefaults] setObject:pushtoken forKey:@"voipPushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSString*)getVoipPushToken
{
    NSString *tokenstr = [[NSUserDefaults standardUserDefaults]objectForKey:@"voipPushToken"];
    return tokenstr;
}

+ (void)saveVoipPayLoadDic:(NSDictionary*)dicwithPayLoad;
{
    if( dicwithPayLoad && (dicwithPayLoad.count > 0) )
    {
        NSDictionary* dic = @{@"payLoad":dicwithPayLoad , @"lastTime":@([[NSDate date] timeIntervalSince1970])};
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"VOIP_PAYLOAD_DIC"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (NSDictionary*)getVoipPayLoadDic
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"VOIP_PAYLOAD_DIC"];
}

+ (void)clearVoipPayLoadDic
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"VOIP_PAYLOAD_DIC"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)addNetUrl:(NSString *)url time:(NSNumber *)time{
    
    NSString *urlTime = [NSString stringWithFormat:@"%@%@",url,time];
    
    DDLogDebug(@"addNetUrl.urlTime:%@",urlTime);
    
    if(![_urlDict objectForKey:urlTime]){
        
        DDLogDebug(@"addNetUrl.key is not find:%@",urlTime);
        [_urlDict setValue:time forKey:urlTime];
        
        return YES;
        
    } else{
        
        return NO;
    }
    
    return NO;
}

-(void)removeNetUrl:(NSString *)url time:(NSNumber *)time{
    
    NSString *urlTime = [NSString stringWithFormat:@"%@%@",url,time];
    
    DDLogDebug(@"removeNetUrl.urlTime:%@",urlTime);
    [_urlDict removeObjectForKey:urlTime];
    
}

+ (NSString *)setUpLoadUrlStr:(QinChatBodyMsg_TYPE)msgType {
    NSString *suffx = nil;
    switch (msgType) {
        case QinChatBodyText_IMAGE:
            suffx = @"/upload.do";
            break;
        case QinChatBodyText_HANDWRITE:
            suffx = @"/upload.do";
            break;
        case QinChatBodyText_LOCATION:
            suffx = @"/upload.do";
            break;
        case QinChatBodyText_AUDIO:
            suffx = @"/vupload.do";
            break;
        case QinChatBodyText_SMAlL_VIDEO:
            suffx = @"/video/upload.do";
            break;
        default:
            break;
    }
    return suffx;
}


+ (NSString *)getAudioPath {
    return [[self getBasePath] stringByAppendingPathComponent:@"AudioCache"];
}

+ (NSString *)getAudioPathWithFileName:(NSString *)file {
    if (!file) {
        return @"";
    }
    return [[self getAudioPath] stringByAppendingPathComponent:file];
}

+ (NSString *)getPhotoPath {
    return [[self getBasePath] stringByAppendingPathComponent:@"PhotosCache"];
}

+ (NSString *)getPhotoPathWithFileName:(NSString *)file {
    if (!file) {
        return @"";
    }
    return [[self getPhotoPath] stringByAppendingPathComponent:file];
}

+ (NSString *)getVideoPathWithFileName:(NSString *)file {
    if (!file) {
        return @"";
    }
    return [[self getHttpServerPath] stringByAppendingPathComponent:file];
}
+ (NSString *)getHttpServerPath
{
    return [[self getBasePath] stringByAppendingPathComponent:@"VideosCache"];
}

+ (NSString *)getBasePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
+ (BOOL)isExist:(NSString *)file
{
    BOOL tf = YES;
    NSFileManager *nfm = [NSFileManager defaultManager];
    BOOL isDir;
    BOOL isExist = [nfm fileExistsAtPath:file isDirectory:&isDir];
    if (isExist == NO || isDir == YES) {
        tf = NO;
        return tf;
    }
    tf = [nfm fileExistsAtPath:file];
    return tf;
}

+ (void)moveItemToDir:(NSString*)file_path dir:(NSString*)dirPath
{
    if([self isExist:file_path]){
        NSFileManager * manager = [NSFileManager defaultManager];

        [manager copyItemAtPath:file_path toPath:dirPath error:nil];
//        [manager copyItemAtPath:<#(NSString *)srcPath#> toPath:<#(NSString *)dstPath#> error:<#(NSError **)error#>];

    }

}
+ (NSString*)getDocumentPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

+ (NSString*)getLibraryPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
+ (void)moveDB:(NSString *)dbName
{
    NSString* dirPath = [[self getDocumentPath] stringByAppendingPathComponent:@"db"];
    BOOL isDir = NO;
    BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir];
    if (isCreated) {
        
        NSString *dbPath = [dirPath stringByAppendingPathComponent:dbName];
        
        BOOL isDbCreated = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
        
        if(isDbCreated == NO){
            return ;
        }
        
        NSString* toDirPath = [[self getLibraryPath] stringByAppendingPathComponent:@"db"];
        
        NSString * toDBPath = [toDirPath stringByAppendingPathComponent:dbName];
        BOOL isCreated2Dir = [[NSFileManager defaultManager] fileExistsAtPath:toDBPath];
        if (isCreated2Dir) {
            
            [[NSFileManager defaultManager] removeItemAtPath:toDBPath error:nil];
        }else{
            BOOL isDir = NO;
            BOOL isCreated = [[NSFileManager defaultManager] fileExistsAtPath:toDirPath isDirectory:&isDir];
            if (isCreated == NO || isDir == NO) {
                NSError* error = nil;
                BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:toDirPath withIntermediateDirectories:YES attributes:nil error:&error];
                if (success == NO)
                    NSLog(@"create dir error: %@", error.debugDescription);
            }
        }
         NSError *error = nil;
         [[NSFileManager defaultManager] copyItemAtPath:dbPath toPath:toDBPath error:&error];
        if(!error){
        [[NSFileManager defaultManager] removeItemAtPath:dbPath error:nil];
        }

    }
}

@end

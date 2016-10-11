//
// Created by LEI on 15/10/20.
//

#import "QinConfigInfo.h"
#import "QinHttpProtocol.h"
#import "QinHttpManager.h"
#import "QinCommonUtil.h"
#import "QinBeanUtil.h"
#import "QinDynamicConfig.h"
#import "NSObject+MJKeyValue.h"

#define kGetServerConfigTime    60 * 60 * 1        //1小时
@implementation QinConfigInfo {

}

IMP_SINGLETON(QinConfigInfo)
- (instancetype)init {
    self = [super init];
    if (self) {
        [self initFromLocal];
    }

    return self;
}
- (id)initConfigInfo:(NSInteger)env
{
    self = [super init];
    
    self.h5ServerUrl=@"";
    
    //0为线上环境，  1为线上测试环境  2为公司开发环境
    if(env==0){
       _connectServerUrl = @"https://cs.kinstalk.com";
    }else if(env==1){
         _connectServerUrl = @"https://test-cs.kinstalk.com";
    }else if (env==2){
         _connectServerUrl = @"https://dev-cs.kinstalk.com";
    }

        if (self) {
            //TODO 从配置文件中下载数据，并填上正确地址
            if(![self initFromLocal]){
                self.dyConfig= [[NSDictionary alloc] init];
                //如果没有初始化成功，用以下默认配置。
                if (env==0) {
                    self.chatServerIP = @"54.223.178.102";
                    self.chatServerPort=8001;
                    //FIXME 这里需要改成线上的域名
                    self.apiServerUrl=@"https://api.kinstalk.com";
                    //FIXME 需要改成线上地址。
                    self.uploadServerUrl=@"https://upload.kinstalk.com/upload";
                    self.downloadServerUrl=@"https://download.kinstalk.com";
                    self.h5ServerUrl = @"https://x.kinstalk.com";
                }else if (env==1){
                    self.chatServerIP = @"54.223.154.224";
                    self.chatServerPort=8001;
                    self.apiServerUrl=@"https://test-api.kinstalk.com";
                    self.uploadServerUrl=@"https://test-api.kinstalk.com/upload";
                    self.downloadServerUrl=@"https://test-api.kinstalk.com";
                    self.h5ServerUrl = @"https://test-api.kinstalk.com";
                } else if (env==2) {
                    self.chatServerIP = @"192.168.100.107";
                    self.chatServerPort=9000;
                    self.apiServerUrl=@"https://dev-api.kinstalk.com";
                    self.uploadServerUrl=@"http://192.168.100.104:8333/priest-upload/upload";
                    self.downloadServerUrl=@"http://192.168.100.104:8333/priest-upload";
                    
                }
            }
            [self initFromeServer];
        }
    return self;

}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@", self.connectServerUrl=%@", self.connectServerUrl];
    [description appendFormat:@", self.httpUrl=%@", self.apiServerUrl];
    [description appendFormat:@", self.uploadServerUrl=%@", self.uploadServerUrl];
    [description appendFormat:@", self.downloadServerUrl=%@", self.downloadServerUrl];
    [description appendFormat:@", self.chatServerIP=%@", self.chatServerIP];
    [description appendFormat:@", self.chatServerPort=%hu", self.chatServerPort];
    [description appendFormat:@", self.chatServerPorts=%@", self.chatServerPorts];
    [description appendFormat:@", self.h5ServerUrl=%@", self.h5ServerUrl];
    [description appendString:@">"];
    return description;
}

-(bool) initFromLocal{
    bool result=NO;
    NSString *filename = [self getConfigInfoFilePath];
    NSDictionary *dictionary= [NSDictionary dictionaryWithContentsOfFile:filename];
    if(dictionary){
        NSDictionary *config=[dictionary[@"last"] objectForKey:@"config"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"chatServerUrl" model:self propertyName:@"chatServerIP"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"chatServerPort" model:self propertyName:@"chatServerPort"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"uploadServerUrl" model:self propertyName:@"uploadServerUrl"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"downloadServerUrl" model:self propertyName:@"downloadServerUrl"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"apiServerUrl" model:self propertyName:@"apiServerUrl"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"chatServerPorts" model:self propertyName:@"chatServerPorts"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"dyConfig" model:self propertyName:@"dyConfig"];
        [QinBeanUtil setPropertyFromDictionary:config andKey:@"h5ServerUrl" model:self propertyName:@"h5ServerUrl"];
        result=YES;
    }else{
        NSLog(@"file not exist, dictionary file:%@",filename);
    }

    [self addSkipBackupAttributeToItemAtPath:[NSURL fileURLWithPath:filename]];
    return result;
}

-(bool) initFromeServer{

    __block BOOL bret = NO;

    @try{

        NSString *urlString= [NSString stringWithFormat:@"%@%@",_connectServerUrl,@"/config/commons"];

        NSDictionary *info= [[NSBundle mainBundle] infoDictionary];
        NSDictionary* param = @{@"deviceType":@(2),@"channelId":@(2),@"versionCode":info[@"CFBundleVersion"],@"gwVersion":@(4)};

        QinHttpProtocol *qinHttpProtocol = [[QinHttpProtocol alloc] init];
        qinHttpProtocol.requestUrl=urlString;
        qinHttpProtocol.method = @"GET";
        qinHttpProtocol.param=param;

        [[QinHttpManager sharedInstance] getHttpRequest:qinHttpProtocol success:^(id *operation, QinHttpProtocol *httpProtocol) {

            if(httpProtocol.data!=nil && httpProtocol.data!= NULL){

                DDLogDebug(@"qinHttpProtocol.data=%@",httpProtocol.data);

                self.chatServerIP= httpProtocol.data[@"chatServerUrl"];
                self.chatServerPort= (UInt16) [httpProtocol.data[@"chatServerPort"] integerValue];
                self.uploadServerUrl= httpProtocol.data[@"uploadServerUrl"];
                self.downloadServerUrl=httpProtocol.data[@"downloadServerUrl"];
                self.apiServerUrl=httpProtocol.data[@"apiServerUrl"];
                
                self.chatServerPorts = httpProtocol.data[@"chatServerPorts"];
                if(httpProtocol.data[@"dynamicConfigMap"]){
                    self.dyConfig = httpProtocol.data[@"dynamicConfigMap"];
                }
                
                if(httpProtocol.data[@"h5ServerUrl"]){
                    self.h5ServerUrl=httpProtocol.data[@"h5ServerUrl"];
                }
                

                [self saveLastConfig];

                //是否升级标识位
//                NSInteger upgradeFlag = [httpProtocol.data[@"upgradeFlag"] integerValue];
//                if( upgradeFlag > 0 )
//                {
//                    //需要升级
//                    NSInteger upgradePolicy = [httpProtocol.data[@"upgradePolicy"] integerValue];
//                    //下载地址
//                    NSString* fullPackageUrl = httpProtocol.data[@"fullPackageUrl"];
//                    //升级信息
//                    NSString* upgradeInfo = httpProtocol.data[@"upgradeInfo"];

//                    NSDictionary* upgradedic = @{@"upgradePolicy":@(upgradePolicy),
//                            @"upgradeInfo":upgradeInfo,
//                            @"fullPackageUrl":fullPackageUrl};

                    //FIXME 升级处理逻辑

//                }

                bret = YES;



            }

        } failure:^(id *operation, NSString *error) {

            DDLogDebug(@"获取配置信息失败::%@",error);
        }];


    }@catch (NSException *exception) {

        DDLogDebug(@"initFromServer error:%@", [exception description]);
    }

    return bret;
}

- (BOOL)addSkipBackupAttributeToItemAtPath:(NSURL*) URL
{
    //     URL= [NSURL fileURLWithPath: filePathString];
    if(![[NSFileManager defaultManager] fileExistsAtPath: [URL path]]) {
        return NO;
    }
    NSLog(@"addSkipBackupAttributeToItemAtPath %@", [URL path]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    } else {
        NSLog(@"OK excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (NSString *)getConfigInfoFilePath {
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    NSString *catchPath = paths[0];

    NSString *filename=[catchPath stringByAppendingPathComponent:@"ConfigInfo.plist"];
    return filename;
}
- (void)saveLastConfig {

    NSString *filename = [self getConfigInfoFilePath];

    if(self.dyConfig ==nil){
        self.dyConfig = [[NSDictionary alloc]init];
        
    }

    NSDictionary* data = @{@"last":@{@"t":[NSDate date],
            @"config":@{
                    @"chatServerUrl":self.chatServerIP,
                    @"chatServerPort": @(self.chatServerPort),
                    @"uploadServerUrl":self.uploadServerUrl,
                    @"downloadServerUrl":self.downloadServerUrl,
                    @"apiServerUrl":self.apiServerUrl,
                    @"chatServerPorts":self.chatServerPorts,
                    @"h5ServerUrl":self.h5ServerUrl,
                    @"dyConfig":self.dyConfig
            }}};
    [data writeToFile:filename atomically:YES];
}

+ (NSString *)getApiServerUrl {
    return [QinConfigInfo sharedInstance].apiServerUrl;
}

+ (NSString *)getUploadServerUrl {
    return [QinConfigInfo sharedInstance].uploadServerUrl;
}

+ (NSString *)getDownloadServerUrl {
    return [QinConfigInfo sharedInstance].downloadServerUrl;
}

+ (NSString *)getChatServerIP {
    return [QinConfigInfo sharedInstance].chatServerIP;
}

+ (NSString *)getH5ServerUrl {
    return [QinConfigInfo sharedInstance].h5ServerUrl;
}

+ (UInt16)getChatServerPort {

    NSString *ports = [QinConfigInfo sharedInstance].chatServerPorts;

    if(ports && ports.length>0)
    {
        NSArray *portArray = [ports componentsSeparatedByString:@","];
        if(portArray && portArray.count>0){

            int i = arc4random()%portArray.count;

            DDLogDebug(@"socketPort==%@", portArray[i]);
            return (UInt16)[portArray[i] integerValue];
        }
    }

    return [QinConfigInfo sharedInstance].chatServerPort;
}

-(QinDynamicConfig *)getDynamicConfig{

    if(self.dyConfig){
        
        QinDynamicConfig *config=[QinDynamicConfig mj_objectWithKeyValues:self.dyConfig];
//        config.liveEnabled=1;
        return config;
    }else{
        return nil;
    }
}

@end

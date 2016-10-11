//服务器配置处理工具类
// Created by LEI on 15/10/20.
//

#import <Foundation/Foundation.h>
#import "QinServiceConstants.h"

@class QinDynamicConfig;

@interface QinConfigInfo : NSObject
DEF_SINGLETON(QinConfigInfo)

//连接url
@property(nonatomic,strong,readonly)NSString* connectServerUrl;

//http服务器url
@property (nonatomic, strong) NSString * apiServerUrl;

//上传服务器URL
@property (nonatomic, strong) NSString * uploadServerUrl;

//下载服务器URL
@property (nonatomic, strong) NSString * downloadServerUrl;

//聊天服务器IP
@property (nonatomic, strong) NSString * chatServerIP;

//h5服务器URL
@property (nonatomic, strong) NSString * h5ServerUrl;


//聊天服务器端口
@property (nonatomic) UInt16 chatServerPort;

//聊天服务器端口号字符串,包括多个端口
@property (nonatomic, strong) NSString * chatServerPorts;
//动态开关配置
@property (nonatomic, strong) NSDictionary * dyConfig;
//获取服务器配置信息 0为线上环境，  1为线上测试环境  2为公司开发环境
- (id)initConfigInfo:(NSInteger)env;

- (NSString *)description;
+ (NSString *)getApiServerUrl;
+(NSString *)getUploadServerUrl;
+(NSString *)getDownloadServerUrl;
+(NSString *)getChatServerIP;
+(UInt16 )getChatServerPort;
-(QinDynamicConfig *)getDynamicConfig;
+(NSString *)getH5ServerUrl;
@end

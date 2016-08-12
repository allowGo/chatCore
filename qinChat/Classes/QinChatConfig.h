/*!
 @header ChatConfig.h
 @abstract
 @author kinstalk.com
 @version 1.00 15/8/15
 Created by DengHua on 15/8/15.
 */

#import <Foundation/Foundation.h>


@interface QinChatConfig : NSObject
@property(nonatomic, strong) NSString *address;
@property(nonatomic) UInt16 port;
@property(nonatomic, copy) NSString *deviceId;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, strong) NSNumber *uId;

@property(nonatomic, strong) NSString *apiServerUrl;

@property(nonatomic, strong) NSString *downloadServerUrl;

/**
 *  channelID ,必须要设置了sku和bundid才能获取到这个值
 */
@property(nonatomic, strong, readonly, getter=getChannelIdDic) NSDictionary* channelIdDic;

/**
 *  上层传过来的bundid,sku
 */
@property(nonatomic, strong)NSString* sku;
@property(nonatomic, strong)NSString* bundleVersion;


@end
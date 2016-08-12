//
// Created by DengHua on 15/8/15.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import "QinChatConfig.h"


@implementation QinChatConfig {
    
}

-(BOOL)isQloveVersion:(NSString*)skuStr
{
    BOOL bRet = YES;
    
    //装换为小写
    NSString* lowerStr = [skuStr lowercaseString];
    
    NSRange range;
    range = [lowerStr rangeOfString:@"qlove"];
    if (range.location != NSNotFound) {
        bRet = YES;
    }else{
        bRet = NO;
    }
    
    return bRet;
}

- (NSDictionary*)getChannelIdDic
{
    NSDictionary* result = nil;
    
    if( nil == _sku || nil == _bundleVersion )
        return result;
    
    
    if( [_sku isEqualToString:@"com.kinstalk.youngQinjian"] && [self isQloveVersion:_bundleVersion] )
    {
        //测试-qlove-IOS下载
        result = @{@"channelId":@"S00200020002"};
    }
    else if( [_sku isEqualToString:@"com.kinstalk.youngQinjian"] )
    {
        //亲见-官网-IOS下载
        result = @{@"channelId":@"S00100010002"};
    }
    else if( [_sku isEqualToString:@"com.kinstalk.qinjian"])
    {
        //AppStore-AppStore审核-亲见-AppStore-IOS下载
        result = @{@"channelId":@"S00400010001"};
    }
    else
    {
        result = nil;
    }
    
    return result;
}


@end
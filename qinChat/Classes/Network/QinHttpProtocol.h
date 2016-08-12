//
// Created by 祥龙 on 15/8/13.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    //消息
    QinHttpProtocol_FROMTYPE_MSG_START = 1000,
    QinHttpProtocol_FROMTYPE_NORMAL,
    QinHttpProtocol_FROMTYPE_PULLMSG=1,//批量拉消息

    //图片
    QinHttpProtocol_FROMTYPE_PHOTO_START = 2000,
    QinHttpProtocol_FROMTYPE_PHOTO_ADDTAG,       //加标签
    QinHttpProtocol_FROMTYPE_PHOTO_MODIFYTAG,       //改标签
    QinHttpProtocol_FROMTYPE_PHOTO_DELTAG,          //删除标签
    QinHttpProtocol_FROMTYPE_BATCH,          //删除标签
} QinHttpProtocol_FROMTYPE;


@interface QinHttpProtocol : NSObject

//请求url
@property(nonatomic, strong) NSString *requestUrl;
//请求方式 get or post
@property(nonatomic, strong) NSString *method;
//请求参数
@property(nonatomic, copy) id param;


//请求token
@property(nonatomic, strong) NSString *token;
//请求deviceId
@property(nonatomic, strong) NSString *deviceId;

//返回数据
@property(nonatomic, strong) NSDictionary *data;

/**
*  来源类型
*/
@property(nonatomic, assign) QinHttpProtocol_FROMTYPE formType;
/**
*  用户自定义数据
*/
@property(nonatomic, strong) NSDictionary *userDic;

//apiUrl
@property(nonatomic, strong) NSString *apiUrl;

/**
 * 上传文件
 */
@property (nonatomic, strong) NSString *filePath;

//ci
@property(nonatomic, assign) NSInteger ci;

//seq
@property(nonatomic, strong) NSNumber *seq;




@end
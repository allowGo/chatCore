//
// Created by LEI on 16/7/9.
// Copyright (c) 2016 kinstalk.com. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface QinNetConfig : NSObject
@property(nonatomic, strong) NSString *address; //socket server ip
@property(nonatomic, assign) UInt16 port;       //端口号
@property(nonatomic, assign) UInt16 beatTime;   //心跳时间
@property(nonatomic, strong) NSString *deviceId; //设备id
@property(nonatomic, strong) NSString *token;    //登录token
@property(nonatomic, strong) NSNumber *uId;      //用户id
@end

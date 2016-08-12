//
// Created by 祥龙 on 15/9/23.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QinGroupUserModel : NSObject


@property (nonatomic, strong) NSNumber* uid; //用户id
@property (nonatomic, strong) NSNumber* gid;//群id
@property (nonatomic, strong) NSString* nickname;//群昵称
@property (nonatomic, strong) NSNumber* master;//是否是群主 1群主 0非群主
@property (nonatomic, strong) NSNumber* status;//群用户状态 1:在群 2:离群 0:离群被邀请
@property (nonatomic, strong) NSNumber* publicBirthday;//是否公开生日 1是，0否
@property (nonatomic, strong) NSNumber* publicMobile;//是否公开手机号码 1是 0否
@property (nonatomic, strong) NSNumber* commentNotify; //是否接受评论通知 1是 0否
@property (nonatomic, strong) NSNumber* feedNotify;//是否接收feed通知 1是 0否
@property (nonatomic, strong) NSNumber* chatNotify;//是否接收聊天通知 1是 0否
@property (nonatomic, strong) NSString* avatar;//群用户头像
@property (nonatomic, strong) NSNumber* avatarType;//头像类型 1用户处定义上传
@property (nonatomic, strong) NSNumber* createDt;//创建时间 毫秒
@property (nonatomic, strong) NSNumber* updateDt;//修改时间 毫秒
@property (nonatomic, strong) NSString* groupName;//群名称
@end
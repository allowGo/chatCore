//
// Created by LEI on 15/9/23.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QinServiceConstants.h"


@interface QinGroupModel : NSObject


@property (nonatomic, strong) NSNumber * id; //gid
@property (nonatomic, strong) NSString* name; //群名称
@property (nonatomic, strong) NSString* avatar; //头像地址
@property (nonatomic, strong) NSNumber * avatarType; //头像类型
@property (nonatomic, strong) NSNumber* size; //群当前人数
@property (nonatomic, strong) NSNumber* max; //群最大人数
@property (nonatomic, strong) NSNumber* type; //现在只有3：普通群

@property (nonatomic, strong) NSNumber* verify; //是否需要审核：0不需验证 1群主验证 2全员验证
@property (nonatomic, strong) NSNumber* verifyType;   //群审核类型 q:1 c:2 o:3 p:4


@property (nonatomic, strong) NSNumber* displayNickname; //是否显示群昵称
@property (nonatomic, strong) NSNumber* noDisturb;//免打扰
@property (nonatomic, strong) NSNumber* main; //主群
@property (nonatomic, strong) NSNumber* master;//是否是群主 1:群主 0:非群主
@property (nonatomic, strong) NSNumber* status;//1:在群 2:离群 0:离群被邀请

@property (nonatomic, strong) NSNumber* publicBirthday;//是否公开生日
@property (nonatomic, strong) NSNumber* publicMobile; //是否公开手机号

@property (nonatomic, strong) NSNumber* commentNotify;//是否开启 评论提醒 1提醒 0 不提醒
@property (nonatomic, strong) NSNumber* feedNotify;//是否开启 1.完全提醒 2.部分提醒 3.不提醒
@property (nonatomic, strong) NSNumber* chatNotify;//是否开启 聊天通知 1开启 0关闭
@property (nonatomic, strong) NSNumber* createDt; //创建时间 毫秒
@property (nonatomic, strong) NSNumber* updateDt; //修改时间 毫秒

@property (nonatomic, strong) NSString* nickname;//群昵称
@property (nonatomic, strong) NSString * groupDescription;
@property (nonatomic, strong) NSNumber * publicDiscuss;
@property (nonatomic, strong) NSString* userAvatar;//群用户头像
@property (nonatomic, strong) NSNumber* userAvatarType;//头像类型 1用户处定义上传

@property (nonatomic, strong) NSString* contentType;//群类型(UI专用)

//群扩展信息
@property (nonatomic, strong) NSNumber* c1; //公开群的类型
@property (nonatomic, strong) NSString* desc; //描述信息
@property (nonatomic, strong) NSNumber* followNum; //关注数
@property (nonatomic, strong) NSString* tagName; //公开群的类型名称
@property (nonatomic, assign) NSInteger topStatus; //置顶状态

@property (nonatomic, assign) NSInteger groupStatus;// 群的状态  1：未初始化  2：已初始化（第一次邀请后设置了邀请权限）

@property (nonatomic, strong) NSString* cover;// 群的封面
@property (nonatomic, strong) NSNumber * isApply;//是否允许申请 1可申请 ，0不可申请
@property (nonatomic, strong) NSString * longitude;//经度
@property (nonatomic, strong) NSString * latitude;//纬度
@property (nonatomic, strong) NSString * location;//地理位置中文描述
@property (nonatomic, assign) NSInteger permitApplication;//是否允许申请
@property (nonatomic, strong) NSString * groupCode;//群号

@property (nonatomic, strong) NSNumber* unReadUpdateTime; //未读消息更新时间 毫秒(本地专用)

@property (nonatomic,strong)NSNumber * forwardUpdateTime;  //转发时间更新 




@end

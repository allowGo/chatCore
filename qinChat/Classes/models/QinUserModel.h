//
// Created by 祥龙 on 15/9/23.
// Copyright (c) 2015 kinstalk.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QinUserModel : NSObject

@property(nonatomic,strong) NSNumber * uid;
//@property(nonatomic,strong) NSNumber * gid;
@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSString* avatar;
@property(nonatomic,strong) NSNumber* type;   //QUserModelsAvatarType
@property(nonatomic,strong) NSNumber* birthday;
@property(nonatomic,strong) NSString* area;
@property(nonatomic,strong) NSString* province; //省

@property(nonatomic,strong) NSString* city;     //市
@property(nonatomic,strong) NSString* district; //区
@property(nonatomic,strong) NSString* mobile;
@property(nonatomic,strong) NSNumber* gender;   //0,男，1，女

@property(nonatomic,strong) NSNumber* updateTime;

@property(nonatomic,strong) NSString* worldName;

@property(nonatomic,strong) NSString* worldAvatar;


@property(nonatomic,strong) NSNumber* bQloveUser;       //是不是qlove用户,1 qlove
@property(nonatomic,strong) NSString* userCode;         //只有qlove用户才有这个字段
@property(nonatomic,strong) NSString* serialNo;         //只有qlove用户才有这个字段

//@property (nonatomic,assign) int selectedType;//亲友录邀请被选择

//名称排序
//@property (nonatomic,assign) NSInteger sectionNum;
//@property (nonatomic,assign) NSInteger originIndex;
//- (NSString *) getFirstName;
@end

/*
 @property (nonatomic, strong) NSNumber* uid;
 @property (nonatomic, strong) NSString* userCode;
 @property (nonatomic, strong) NSString* area;
 @property (nonatomic, strong) NSString* avatar;
 @property (nonatomic, strong) NSString* name;
 @property (nonatomic, strong) NSString* qMobile;
*/
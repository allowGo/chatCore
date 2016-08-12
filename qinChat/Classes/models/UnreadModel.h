//
// Created by 祥龙 on 15/10/28.
//

#import <Foundation/Foundation.h>


@interface UnReadModel : NSObject
@property (nonatomic, strong) NSNumber * gId; //gid
@property (nonatomic,assign)NSInteger newsCount;  //news未读数
@property (nonatomic,assign)NSInteger notifyCount; //通知未读数
@property (nonatomic, strong) NSNumber * updateTime; //最新news更新时间


@end
//
//hotFixBug
// Created by 祥龙 on 16/6/24.
//

#import <Foundation/Foundation.h>

typedef void (^UpdateCallback)(NSError *error);

@interface QinHotPatchLoader : NSObject
/**
 * 启动patch引擎
 */
+ (BOOL)run;
/**
 * 在线更新补丁
 */
+ (void)updateToVersion:(NSInteger)version callback:(UpdateCallback)callback;
/**
 * 测试 js是否可用
 */
+ (void)runTestScriptInBundle;

@end
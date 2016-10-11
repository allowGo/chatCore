//
// Created by LEI on 16/6/24.
//

#import "QinHotPatchLoader.h"
#import "JPEngine.h"

#define kJSPatchVersion(appVersion)   [NSString stringWithFormat:@"JSPatchVersion_%@", appVersion]
#pragma mark - Extension

@interface JPLoaderInclude : JPExtension

@end

@implementation JPLoaderInclude

+ (void)main:(JSContext *)context
{
    context[@"include"] = ^(NSString *filePath) {
        if (!filePath.length || [filePath rangeOfString:@".js"].location == NSNotFound) {
            return;
        }
        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        NSString *scriptPath = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/%@", appVersion, filePath]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
            [JPEngine startEngine];
            [JPEngine evaluateScriptWithPath:scriptPath];
        }
    };
}

@end

@interface JPLoaderTestInclude : JPExtension

@end

@implementation JPLoaderTestInclude

+ (void)main:(JSContext *)context
{
    context[@"include"] = ^(NSString *filePath) {
        NSArray *component = [filePath componentsSeparatedByString:@"."];
        if (component.count > 1) {
            NSString *testPath = [[NSBundle bundleForClass:[self class]] pathForResource:component[0] ofType:component[1]];
            [JPEngine evaluateScriptWithPath:testPath];
        }
    };
}

@end

@implementation QinHotPatchLoader {

}
+ (BOOL)run
{
   DDLogDebug(@"JSPatch: runScript");

    NSString *scriptDirectory = [self fetchScriptDirectory];
    NSString *scriptPath = [scriptDirectory stringByAppendingPathComponent:@"main.js"];

    if ([[NSFileManager defaultManager] fileExistsAtPath:scriptPath]) {
        [JPEngine startEngine];
        [JPEngine addExtensions:@[@"JPLoaderInclude"]];
        [JPEngine evaluateScriptWithPath:scriptPath];
       DDLogDebug(@"JSPatch: evaluated script %@", scriptPath);
        return YES;
    } else {
        return NO;
    }
}

+ (void)updateToVersion:(NSInteger)version callback:(UpdateCallback)callback {



}


+ (void)runTestScriptInBundle
{
    [JPEngine startEngine];
    [JPEngine addExtensions:@[@"JPLoaderTestInclude"]];

    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"main" ofType:@"js"];
    NSAssert(path, @"can't find main.js");
    NSString *script = [[NSString alloc] initWithData:[[NSFileManager defaultManager] contentsAtPath:path] encoding:NSUTF8StringEncoding];
    [JPEngine evaluateScript:script];
}

+ (NSInteger)currentVersion
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [[NSUserDefaults standardUserDefaults] integerForKey:kJSPatchVersion(appVersion)];
}

+ (NSString *)fetchScriptDirectory
{
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *libraryDirectory = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
    NSString *scriptDirectory = [libraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"JSPatch/%@/", appVersion]];
    return scriptDirectory;
}
@end

//
//  DCCommon.m
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCCommon.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSString *exceptionLog = [NSString stringWithFormat:@"Exception: %@ %@\nCall Stack: %@", exception.name, exception.reason, [exception callStackSymbols]];
    NSLog(@"%@", exceptionLog);

    NSString *cachesDirectory = [NSSearchPathForDirectoriesInDomains (NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dirPath = [cachesDirectory stringByAppendingPathComponent:@"Crash"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dirPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", [NSDate date]]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [file seekToEndOfFile];
    [file writeData:[exceptionLog dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
}

BOOL isRunningTests(void) {
    NSDictionary* environment = [[NSProcessInfo processInfo] environment];
    NSString* injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}

BOOL isTestMode(void) {
    return [[[NSProcessInfo processInfo] environment][@"TEST_MODE"] boolValue];
}

NSString *appVersion() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
NSString *appBuildVersion() {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}
NSString *appGitInfo() {
    NSString *gitInfoStr = @"";
    NSString * gitInfoFilePathStr = [[NSBundle mainBundle] pathForResource:@"GIT_INFO_FILE" ofType:@"plist"];
    if (gitInfoFilePathStr) {
        NSDictionary *gitInfoDic = [NSDictionary dictionaryWithContentsOfFile:gitInfoFilePathStr];
        if (gitInfoDic) {
            NSString *keySHAShort = @"SHAShort";
            NSString *keyParentSHAShort = @"ParentSHAShort";
            NSString *curGitSHA = [gitInfoDic objectForKey:keySHAShort];
            NSString *parentGitSHA = [gitInfoDic objectForKey:keyParentSHAShort];
            gitInfoStr = [NSString stringWithFormat:@"%@ %@", curGitSHA ? curGitSHA : @"", parentGitSHA ? parentGitSHA : @""];
        }
    }
    return gitInfoStr;
}
NSString *serverURL() {
    return SERVER_URL;
}

NSString *appState() {
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive:
            return @"UIApplicationStateActive";
        case UIApplicationStateInactive:
            return @"UIApplicationStateInactive";
        case UIApplicationStateBackground:
            return @"UIApplicationStateBackground";
        default:
            return nil;
    }
}

ScreenSize screenSize(void) {
    CGSize size = [UIScreen mainScreen].preferredMode.size;
    if (CGSizeEqualToSize(size, CGSizeMake(1242, 2208))) {
        return Screen_iPhone6P;
    } else if (CGSizeEqualToSize(size, CGSizeMake(750, 1334))) {
        return Screen_iPhone6;
    } else if (CGSizeEqualToSize(size, CGSizeMake(640, 1136))) {
        return Screen_iPhone5;
    } else {
        return Screen_iPhone;
    }
}

CGFloat deviceScreenWidth() {
    switch (screenSize()) {
        case Screen_iPhone:
            return 320;

        case Screen_iPhone5:
            return 320;
            
        case Screen_iPhone6:
            return 375;

        case Screen_iPhone6P:
            return 414;

        default:
            break;
    }
    return 320;
}

NSString *prettyPrintedstringForJSONObject(id object) {
    if (object) {
        return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }
    return @"";
}

NSDictionary *dictWithoutNSNull(NSDictionary *dict) {
    NSMutableDictionary *cleanDict = [dict mutableCopy];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == [NSNull null]) {
            [cleanDict removeObjectForKey:key];
        }
    }];
    return [cleanDict copy];
}

@implementation DCCommon

+ (void)screenAdapter:(ScreenAdapter)adapter
               iPhone:(ScreenAdapter)iPhone
              iPhone5:(ScreenAdapter)iPhone5
              iPhone6:(ScreenAdapter)iPhone6
             iPhone6P:(ScreenAdapter)iPhone6P {
    if (adapter) { adapter(); }
    switch (screenSize()) {
        case Screen_iPhone:
            if (iPhone) { iPhone(); }
            break;
            
        case Screen_iPhone5:
            if (iPhone5) { iPhone5(); }
            break;
            
        case Screen_iPhone6:
            if (iPhone6) { iPhone6(); }
            break;
            
        case Screen_iPhone6P:
            if (iPhone6P) { iPhone6P(); }
            break;
            
        default:
            break;
    }
}

#pragma mark 判断是否包含中文
+(BOOL)judgeStringNotContaintCN:(NSString *)string{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return [string isEqualToString:filtered];
}

@end



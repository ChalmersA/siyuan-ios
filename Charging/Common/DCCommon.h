//
//  DCCommon.h
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDateFormatter+HSSYCategory.h"
#import "UIColor+HSSYColor.h"
#import "UIImage+HSSYCategory.h"
#import "UIView+HSSYView.h"

//数字和字母
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

void uncaughtExceptionHandler(NSException *exception);
BOOL isRunningTests(void);
BOOL isTestMode(void);
NSString *appVersion();
NSString *appBuildVersion();
NSString *appGitInfo();
NSString *serverURL();
NSString *appState();

typedef NS_ENUM(NSInteger, ScreenSize) {
    Screen_iPhone,
    Screen_iPhone5,//(640, 1136) 4-inch  320*568
    Screen_iPhone6,//(750, 1334) 4.7-inch  375*667
    Screen_iPhone6P,//(1242, 2208) 5.5-inch  414*736
};

ScreenSize screenSize(void);

CGFloat deviceScreenWidth();

NSString *prettyPrintedstringForJSONObject(id object);

NSDictionary *dictWithoutNSNull(NSDictionary *dict);

typedef void(^ScreenAdapter)(void);

@interface DCCommon : NSObject

+ (void)screenAdapter:(ScreenAdapter)adapter
               iPhone:(ScreenAdapter)iPhone
              iPhone5:(ScreenAdapter)iPhone5
              iPhone6:(ScreenAdapter)iPhone6
             iPhone6P:(ScreenAdapter)iPhone6P;
+(BOOL)judgeStringNotContaintCN:(NSString *)string;
@end

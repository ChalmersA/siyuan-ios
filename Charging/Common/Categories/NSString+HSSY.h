//
//  NSString+HSSY.h
//  Charging
//
//  Created by  Blade on 1/29/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HSSY)
- (NSData *)decodeToHexidecimal;
- (NSString*)phoneNumWithHiddenPart;
- (NSString*)nameWithHiddenPart;
- (NSString *)pinyin;
+ (NSString *)stringByDoubleValue:(double)param;
- (BOOL)isZeroPrice; //判断金额是否为0
+ (BOOL)isStringContainsEmoji:(NSString *)string;
@end

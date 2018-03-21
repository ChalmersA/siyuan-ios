//
//  NSString+HSSY.m
//  Charging
//
//  Created by  Blade on 1/29/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "NSString+HSSY.h"
unsigned char strToChar (char a, char b)
{
    char encoder[3] = {'\0','\0','\0'};
    encoder[0] = a;
    encoder[1] = b;
    return (char) strtol(encoder,NULL,16);
}

@implementation NSString (HSSY)
- (NSData *) decodeToHexidecimal
{
    const char * bytes = [self cStringUsingEncoding: NSUTF8StringEncoding];
    NSUInteger length = strlen(bytes);
    unsigned char * r = (unsigned char *) malloc(length / 2 + 1);
    unsigned char * index = r;
    
    while ((*bytes) && (*(bytes +1))) {
        *index = strToChar(*bytes, *(bytes +1));
        index++;
        bytes+=2;
    }
    *index = '\0';
    
    NSData * result = [NSData dataWithBytes: r length: length / 2];
    free(r);
    
    return result;
}

// 隐藏部分信息的电话号码
- (NSString*) phoneNumWithHiddenPart {
    if (self.length == 11) { // 手机号码
        return [self stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }
    else if(self.length > 1) {
        NSUInteger index = (int)(self.length / 4);
        NSUInteger length = (int)(self.length / 2);
        index = (index == 0 && self.length > 1) ? 1 : index;
        NSMutableString* retStr = [NSMutableString stringWithString:self];
        for (NSUInteger i=0; i<length; i++) {
            [retStr replaceCharactersInRange:NSMakeRange(index+i, 1) withString:@"*"];
        }
        return [retStr copy];
    }
    else if(self.length == 1) {
        return @"*";
    }
    return [self copy];
}

- (NSString*) nameWithHiddenPart {
    if(self.length > 1) {
        NSUInteger index = (int)(self.length / 4);
        NSUInteger length = (int)(self.length / 2);
        index = (index == 0 && self.length > 1) ? 1 : index;
        NSMutableString* retStr = [NSMutableString stringWithString:self];
        for (NSUInteger i=0; i<length; i++) {
            [retStr replaceCharactersInRange:NSMakeRange(index+i, 1) withString:@"*"];
        }
        return [retStr copy];
    }
    else if(self.length == 1) {
        return @"*";
    }
    return [self copy];
}

- (NSString *)pinyin {
    NSMutableString *string = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)string, nil, kCFStringTransformToLatin, NO);
    CFStringTransform((CFMutableStringRef)string, nil, kCFStringTransformStripCombiningMarks, NO);
    return [string copy];
}

+ (NSString *)stringByDoubleValue:(double)param {
    return [NSString stringWithFormat:@"%0.2f", param];
}

- (BOOL)isZeroPrice {
    if ([self floatValue] < 0.01) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)isStringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

@end

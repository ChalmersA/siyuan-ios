//
//  NSDateFormatter+HSSYCategory.m
//  Charging
//
//  Created by xpg on 15/1/12.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "NSDateFormatter+HSSYCategory.h"

@implementation NSDateFormatter (HSSYCategory)

+ (instancetype)authDateFormatter {
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:usLocale];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    });
    return dateFormatter;
}

+ (instancetype)authDateTimeFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    });
    return dateTimeFormatter;
}

+ (instancetype)reserveStartTimeFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    });
    return dateTimeFormatter;
}

+ (instancetype)reserveEndTimeFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"HH:mm"];
    });
    return dateTimeFormatter;
}

+ (instancetype)mapFilterDateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [formatter setLocale:usLocale];
        [formatter setDateFormat:@"M月d日"];
    });
    return formatter;
}

+ (instancetype)pileEvaluateDateFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    return dateTimeFormatter;
}

+ (instancetype)circleArticleDateFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"MM-dd HH:mm"];
    });
    return dateTimeFormatter;
}

+ (instancetype)minuteDateFormatter {
    static NSDateFormatter *dateTimeFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateTimeFormatter = [[NSDateFormatter alloc] init];
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateTimeFormatter setLocale:usLocale];
        [dateTimeFormatter setDateFormat:@"mm:ss"];
    });
    return dateTimeFormatter;
}
@end

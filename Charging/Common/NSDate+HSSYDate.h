//
//  NSDate+HSSYDate.h
//  CollectionViewTest
//
//  Created by  Blade on 5/7/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (HSSYDate)
+ (BOOL)isSameDayWithDateOne:(NSDate *)dateOne dateTwo:(NSDate *)dateTwo;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
- (NSDate*)dateByAddingCompoent:(CFCalendarUnit)componentType withCount:(NSInteger)count;
- (NSString *)weekdayString;

+(NSString *)stringDateFromNow:(NSDate *)date;

/**
 *  将当前时间格式解析成 “HH:mm” 的格式的字符串
 *
 *  @param isEndTime 是否是一个时段当中的结束时间，YES返回：“00:00”; NO返回：“24:00”。
 *
 *  @return “HH:mm” 格式的字符串，包含“24:00”
 */
// 将时间格式解析成 “HH:mm” 的格式
- (NSString*)parseToTimeString:(BOOL)isEndTime;

// 毫秒时间戳
- (long long)timestamp;
+ (instancetype)dateWithTimestamp:(long long)timestamp;

// 计算时长 例：2小时15分
+ (NSString *)timeLengthFromStartTime:(NSDate *)startTime toEndTime:(NSDate *)endTime;

- (NSInteger)year;
- (NSInteger)month;
@end

//
//  HSSYTime.m
//  Charging
//
//  Created by Ben on 15/1/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCTime.h"
#import "NSDateFormatter+HSSYCategory.h"
#import "NSDictionary+Model.h"

@implementation DCTime

//7200000 == 10:00, 57600000 == 24:00
- (instancetype)initWithStartTime:(ClockTime)startTime endTime:(ClockTime)endTime weekday:(NSString *)weekday {
    self = [super init];
    if (self) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:[NSDate dateWithTimeIntervalSince1970:0]];
        components.hour = startTime.hour;
        components.minute = startTime.minute;
        NSDate *startDate = [gregorian dateFromComponents:components];
        _startTimestamp = [startDate timeIntervalSince1970] * 1000;
        
        components.hour = endTime.hour;
        components.minute = endTime.minute;
        NSDate *endDate = [gregorian dateFromComponents:components];
        _endTimestamp = [endDate timeIntervalSince1970] * 1000;
        
        _weekString = [weekday copy];
    }
    return self;
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            _timeId = [dict stringForKey:@"id"];
            _startTimestamp = [dict doubleForKey:@"startTime"];
            _endTimestamp = [dict doubleForKey:@"endTime"];
            _weekString = [dict stringForKey:@"week"];
            _servicePay = [dict doubleForKey:@"servicePay"];
        }
    }
    return self;
}

#pragma mark - Extension
- (NSDate *)startTimeDate {
    return [NSDate dateWithTimeIntervalSince1970:self.startTimestamp / 1000];
}

- (NSDate *)endTimeDate {
    return [NSDate dateWithTimeIntervalSince1970:self.endTimestamp / 1000];
}

- (NSString *)timeFrameString {
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.startTimestamp/1000];
    return [NSString stringWithFormat:@"%@-%@", [[NSDateFormatter reserveEndTimeFormatter] stringFromDate:startDate], NSStringFromClockTime(self.endTime)];
}

- (ClockTime)timeFromTimestamp:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:date];
    if (components.day > 1) {
        components.hour += 24;
    }
    return clockTimeMake(components.hour, components.minute);
}

- (ClockTime)startTime {
    return [self timeFromTimestamp:self.startTimestamp];
}

- (ClockTime)endTime {
    ClockTime endTime = [self timeFromTimestamp:self.endTimestamp];
    if (isClockTimeEqual(endTime, clockTimeMake(0, 0))) { // fix for end time 24 hour
        endTime = clockTimeMake(24, 0);
    }
    return endTime;
}

- (NSString *)weekStringCN {
    return [self weekStringToCN:self.weekString];
}

- (NSString *)weekStringToCN:(NSString *)weekString {
    NSMutableArray *weekArray = [NSMutableArray array];
    NSArray *weekDay = [weekString componentsSeparatedByString:@","];
    for (NSString *day in weekDay) {
        if ([day isEqualToString:@"1"]) {
            [weekArray addObject:@"周日"];
        } else if ([day isEqualToString:@"2"]) {
            [weekArray addObject:@"周一"];
        } else if ([day isEqualToString:@"3"]) {
            [weekArray addObject:@"周二"];
        } else if ([day isEqualToString:@"4"]) {
            [weekArray addObject:@"周三"];
        } else if ([day isEqualToString:@"5"]) {
            [weekArray addObject:@"周四"];
        } else if ([day isEqualToString:@"6"]) {
            [weekArray addObject:@"周五"];
        } else if ([day isEqualToString:@"7"]) {
            [weekArray addObject:@"周六"];
        }
    }
    NSString *weekStringCN = [weekArray componentsJoinedByString:@" "];
    return weekStringCN;
}
@end

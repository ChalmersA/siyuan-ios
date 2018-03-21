//
//  NSDate+HSSYDate.m
//  CollectionViewTest
//
//  Created by  Blade on 5/7/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "NSDate+HSSYDate.h"

@implementation NSDate (HSSYDate)
+ (BOOL)isSameDayWithDateOne:(NSDate *)dateOne dateTwo:(NSDate *)dateTwo{
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateComponents *compOne = [calender components:unitFlags fromDate:dateOne];
    NSDateComponents *compTwo = [calender components:unitFlags fromDate:dateTwo];
    
    return ([compOne day] == [compTwo day] && [compOne month] == [compTwo month] && [compOne year] == [compTwo year]);
}

+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

- (NSDate*)dateByAddingCompoent:(CFCalendarUnit)componentType withCount:(NSInteger)count {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    switch (componentType) {
        case kCFCalendarUnitSecond:
            dayComponent.second = count;
            break;
        case kCFCalendarUnitMinute:
            dayComponent.minute = count;
            break;
        case kCFCalendarUnitHour:
            dayComponent.hour = count;
            break;
        case kCFCalendarUnitDay:
            dayComponent.day = count;
            break;
        case kCFCalendarUnitMonth:
            dayComponent.month = count;
            break;
        case kCFCalendarUnitYear:
            dayComponent.year = count;
            break;
        default:
            NSLog(@"component not match!!");
            break;
    }
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:self options:0];
    return nextDate;
}

- (NSString *)weekdayString {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitWeekday) fromDate:self];
    switch (components.weekday) {
        case 1:
            return @"周日";
        case 2:
            return @"周一";
        case 3:
            return @"周二";
        case 4:
            return @"周三";
        case 5:
            return @"周四";
        case 6:
            return @"周五";
        case 7:
            return @"周六";
        default:
            return @"";
    }
}

- (NSString*)parseToTimeString:(BOOL)isEndTime {
    NSDateFormatter* ft = [[NSDateFormatter alloc] init];
    //    ft.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    ft.dateFormat = @"HH:mm";
    NSString *timeStr = [ft stringFromDate:self];
    if (isEndTime && [timeStr isEqualToString:@"00:00"]) {
        timeStr = @"24:00";
    }
    return timeStr;
}

+(NSString *)stringDateFromNow:(NSDate *)date {
    
    NSString * nowYearString = [[[NSDate date] toString] substringToIndex:4];
    NSString * dateYearString = [[date toString] substringToIndex:4];
    
    BOOL isYearEqual = [nowYearString isEqualToString:dateYearString];
    NSTimeInterval timeInterval = -[date timeIntervalSinceDate:[NSDate date]];

    
    NSString * str = [NSString stringWithFormat:@"%@",timeInterval < 60 ? @"刚刚" : [NSString stringWithFormat:@"%@",
                                                      timeInterval < 60 * 60 ? [NSString stringWithFormat:@"%d分钟前",
                                                      (int)timeInterval / 60] : timeInterval < 60 * 60 * 24 ? [NSString stringWithFormat:@"%d小时前",
                                                      (int)timeInterval / (60 * 60)] : timeInterval < 60 * 60 * 24 * 4 ? [NSString stringWithFormat:@"%d天前",
                                                      (int)(timeInterval) / (60 * 60 * 24)] : isYearEqual ? [date toStringWithFormaterMonth:@"月" Day:@"日"] : [date toStringWithFormaterYear:@"年" Month:@"月" Day:@"日"]]];
    
    
//    [[date toStringWithFormaterYear:@"年" Month:@"月" Day:@"日"] substringWithRange:isYearEqual ? NSMakeRange(5, 5) : NSMakeRange(0, 10)]
    if (timeInterval > 60 * 60 * 24 * 31) {
        str = [str substringToIndex:str.length - 1];
    }
    return str;
}

-(NSString *)toStringWithFormaterYear:(NSString *)year
                                Month:(NSString *)month
                                  Day:(NSString *)day{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy%@M%@d%@",year,month,day]];
    return [dateFormatter stringFromDate:self];
}

-(NSString *)toStringWithFormaterMonth:(NSString *)month
                                   Day:(NSString *)day{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"M%@d%@",month,day]];
    return [dateFormatter stringFromDate:self];
}

+(instancetype)dateWithDateFormatString:(NSString *)dateFormatString
                               withYear:(NSString *)year
                                  Month:(NSString *)month
                                    Day:(NSString *)day{
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"yyyy%@M%@d%@",year,month,day]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    return [dateFormatter dateFromString:dateFormatString];
}

+(instancetype)dateWithDateFormatString:(NSString *)dateFormatString{
    return [NSDate dateWithDateFormatString:dateFormatString withYear:@"年" Month:@"月" Day:@"日"];
}

-(NSString *)toString{
    return [self toStringWithFormaterYear:@"年" Month:@"月" Day:@"日"];
}

+ (NSString *)timeLengthFromStartTime:(NSDate *)startTime toEndTime:(NSDate *)endTime {
    NSString *timeLength = @"未知";
    if (startTime && endTime) {
        NSInteger seconds = [endTime timeIntervalSinceDate:startTime];
        NSInteger minutes = seconds / 60;
        NSInteger hours = minutes / 60;
        if (hours) {
            minutes -= hours * 60;
            timeLength = [NSString stringWithFormat:@"%d小时%d分", (int)hours, (int)minutes];
        } else if (minutes > 0 ) {
            timeLength = [NSString stringWithFormat:@"0小时%d分", (int)minutes];
        } else {
            timeLength = [NSString stringWithFormat:@"%d秒", (int)seconds];
        }
    }
    return timeLength;
}

#pragma mark -
- (NSInteger)year {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitYear) fromDate:self];
    NSInteger year = [components year];
    return year;
}

- (NSInteger)month {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSCalendarUnitMonth) fromDate:self];
    NSInteger month = [components month];
    return month;
}

#pragma mark - timestamp
- (long long)timestamp {
    return [self timeIntervalSince1970] * 1000;
}

+ (instancetype)dateWithTimestamp:(long long)timestamp {
    return [NSDate dateWithTimeIntervalSince1970:timestamp / 1000];
}

@end

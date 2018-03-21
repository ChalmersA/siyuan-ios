//
//  HSSYSharePeriod.m
//  CollectionViewTest
//
//  Created by  Blade on 4/29/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCSharePeriod.h"
#import "NSDate+HSSYDate.h"

@implementation DCSharePeriod
#pragma mark - initialization
- (instancetype)initWithDict:(NSDictionary *)dict dateOfShareDay:(NSDate*)shareDate{
    self = [super init];
    if (self) {
        self.dateOfShare = shareDate;
        self.arrFreeSplitedPeriod = [NSMutableArray array];
        self.arrBookedSplitedPeriod = [NSMutableArray array];
        self.arrOverdueSplitedPeriod = [NSMutableArray array];
        if ([dict isKindOfClass:[NSDictionary class]]) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([(NSString*) key isEqualToString:@"startTime"]) {
                    self.timeShareStart = [self parseWithTimeStringWithHourAndMinute:(NSString*)obj];
                }
                else if ([(NSString*) key isEqualToString:@"endTime"]) {
                    self.timeShareEnd = [self parseWithTimeStringWithHourAndMinute:(NSString*)obj];
                }
                else if ([(NSString*) key isEqualToString:@"splitPeriod"]) {
                    self.duration = [((NSNumber*)obj) copy];
                }
                else if ([(NSString*) key isEqualToString:@"free"] && [obj isKindOfClass:[NSArray class]]) {
                    [self.arrFreeSplitedPeriod addObjectsFromArray:[self parseTimeArrWithTimeStringArr:obj]];
                }
                else if ([(NSString*) key isEqualToString:@"booked"] && [obj isKindOfClass:[NSArray class]]) {
                    [self.arrBookedSplitedPeriod addObjectsFromArray:[self parseTimeArrWithTimeStringArr:obj]];
                }
                else if ([(NSString*) key isEqualToString:@"overdue"] && [obj isKindOfClass:[NSArray class]]) {
                    [self.arrOverdueSplitedPeriod addObjectsFromArray:[self parseTimeArrWithTimeStringArr:obj]];
                }
                else if(![obj isKindOfClass:[NSNull class]]) {
                    [self setValue:obj forKey:key];
                }
            }];
        }
        self.arrAllSplitedPeriod = [NSMutableArray array];
        [self.arrAllSplitedPeriod addObjectsFromArray:self.arrFreeSplitedPeriod];
        [self.arrAllSplitedPeriod addObjectsFromArray:self.arrBookedSplitedPeriod];
        [self.arrAllSplitedPeriod addObjectsFromArray:self.arrOverdueSplitedPeriod];
        
        // sort arrays
        [self sortDateArrAscendingly:self.arrFreeSplitedPeriod];
        [self sortDateArrAscendingly:self.arrBookedSplitedPeriod];
        [self sortDateArrAscendingly:self.arrOverdueSplitedPeriod];
        [self sortDateArrAscendingly:self.arrAllSplitedPeriod];
    }
    return self;
}

#pragma mark - 
- (NSDate*)combineDay:(NSDate*)dateOfShare withShareTime:(NSDate*)timeOfShare {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:dateOfShare];
    NSDateComponents *timeComponents = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:timeOfShare];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc]init];
    newComponents.timeZone = [NSTimeZone systemTimeZone];
    [newComponents setDay:[dateComponents day]];
    [newComponents setMonth:[dateComponents month]];
    [newComponents setYear:[dateComponents year]];
    [newComponents setHour:[timeComponents hour]];
    [newComponents setMinute:[timeComponents minute]];
    return [calendar dateFromComponents:newComponents];
}
- (NSString*)sharePeriodStr {
    NSMutableString* sharePeriodStr = [NSMutableString string];
    [sharePeriodStr appendString:[NSString stringWithFormat:@"%@ - %@", [self.timeShareStart parseToTimeString:NO], [self.timeShareEnd parseToTimeString:YES]]];
    return sharePeriodStr;
}
- (NSString*)splitePeriodStringAtIndex:(NSInteger)index {
    NSDate *splitedStartTime = [self.arrAllSplitedPeriod objectAtIndex:index];
    NSInteger minuteCount = self.duration ? [self.duration floatValue] * 60 : 0;
    NSDate *splitedEndTime = [splitedStartTime dateByAddingCompoent:kCFCalendarUnitMinute withCount:minuteCount];
    NSString *splitedPeriodStr = [NSString stringWithFormat:@"%@ - %@", [splitedStartTime parseToTimeString:NO], [splitedEndTime parseToTimeString:YES]];
    return splitedPeriodStr;
}

-(BOOL) canSelectThisPeriod {
    return (self.arrFreeSplitedPeriod && [self.arrFreeSplitedPeriod count] > 0);
}

-(BOOL) canSelected:(NSInteger) index {
    NSDate *splitedStartTime = [self.arrAllSplitedPeriod objectAtIndex:index];
    if ([self.arrFreeSplitedPeriod containsObject:splitedStartTime]) {
        return YES;
    }
    return NO;
}

- (NSArray*)datesOfPeriodWithIndex:(NSInteger)index {
//    NSDate *splitedStartTime = [self.arrAllSplitedPeriod objectAtIndex:index];
    NSDate *startTime = [self.arrAllSplitedPeriod objectAtIndex:index];
    NSInteger minuteCount = self.duration ? [self.duration floatValue] * 60 : 0;
    NSDate *endTime = [startTime dateByAddingCompoent:kCFCalendarUnitMinute withCount:minuteCount];
    return @[startTime, endTime];
}

#pragma mark - Utilities functions
// 将timestamp 转化成 NSDate， timezone为英国格林威治
- (NSDate*) parseWithTimeStringWithHourAndMinute:(NSString*) timeStr {
    NSDateFormatter* ft = [[NSDateFormatter alloc] init];
//    ft.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    ft.dateFormat = @"HH:mm";
    NSDate* time = [ft dateFromString:timeStr];
    return [self combineDay:self.dateOfShare withShareTime:time];
}

- (NSArray*) parseTimeArrWithTimeStringArr:(NSArray*) timeStrArr {
    NSMutableArray* timeArr = [NSMutableArray array];
    for (NSString* timeStr in timeStrArr) {
        [timeArr addObject:[self parseWithTimeStringWithHourAndMinute:(NSString*)timeStr]];
    }
    return [timeArr copy];
}

// 排列NSDate 数组
- (void)sortDateArrAscendingly:(NSMutableArray*) arr {
    [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSDate*) obj1 compare:(NSDate*)obj2];
    }];
}
@end

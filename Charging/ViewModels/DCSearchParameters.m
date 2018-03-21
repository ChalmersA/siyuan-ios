//
//  HSSYSearchParameters.m
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCSearchParameters.h"
#define MAX_DISTANCE 6374000*3.14/2

@interface DCSearchParameters ()
@property (strong, nonatomic) NSDateComponents *startTimeComponent;
@property (strong, nonatomic) NSDateComponents *endTimeComponent;
@property (strong, nonatomic) NSDateComponents *dayComponent;
@property (strong, nonatomic) NSNumber *duration;
@end

@implementation DCSearchParameters

- (instancetype)init {
    self = [super init];
    if (self) {
        self.stationType = DCSearchStationTypeAll;
        self.chargeType = DCSearchChargeType_All;
        self.keyword = nil;
        self.onlyIdle = NO;
        self.distance = @(MAX_DISTANCE);
    }
    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.placeCode forKey:@"placeCode"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.distance forKey:@"distance"];

    [aCoder encodeInteger:self.sort forKey:@"sort"];
    
//    [aCoder encodeObject:self.startTime forKey:@"startTime"];
//    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.startTimeComponent forKey:@"startTimeComponent"];
    [aCoder encodeObject:self.endTimeComponent forKey:@"endTimeComponent"];
    [aCoder encodeObject:self.dayComponent forKey:@"dayComponent"];
    [aCoder encodeObject:self.duration forKey:@"duration"];
    
    [aCoder encodeBool:self.stationType forKey:@"stationType"];
    [aCoder encodeBool:self.chargeType forKey:@"chargeType"];
    [aCoder encodeBool:self.onlyIdle forKey:@"onlyIdle"];
    
    [aCoder encodeObject:self.keyword forKey:@"keyword"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _placeCode = [coder decodeObjectForKey:@"placeCode"];
        _location = [coder decodeObjectForKey:@"location"];
        _distance = [coder decodeObjectForKey:@"distance"];
        
        _sort = [coder decodeIntegerForKey:@"sort"];
        
//        _startTime = [coder decodeObjectForKey:@"startTime"];
//        _endTime = [coder decodeObjectForKey:@"endTime"];
        _startTimeComponent = [coder decodeObjectForKey:@"startTimeComponent"];
        _endTimeComponent = [coder decodeObjectForKey:@"startTimeComponent"];
        _dayComponent = [coder decodeObjectForKey:@"startTimeComponent"];
        _duration = [coder decodeObjectForKey:@"duration"];
        
        _stationType = [coder decodeBoolForKey:@"stationType"];
        _chargeType = [coder decodeBoolForKey:@"chargeType"];
        _onlyIdle = [coder decodeBoolForKey:@"onlyIdle"];
        
        _keyword = [coder decodeObjectForKey:@"keyword"];
    }
    return self;
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone {
    DCSearchParameters *param = [[DCSearchParameters alloc] init];
    param.placeCode = [self.placeCode copy];
    param.location = [self.location copy];
    param.distance = [self.distance copy];
    
    param.sort = self.sort;
    
//    param.startTime = [self.startTime copy];
//    param.endTime = [self.endTime copy];
    param.startTimeComponent = [self.startTimeComponent copy];
    param.endTimeComponent = [self.endTimeComponent copy];
    param.dayComponent = [self.dayComponent copy];
    param.duration = [self.duration copy];
    
    param.stationType = self.stationType;
    param.chargeType = self.chargeType;
    param.onlyIdle = self.onlyIdle;
    
    param.keyword = [self.keyword copy];
    return param;
}

#pragma mark - setter
//- (void)setLocation:(CLLocation *)location {
//    _location = location;
//    [[NSNotificationCenter defaultCenter] postNotificationName:HSSYSearchLocationChangedNotification object:self];
//}

#pragma mark - distance
- (void)setDistanceFromFilterIndex:(NSInteger)index {
//    @"不限", @"500m", @"1km", @"2km", @"5km"
    switch (index) {
        case 0:
            self.distance = @(MAX_DISTANCE);
            break;
            
        case 1:
            self.distance = @(500);
            break;
            
        case 2:
            self.distance = @(1000);
            break;
            
        case 3:
            self.distance = @(2000);
            break;
            
        case 4:
            self.distance = @(5000);
            break;
            
        default:
            break;
    }
}

- (NSInteger)distanceFilterIndex {
    if (self.distance) {
        NSInteger distance = [self.distance integerValue];
        if (distance == 500) {
            return 1;
        } else if (distance == 1000) {
            return 2;
        } else if (distance == 2000) {
            return 3;
        } else if (distance == 5000) {
            return 4;
        }
    }
    return 0;
}

#pragma mark - sort
- (void)setSortFromFilterIndex:(NSInteger)index {
    if (index <= 0) {
        self.sort = 0;
    } else {
        self.sort = index;
    }
}

- (NSInteger)sortFilterIndex {
    if (self.sort) {
        return self.sort;
    }
    return 0;
}

#pragma mark - Public
/*
 * 清除所有搜索条件数据
 */
+ (void)clearData{
    [DCApp sharedApp].searchParam = [[DCSearchParameters alloc]init];
}

- (BOOL)isChangedFrom:(DCSearchParameters *)param {
    BOOL distanceChanged = YES;
    if (self.distance && param.distance) {
        if ([self.distance isEqualToNumber:param.distance]) {
            distanceChanged = NO;
        }
    } else if (!self.distance && !param.distance) {
        distanceChanged = NO;
    }
    
    
    BOOL sortChanged = YES;
    if (self.sort && param.sort) {
        if (self.sort == param.sort) {
            sortChanged = NO;
        }
    } else if (!self.sort && !param.sort) {
        sortChanged = NO;
    }
    

    BOOL startTimeChanged = YES;
    if (self.startTimeComponent && param.startTimeComponent) {
        if ((self.startTimeComponent.hour == param.startTimeComponent.hour) && (self.startTimeComponent.minute == param.startTimeComponent.minute)) {
            startTimeChanged = NO;
        }
    } else if (!self.startTimeComponent && !param.startTimeComponent) {
        startTimeChanged = NO;
    }
    
    BOOL endTimeChanged = YES;
    if (self.endTimeComponent && param.endTimeComponent) {
        if ((self.endTimeComponent.hour == param.endTimeComponent.hour) && (self.endTimeComponent.minute == param.endTimeComponent.minute)) {
            endTimeChanged = NO;
        }
    } else if (!self.endTimeComponent && !param.endTimeComponent) {
        endTimeChanged = NO;
    }
    
    BOOL dayChanged = YES;
    if (self.dayComponent && param.dayComponent) {
        if ((self.dayComponent.day == param.dayComponent.day) && (self.dayComponent.month == param.dayComponent.month) && (self.dayComponent.year == param.dayComponent.year)) {
            dayChanged = NO;
        }
    } else if (!self.dayComponent && !param.dayComponent) {
        dayChanged = NO;
    }
    
    BOOL durationChanged = YES;
    if (self.duration && param.duration) {
        if ([self.duration isEqualToNumber:param.duration]) {
            durationChanged = NO;
        }
    } else if (!self.duration && !param.duration) {
        durationChanged = NO;
    }
    
    BOOL typeChanged = (param.stationType != self.stationType);
    
    BOOL idleChanged = (param.onlyIdle != self.onlyIdle);
    
    BOOL result = (distanceChanged || sortChanged || startTimeChanged || endTimeChanged || dayChanged || durationChanged || typeChanged || idleChanged);
    
#if DEBUG
    if (result) {
        NSMutableString *log = [NSMutableString string];
        if (distanceChanged) {
            [log appendFormat:@" distanceChanged"];
        }
        if (sortChanged) {
            [log appendFormat:@" sortChanged"];
        }
        if (startTimeChanged) {
            [log appendFormat:@" startTimeChanged"];
        }
        if (endTimeChanged) {
            [log appendFormat:@" endTimeChanged"];
        }
        if (dayChanged) {
            [log appendFormat:@" dayChanged"];
        }
        if (durationChanged) {
            [log appendFormat:@" durationChanged"];
        }
        if (typeChanged) {
            [log appendFormat:@" typeChanged"];
        }
        if (idleChanged) {
            [log appendFormat:@" idleChanged"];
        }
        NSLog(@"search param changed:%@", log);
    }
#endif
    
    return result;
}

- (NSString *)stationTypeParam {
    if (self.stationType == DCSearchStationTypePublic) { // 1:DC 2:AC
        return @"1";
    } else if (self.stationType == DCSearchStationTypeSpecial) {
        return @"2";
    }
    return @"0,1,2";
}

- (NSString *)chargeTypeParam {
    if (self.chargeType == DCSearchChargeType_Slow) {
        return @"0";
    } else if (self.chargeType == DCSearchChargeType_Quick) {
        return @"1";
    }
    return nil;
}

- (BOOL)onlyIdleParam {
    if (self.onlyIdle) {
        return self.onlyIdle;
    }
    return NO;
}

- (NSDate *)startTime {
    if (self.startTimeComponent) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        [components setHour:self.startTimeComponent.hour];
        [components setMinute:self.startTimeComponent.minute];
        if (self.dayComponent) {
            [components setYear:self.dayComponent.year];
            [components setMonth:self.dayComponent.month];
            [components setDay:self.dayComponent.day];
        }
        NSDate *startTime = [[NSCalendar currentCalendar] dateFromComponents:components];
        return startTime;
    }
    return nil;
}

- (NSDate *)endTime {
    if (self.endTimeComponent) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
        [components setHour:self.endTimeComponent.hour];
        [components setMinute:self.endTimeComponent.minute];
        if (self.dayComponent) {
            [components setYear:self.dayComponent.year];
            [components setMonth:self.dayComponent.month];
            [components setDay:self.dayComponent.day];
        }
        NSDate *endTime = [[NSCalendar currentCalendar] dateFromComponents:components];
        return endTime;
    }
    return nil;
}

- (void)setStartClockTime:(ClockTime)startTime startTimeActivated:(BOOL)startTimeActivated endClockTime:(ClockTime)endTime endTimeActivated:(BOOL)endTimeActivated duration:(double)duration {
    if (startTimeActivated) {
        NSDateComponents *startTimeComponent = self.startTimeComponent;
        if (!startTimeComponent) {
            startTimeComponent = [[NSDateComponents alloc] init];
        }
        startTimeComponent.hour = startTime.hour;
        startTimeComponent.minute = startTime.minute;
        self.startTimeComponent = startTimeComponent;
    } else {
        self.startTimeComponent = nil;
    }
    
    if (endTimeActivated) {
        NSDateComponents *endTimeComponent = self.endTimeComponent;
        if (!endTimeComponent) {
            endTimeComponent = [[NSDateComponents alloc] init];
        }
        endTimeComponent.hour = endTime.hour;
        endTimeComponent.minute = endTime.minute;
        self.endTimeComponent = endTimeComponent;
    } else {
        self.endTimeComponent = nil;
    }
    
    if (duration) {
        self.duration = @(duration);
    } else {
        self.duration = nil;
    }
}

//- (void)setupTimeComponents {
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    self.startTimeComponent = [gregorian components:(NSCalendarUnitHour|NSCalendarUnitMinute) fromDate:[NSDate date]];
//    self.startTimeComponent.minute = self.startTimeComponent.minute/30*30;
//    self.endTimeComponent = nil;
//    self.duration = nil;
//}

- (void)setDayComponentWithDate:(NSDate *)date {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    self.dayComponent = [gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
}

@end

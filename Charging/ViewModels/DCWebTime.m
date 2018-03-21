//
//  HSSYWebTime.m
//  Charging
//
//  Created by Ben on 15/1/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCWebTime.h"

@implementation DCWebTime

- (instancetype)initWithHssyTime:(DCTime *)hssyTime {
    self = [super init];
    if (self) {
        self.startTime = [NSString stringWithFormat:@"%ld", (long)hssyTime.startTimestamp];
        self.endTime = [NSString stringWithFormat:@"%ld", (long)hssyTime.endTimestamp];
        self.week = hssyTime.weekString;
        self.servicePay = hssyTime.servicePay;
    }
    return self;
}

- (NSDictionary *)jsonDict {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.startTime) {
        [dict setObject:self.startTime forKey:@"startTime"];
    }
    if (self.endTime) {
        [dict setObject:self.endTime forKey:@"endTime"];
    }
    if (self.week) {
        [dict setObject:self.week forKey:@"week"];
    }
    [dict setObject:@(self.servicePay) forKey:@"servicePay"];
    
    return dict;
}

@end

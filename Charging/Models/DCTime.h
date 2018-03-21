//
//  HSSYTime.h
//  Charging
//
//  Created by Ben on 15/1/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCClockView.h"

@interface DCTime : NSObject
@property (copy, nonatomic) NSString *timeId;
@property (nonatomic) NSTimeInterval startTimestamp; //277000
@property (nonatomic) NSTimeInterval endTimestamp;  //277000
@property (copy, nonatomic) NSString *weekString; //星期，如，@"1,2,4"

@property (assign, nonatomic) double servicePay;

@property (readonly) NSDate *startTimeDate;
@property (readonly) NSDate *endTimeDate;
@property (readonly) NSString *timeFrameString; // 显示的时段，如，@"09:20 - 10:00"
@property (readonly) NSString *weekStringCN; //星期（中文格式）,如,@"周一 周二"

@property (readonly) ClockTime startTime;
@property (readonly) ClockTime endTime;

- (instancetype)initWithStartTime:(ClockTime)startTime endTime:(ClockTime)endTime weekday:(NSString *)weekday;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

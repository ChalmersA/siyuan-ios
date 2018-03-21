//
//  DCOpeningTime.h
//  Charging
//
//  Created by kufufu on 16/3/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

typedef NS_ENUM(NSInteger, DCOpenType) {
    DCOpenTypeAllYear = 1,
    DCOpenTypeWorkday,
    DCOpenTypeHolidays,
};

@interface DCOpeningTime : DCModel <NSCoding>

@property (assign, nonatomic) DCOpenType openType;      //开放类型
@property (copy, nonatomic) NSString *startTime;        //开放开始时间
@property (copy, nonatomic) NSString *endTime;          //开放结束时间
@property (assign, nonatomic) double fee;

- (instancetype)initOpeningAtWithDict:(NSDictionary *)dict;
//- (instancetype)initChargeFeeWithDict:(NSDictionary *)dict;

@end

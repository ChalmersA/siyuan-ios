//
//  HSSYWebTime.h
//  Charging
//
//  Created by Ben on 15/1/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCTime.h"

@interface DCWebTime : NSObject
@property (copy,nonatomic) NSString *endTime;
@property (copy,nonatomic) NSString *startTime;
@property (copy,nonatomic) NSString *week;
@property (assign, nonatomic) double servicePay;
-(instancetype)initWithHssyTime:(DCTime *)hssyTime;
-(NSDictionary *)jsonDict;
@end

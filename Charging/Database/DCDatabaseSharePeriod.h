//
//  HSSYDatabaseSharePeriod.h
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseSharePeriod : NSObject

@property (copy, nonatomic) NSString *pole_no;
@property (assign, nonatomic) NSTimeInterval start_time;
@property (assign, nonatomic) NSTimeInterval end_time;
@property (copy, nonatomic) NSString *week;

+ (NSArray *)periodsWithPoleNo:(NSString *)pole_no;
+ (void)savePeriods:(NSArray *)periods forPoleNo:(NSString *)pole_no;

@end

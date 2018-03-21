//
//  HSSYDatabaseSharePeriod.m
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseSharePeriod.h"
#import "DCDatabase.h"

//"pole_no CHAR(8) NULL,"
//"start_time TIME NULL,"
//"end_time TIME NULL,"
//"week VARCHAR(45) NULL);"

@implementation DCDatabaseSharePeriod

+ (instancetype)sharePeriodWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseSharePeriod *period = [[self alloc] init];
    [period updateWithResultSet:resultSet];
    return period;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.pole_no = [resultSet stringForColumn:@"pole_no"];
    self.start_time = [resultSet doubleForColumn:@"start_time"];
    self.end_time = [resultSet doubleForColumn:@"end_time"];
    self.week = [resultSet stringForColumn:@"week"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"pole_no", @"start_time", @"end_time", @"week"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

+ (NSArray *)periodsWithPoleNo:(NSString *)pole_no {
    NSMutableArray *periods = [NSMutableArray array];
    if (!pole_no) {
        return periods;
    }
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Share_Period WHERE pole_no = ?"
               withArgumentsInArray:@[pole_no]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseSharePeriod *period = [self sharePeriodWithResultSet:resultSet];
                                [periods addObject:period];
                            }
                        }];
    return periods;
}

+ (void)savePeriods:(NSArray *)periods forPoleNo:(NSString *)pole_no {
    if (!pole_no) {
        return;
    }
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM T_Share_Period WHERE pole_no = ?" withArgumentsInArray:@[pole_no]];
        for (DCDatabaseSharePeriod *period in periods) {
            [db executeUpdate:@"INSERT INTO T_Share_Period (pole_no, start_time, end_time, week) VALUES (:pole_no, :start_time, :end_time, :week)" withParameterDictionary:[period parameterDictionary]];
        }
    }];
}

@end

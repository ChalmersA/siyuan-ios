//
//  HSSYDatabaseFault.m
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseFault.h"
#import "DCDatabase.h"

@implementation DCDatabaseFault

+ (instancetype)faultWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseFault *fault = [[self alloc] init];
    [fault updateWithResultSet:resultSet];
    return fault;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.fault_no = [resultSet longLongIntForColumn:@"fault_no"];
    self.pole_no = [resultSet stringForColumn:@"pole_no"];
    self.record_time = [resultSet doubleForColumn:@"record_time"];
    self.fault_type = [resultSet intForColumn:@"fault_type"];
    self.data = [resultSet stringForColumn:@"data"];
    self.response_data = [resultSet stringForColumn:@"response_data"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"fault_no", @"pole_no", @"record_time", @"fault_type", @"data", @"response_data"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (BOOL)isSameAs:(DCDatabaseFault *)fault {
    return (self.fault_no == fault.fault_no) &&
    [self.pole_no isEqualToString:fault.pole_no] &&
    (self.record_time == fault.record_time) &&
    (self.fault_type == fault.fault_type) &&
    [self.data isEqualToString:fault.data] &&
    [self.response_data isEqualToString:fault.response_data];
}

- (void)insertToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT INTO T_Fault (fault_no, pole_no, record_time, fault_type, data, response_data) VALUES (:fault_no, :pole_no, :record_time, :fault_type, :data, :response_data)" withParameterDictionary:[self parameterDictionary]];
    }];
}

@end

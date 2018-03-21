//
//  HSSYDatabaseOrder.m
//  Charging
//
//  Created by xpg on 15/1/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseOrder.h"
#import "DCDatabase.h"

//"order_id INT NULL DEFAULT NULL,"
//"user_id INT NULL DEFAULT NULL,"
//"pole_no CHAR(8) NULL DEFAULT NULL,"
//"schedule_start_t TIMESTAMP NULL DEFAULT NULL,"
//"schedule_end_t TIMESTAMP NULL DEFAULT NULL,"
//"state INT NULL,"
//"confirm_time TIMESTAMP NULL,"

@implementation DCDatabaseOrder

+ (instancetype)orderWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseOrder *order = [[self alloc] init];
    [order updateWithResultSet:resultSet];
    return order;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.orderId = [resultSet stringForColumn:@"orderId"];
    self.pileId = [resultSet stringForColumn:@"pileId"];
    self.ownerId = [resultSet stringForColumn:@"ownerId"];
    self.tenantId = [resultSet stringForColumn:@"tenanId"];
    self.stationId = [resultSet stringForColumn:@"stationId"];
    self.schedule_start_t = [resultSet doubleForColumn:@"schedule_start_t"];
    self.schedule_end_t = [resultSet doubleForColumn:@"schedule_end_t"];
    self.orderState= [resultSet intForColumn:@"orderState"];
    self.create_time = [resultSet doubleForColumn:@"create_time"];
    self.serviceFee = [resultSet doubleForColumn:@"serviceFee"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"orderId", @"pileId", @"ownerId", @"tenantId", @"stationId", @"schedule_start_t", @"schedule_end_t", @"orderState", @"create_time", @"serviceFee"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

+ (NSArray *)ordersWithUserId:(int64_t)user_id {
    NSMutableArray *orders = [NSMutableArray array];
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Order WHERE user_id = ? ORDER BY schedule_start_t DESC"
               withArgumentsInArray:@[@(user_id)]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseOrder *order = [self orderWithResultSet:resultSet];
                                [orders addObject:order];
                            }
                        }];
    return orders;
}

+ (NSArray *)ordersWithPoleNo:(NSString *)poleNo {
    NSMutableArray *orders = [NSMutableArray array];
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Order WHERE pole_no = ? ORDER BY schedule_start_t DESC"
               withArgumentsInArray:@[poleNo]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseOrder *order = [self orderWithResultSet:resultSet];
                                [orders addObject:order];
                            }
                        }];
    return orders;
}

+ (DCDatabaseOrder *)ordersWithOrderId:(NSString *)orderId {
    DCDatabaseOrder * __block order;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Order WHERE orderId = ? ORDER BY schedule_start_t DESC"
               withArgumentsInArray:@[orderId]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                order = [self orderWithResultSet:resultSet];
                            }
                        }];
    return order;
}

- (void)saveToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_Order (orderId, pileId, ownerId, tenantId, stationId, schedule_start_t, schedule_end_t, create_time, orderState, serviceFee) VALUES (:orderId, :pileId, :ownerId, :tenantId, :stationId, :schedule_start_t, :schedule_end_t, :create_time, :orderState, :serviceFee)" withParameterDictionary:[self parameterDictionary]];
    }];
}

@end

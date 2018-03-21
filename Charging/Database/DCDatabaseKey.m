//
//  HSSYDatabaseKey.m
//  Charging
//
//  Created by xpg on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseKey.h"
#import "DCDatabase.h"

@implementation DCDatabaseKey

+ (instancetype)keyWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseKey *key = [[self alloc] init];
    [key updateWithResultSet:resultSet];
    return key;
}

+ (void)cleanAllKeysInDataBase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:@"DELETE FROM T_Ownership"];
//        isSuccess = isSuccess ? [db executeUpdate:@"UPDATE sqlite_sequence set seq=0 where name='T_Ownership'"] : isSuccess;
        
        if (isSuccess == NO) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.user_id = [resultSet longLongIntForColumn:@"user_id"];
    self.user_role = [resultSet intForColumn:@"user_role"];
    self.pole_no = [resultSet stringForColumn:@"pole_no"];
    self.add_time = [resultSet doubleForColumn:@"add_time"];
    self.key = [resultSet stringForColumn:@"key"];
    self.key_type = [resultSet intForColumn:@"key_type"];
    self.valid_time_start = [resultSet doubleForColumn:@"valid_time_start"];
    self.valid_time_end = [resultSet doubleForColumn:@"valid_time_end"];
    self.order_id = [resultSet longLongIntForColumn:@"order_id"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"user_id", @"user_role", @"pole_no", @"add_time", @"key", @"key_type", @"valid_time_start", @"valid_time_end", @"order_id"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (BOOL)isSameAs:(DCDatabaseKey *)key {
    return (self.user_id == key.user_id) &&
    (self.user_role == key.user_role) &&
    [self.pole_no isEqualToString:key.pole_no] &&
    (self.add_time == key.add_time) &&
    [self.key isEqualToString:key.key] &&
    (self.key_type == key.key_type) &&
    (self.valid_time_start == key.valid_time_start) &&
    (self.valid_time_end == key.valid_time_end) &&
    (self.order_id == key.order_id);
}

+ (NSArray *)keysWithUserId:(int64_t)user_id {
    NSMutableArray *keys = [NSMutableArray array];
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Ownership WHERE user_id = ? ORDER BY key_type"
               withArgumentsInArray:@[@(user_id)]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseKey *key = [self keyWithResultSet:resultSet];
                                [keys addObject:key];
                            }
                        }];
    return [keys copy];
}

+ (NSArray *)keysWithUserId:(int64_t)user_id poleNo:(NSString *)pole_no {
    NSMutableArray *keys = [NSMutableArray array];
    if (!pole_no) {
        return keys;
    }
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Ownership WHERE user_id = ? AND pole_no = ? ORDER BY key_type"
               withArgumentsInArray:@[@(user_id), pole_no]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseKey *key = [self keyWithResultSet:resultSet];
                                [keys addObject:key];
                            }
                        }];
    return [keys copy];
}

+ (NSArray *)keysWithUserId:(int64_t)user_id poleNo:(NSString *)pole_no keyType:(int8_t)key_type {
    NSMutableArray *keys = [NSMutableArray array];
    if (!pole_no) {
        return keys;
    }
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Ownership WHERE user_id = ? AND pole_no = ? AND key_type = ? ORDER BY add_time DESC"
               withArgumentsInArray:@[@(user_id), pole_no, @(key_type)]
                        resultBlock:^(FMResultSet *resultSet) {
                            while ([resultSet next]) {
                                DCDatabaseKey *key = [self keyWithResultSet:resultSet];
                                [keys addObject:key];
                            }
                        }];
    return [keys copy];
}

- (void)insertKeyToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        // DELETE old KEY??
        [db executeUpdate:@"DELETE FROM T_Ownership WHERE user_id = :user_id AND pole_no = :pole_no AND key_type = :key_type AND key = :key" withParameterDictionary:[self parameterDictionary]];
        
        // INSERT the new one??
        BOOL success =
        [db executeUpdate:@"INSERT INTO T_Ownership (user_id, user_role, pole_no, add_time, key, key_type, valid_time_start, valid_time_end, order_id) VALUES (:user_id, :user_role, :pole_no, :add_time, :key, :key_type, :valid_time_start, :valid_time_end, :order_id)" withParameterDictionary:[self parameterDictionary]];
        if (!success) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

@end

//
//  DCDatabaseUser.m
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabaseUser.h"
#import "DCDatabase.h"

@interface DCDatabaseUser ()

@end

@implementation DCDatabaseUser

+ (instancetype)userWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseUser *user = [[self alloc] init];
    [user updateWithResultSet:resultSet];
    return user;
}

+ (void)cleanAllUsersInDataBase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:@"DELETE FROM T_User"];
        if (isSuccess == NO) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.user_id = [resultSet stringForColumn:@"user_id"];
    self.user_portrait = [resultSet dataForColumn:@"user_portrait"];
    self.user_thirdUuid = [resultSet stringForColumn:@"user_thirdUuid"];
    self.user_phone = [resultSet stringForColumn:@"user_phone"];
    self.user_gender = [resultSet intForColumn:@"user_gender"];
    self.user_nickName = [resultSet stringForColumn:@"user_nickName"];
    self.user_bindType = [resultSet intForColumn:@"user_bindType"];
    self.user_createAt = [resultSet longLongIntForColumn:@"user_createAt"];
    self.user_pushId = [resultSet stringForColumn:@"user_pushId"];
    self.user_pushType = [resultSet intForColumn:@"user_pushType"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"user_id", @"user_portrait", @"user_thirdUuid", @"user_phone", @"user_gender", @"user_nickName", @"user_bindType", @"user_createAt", @"user_pushId", @"user_pushType"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (BOOL)isSameAs:(DCDatabaseUser *)user {
    return [self.user_id isEqualToString:user.user_id] &&
    //    self.user_portrait;
    [self.user_thirdUuid isEqualToString:user.user_thirdUuid] &&
    [self.user_phone isEqualToString:user.user_phone] &&
    (self.user_gender == user.user_gender) &&
    [self.user_nickName isEqualToString:user.user_nickName] &&
    (self.user_bindType == user.user_bindType) &&
    (self.user_createAt == user.user_createAt) &&
    [self.user_pushId isEqualToString:user.user_pushId] &&
    (self.user_pushType == user.user_pushType);
}

+ (instancetype)userWithId:(int64_t)user_id {
    DCDatabaseUser * __block user = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_User WHERE user_id = ?" withArgumentsInArray:@[@(user_id)] resultBlock:^(FMResultSet *resultSet) {
        if ([resultSet next]) {
            user = [self userWithResultSet:resultSet];
        }
    }];
    return user;
}

- (void)saveToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_User (user_id, user_portrait, user_thirdUuid, user_phone, user_gender, user_nickName, user_bindType, user_createAt, user_pushId, user_pushType) VALUES (:user_id, :user_portrait, :user_thirdUuid, :user_phone, :user_gender, :user_nickName, :user_bindType, :user_createAt, :user_pushId, :user_pushType)" withParameterDictionary:[self parameterDictionary]];
    }];
}

@end

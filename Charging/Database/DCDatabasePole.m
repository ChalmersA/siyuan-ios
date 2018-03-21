//
//  HSSYDatabasePole.m
//  Charging
//
//  Created by xpg on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDatabasePole.h"
#import "DCDatabase.h"

@implementation DCDatabasePole

+ (instancetype)poleWithResultSet:(FMResultSet *)resultSet {
    DCDatabasePole *pole = [[self alloc] init];
    [pole updateWithResultSet:resultSet];
    return pole;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.pole_no = [resultSet stringForColumn:@"pole_no"];
    self.nick_name = [resultSet stringForColumn:@"nick_name"];
    self.pole_type = [resultSet intForColumn:@"pole_type"];
    self.location = [resultSet stringForColumn:@"location"];
    self.longitude = [resultSet doubleForColumn:@"longitude"];
    self.latitude = [resultSet doubleForColumn:@"latitude"];
    self.altitude = [resultSet doubleForColumn:@"altitude"];
    self.rated_cur = [resultSet doubleForColumn:@"rated_cur"];
    self.rated_volt = [resultSet doubleForColumn:@"rated_volt"];
    self.price = [resultSet doubleForColumn:@"price"];
    self.contact_name = [resultSet stringForColumn:@"contact_name"];
    self.contact_phone_no = [resultSet stringForColumn:@"contact_phone_no"];
    self.appointManageType = [resultSet intForColumn:@"appointManageType"];
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"pole_no", @"nick_name", @"pole_type", @"location", @"longitude", @"latitude", @"altitude", @"rated_cur", @"rated_volt", @"price", @"contact_name", @"contact_phone_no", @"appointManageType"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (BOOL)isSameAs:(DCDatabasePole *)pole {
    return [self.pole_no isEqualToString:pole.pole_no] &&
    [self.nick_name isEqualToString:pole.nick_name] &&
    (self.pole_type == pole.pole_type) &&
    [self.location isEqualToString:pole.location] &&
    (self.longitude == pole.longitude) &&
    (self.latitude == pole.latitude) &&
    (self.altitude == pole.altitude) &&
    (self.rated_cur == pole.rated_cur) &&
    (self.rated_volt == pole.rated_volt) &&
    (self.price == pole.price) &&
    [self.contact_name isEqualToString:pole.contact_name] &&
    [self.contact_phone_no isEqualToString:pole.contact_phone_no] &&
    (self.appointManageType == pole.appointManageType) ;
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCDatabasePole class]]) {
        DCDatabasePole *pole = object;
        return [self.pole_no isEqualToString:pole.pole_no];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.pole_no hash];
}

+ (instancetype)poleWithPoleNo:(NSString *)pole_no {
    if (!pole_no) {
        return nil;
    }
    
    DCDatabasePole * __block pole = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_Pole WHERE pole_no = ?" withArgumentsInArray:@[pole_no] resultBlock:^(FMResultSet *resultSet) {
        if ([resultSet next]) {
            pole = [self poleWithResultSet:resultSet];
        }
    }];
    return pole;
}

+ (NSArray*)dbPolesWithPoleNOs:(NSArray *)poleNOs {
    if (!poleNOs || poleNOs.count <= 0) {
        return nil;
    }
    NSMutableString *queryStr = [NSMutableString stringWithString:@"SELECT * FROM T_Pole WHERE"];
    for (int i=0; i< [poleNOs count]; i++){
        id poleNum = [poleNOs objectAtIndex:i];
        if ([poleNum isKindOfClass:[NSString class]]) {
            if (i == 0) {
                [queryStr appendString:@" pole_no = ?"];
            }
            else {
                [queryStr appendString:@" OR pole_no = ?"];
            }
        }
    }
    
    NSMutableArray __block *poles = [NSMutableArray array];
    DCDatabasePole * __block pole = nil;
    [[DCDatabase db] executeQuery:[queryStr copy] withArgumentsInArray:poleNOs resultBlock:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            pole = [self poleWithResultSet:resultSet];
            [poles addObject:pole];
        }
    }];
    return [poles copy];
}
+ (void)cleanAllPolesInDataBase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:@"DELETE FROM T_Pole"];
        if (isSuccess == NO) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

+ (void)deleteWithPoleNo:(NSString *)pole_no {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM T_Pole WHERE pole_no = ?" withArgumentsInArray:@[pole_no]];
    }];
}

+ (NSArray *)polesOfUserAsOwner:(int64_t)user_id {
    NSMutableArray *poles = [NSMutableArray array];
    NSArray *keys = [DCDatabaseKey keysWithUserId:user_id];
    for (DCDatabaseKey *key in keys) {
        if (key.key_type == HSSYKeyTypeOwner) {
            DCDatabasePole *pole = [DCDatabasePole poleWithPoleNo:key.pole_no];
            if (pole && ![poles containsObject:pole]) {
                [poles addObject:pole];
            }
        }
    }
    return [poles copy];
}

+ (NSArray *)polesOfUserAsFamily:(int64_t)user_id {
    NSMutableArray *poles = [NSMutableArray array];
    NSArray *keys = [DCDatabaseKey keysWithUserId:user_id];
    for (DCDatabaseKey *key in keys) {
        if ((key.key_type == HSSYKeyTypeFamilyWhiteList) || (key.key_type == HSSYKeyTypeFamilyPeriod)) {
            DCDatabasePole *pole = [DCDatabasePole poleWithPoleNo:key.pole_no];
            if (pole && ![poles containsObject:pole]) {
                [poles addObject:pole];
            }
        }
    }
    return [poles copy];
}

+ (NSArray *)polesOfUserAsTenant:(int64_t)user_id {
    NSMutableArray *poles = [NSMutableArray array];
    NSArray *keys = [DCDatabaseKey keysWithUserId:user_id];
    for (DCDatabaseKey *key in keys) {
        if (key.key_type == HSSYKeyTypeTenant) {
            DCDatabasePole *pole = [DCDatabasePole poleWithPoleNo:key.pole_no];
            if (pole && ![poles containsObject:pole]) {
                [poles addObject:pole];
            }
        }
    }
    return [poles copy];
}

- (void)saveToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_Pole (pole_no, nick_name, pole_type, location, longitude, latitude, altitude, rated_cur, rated_volt, price, contact_name, contact_phone_no, appointManageType) VALUES (:pole_no, :nick_name, :pole_type, :location, :longitude, :latitude, :altitude, :rated_cur, :rated_volt, :price, :contact_name, :contact_phone_no, :appointManageType)" withParameterDictionary:[self parameterDictionary]];
    }];
}

@end

//
//  DCDatabasePile.m
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCDatabasePile.h"
#import "DCDatabaseKey.h"
#import "DCDatabase.h"

@implementation DCDatabasePile

+ (instancetype)pileWithResultSet:(FMResultSet *)resultSet {
    DCDatabasePile *pile = [[self alloc] init];
    [pile updateWithResultSet:resultSet];
    return pile;
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"pile_id", @"pile_deviceId", @"pile_stationId", @"pile_pileName", @"pile_pileType", @"ratePower", @"rateVoltage", @"rateCurrent", @"chargerNum"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.pile_id = [resultSet stringForColumn:@"pile_id"];
    self.pile_deviceId = [resultSet stringForColumn:@"pile_deviceId"];
    self.pile_stationId = [resultSet stringForColumn:@"pile_stationId"];
    self.pile_pileName = [resultSet stringForColumn:@"pile_pileName"];
    self.pile_pileType = [resultSet intForColumn:@"pile_pileType"];
    self.ratePower = [resultSet doubleForColumn:@"ratePower"];
    self.rateVoltage = [resultSet doubleForColumn:@"rateVoltage"];
    self.rateCurrent = [resultSet doubleForColumn:@"rateCurrent"];
    self.chargerNum = [resultSet intForColumn:@"chargerNum"];
}

- (BOOL)isSameAs:(DCDatabasePile *)pile {
    return [self.pile_id isEqualToString:pile.pile_id] &&
    [self.pile_deviceId isEqualToString:pile.pile_deviceId] &&
    ([self.pile_stationId isEqualToString:pile.pile_stationId]) &&
    [self.pile_pileName isEqualToString:pile.pile_pileName] &&
    (self.pile_pileType == pile.pile_pileType) &&
    (self.ratePower == pile.ratePower) &&
    (self.rateVoltage == pile.rateVoltage) &&
    (self.rateCurrent == pile.rateCurrent);
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCDatabasePile class]]) {
        DCDatabasePile *pile = object;
        return [self.pile_id isEqualToString:pile.pile_id];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.pile_id hash];
}

#pragma mark - Database
+ (instancetype)pileWithPileId:(NSString *)pileId {
    if (!pileId) {
        return nil;
    }
    
    DCDatabasePile * __block pile = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_pile WHERE pile_id = ?" withArgumentsInArray:@[pileId] resultBlock:^(FMResultSet *resultSet) {
        if ([resultSet next]) {
            pile = [self pileWithResultSet:resultSet];
        }
    }];
    return pile;
}

+ (NSArray *)pileWithStationId:(NSString *)station_id {
    NSMutableArray *piles = [NSMutableArray array];
    if (!station_id) {
        return piles;
    }
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_pile WHERE station_id = ?" withArgumentsInArray:@[station_id] resultBlock:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            DCDatabasePile *pile = [self pileWithResultSet:resultSet];
            [piles addObject:pile];
        }
    }];
    return piles;
}

+ (NSArray *)dbPilesWithPileIds:(NSArray *)pileIds {
    if (!pileIds || pileIds.count <= 0) {
        return nil;
    }
    NSMutableString *queryStr = [NSMutableString stringWithString:@"SELECT * FROM T_pile WHERE"];
    for (int i=0; i< [pileIds count]; i++){
        id pileNum = [pileIds objectAtIndex:i];
        if ([pileNum isKindOfClass:[NSString class]]) {
            if (i == 0) {
                [queryStr appendString:@" pile_id = ?"];
            }
            else {
                [queryStr appendString:@" OR pile_id = ?"];
            }
        }
    }
    
    NSMutableArray __block *piles = [NSMutableArray array];
    DCDatabasePile * __block pile = nil;
    [[DCDatabase db] executeQuery:[queryStr copy] withArgumentsInArray:pileIds resultBlock:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            pile = [self pileWithResultSet:resultSet];
            [piles addObject:pile];
        }
    }];
    return [piles copy];
}
+ (void)cleanAllPilesInDataBase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:@"DELETE FROM T_pile"];
        if (isSuccess == NO) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

+ (void)deleteWithPileId:(NSString *)pileId{
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM T_pile WHERE pile_id = ?" withArgumentsInArray:@[pileId]];
    }];
}
- (void)saveToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_pile (pile_id, pile_deviceId, pile_stationId, pile_pileName, pile_pileType, ratePower, rateVoltage, rateCurrent, chargerNum) VALUES (:pile_id, :pile_deviceId, :pile_stationId, :pile_pileName, :pile_pileType, :ratePower, :rateVoltage, :rateCurrent, :chargerNum)" withParameterDictionary:[self parameterDictionary]];
    }];
}


@end

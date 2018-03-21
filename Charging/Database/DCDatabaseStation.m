//
//  DCDatabaseStation.m
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCDatabaseStation.h"
#import "DCDatabaseKey.h"
#import "DCDatabase.h"

@implementation DCDatabaseStation

+ (instancetype)stationWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseStation *station = [[self alloc] init];
    [station updateWithResultSet:resultSet];
    return station;
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"station_id", @"station_stationName", @"station_stationType", @"station_stationStatus", @"address", @"longitude", @"latitude", @"station_directNum", @"station_alterNum", @"ownerId", @"ownerName", @"ownerPhone", @"bookFee", @"refundState", @"allowBookNum"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?:[NSNull null] forKey:key];
    }
    return [dict copy];
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.station_id = [resultSet stringForColumn:@"station_id"];
    self.station_stationName = [resultSet stringForColumn:@"station_stationName"];
    self.station_stationType = [resultSet intForColumn:@"station_stationType"];
    self.station_stationStatus = [resultSet intForColumn:@"pile_pileName"];
    self.address = [resultSet stringForColumn:@"address"];
    self.longitude = [resultSet doubleForColumn:@"longitude"];
    self.latitude = [resultSet doubleForColumn:@"latitude"];
    self.station_directNum = [resultSet intForColumn:@"station_directNum"];
    self.station_alterNum = [resultSet intForColumn:@"station_alterNum"];
    self.ownerId = [resultSet stringForColumn:@"ownerId"];
    self.ownerName = [resultSet stringForColumn:@"ownerName"];
    self.ownerPhone = [resultSet stringForColumn:@"ownerPhone"];
    self.bookFee = [resultSet doubleForColumn:@"bookFee"];
    self.outBookWaitTime = [resultSet intForColumn:@"outBookWaitTime"];
    self.refundState = [resultSet intForColumn:@"refundState"];
    self.allowBookNum = [resultSet intForColumn:@"allowBookNum"];
}

- (BOOL)isSameAs:(DCDatabaseStation *)station {
    return [self.station_id isEqualToString:station.station_id] &&
    [self.station_stationName isEqualToString:station.station_stationName] &&
    (self.station_stationType = station.station_stationType) &&
    (self.station_stationStatus = station.station_stationStatus) &&
    [self.address isEqualToString:station.address] &&
    (self.longitude = station.longitude) &&
    (self.latitude = station.latitude) &&
    (self.station_directNum = station.station_directNum) &&
    (self.station_alterNum = station.station_alterNum) &&
    [self.ownerId isEqualToString:station.ownerId] &&
    [self.ownerName isEqualToString:station.ownerName] &&
    [self.ownerPhone isEqualToString:station.ownerPhone] &&
    (self.bookFee = station.bookFee) &&
    (self.outBookWaitTime = station.outBookWaitTime) &&
    (self.refundState = station.refundState) &&
    (self.allowBookNum = station.allowBookNum);
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCDatabaseStation class]]) {
        DCDatabaseStation *station = object;
        return [self.station_id isEqualToString:station.station_id];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.station_id hash];
}

+ (instancetype)stationWithStationId:(NSString *)stationId {
    if (!stationId) {
        return nil;
    }
    
    DCDatabaseStation * __block station = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_station WHERE station_id = ?" withArgumentsInArray:@[stationId] resultBlock:^(FMResultSet *resultSet) {
        if ([resultSet next]) {
            station = [self stationWithResultSet:resultSet];
        }
    }];
    return station;
}

+ (NSArray *)dbStationsWithStationIds:(NSArray *)stationIds {
    if (!stationIds || stationIds.count <= 0) {
        return nil;
    }
    NSMutableString *queryStr = [NSMutableString stringWithString:@"SELECT * FROM T_station WHERE"];
    for (int i=0; i< [stationIds count]; i++){
        id pileNum = [stationIds objectAtIndex:i];
        if ([pileNum isKindOfClass:[NSString class]]) {
            if (i == 0) {
                [queryStr appendString:@" station_id = ?"];
            }
            else {
                [queryStr appendString:@" OR station_id = ?"];
            }
        }
    }
    
    NSMutableArray __block *stations = [NSMutableArray array];
    DCDatabaseStation * __block station = nil;
    [[DCDatabase db] executeQuery:[queryStr copy] withArgumentsInArray:stationIds resultBlock:^(FMResultSet *resultSet) {
        while ([resultSet next]) {
            station = [self stationWithResultSet:resultSet];
            [stations addObject:station];
        }
    }];
    return [stations copy];
}
+ (void)cleanAllStationsInDataBase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        BOOL isSuccess = [db executeUpdate:@"DELETE FROM T_station"];
        if (isSuccess == NO) {
            DDLogDebug(@"[database] error insert key (%d:%@)", [db lastErrorCode], [db lastErrorMessage]);
        }
    }];
}

+ (void)deleteWithStationId:(NSString *)stationId{
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"DELETE FROM T_station WHERE station_id = ?" withArgumentsInArray:@[stationId]];
    }];
}
- (void)saveToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_pile (station_id, station_stationName, station_stationType, station_stationStatus, address, longitude, latitude, station_directNum, station_alterNum, ownerId, ownerName, ownerPhone, bookFee, outBookWaitTime, refundState, allowBookNum) VALUES (:station_id, :station_stationName, :station_stationType, :station_stationStatus, :address, :longitude, :latitude, :station_directNum, :station_alterNum, :ownerId, :ownerName, :ownerPhone, :bookFee, :outBookWaitTime, :refundState, :allowBookNum)" withParameterDictionary:[self parameterDictionary]];
    }];
}

@end

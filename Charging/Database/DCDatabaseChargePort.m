//
//  DCDatabaseChargePort.m
//  Charging
//
//  Created by kufufu on 16/3/2.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCDatabaseChargePort.h"
#import "DCDatabase.h"
#import "DCDatabaseKey.h"

@implementation DCDatabaseChargePort

+ (instancetype)chargePortWithResultSet:(FMResultSet *)resultSet {
    DCDatabaseChargePort *chargePort = [[self alloc] init];
    [chargePort updateWithResultSet:resultSet];
    return chargePort;
}

- (NSDictionary *)parameterDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys = @[@"cp_index", @"pileId", @"chargePortType", @"orderId", @"runStatus",@"chatgeStartType", @"chargeMode"];
    for (NSString *key in keys) {
        id object = [self valueForKey:key];
        [dict setObject:object?object:[NSNull null] forKey:key];
    }
    return dict;
}

- (void)updateWithResultSet:(FMResultSet *)resultSet {
    self.index = [resultSet stringForColumn:@"cp_index"];
    self.pileId = [resultSet stringForColumn:@"pileId"];
    self.chargePortType = [resultSet intForColumn:@"chargePortType"];
    self.orderId = [resultSet stringForColumn:@"orderId"];
    self.runStatus = [resultSet intForColumn:@"runStatus"];
    self.chargeStartType = [resultSet intForColumn:@"chargeStartType"];
    self.chargeMode = [resultSet intForColumn:@"chargeMode"];
}

+ (instancetype)chargePortWithIndex:(NSString *)index {
    if (!index) {
        return nil;
    }
    DCDatabaseChargePort * __block chargePort = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_chargePort WHERE cp_index = ?" withArgumentsInArray:@[index] resultBlock:^(FMResultSet *resultSet) {
        chargePort = [self chargePortWithResultSet:resultSet];
    }];
    return chargePort;
}


+ (NSArray *)chargePortsWithPileId:(NSString *)pileId {
    NSMutableArray *chargePorts = [NSMutableArray array];
    if (!pileId) {
        return nil;
    }
    DCDatabaseChargePort * __block chargePort = nil;
    [[DCDatabase db] executeQuery:@"SELECT * FROM T_chargePort WHERE pileId = ?" withArgumentsInArray:@[pileId] resultBlock:^(FMResultSet *resultSet) {
        if ([resultSet next]) {
            chargePort = [self chargePortWithResultSet:resultSet];
            [chargePorts addObject:chargePort];
        }
    }];
    return chargePorts;
}

- (void)saveChargePortToDatabase {
    [[DCDatabase db] syncExecute:^(FMDatabase *db, BOOL *rollback) {
        [db executeUpdate:@"INSERT OR REPLACE INTO T_chargePort (cp_index, pileId, orderId, runStatus, chargePortType, chargeStartType, chargeMode) VALUES (:cp_index, :pileId, :orderId, :runStatus, :chargePortType, :chargeStartType, :chargeMode)" withParameterDictionary:[self parameterDictionary]];
    }];
}

- (BOOL)isSameAs:(DCDatabaseChargePort *)chargePort {
    return [self.index isEqualToString:chargePort.index] &&
    [self.pileId isEqualToString:chargePort.pileId] &&
    (self.chargePortType = chargePort.chargePortType) &&
    [self.orderId isEqualToString:chargePort.orderId] &&
    (self.runStatus = chargePort.runStatus) &&
    (self.chargeStartType = chargePort.chargeStartType) &&
    (self.chargeMode = chargePort.chargeMode);
}

@end

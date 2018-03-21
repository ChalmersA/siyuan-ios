//
//  DCPile.m
//  Charging
//
//  Created by kufufu on 16/2/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCPile.h"
#import "DCChargePort.h"

@implementation DCPile

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pileId forKey:@"pileId"];
    [aCoder encodeObject:self.deviceId forKey:@"deviceId"];
    [aCoder encodeObject:self.stationId forKey:@"stationId"];
    [aCoder encodeObject:self.pileName forKey:@"pileName"];
    [aCoder encodeInteger:self.pileType forKey:@"pileType"];
    [aCoder encodeDouble:self.ratePower forKey:@"ratePower"];
    [aCoder encodeDouble:self.ratedVoltage forKey:@"rateVoltage"];
    [aCoder encodeDouble:self.ratedCurrent forKey:@"rateCurrent"];
    [aCoder encodeInteger:self.chargerNum forKey:@"chargerNum"];
    [aCoder encodeObject:self.chargePort forKey:@"chargePort"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _pileId = [aDecoder decodeObjectForKey:@"pileId"];
        _deviceId = [aDecoder decodeObjectForKey:@"deviceId"];
        _stationId = [aDecoder decodeObjectForKey:@"stationId"];
        _pileName = [aDecoder decodeObjectForKey:@"pileName"];
        _pileType = [aDecoder decodeIntegerForKey:@"pileType"];
        _ratePower = [aDecoder decodeDoubleForKey:@"ratePower"];
        _ratedVoltage = [aDecoder decodeDoubleForKey:@"rateVoltage"];
        _ratedCurrent = [aDecoder decodeDoubleForKey:@"ratedCurrent"];
        _chargerNum = [aDecoder decodeIntegerForKey:@"chargerNum"];
        _chargePort = [aDecoder decodeObjectForKey:@"chargePort"];
    }
    return self;
}

- (instancetype)initPileWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"id"]) {
                self.pileId = [dict objectForKey:@"id"];
            }
            if ([dict objectForKey:@"chargePorts"]) {
                self.chargePort = [dict objectForKey:@"chargePorts"];
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"ratedVoltage"] ||
        [key isEqualToString:@"rateVoltage"] ||
        [key isEqualToString:@"rateCurrent"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    else if ([key isEqualToString:@"chargerNum"] ||
             [key isEqualToString:@"runStatus"] ||
             [key isEqualToString:@"devStatus"] ||
             [key isEqualToString:@"manStatus"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    [super setValue:value forKey:key];
}

#pragma mark Database
+ (instancetype)pileFromDatabase:(DCDatabasePile *)dbPile {
    DCPile *pile = [self new];
    pile.pileId = dbPile.pile_id;
    pile.deviceId = dbPile.pile_deviceId;
    pile.stationId = dbPile.pile_stationId;
    pile.pileName = dbPile.pile_pileName;
    pile.pileType = dbPile.pile_pileType;
    pile.ratePower = dbPile.ratePower;
    pile.ratedVoltage = dbPile.rateVoltage;
    pile.ratedCurrent = dbPile.rateCurrent;
    return pile;
}

- (void)savePileToDatabase {
    if (!self.pileId) {
        return;
    }
    DCDatabasePile *dbpile = [DCDatabasePile new];
    dbpile.pile_id = self.pileId;
    dbpile.pile_deviceId = self.deviceId;
    dbpile.pile_stationId = self.stationId;
    dbpile.pile_pileName = self.pileName;
    dbpile.pile_pileType = self.pileType;
    dbpile.ratePower = self.ratePower;
    dbpile.rateVoltage = self.ratedVoltage;
    dbpile.rateCurrent = self.ratedCurrent;
    [dbpile saveToDatabase];
}

@end

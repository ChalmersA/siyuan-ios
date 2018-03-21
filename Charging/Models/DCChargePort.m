//
//  DCChargePort.m
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargePort.h"
#import "DCDatabaseChargePort.h"


@implementation DCChargePort

- (instancetype)initChargePortWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDict:dictionary];
    if (self) {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            if ([dictionary objectForKey:@"type"]) {
                self.chargePortType = [[dictionary objectForKey:@"type"] integerValue];
            }
            if ([dictionary objectForKey:@"chargeType"]) {
                self.chargeStartType = [[dictionary objectForKey:@"chargeType"] integerValue];
            }
            if ([dictionary objectForKey:@"eQuantity"]) {
                self.electricQuantity = [[dictionary objectForKey:@"eQuantity"] doubleValue];
            }
            if ([dictionary objectForKey:@"chargeMode"]) {
                self.chargeMode = [[dictionary objectForKey:@"chargeMode"] integerValue];
            }
            switch (self.chargeMode) {
                case DCChargeModeTypeByFull:
                    self.chargeLimit = nil;
                    break;
                    
                case DCChargeModeTypeByTime: {
                    self.chargeLimit = [NSString stringWithFormat:@"%ld", [[dictionary objectForKey:@"chargeLimit"] integerValue]];
                }
                    break;
                  
                case DCChargeModeTypeByPower: {
                    self.chargeLimit = [NSString stringWithFormat:@"%f", [[dictionary objectForKey:@"chargeLimit"] doubleValue]];
                }
                    break;
                    
                case DCChargeModeTypeByMoney: {
                    self.chargeLimit = [NSString stringWithFormat:@"%f", [[dictionary objectForKey:@"chargeLimit"] doubleValue] * 100];
                }
                    break;
                default:
                    break;
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"voltage"] ||
        [key isEqualToString:@"current"] ||
        [key isEqualToString:@"eQuantity"]) {
        if ([key isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    else if ([key isEqualToString:@"runstatus"] ||
             [key isEqualToString:@"chargeMode"] ||
             [key isEqualToString:@"manStatus"]) {
        if ([key isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    [super setValue:value forKey:key];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.index forKey:@"index"];
    [aCoder encodeObject:self.pileId forKey:@"pileId"];
    [aCoder encodeInteger:self.chargePortType forKey:@"chargePortType"];
    [aCoder encodeDouble:self.voltage forKey:@"voltage"];
    [aCoder encodeDouble:self.current forKey:@"current"];
    [aCoder encodeDouble:self.electricQuantity forKey:@"electricQuantity"];
    [aCoder encodeObject:self.orderId forKey:@"orderId"];
    [aCoder encodeInteger:self.runStatus forKey:@"runStatus"];
    [aCoder encodeInteger:self.manStatus forKey:@"manStatus"];
    [aCoder encodeInteger:self.chargeStartType forKey:@"chargeStartType"];
    [aCoder encodeInteger:self.chargeMode forKey:@"chargeMode"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _index = [aDecoder decodeObjectForKey:@"index"];
        _pileId = [aDecoder decodeObjectForKey:@"pileId"];
        _chargePortType = [aDecoder decodeIntegerForKey:@"chargePortType"];;
        _voltage = [aDecoder decodeDoubleForKey:@"voltage"];
        _current = [aDecoder decodeDoubleForKey:@"current"];
        _electricQuantity = [aDecoder decodeDoubleForKey:@"electricQuantity"];
        _runStatus = [aDecoder decodeIntegerForKey:@"runStatus"];
        _manStatus = [aDecoder decodeIntegerForKey:@"manStatus"];
        _chargeStartType = [aDecoder decodeIntegerForKey:@"chargeStatrtType"];
        _chargeMode = [aDecoder decodeIntegerForKey:@"chargeMode"];
    }
    return self;
}

#pragma mark - Database
- (void)saveChargePortToDatabase {
    if (!self.index) {
        return;
    }
    DCDatabaseChargePort *dbChargePort = [DCDatabaseChargePort new];
    dbChargePort.index = self.index;
    dbChargePort.pileId = self.pileId;
    dbChargePort.chargePortType = self.chargePortType;
    dbChargePort.orderId = self.orderId;
    dbChargePort.runStatus = self.runStatus;
    dbChargePort.chargeStartType = self.chargeStartType;
    dbChargePort.chargeMode = self.chargeMode;
}

- (void)chargePortFromDatabase:(DCDatabaseChargePort *)chargePort {
    self.index = chargePort.index;
    self.pileId = chargePort.pileId;
    self.chargePortType = self.chargePortType;
    self.orderId = chargePort.orderId;
    self.runStatus = chargePort.runStatus;
    self.chargeStartType = chargePort.chargeStartType;
    self.chargeMode = chargePort.chargeMode;
}

@end

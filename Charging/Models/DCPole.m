//
//  HSSYPole.m
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPole.h"
@implementation DCPole

// 电站
- (instancetype)initWithStationDict:(NSDictionary *)dict
{
    self = [super initWithDict:dict];
    if (self) {
        self.operatorType = HSSYOperatorHssy;    //直接给华商三优
        
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([[dict objectForKey:@"isIdle"]isKindOfClass:[NSString class]]){
                self.isIdle = [[dict objectForKey:@"isIdle"] intValue];
            }
            if ([dict objectForKey:@"type"]) {
                self.stationType = [[dict objectForKey:@"type"] intValue];
            }
            if ([dict objectForKey:@"operatorName"]) {
                self.contactName = [dict objectForKey:@"operatorName"];
            }
            if ([dict objectForKey:@"stationName"]){
                self.pileName = [dict objectForKey:@"stationName"];
            }
            if ([dict objectForKey:@"id"]){
                self.pileId = [dict objectForKey:@"id"];
            }
            if ([dict objectForKey:@"imgurl"]){
                self.introImgs = [dict objectForKey:@"imgurl"];
            }
            if ([dict objectForKey:@"operatorPhone"]){
                self.contactPhone = [dict objectForKey:@"operatorPhone"];
            }
            if ([dict objectForKey:@"chargeFee"] && [[dict objectForKey:@"chargeFee"] isKindOfClass:[NSNumber class]]){
                self.price = [DCUVPrice priceWithNumber:[dict objectForKey:@"chargeFee"]];// 充电价格
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"avgLevel"] ||
        [key isEqualToString:@"longitude"] ||
        [key isEqualToString:@"latitude"] ||
        [key isEqualToString:@"power"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    else if ([key isEqualToString:@"price"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = [DCUVPrice priceWithDouble:[value doubleValue]];
        }
        else if([value isKindOfClass:[NSNumber class]]) {
            value = [DCUVPrice priceWithNumber:value];
        }
    }
    else if ([key isEqualToString:@"acount"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    else if ([key isEqualToString:@"pileShares"]) {
        key = @"shareTimeArray";
        if ([value isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dict in value) { //解析时间
                DCTime *time = [[DCTime alloc] initWithDict:dict];
                [array addObject:time];
            }
            value = array;
        }
    }
    else if ([key isEqualToString:@"favor"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    else if ([key isEqualToString:@"userid"]) {
        key = @"userId";
    }
    else if ([key isEqualToString:@"operator"]) {
        key = @"operatorType";
    }
    else if ([key isEqualToString:@"desp"]) {
        key = @"poleDescription";
    }
    else if ([key isEqualToString:@"remark"]) {
        key = @"stationDescription";
    }
    else if ([key isEqualToString:@"isIdle"]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.isIdle = [value integerValue];
            return;
        }
    }
    else if ([key isEqualToString:@"appointManage"]) {
        if ([value isKindOfClass:[NSString class]]) {
            self.appointManage = [value intValue];
        }
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCPole class]]) {
        DCPole *pole = object;
        return [pole.pileId isEqualToString:self.pileId];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.pileId hash];
}

#pragma mark - Public
- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

// 所有电桩图片
- (NSArray *)pileImagesUrl {
    NSMutableArray *picUrlArr = [NSMutableArray array];
    if (self.coverImg.length > 0) {
        [picUrlArr addObject:self.coverImg];
    }
    for (NSString *intro in self.introImgs) {
        if (intro.length > 0) {
            [picUrlArr addObject:intro];
        }
    }
    return [picUrlArr count] > 0 ? [picUrlArr copy]: nil;
}

//- (NSString *)imageUrlOfImage:(NSString*)imageUrlPart {
//    if ([imageUrlPart length]) {
//        return [SERVER_URL stringByAppendingString:[imageUrlPart stringByReplacingOccurrencesOfString:@"//" withString:@"/"]];
//    }
//    return nil;
//}

#pragma mark - Database
+ (NSArray *)userAccessiblePolesFromDatabase:(NSString *)userId {
    NSMutableArray *poles = [NSMutableArray array];
    NSArray *dbPoles = [DCDatabasePole polesOfUserAsOwner:[userId longLongValue]];
    for (DCDatabasePole *dbPole in dbPoles) {
        DCPole *pole = [self poleFromDatabase:dbPole];
        pole.userId = userId;
        [poles addObject:pole];
    }

    dbPoles = [DCDatabasePole polesOfUserAsFamily:[userId longLongValue]];
    for (DCDatabasePole *dbPole in dbPoles) {
        DCPole *pole = [self poleFromDatabase:dbPole];
        if ([poles containsObject:pole]) {
            continue;
        }
        [poles addObject:pole];
    }

    return [poles copy];
}

+ (NSArray *)userOwnedPolesFromDatabase:(NSString *)userId {
    DDLogDebug(@"%s %@", __FUNCTION__, userId);
    NSArray *dbPoles = [DCDatabasePole polesOfUserAsOwner:[userId longLongValue]];
    NSMutableArray *poles = [NSMutableArray array];
    for (DCDatabasePole *pole in dbPoles) {
        [poles addObject:[self poleFromDatabase:pole]];
    }
    return [poles copy];
}

+ (NSArray *)polesWithPoleNOsFromDatabase:(NSArray *)poleNOs {
    DDLogDebug(@"%s %@", __FUNCTION__, poleNOs);
    NSArray *dbPoles = [DCDatabasePole dbPolesWithPoleNOs:poleNOs];
    NSMutableArray *poles = [NSMutableArray array];
    for (DCDatabasePole *pole in dbPoles) {
        [poles addObject:[self poleFromDatabase:pole]];
    }
    return [poles copy];
}

+ (instancetype)poleFromDatabase:(DCDatabasePole *)dbPole {
    DCPole *pole = [self new];
    pole.pileId = dbPole.pole_no;
    pole.pileName = dbPole.nick_name;
    pole.type = dbPole.pole_type;
    pole.location = dbPole.location;
    pole.longitude = dbPole.longitude;
    pole.latitude = dbPole.latitude;
    pole.altitude = dbPole.altitude;
    pole.ratedCurrent = dbPole.rated_cur;
    pole.ratedVoltage = dbPole.rated_volt;
    pole.appointManage = dbPole.appointManageType;
    return pole;
}

- (void)savePoleToDatabase {
    if (!self.pileId) {
        return;
    }
    
    DCDatabasePole *dbPole = [DCDatabasePole new];
    dbPole.pole_no = self.pileId;
    dbPole.nick_name = self.pileName;
    dbPole.pole_type = self.type;
    dbPole.location = self.location;
    dbPole.longitude = self.longitude;
    dbPole.latitude = self.latitude;
    dbPole.altitude = self.altitude;
    dbPole.rated_cur = self.ratedCurrent;
    dbPole.rated_volt = self.ratedVoltage;
    dbPole.appointManageType = self.appointManage;
    [dbPole saveToDatabase];
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.pileId forKey:@"pileId"];
    [aCoder encodeObject:self.pileName forKey:@"pileName"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _pileId = [aDecoder decodeObjectForKey:@"pileId"];
        _pileName = [aDecoder decodeObjectForKey:@"pileName"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _latitude = [aDecoder decodeDoubleForKey:@"latitude"];
    }
    return self;
}

#pragma mark -- Template Station
- (NSString*)stationRealTimeInfo {
    if (!self.gprsNum || [self.gprsNum integerValue] <=0) {
        return nil;
    }
    NSMutableString *realTimeInfo = [NSMutableString string];
    [realTimeInfo appendString:[NSString stringWithFormat:@"总数%@", self.gprsNum]];
    
    [realTimeInfo appendString:@"  "];
    if (self.freeNum && [self.freeNum integerValue] > 0) {
        [realTimeInfo appendString:[NSString stringWithFormat:@"空闲%@", self.freeNum]];
    }
    else {
        [realTimeInfo appendString:@"空闲0"];
    }
    return realTimeInfo;
}


#pragma mark - Utilities
- (BOOL)isPole {
    return (self.operatorType != HSSYOperatorHssy && self.operatorType != HSSYOperatorNation);
}
- (BOOL)isSharing {
    return (self.shareState == HSSYShareStateShared);
}
- (BOOL)isBookable {
    BOOL isThisPoleBookable = NO;
    if (self.isPole && self.isSharing) {
        if (self.gprsType == HSSYGPRSTypeBluetooth) {
            isThisPoleBookable = YES;
        }
        else if (self.gprsType == HSSYGPRSTypeGPRSBluetooth) {
            if (self.runStatus == HSSYDeviceStatusSpare || self.runStatus == HSSYDeviceStatusGPRSOff) {
                isThisPoleBookable = YES;
            }
        }
    }
    return isThisPoleBookable;
}
@end

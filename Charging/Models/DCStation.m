//
//  DCStation.m
//  Charging
//
//  Created by kufufu on 16/2/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCStation.h"
#import "DCChargeFee.h"

@implementation DCStation

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.stationId forKey:@"stationId"];
    [aCoder encodeObject:self.stationName forKey:@"stationName"];
    [aCoder encodeInteger:self.stationType forKey:@"stationType"];
    [aCoder encodeInteger:self.stationStatus forKey:@"stationStatus"];
    [aCoder encodeInteger:self.hasFreePile forKey:@"hasFreePile"];
    [aCoder encodeInteger:self.funcType forKey:@"funcType"];
    [aCoder encodeObject:self.province forKey:@"province"];
    [aCoder encodeObject:self.provinceId forKey:@"provinceId"];
    [aCoder encodeObject:self.city forKey:@"city"];
    [aCoder encodeObject:self.cityId forKey:@"cityId"];
    [aCoder encodeObject:self.district forKey:@"district"];
    [aCoder encodeObject:self.districtId forKey:@"districtId"];
    [aCoder encodeObject:self.addr forKey:@"address"];
    [aCoder encodeDouble:self.longitude forKey:@"longitude"];
    [aCoder encodeDouble:self.latitude forKey:@"latitude"];
    [aCoder encodeInteger:self.commentNum forKey:@"commentNum"];
    [aCoder encodeDouble:self.commentAvgScore forKey:@"commentAvgScore"];
    [aCoder encodeDouble:self.envirAvgScore forKey:@"envirAvgScore"];
    [aCoder encodeDouble:self.devAvgScore forKey:@"devAvgScore"];
    [aCoder encodeDouble:self.cspeedAvgScore forKey:@"cspeedAvgScore"];
    [aCoder encodeInteger:self.directNum forKey:@"directNum"];
    [aCoder encodeInteger:self.alterNum forKey:@"alterNum"];
    [aCoder encodeObject:self.ownerId forKey:@"ownerId"];
    [aCoder encodeObject:self.ownerName forKey:@"ownerName"];
    [aCoder encodeObject:self.ownerPhone forKey:@"ownerPhone"];
    [aCoder encodeInteger:self.stationShareState forKey:@"stationShareState"];
    [aCoder encodeObject:self.openingAt forKey:@"openingAt"];
    [aCoder encodeObject:self.chargeFee forKey:@"chargeFee"];
    [aCoder encodeDouble:self.bookFee forKey:@"bookFee"];
    [aCoder encodeInteger:self.outBookWaitTime forKey:@"outBookWaitTime"];
    [aCoder encodeInteger:self.refundState forKey:@"refundState"];
    [aCoder encodeInteger:self.allowBookNum forKey:@"allowBookNum"];
    [aCoder encodeInteger:self.hadBookNum forKey:@"hadBookNum"];
    [aCoder encodeDouble:self.deposit forKey:@"deposit"];
    [aCoder encodeBool:self.favor forKey:@"favor"];
    [aCoder encodeObject:self.remark forKey:@"remark"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _stationId = [aDecoder decodeObjectForKey:@"stationId"];
        _stationName = [aDecoder decodeObjectForKey:@"stationName"];
        _stationType = [aDecoder decodeIntegerForKey:@"stationType"];
        _stationStatus = [aDecoder decodeIntegerForKey:@"stationStatus"];
        _hasFreePile = [aDecoder decodeIntegerForKey:@"hasFreePile"];
        _funcType = [aDecoder decodeIntegerForKey:@"funcType"];
        _province = [aDecoder decodeObjectForKey:@"province"];
        _provinceId = [aDecoder decodeObjectForKey:@"provinceId"];
        _city = [aDecoder decodeObjectForKey:@"city"];
        _cityId = [aDecoder decodeObjectForKey:@"cityId"];
        _district = [aDecoder decodeObjectForKey:@"district"];
        _districtId = [aDecoder decodeObjectForKey:@"districtId"];
        _addr = [aDecoder decodeObjectForKey:@"address"];
        _longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        _commentNum = [aDecoder decodeIntegerForKey:@"commentNum"];
        _commentAvgScore = [aDecoder decodeDoubleForKey:@"commentAvgScore"];
        _envirAvgScore = [aDecoder decodeDoubleForKey:@"envirAvgScore"];
        _devAvgScore = [aDecoder decodeDoubleForKey:@"devAvgScore"];
        _cspeedAvgScore = [aDecoder decodeDoubleForKey:@"cspeedAvgScore"];
        _directNum = [aDecoder decodeIntegerForKey:@"directNum"];
        _alterNum = [aDecoder decodeIntegerForKey:@"alterNum"];
        _dcGunIdleNum = [aDecoder decodeIntegerForKey:@"dcGunIdleNum"];
        _dcGunBookableNum = [aDecoder decodeIntegerForKey:@"dcGunBookableNum"];
        _acGunIdleNum = [aDecoder decodeIntegerForKey:@"acGunIdleNum"];
        _acGunBookableNum = [aDecoder decodeIntegerForKey:@"acGunBookableNum"];
        _ownerId = [aDecoder decodeObjectForKey:@"ownerId"];
        _ownerName = [aDecoder decodeObjectForKey:@"ownerName"];
        _ownerPhone = [aDecoder decodeObjectForKey:@"ownerPhone"];
        _stationShareState = [aDecoder decodeIntegerForKey:@"stationShareState"];
        _openingAt = [aDecoder decodeObjectForKey:@"openingAt"];
        _chargeFee = [aDecoder decodeObjectForKey:@"chargeFee"];
        _bookFee = [aDecoder decodeDoubleForKey:@"bookFee"];
        _outBookWaitTime = [aDecoder decodeIntegerForKey:@"outBookWaitTime"];
        _refundState = [aDecoder decodeIntegerForKey:@"refundState"];
        _allowBookNum = [aDecoder decodeIntegerForKey:@"allowBookNum"];
        _hadBookNum = [aDecoder decodeIntegerForKey:@"hadBookNum"];
        _deposit = [aDecoder decodeDoubleForKey:@"deposit"];
        _favor = [aDecoder decodeBoolForKey:@"favor"];
        _remark = [aDecoder decodeObjectForKey:@"remark"];
    }
    return self;
}

- (instancetype)initStationWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"id"]){
                self.stationId = [dict objectForKey:@"id"];
            }
            if ([dict objectForKey:@"coverImgUrl"]) {
                self.coverImageUrl = [dict objectForKey:@"coverImgUrl"];
            }
            if ([dict objectForKey:@"detailImgUrl"]) {
                self.detailImageUrl = [dict objectForKey:@"detailImgUrl"];
            }
            if ([dict objectForKey:@"onTimeChargeRet"]) {
                self.refundState = [[dict objectForKey:@"onTimeChargeRet"] integerValue];
            }
            if ([dict objectForKey:@"opening"]) {
                self.stationShareState = [[dict objectForKey:@"opening"] integerValue];
            }
            if ([dict objectForKey:@"openingAt"]) {
                self.openingAt = [self openingAtWithDict:[dict objectForKey:@"openingAt"]];
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"longitude"] ||
        [key isEqualToString:@"latitude"] ||
        [key isEqualToString:@"commentAvgScore"] ||
        [key isEqualToString:@"envirAvgScore"] ||
        [key isEqualToString:@"devAvgScore"] ||
        [key isEqualToString:@"cspeedAvgScore"] ||
        [key isEqualToString:@"bookFee"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    else if ([key isEqualToString:@"directNum"] ||
             [key isEqualToString:@"alterNum"] ||
             [key isEqualToString:@"dcGunIdleNum"] ||
             [key isEqualToString:@"dcGunBookableNum"] ||
             [key isEqualToString:@"acGunIdleNum"] ||
             [key isEqualToString:@"acGunBookableNum"] ||
             [key isEqualToString:@"outBookWaitTime"] ||
             [key isEqualToString:@"allowBookNum"] ||
             [key isEqualToString:@"hadBookNum"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    else if ([key isEqualToString:@"stationType"] ||
             [key isEqualToString:@"stationStatus"] ||
             [key isEqualToString:@"hasFreePile"] ||
             [key isEqualToString:@"funcType"] ||
             [key isEqualToString:@"stationShareState"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    [super setValue:value forKey:key];
}

#pragma mark - Database
+ (instancetype)stationFromDatabase:(DCDatabaseStation *)dbStation {
    DCStation *station = [self new];
    dbStation.station_id = station.stationId;
    dbStation.station_stationName = station.stationName;
    dbStation.station_stationType = station.stationType;
    dbStation.station_stationStatus = station.stationStatus;
    dbStation.address = station.addr;
    dbStation.longitude = station.longitude;
    dbStation.latitude = station.latitude;
    dbStation.station_directNum = station.directNum;
    dbStation.station_alterNum = station.alterNum;
    dbStation.ownerId = station.ownerId;
    dbStation.ownerName = station.ownerName;
    dbStation.ownerPhone = station.ownerPhone;
    dbStation.bookFee = station.bookFee;
    dbStation.outBookWaitTime = station.outBookWaitTime;
    dbStation.refundState = station.refundState;
    dbStation.allowBookNum = station.allowBookNum;
    return station;
}

- (void)saveStationToDatabase {
    if (!self.stationId) {
        return;
    }
    DCDatabaseStation *dbStation = [DCDatabaseStation new];
    dbStation.station_id = self.stationId;
    dbStation.station_stationName = self.stationName;
    dbStation.station_stationType = self.stationType;
    dbStation.station_stationStatus = self.stationStatus;
    dbStation.address = self.addr;
    dbStation.longitude = self.longitude;
    dbStation.latitude = self.latitude;
    dbStation.station_directNum = self.directNum;
    dbStation.station_alterNum = self.alterNum;
    dbStation.ownerId = self.ownerId;
    dbStation.ownerName = self.ownerName;
    dbStation.ownerPhone = self.ownerPhone;
    dbStation.bookFee = self.bookFee;
    dbStation.outBookWaitTime = self.outBookWaitTime;
    dbStation.refundState = self.refundState;
    dbStation.allowBookNum = self.allowBookNum;
}

#pragma mark - Public
- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (DCOpeningTime *)openingAtWithDict:(NSDictionary *)dict {
    DCOpeningTime *openingAt = [[DCOpeningTime alloc] initOpeningAtWithDict:dict];
    return openingAt;
}

- (NSString *)facilityLabelDescription {
    if (self.facilities.length > 0) {
        NSArray *numArray = [self.facilities componentsSeparatedByString:@","];
        NSMutableArray *array = [NSMutableArray array];
        NSString *str = nil;
        for (int i = 0; i < numArray.count; i++) {
            NSInteger number = [numArray[i] integerValue];
            switch (number) {
                case DCFacilityTypeWIFI:
                    str = @"WIFI";
                    break;
                case DCFacilityTypeCarmera:
                    str = @"摄像头";
                    break;
                case DCFacilityTypePaking:
                    str = @"停车场";
                    break;
                case DCFacilityTypeCVS:
                    str = @"便利店";
                    break;
                case DCFacilityTypeMarket:
                    str = @"大型超市";
                    break;
                case DCFacilityTypeRestaurant:
                    str = @"餐厅";
                    break;
                case DCFacilityTypeHotel:
                    str = @"旅馆";
                    break;
                    
                default:
                    break;
            }
            [array addObject:str];
        }
        return [array componentsJoinedByString:@"、"];
    }
    return @"暂无";
}

- (NSString *)chargeFeeDescription {
    NSString *defaultFee = [self.chargeFee objectForKey:@"defaultFee"];
    NSArray *timeQuantum = [self.chargeFee objectForKey:@"timeQuantum"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    for (int i = 0; i < timeQuantum.count; i++) {
        DCTimeQuantum *time = [[DCTimeQuantum alloc] initTimeQuantumWithDict:timeQuantum[i]];
        if (time.startTime && time.endTime) {
            NSString *now = [formatter stringFromDate:[NSDate date]];
            //以同一天来初始化时间
            NSDate *nowTime = [[NSDate alloc] initWithTimeIntervalSince1970:[self intervalForTime:now]];
            NSDate *startTime = [[NSDate alloc] initWithTimeIntervalSince1970:[self intervalForTime:time.startTime]];
            NSDate *endTime = [[NSDate alloc] initWithTimeIntervalSince1970:[self intervalForTime:time.endTime]];
            //比较时间是否在该时间段内
            if ([nowTime compare:startTime] == NSOrderedDescending && [nowTime compare:endTime] == NSOrderedAscending) {
                return time.fee;
            }
        }
    }
    return defaultFee;
}
// 计算出该时间的秒数
- (NSTimeInterval)intervalForTime:(NSString *)time {
    NSArray *numArray = [time componentsSeparatedByString:@":"];
    NSTimeInterval hour = [[numArray firstObject] integerValue] * 60 * 60;
    NSTimeInterval minute = [[numArray lastObject] integerValue] * 60;
    return hour + minute;
}

// 所有电桩图片
- (NSArray *)stationImagesUrl {
    NSMutableArray *picUrlArr = [NSMutableArray array];
    if (self.coverImageUrl.length > 0) {
        [picUrlArr addObject:self.coverImageUrl];
    }
    if ([self.detailImageUrl isKindOfClass:[NSArray class]] && self.detailImageUrl.count > 0) {
        for (NSString *intro in self.detailImageUrl) {
            if (intro.length > 0) {
                [picUrlArr addObject:intro];
            }
        }
    }
    return [picUrlArr count] > 0 ? [picUrlArr copy]: nil;
}

#pragma mark - Utilities
- (BOOL)isSharing {
    return (self.stationShareState == DCStationShareStateShare);
}
- (BOOL)isHasFreePile {
    return self.hasFreePile;
}

- (BOOL)isCollect {
    return self.favor;
}

@end

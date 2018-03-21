//
//  DCArea.m
//  Charging
//
//  Created by  Blade on 4/3/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCArea.h"
#import "DCCitySelection.h"

@implementation DCArea

-(DCArea*) parseWithBMKReverseGeoCodeResult:(BMKReverseGeoCodeResult*) result {
    if (result) {
        NSMutableString* detailAdress =  [NSMutableString string];
        BMKAddressComponent *addressComponent = result.addressDetail;
        [detailAdress appendFormat:@"%@%@%@",(addressComponent.district != nil ? addressComponent.district : @"")
         ,(addressComponent.streetName != nil ? addressComponent.streetName : @"")
         ,(addressComponent.streetNumber != nil ? addressComponent.streetNumber : @"")];
        self.addressDetail = detailAdress;
        self.city = [DCArea findCityByCityName:addressComponent.city];
        self.pt = result.location;
    }
    return self;
}

-(DCArea*) parseWithBMKPoiInfo:(BMKPoiInfo *)info {
    if (info) {
        self.addressDetail = info.address;
        self.city = [DCArea findCityByCityName:info.city];
        self.pt = info.pt;
    }
    return self;
}

+ (City *)findCityByCityName:(NSString *)cityName {
    City *result = nil;
    NSArray *cities = [DCCitySelection defaultSelection].popularCities;
    for (City *city in cities) {
        if ([city.name rangeOfString:cityName].location != NSNotFound) {
            result = city;
            break;
        }
    }
    if (!result) {
        cities = [DCCitySelection defaultSelection].cities;
        for (City *city in cities) {
            if ([city.name rangeOfString:cityName].location != NSNotFound) {
                result = city;
                break;
            }
        }
    }
    DDLogDebug(@"find city by name %@ result cityId:%@", cityName, result.cityId);
    return result;
}

+ (City *)findCityByCityId:(NSString *)cityId {
    if (!cityId) {
        return [[City alloc]initWithCityId:@"0" name:@"未知"];
    }
    City *result = nil;
    NSArray *cities = [DCCitySelection defaultSelection].popularCities;
    for (City *city in cities) {
        if ([city.cityId rangeOfString:cityId].location != NSNotFound) {
            result = city;
            break;
        }
    }
    if (!result) {
        cities = [DCCitySelection defaultSelection].cities;
        for (City *city in cities) {
            if ([city.cityId rangeOfString:cityId].location != NSNotFound) {
                result = city;
                break;
            }
        }
    }
    DDLogDebug(@"find city by id %@ result cityId:%@", cityId, result.name);
    return result;
}

@end

//
//  HSSYPoleMapAnnotation.m
//  Charging
//
//  Created by xpg on 15/1/21.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleMapAnnotation.h"
#import "DCStation.h"

@implementation DCPoleMapAnnotation

- (instancetype)initWithDict:(NSDictionary *)dict isMaxLevel:(BOOL)isMaxLevel{
    self = [super init];
    if (self) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        _isMaxLevel = isMaxLevel;
        _stationsCount = [dict integerForKey:@"num"];
        
        NSArray *stationsArr = [dict arrayForKey:@"stations"];
        
        if (_stationsCount == 1) {
            self.station = [[DCStation alloc] initStationWithDict:[stationsArr firstObject]];
        }
        
        if (_stationsCount > 1 || isMaxLevel) {
            NSMutableArray *arr = [NSMutableArray array];
            for (NSDictionary* aPileDic in stationsArr) {
                if ([aPileDic isKindOfClass:[NSDictionary class]]) {
                    DCStation* station = [[DCStation alloc] initStationWithDict:aPileDic];
                    [arr addObject:station];
                }
            }
            self.stations = [arr copy];
        }
        
        _coordinate = CLLocationCoordinate2DMake([dict doubleForKey:@"avgLat"], [dict doubleForKey:@"avgLng"]);
        
        if([dict objectForKey:@"topRightLat"] && [dict objectForKey:@"topRightLng"] && [dict objectForKey:@"bottomLeftLat"] && [dict objectForKey:@"bottomLeftLng"]) {
            _isClusterCoorKnow = YES;
            _topRightCoordinate = CLLocationCoordinate2DMake([dict doubleForKey:@"topRightLat"], [dict doubleForKey:@"topRightLng"]);
            _bottomLeftCoordinate = CLLocationCoordinate2DMake([dict doubleForKey:@"bottomLeftLat"], [dict doubleForKey:@"bottomLeftLng"]);
        }
    }
    return self;
}

+ (instancetype)annotationWithStation:(DCStation *)station {
    DCPoleMapAnnotation *annotation = [[DCPoleMapAnnotation alloc] init];
    CLLocationCoordinate2D coor;
    coor.latitude = station.latitude;
    coor.longitude = station.longitude;
    annotation.coordinate = coor;
    annotation.station = station;
    annotation.stationsCount = 1;
    return annotation;
}

@end

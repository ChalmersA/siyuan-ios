//
//  DCMapManager.h
//  Charging
//
//  Created by xpg on 14/12/27.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMapKits.h"

@interface DCMapManager : NSObject
+ (instancetype)shareMapManager;
- (void)configureBaiduMap;

- (void)reversePositionUpdated:(BMKReverseGeoCodeResult*) reversePosition;
- (BMKReverseGeoCodeResult*)lastReversePosResult;

#pragma mark - Calculation
+ (BOOL)isCoordinateValid:(CLLocationCoordinate2D)coor;
+ (CLLocationDistance)distanceFromCoor:(CLLocationCoordinate2D)fromCoor toCoor:(CLLocationCoordinate2D)toCoor;

#pragma mark - Navi
+ (void)showNaviActionSheetInView:(UIView *)view withCoordinate:(CLLocationCoordinate2D)coordinate;
+ (BOOL)canOpenBaiduMap;
+ (BOOL)baiduMapNavi:(CLLocationCoordinate2D)coordinate;
+ (BOOL)canOpenAmap;
+ (BOOL)amapNavi:(CLLocationCoordinate2D)coordinate;
+ (BOOL)appleNavi:(CLLocationCoordinate2D)coordinate;

#pragma mark - Location
+ (BOOL)locationServicesAvailable;

#pragma mark - Utilities
+ (NSString *)shortAddressFromBMKReverseGeoCodeResult:(BMKReverseGeoCodeResult *)result;
+ (NSString *)stringFromBMKCoordinateRegion:(BMKCoordinateRegion)region;

/*
 * 计算地图中心点与目标之间的距离
 *
 **/
+ (NSString *)getDistanceStringWithTarget:(CLLocationCoordinate2D)targetCoordinate andMapViewCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate;
@end

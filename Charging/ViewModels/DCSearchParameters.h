//
//  HSSYSearchParameters.h
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "DCPole.h"
#import "DCClockView.h"
#import "DCApp.h"

typedef NS_ENUM(NSInteger, DCSearchSort) {
    DCSearchSortTop,//sort=0：热门，评分人数从多到少  //智能排序
    DCSearchSortDistance,//sort=1：距离，从近到远  //距离优先
    DCSearchSortScore,//sort=2：评分，从高到低  //好评优先
//    DCSearchSortPrice,//sort=3：费用，从低到高  //价格优先
};

typedef NS_ENUM(NSInteger, DCSearchStationType) {
    DCSearchStationTypeAll,
    DCSearchStationTypePublic,
    DCSearchStationTypeSpecial,
};

typedef NS_ENUM(NSInteger, DCSearchChargeType) { //充电方式
    DCSearchChargeType_All, //全部
    DCSearchChargeType_Slow, //慢充
    DCSearchChargeType_Quick, //快充
};

static NSString * const HSSYSearchLocationChangedNotification = @"HSSYSearchLocationChangedNotification";
@interface DCSearchParameters : NSObject <NSCoding, NSCopying>

// placeCode || (coordinate && distance)
@property (copy, nonatomic) NSString *placeCode;//cityId
@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) NSNumber *distance;

@property (assign, nonatomic) DCSearchSort sort;//DCSearchSort

// time
- (NSDate *)startTime;
- (NSDate *)endTime;

@property (strong, nonatomic, readonly) NSDateComponents *startTimeComponent;
@property (strong, nonatomic, readonly) NSDateComponents *endTimeComponent;
@property (strong, nonatomic, readonly) NSDateComponents *dayComponent;
@property (strong, nonatomic, readonly) NSNumber *duration;//Double 充电时长

- (void)setStartClockTime:(ClockTime)startTime startTimeActivated:(BOOL)startTimeActivated endClockTime:(ClockTime)endTime endTimeActivated:(BOOL)endTimeActivated duration:(double)duration;
//- (void)setupTimeComponents;
- (void)setDayComponentWithDate:(NSDate *)date;

// other
@property (nonatomic) DCSearchStationType stationType;
- (NSString *)stationTypeParam;

@property (nonatomic) DCSearchChargeType chargeType;
- (NSString *)chargeTypeParam;

@property (assign, nonatomic) BOOL onlyIdle;//只显示...
- (BOOL)onlyIdleParam;

@property (copy, nonatomic) NSString *keyword;

- (void)setDistanceFromFilterIndex:(NSInteger)index;
- (NSInteger)distanceFilterIndex;

- (void)setSortFromFilterIndex:(NSInteger)index;
- (NSInteger)sortFilterIndex;

- (BOOL)isChangedFrom:(DCSearchParameters *)param;

/*
 * 清除所有搜索条件数据
 */
+ (void)clearData;
@end

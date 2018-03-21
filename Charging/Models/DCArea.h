//
//  DCArea.h
//  Charging
//
//  Created by  Blade on 4/3/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaiduMapKits.h"
#import "City.h"

@interface DCArea : NSObject
/// 具体位置
@property (nonatomic, strong) NSString* addressDetail;
/// 城市名称
@property (nonatomic, strong) City* city;
@property (nonatomic,assign) CLLocationCoordinate2D pt;

-(DCArea*) parseWithBMKReverseGeoCodeResult:(BMKReverseGeoCodeResult*) result;
-(DCArea*) parseWithBMKPoiInfo:(BMKPoiInfo*) info;

+ (City *)findCityByCityName:(NSString *)cityName;
+ (City *)findCityByCityId:(NSString *)cityId;
@end

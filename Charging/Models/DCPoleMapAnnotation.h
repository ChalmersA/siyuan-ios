//
//  HSSYPoleMapAnnotation.h
//  Charging
//
//  Created by xpg on 15/1/21.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "BaiduMapKits.h"
#import "DCPole.h"
#import "DCStation.h"

@interface DCPoleMapAnnotation : BMKPointAnnotation

@property (strong, nonatomic) DCStation *station;//电桩信息, nil为聚合点
@property (strong, nonatomic) NSArray *stations;//聚合点中各个电桩信息, nil为单个电桩
@property (strong, nonatomic) DCStation *selectedStation;//被选中的桩

@property (assign, nonatomic) NSInteger stationsCount;//电桩数量, 大于1为聚合点
//@property (nonatomic, assign) CLLocationCoordinate2D coordinate; //电桩平均坐标
@property (assign, nonatomic) BOOL isClusterCoorKnow; // 是否知道聚合点的最小范围的对角点
@property (nonatomic, assign) CLLocationCoordinate2D topRightCoordinate; //被聚合的点群范围右上角坐标
@property (nonatomic, assign) CLLocationCoordinate2D bottomLeftCoordinate; //被聚合的点群范围左下角坐标
@property (assign, nonatomic) BOOL hasIdle; //是否包含空闲的充电口
@property (assign, nonatomic) BOOL isMaxLevel; //是否放大到地图最大level

@property (assign, nonatomic) BOOL isOrderStation;  //是否从订单跳转到searchVC的地图

- (instancetype)initWithDict:(NSDictionary *)dict isMaxLevel:(BOOL)isMaxLevel;
+ (instancetype)annotationWithStation:(DCStation *)station;
@end

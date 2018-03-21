//
//  DCMapManager.m
//  Charging
//
//  Created by xpg on 14/12/27.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCMapManager.h"
#import <MapKit/MapKit.h>
#import "UIActionSheet+HSSYCategory.h"
#import "UIAlertView+HSSYCategory.h"
#import "DCApp.h"

@interface DCMapManager () <BMKGeneralDelegate> {
    
}
@property (nonatomic, retain) BMKReverseGeoCodeResult* lastReversePositioningResult;
@end

@implementation DCMapManager
static DCMapManager *baiduMapManager;
static BMKMapManager *baiduMap;


+ (instancetype)shareMapManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baiduMapManager = [[self alloc] init];
        baiduMap = [[BMKMapManager alloc] init];
    });
    return baiduMapManager;
}

- (void)configureBaiduMap {
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    
    NSString *key = nil;
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.xpg.siyuan.charging"]) {
        key = @"KIvAw3Y4eskwHYzIY6dNN95w8iMeZrBG";
    }
    
    BOOL ret = [baiduMap start:key generalDelegate:self];
    if (!ret) {
        NSLog(@"map manager start fail");
    }
}

- (void)reversePositionUpdated:(BMKReverseGeoCodeResult*) reversePosition {
    self.lastReversePositioningResult = reversePosition;
}
- (BMKReverseGeoCodeResult*)lastReversePosResult {
    return self.lastReversePositioningResult;
}

#pragma mark - Calculation
+ (BOOL)isCoordinateValid:(CLLocationCoordinate2D)coor {
    if (CLLocationCoordinate2DIsValid(coor)) {
        if (coor.latitude > 0 && coor.longitude > 0) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isCoordinateInBeijing:(CLLocationCoordinate2D)coor {
    if (coor.latitude > 39.699679 && coor.latitude < 40.182064 && coor.longitude > 116.10613 && coor.longitude < 116.827101) {
        return YES;
    }
    return NO;
}

+ (CLLocationDistance)distanceFromCoor:(CLLocationCoordinate2D)fromCoor toCoor:(CLLocationCoordinate2D)toCoor {
    return BMKMetersBetweenMapPoints(BMKMapPointForCoordinate(fromCoor), BMKMapPointForCoordinate(toCoor)); // basic on baidu Map SDK
//    CLLocation *startlocation = [[CLLocation alloc] initWithLatitude:fromCoor.latitude longitude:fromCoor.longitude];
//    CLLocation *endLocation = [[CLLocation alloc] initWithLatitude:toCoor.latitude longitude:toCoor.longitude];
//    return [startlocation distanceFromLocation:endLocation];
}

/// 百度坐标转高德坐标
+ (CLLocationCoordinate2D)GCJ02FromBD09:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude - 0.0065, y = coor.latitude - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * x_pi);
    CLLocationDegrees gg_lon = z * cos(theta);
    CLLocationDegrees gg_lat = z * sin(theta);
    return CLLocationCoordinate2DMake(gg_lat, gg_lon);
}

// 高德坐标转百度坐标
+ (CLLocationCoordinate2D)BD09FromGCJ02:(CLLocationCoordinate2D)coor
{
    CLLocationDegrees x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    CLLocationDegrees x = coor.longitude, y = coor.latitude;
    CLLocationDegrees z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    CLLocationDegrees theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationDegrees bd_lon = z * cos(theta) + 0.0065;
    CLLocationDegrees bd_lat = z * sin(theta) + 0.006;
    return CLLocationCoordinate2DMake(bd_lat, bd_lon);
}

#pragma mark - Navi
+ (void)showNaviActionSheetInView:(UIView *)view withCoordinate:(CLLocationCoordinate2D)coordinate {
    NSString * const baiduMap = @"百度地图";
    NSString * const amap = @"高德地图";
    NSString * const appleMap = @"苹果地图";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"导航" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
    if ([DCMapManager canOpenBaiduMap]) {
        [actionSheet addButtonWithTitle:baiduMap];
    }
    if ([DCMapManager canOpenAmap]) {
        [actionSheet addButtonWithTitle:amap];
    }
    [actionSheet addButtonWithTitle:appleMap];
    [actionSheet setClickedButtonHandler:^(NSString *buttonTitle) {
        BOOL result;
        if ([buttonTitle isEqualToString:baiduMap]) {
            result = [DCMapManager baiduMapNavi:coordinate];
        } else if ([buttonTitle isEqualToString:amap]) {
            result = [DCMapManager amapNavi:coordinate];
        } else if ([buttonTitle isEqualToString:appleMap]) {
            result = [DCMapManager appleNavi:coordinate];
        } else {
            return;
        }
        
        if (!result) {
            [UIAlertView showAlertMessage:@"导航失败" hideAfter:2 completion:nil];
        }
    }];
    [actionSheet showInView:view];
}

+ (BOOL)canOpenBaiduMap {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
}

+ (BOOL)baiduMapNavi:(CLLocationCoordinate2D)coordinate {
    //初始化调启导航时的参数管理类
    BMKNaviPara* para = [[BMKNaviPara alloc] init];
    //指定导航类型
    para.naviType = BMK_NAVI_TYPE_NATIVE;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    //指定终点经纬度
    end.pt = coordinate;
    //指定终点名称
//    end.name = _nativeEndName.text;
    //指定终点
    para.endPoint = end;
    
    //指定返回自定义scheme，具体定义方法请参考常见问题
    para.appScheme = @"siyuancharging://";
    //调启百度地图客户端导航
    [BMKNavigation openBaiduMapNavigation:para];
    return YES;
}

+ (BOOL)canOpenAmap {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
}

+ (BOOL)amapNavi:(CLLocationCoordinate2D)coordinate {
    NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    coordinate = [self GCJ02FromBD09:coordinate];
    NSString *urlString = [NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=siyuancharging&lat=%f&lon=%f&dev=0&style=2", name, coordinate.latitude, coordinate.longitude];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    return [[UIApplication sharedApplication] openURL:url];
}

+ (BOOL)appleNavi:(CLLocationCoordinate2D)coordinate {
    coordinate = [self GCJ02FromBD09:coordinate];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil]];
    return [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
}

#pragma mark - Location
+ (BOOL)locationServicesAvailable {
    if ([CLLocationManager locationServicesEnabled]) {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        if (status > kCLAuthorizationStatusDenied) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Route
//驾车路线规划
- (void)driveSearch:(CLLocationCoordinate2D)coor {
    BMKRouteSearch *_routesearch = [[BMKRouteSearch alloc] init];
    CLLocation *_myLocation;
    if (_myLocation) {
        BMKPlanNode *start = [[BMKPlanNode alloc] init];
        start.pt = _myLocation.coordinate;
        BMKPlanNode* end = [[BMKPlanNode alloc] init];
        end.pt = coor;
        
        BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc] init];
        drivingRouteSearchOption.from = start;
        drivingRouteSearchOption.to = end;
        [_routesearch drivingSearch:drivingRouteSearchOption];
    }
}

#pragma mark - BMKRouteSearchDelegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher
                         result:(BMKDrivingRouteResult *)result
                      errorCode:(BMKSearchErrorCode)error {
    BMKMapView *_mapView;
    if (error == BMK_SEARCH_NO_ERROR) {
        NSArray *overlays = [NSArray arrayWithArray:_mapView.overlays];
        [_mapView removeOverlays:overlays];
        
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        int planPointCounts = 0;//轨迹点总数
        for (int i = 0; i < [plan.steps count]; i++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:i];
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint temppoints[planPointCounts];
        int i = 0;
        for (int j = 0; j < [plan.steps count]; j++) {
            BMKDrivingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
        BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [_mapView addOverlay:polyLine]; // 添加路线overlay
    }
}

#pragma mark - Utilities
+ (NSString *)shortAddressFromBMKReverseGeoCodeResult:(BMKReverseGeoCodeResult *)result {
    NSMutableString *shortAddress = [NSMutableString string];
    BMKAddressComponent *component = result.addressDetail;
    [shortAddress appendString:component.district?component.district:@""];
    [shortAddress appendString:component.streetName?component.streetName:@""];
    [shortAddress appendString:component.streetNumber?component.streetNumber:@""];
    return [shortAddress copy];
}

+ (NSString *)stringFromBMKCoordinateRegion:(BMKCoordinateRegion)region {
    return [NSString stringWithFormat:@"latitude: %f(span %f) longitude: %f(span %f)", region.center.latitude, region.span.latitudeDelta, region.center.longitude, region.span.longitudeDelta];
}


- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"BMK 联网成功");
    }
    else{
        NSLog(@"BMK onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"BMK 授权成功");
    }
    else {
        NSLog(@"BMK onGetPermissionState %d",iError);
    }
}

/*
 * 计算地图中心点与目标之间的距离
 *
 **/
+ (NSString *)getDistanceStringWithTarget:(CLLocationCoordinate2D)targetCoordinate andMapViewCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    if ([DCMapManager isCoordinateValid:targetCoordinate]) {
        CLLocationDistance distance = [DCMapManager distanceFromCoor:centerCoordinate toCoor:targetCoordinate];
//        if (distance < 100) {
//            return [NSString stringWithFormat:@"<100m"];
//        } else
            if (distance < 1000) {
            return [NSString stringWithFormat:@"%.1fm", distance];
        } else {
            return [NSString stringWithFormat:@"%.1fkm", distance / 1000];
        }
    } else {
        return @"距离未知";
    }
}


/*
 * 计算用户与目标之间的距离
 *
 **/
//+ (NSString *)getDistanceStringWithTarget:(CLLocationCoordinate2D)targetCoordinate{
//    if ([DCMapManager isCoordinateValid:targetCoordinate] && [DCApp sharedApp].userLocation) {
//        CLLocationDistance distance = [DCMapManager distanceFromCoor:[DCApp sharedApp].userLocation.coordinate toCoor:targetCoordinate];
//        if (distance < 100) {
//            return [NSString stringWithFormat:@"<100m"];
//        } else if (distance < 1000) {
//            return [NSString stringWithFormat:@"%.1fm", distance];
//        } else {
//            return [NSString stringWithFormat:@"%.1fkm", distance / 1000];
//        }
//    } else {
//        return @"距离未知";
//    }
//}
@end

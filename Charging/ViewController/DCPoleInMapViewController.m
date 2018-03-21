//
//  DCPoleInMapViewController.m
//  Charging
//
//  Created by Ben on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleInMapViewController.h"
#import "BaiduMapKits.h"
#import "DCMapManager.h"

@interface DCPoleInMapViewController () <BMKLocationServiceDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate> {
    BMKGeoCodeSearch *_geocodesearch;
    BMKLocationService *_locService;
}
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *chargerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@end

@implementation DCPoleInMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地图导航" style:UIBarButtonItemStylePlain target:self action:@selector(startNavigation:)];
    
    _locService = [[BMKLocationService alloc] init];
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter = 10;
    self.chargerNameLabel.text = (self.stationName.length > 0) ? self.stationName : @"未命名电桩";
    if (self.address.length == 0) {
        self.locationLabel.text = @"位置未知";
        [self reverseGeoCoordinate:self.coordinate];
    } else {
        self.locationLabel.text = [NSString stringWithFormat:@"位置:%@", self.address];
    }
    self.distanceLabel.text = @"距离未知";
    
    _mapView.delegate = self;
    _mapView.rotateEnabled = NO;
    _mapView.overlookEnabled = NO;
    _mapView.zoomLevel = 14;
    
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = self.coordinate;
    [_mapView addAnnotation:annotation];
    [_mapView setCenterCoordinate:self.coordinate animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _geocodesearch.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    //定位
    _locService.delegate = self;
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _geocodesearch.delegate = nil; // 不用时，置nil
    
    //定位
    _locService.delegate = nil;
    [_locService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)startNavigation:(id)sender {
    if ([DCMapManager isCoordinateValid:self.coordinate]) {
        [DCMapManager showNaviActionSheetInView:self.view withCoordinate:self.coordinate];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        [self hideHUD:hud withText:@"抱歉，该电桩经纬度位置未知"];
    }
}

- (IBAction)tapOnBottomBar:(id)sender {
    [_mapView setCenterCoordinate:self.coordinate animated:YES];
}

#pragma mark - BMKGeoCodeSearch
- (void)reverseGeoCoordinate:(CLLocationCoordinate2D)coor {
    if (!_geocodesearch) {
        _geocodesearch = [[BMKGeoCodeSearch alloc] init];
        _geocodesearch.delegate = self;
    }

    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = coor;
    [_geocodesearch reverseGeoCode:reverseGeoCodeSearchOption];
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        self.locationLabel.text = [NSString stringWithFormat:@"位置:%@", result.address];
    }
}

#pragma mark - BMKLocationService
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_mapView updateLocationData:userLocation];
    
    CLLocationDistance distance = [DCMapManager distanceFromCoor:userLocation.location.coordinate toCoor:self.coordinate];
    self.distanceLabel.text = [NSString stringWithFormat:@"距我:%.1f公里", distance / 1000.0];
}

#pragma mark - BMKMapView
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKAnnotationView *view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        view.image = [UIImage imageNamed:@"map_navigation_pole"];
        return view;
    }
    return nil;
}

@end

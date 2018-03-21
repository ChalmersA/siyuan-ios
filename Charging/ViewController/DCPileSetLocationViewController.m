//
//  DCPileSetLocationViewController.m
//  Charging
//
//  Created by xpg on 15/9/21.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPileSetLocationViewController.h"
#import "DCMapManager.h"
#import "DCFillTheInformationViewController.h"

const CLLocationDistance DefaultSearchDistance = 1000;
const CLLocationDistance CityRegionDistance = 6000;


NSString * const DCFillTheInformationVC = @"DCFillTheInformationViewController";//填写信息

@interface DCPileSetLocationViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate> {
    BMKLocationService* _locService;
}
@property (nonatomic) BOOL mapViewDidFinishLoading;
//@property (assign, nonatomic) BOOL mapRequestNow;
@property (strong, nonatomic) BMKGeoCodeSearch *reverseGeoSearch;
@property (strong, nonatomic) BMKGeoCodeSearch *cityLocationSearch;

@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *addressTopLable;
@property (weak, nonatomic) IBOutlet UIView *tipView;

@property (assign, nonatomic) CLLocationCoordinate2D LocationCoordinate2D;

//为了做一些数据保存，先把加载的VC记录下来，
@property (nonatomic) DCFillTheInformationViewController *infoVC;
@end

@implementation DCPileSetLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置位置";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_push_button"] style:UIBarButtonItemStylePlain target:self action:@selector(fillInformationAvtion:)];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(fillInformationAvtion:)];
    
    //地图
    _mapView.zoomLevel = 15;
    _mapView.rotateEnabled = NO;
    _mapView.overlookEnabled = NO;
    _mapView.isSelectedAnnotationViewFront = YES;
    BMKLocationViewDisplayParam *display = [[BMKLocationViewDisplayParam alloc] init];
    display.isAccuracyCircleShow = YES;
    
      _mapView.showsUserLocation = YES;
    
    [_mapView updateLocationViewWithParam:display];
    _locService = [[BMKLocationService alloc] init];
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter = 10;
    
    CLLocation *location = [DCApp sharedApp].userLocation;//移动到定位点
    if (location) {
        [_mapView setCenterCoordinate:location.coordinate animated:YES];
        
        [self reverseCoordinate:location.coordinate];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //地图视图
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    //显示定位图层
    
    //定位服务
    if (self.mapViewDidFinishLoading) {
        _locService.delegate = self;
        [_locService startUserLocationService];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view.window endEditing:YES];
    
    //地图视图
    [_mapView viewWillDisappear];
    //    _mapView.showsUserLocation = NO;//隐藏定位图层
    
    //停止定位服务
    [_locService stopUserLocationService];
}

#pragma mark - Navigation
- (void)navigateBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)fillInformationAvtion:(id)sender {
        if (self.infoVC) {
        //这是返回我保存的VC
        [self.navigationController pushViewController:self.infoVC animated:YES];
        self.infoVC.address = self.addressTopLable.text;
        self.infoVC.LocationCoordinate = self.LocationCoordinate2D;
    } else {
        //第一次进入是从STORYBOARD加载VC
        [self performSegueWithIdentifier:DCFillTheInformationVC sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:DCFillTheInformationVC]) {
        DCFillTheInformationViewController *vc = segue.destinationViewController;
        vc.address = self.addressTopLable.text;
        vc.LocationCoordinate = self.LocationCoordinate2D;
        self.infoVC = vc;
    }
}

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    DDLogDebug(@"map loading finish");
    self.mapViewDidFinishLoading = YES;
    _locService.delegate = self;
    [_locService startUserLocationService];  //开启定位
    
    if (![DCMapManager locationServicesAvailable]) {
        DDLogDebug(@"Location Services Disable!!!");
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, CityRegionDistance, CityRegionDistance);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {  //读取位置成功
        [[DCMapManager shareMapManager] reversePositionUpdated:result];
        
//        self.addressTopLable.text = [DCMapManager shortAddressFromBMKReverseGeoCodeResult:result];
        
        self.addressTopLable.text = result.address;
        
        self.LocationCoordinate2D =  result.location;
    } else {
        DDLogDebug(@"onGetReverseGeoCodeResult fail");
        self.addressTopLable.text = nil; // @"未知"
    }
    
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        // map search
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(result.location, CityRegionDistance, CityRegionDistance);
        [_mapView setRegion:region animated:YES];
        
    }
}

//反向地理编码检索
- (void)reverseCoordinate:(CLLocationCoordinate2D)coor {
    if (self.reverseGeoSearch) {
        self.reverseGeoSearch.delegate = nil;
    }
    self.reverseGeoSearch = [[BMKGeoCodeSearch alloc] init];
    self.reverseGeoSearch.delegate = self;
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = coor;
    BOOL result = [self.reverseGeoSearch reverseGeoCode:reverseGeocodeSearchOption];
    if (!result) {
        self.addressTopLable.text = nil; // @"未知"
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    id<BMKAnnotation> annotation = view.annotation;

    BMKMapStatus *status = [[BMKMapStatus alloc] init];
    status.fLevel = _mapView.zoomLevel+1;
    [_mapView setMapStatus:status withAnimation:YES];
    // deselect this cluster
    [_mapView deselectAnnotation:annotation animated:NO];
    DDLogDebug(@"didSelectAnnotationView %@(%@) (%f, %f)", annotation.title, [annotation class], annotation.coordinate.latitude, annotation.coordinate.longitude);
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
        DDLogDebug(@"didDeselectAnnotationView");
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate { // 点击位置经纬度
//    DDLogDebug(@"onClickedMapBlank (%f, %f)", coordinate.latitude, coordinate.longitude);
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
//    DDLogDebug(@"onClickedMapPoi %@ (%f, %f)", mapPoi.text, mapPoi.pt.latitude, mapPoi.pt.longitude);
}

//TODO:移动
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    DDLogDebug(@"%s", __FUNCTION__);
    
    self.tipView.hidden = YES;
    
    self.sharedSearchParam.location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    static CLLocationCoordinate2D lastCoor;

    CLLocationDistance distance = [DCMapManager distanceFromCoor:lastCoor toCoor:mapView.centerCoordinate];
    lastCoor = mapView.centerCoordinate;

        if (distance > 1) {
        [self reverseCoordinate:mapView.centerCoordinate];
            DDLogDebug(@"mapView.centerCoordinate (.latitude:%f ,longitude:%f )",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude );
    }
    
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    DDLogDebug(@"didUpdateBMKUserLocation updating:%@ (%f, %f)", userLocation.updating?@"YES":@"NO", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    if ([DCApp sharedApp].userLocation == nil) { // first update location move map
        [DCApp sharedApp].userLocation = userLocation.location;
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, DefaultSearchDistance, DefaultSearchDistance);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
    [DCApp sharedApp].userLocation = userLocation.location;
    
    userLocation.title = nil;
    [_mapView updateLocationData:userLocation];
    [self disalbeUserInteraction:self.mapView withClassName:@"LocationView"];
}

//设置定位小蓝点位置
- (void)disalbeUserInteraction:(UIView *)view withClassName:(NSString*)className{
    if ([NSStringFromClass([view class]) isEqualToString:className]) {
        view.userInteractionEnabled = NO;
    }
    for (UIView* subView in view.subviews) {
        [self disalbeUserInteraction:subView withClassName:className];
    }
}

#pragma mark - Property
- (DCSearchParameters *)sharedSearchParam { //移动检索
    DCSearchParameters *param = [DCApp sharedApp].searchParam;
    if (!param) {
        param = [[DCSearchParameters alloc] init];
        [DCApp sharedApp].searchParam = param;
    }
    return param;
}

//地图：当前位置
- (IBAction)myLocation:(id)sender {
    CLLocation *location = [DCApp sharedApp].userLocation;
    if (location) {
        [_mapView setCenterCoordinate:location.coordinate animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

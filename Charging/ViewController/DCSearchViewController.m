//
//  DCSearchViewController.m
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//
#import "DCSearchViewController.h"
#import "DCMapManager.h"
#import "DCStation.h"
#import "DCOptionItem.h"
#import "DCPoleMapAnnotation.h"
#import "DCSelectCityViewController.h"
#import "DCSearchPoleCell.h"
#import "DCFilterListView.h"
#import "DropListView.h"
#import "DCSearchParameters.h"
#import "DCPoleAnnotationView.h"
#import "DCPoleInfoView.h"
#import "DCSelectDetailAreaViewController.h"
#import "DCPoleGroupAnnotationView.h"
#import "DCListStation.h"
#import "DCStationDetailViewController.h"
#import "DCArea.h"
#import "DCTitleButton.h"
#import "Charging-Swift.h"
#import "DCChargingViewController.h"
#import "DevicesWindow.h"
#import "MapSearchFliterView.h"
#import "DCMapTopData.h"

#ifdef DEBUG
    #ifndef DEBUG_CLUSTER_REGION
        #define DEBUG_CLUSTER_REGION true
    #endif
#endif

static int const LoadDataCount = 10; //每次加载的条目数

const CLLocationDistance HSSYDefaultSearchDistance = 1000;
const CLLocationDistance HSSYCityRegionDistance = 10000;
NSString * const DCSegueIdPoleInfo = @"stationDetail";
NSString * const DCSegueIdPushToAddressSearch = @"PushToAddressSearch";
NSString * const DCSegueIdPushToCitySelect = @"PushToCitySelect";

@interface DCSearchViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, SelectCityDelegate, HSSYSearchPoleCellDelegate, MapSearchFliterViewDelegate, CLLocationManagerDelegate> {
    BMKLocationService* _locService;
//    DevicesWindow *devicesWindow; //聚合点的设备列表
    BOOL isMaxLevel; //弹出paopao，弹窗时防止地图的移动引起再次请求数据
}
@property (weak, nonatomic) MBProgressHUD *loadingHUD;
@property (nonatomic) BOOL mapViewDidFinishLoading;

@property (strong, nonatomic) BMKGeoCodeSearch *reverseGeoSearch;
@property (strong, nonatomic) BMKGeoCodeSearch *cityLocationSearch;

@property (weak, nonatomic) NSURLSessionDataTask *mapRequestTask;//地图数据的请求task
@property (weak, nonatomic) NSTimer *mapRequestTimer;
@property (assign, nonatomic) BOOL mapRequestNow;
@property (assign, nonatomic) BOOL mapPolesDataInvalid;
@property (assign, nonatomic) BOOL listPolesDataInvalid;

@property (copy, nonatomic) NSArray *poleAnnotations;//地图桩数据 [HSSYPoleMapAnnotation]
@property (strong, nonatomic) DCPoleMapAnnotation *selectedStationAnnotation;
@property (strong, nonatomic) DCPoleInfoView *poleInfoView;

@property (weak, nonatomic) NSURLSessionDataTask *listRequestTask;//列表请求
@property (assign, nonatomic) NSInteger listRequestStartIndex;//请求数据的起始位置
@property (copy, nonatomic) NSArray *listStations;//列表桩数据 [DCListStation]

@property (strong, nonatomic) DCArea *currentArea;
@property (assign, nonatomic) CGFloat tableViewLastOffsetY;

@property (nonatomic) DCSearchParameters *sharedSearchParam;//公共搜索参数

//@property (nonatomic) DCSearchPoleCell *prototypeCell;

@property (assign, nonatomic) CLLocationCoordinate2D selectedPiledDetailedCenter;

@property (strong, nonatomic) UIBarButtonItem *cityBarButtonItem;
@property (strong, nonatomic) UIBarButtonItem *styleButton;
@property (strong, nonatomic) UIView *searchTitleView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UILabel *stationCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *spareCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *busyCountLabel;

@property (weak, nonatomic) IBOutlet UIView *mapContainer;
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIButton *myLocationButton;
@property (weak, nonatomic) IBOutlet UIView *mapMaskView; // 地图遮盖视图（显示筛选视图时）

@property (weak, nonatomic) IBOutlet UIView *listContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTableLabel;
@property (weak, nonatomic) IBOutlet UIView *listMaskView; // 列表遮盖视图（显示筛选视图时）

@property (weak, nonatomic) IBOutlet UIView *listTopBar;
@property (weak, nonatomic) IBOutlet ArrowButton *listFilterButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *listTopBarTop;
@property (nonatomic, assign) CGFloat tableViewCellHeight;

@property (strong, nonatomic) CLLocationManager *locationManager;

// temp
@property (retain, nonatomic) NSMutableArray * polygons;
@end

@implementation DCSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //navigation bar
    self.cityBarButtonItem = self.navigationItem.leftBarButtonItem;
    self.searchTitleView = self.navigationItem.titleView;
    self.styleButton = [UIBarButtonItem searchBarItemWithTarget:self action:@selector(changeStyle:)];
    self.navigationItem.rightBarButtonItem = self.styleButton;
    self.navigationItem.titleView.frameHeight = 30.0;
    self.navigationItem.titleView.layer.masksToBounds = YES;
    self.navigationItem.titleView.layer.cornerRadius = 4;
    
    /**
     *  TODO: hide mapIcon
     */
    
    //列表
    [self.tableView registerNib:[UINib nibWithNibName:@"DCSearchPoleCell" bundle:nil] forCellReuseIdentifier:@"DCSearchPoleCell"];
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    
    // refresh header
    typeof(self) __weak weakSelf = self;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestStationListDataWithStartIndex:1];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.header = header;
    
    // refresh footer
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf requestStationListDataWithStartIndex:weakSelf.listRequestStartIndex];
    }];
    [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
    [self.tableView.footer noticeNoMoreData];
    
    self.emptyTableLabel.textColor = [UIColor paletteDCMainColor];
    self.emptyTableLabel.text = nil;//@"无匹配的充电桩";
    self.listTopBar.backgroundColor = [UIColor paletteDCMainColor];
    
    self.mapMaskView.alpha = 0; self.mapMaskView.hidden = YES;
    self.listMaskView.alpha = 0; self.listMaskView.hidden = YES;
    
    //地图
    _mapView.maxZoomLevel = 19;
    _mapView.rotateEnabled = NO;
    _mapView.overlookEnabled = NO;
    _mapView.isSelectedAnnotationViewFront = YES;
    BMKLocationViewDisplayParam *display = [[BMKLocationViewDisplayParam alloc] init];
    display.isAccuracyCircleShow = NO;
    [_mapView updateLocationViewWithParam:display];
    _locService = [[BMKLocationService alloc] init];
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter = 10;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // 首先显示列表
    [self setSearchStyle:DCSearchStyleTable];
    self.loadingHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.polygons = [NSMutableArray array];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFavor:) name:@"ChangeFavor" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidChange:) name:NOTIFICATION_USER_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationUpdate:) name:NOTIFICATION_STATION_UPDATE object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //地图视图
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;//显示定位图层
    
    //定位服务
    if (self.mapViewDidFinishLoading) {
        _locService.delegate = self;
        [_locService startUserLocationService];
    }
    
    // 筛选栏隐藏显示优化
    [self scrollViewDidScroll: self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view.window endEditing:YES];
    
    //定位服务
    [_locService stopUserLocationService];
    _locService.delegate = nil;
    
    //地图视图
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _mapView.showsUserLocation = NO;//隐藏定位图层
    
    // clear BMKGeoCodeSearch
    self.reverseGeoSearch.delegate = nil;
    self.reverseGeoSearch = nil;
    self.cityLocationSearch.delegate = nil;
    self.cityLocationSearch = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Property
- (DCSearchParameters *)sharedSearchParam {
    DCSearchParameters *param = [DCApp sharedApp].searchParam;
    if (!param) {
        param = [[DCSearchParameters alloc] init];
        [DCApp sharedApp].searchParam = param;
    }
    return param;
}

- (void)setSharedSearchParam:(DCSearchParameters *)sharedSearchParam {
    [DCApp sharedApp].searchParam = sharedSearchParam;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DCSegueIdPoleInfo]) {
        DCStationDetailViewController *vc = [segue destinationViewController];
        vc.selectStationInfo = sender;
    } else if ([segue.identifier isEqualToString:DCSegueIdPushToAddressSearch]) {
        DCSelectDetailAreaViewController *vc = segue.destinationViewController;
        vc.defaultCity = sender;
    } else if ([segue.identifier isEqualToString:DCSegueIdPushToCitySelect]) {
        DCSelectCityViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

#pragma mark - Aciton
//右上角按钮切换地图事件
- (void)changeStyle:(id)sender {
    //清除所有搜索条件数据
//    [DCSearchParameters clearData];
    
    if (self.styleButton.selected) { //change to list style
        [self setSearchStyle:DCSearchStyleTable];
    }
    else { //change to map style
        [self setSearchStyle:DCSearchStyleMap];
    }
}

- (void)setSearchStyle:(DCSearchStyle)style {
    self.styleButton.selected = (style == DCSearchStyleMap);//change style
    [self.view.window endEditing:YES];
    
    //change ui
    self.listContainer.hidden = (style != DCSearchStyleTable);
    self.mapContainer.hidden = (style != DCSearchStyleMap);
    
    if (self.poleInfoView || self.selectedStationAnnotation) {
        [self deselectPoleAnnotation:nil];
    } else {
        [self updateFilerAndBarStateForSearchStyle:style];
    }
    
    if (style == DCSearchStyleMap) {
        if (self.mapPolesDataInvalid) {
            self.listPolesDataInvalid = YES;
            self.mapPolesDataInvalid = NO;
            [self requestMapPoles];
        }
    } else {
        if (self.listPolesDataInvalid) {
            self.mapPolesDataInvalid = YES;
            self.listPolesDataInvalid = NO;
            DDLogDebug(@"setSearchStyle list data invalid request");
            [self requestStationListDataWithStartIndex:1];
        }
    }
}

- (DCSearchStyle)currentSearchStyle {
    if (self.styleButton.selected) {
        return DCSearchStyleMap;
    }
    return DCSearchStyleTable;
}

- (IBAction)selectCity:(id)sender {
    [self deselectPoleAnnotation:nil];
    [self performSegueWithIdentifier:DCSegueIdPushToCitySelect sender:nil];
}

//列表：搜索
- (void)searchAction:(UITextField *)sender {
    if (sender.text.length > 0) {
        self.sharedSearchParam.keyword = sender.text;
    } else {
        self.sharedSearchParam.keyword = nil;
    }
    
    if (self.currentSearchStyle == DCSearchStyleTable) {
        [self requestStationListDataWithStartIndex:1];
    } else {
        [self requestMapPoles];
    }
}

//列表：距离
- (IBAction)filterDistanceAction:(ArrowButton *)sender {
    [self dropFilterListView:DCFilterTypeDistance underButton:sender];
}

//列表：排序
- (IBAction)sortAction:(ArrowButton *)sender {
    [self dropFilterListView:DCFilterTypeSort underButton:sender];
}

//列表：其他
- (IBAction)filterOtherAction:(ArrowButton *)sender {
    typeof(self) __weak weakSelf = self;
    MapSearchFliterView *view = [MapSearchFliterView showFilterViewWithBlock:^{
        [weakSelf requestStationListDataWithStartIndex:1];
    }];
    view.delegate = self;
}

//地图：当前位置
- (IBAction)myLocation:(id)sender {
    CLLocation *location = [DCApp sharedApp].userLocation;
    if (location) {
        [_mapView setCenterCoordinate:location.coordinate animated:YES];
        self.mapRequestNow = YES;
    }
}

- (IBAction)clickedFilterButton:(UIButton *)sender {
    typeof(self) __weak weakSelf = self;
    MapSearchFliterView *view = [MapSearchFliterView showFilterViewWithBlock:^{
        [weakSelf requestMapPoles];
    }];
    view.delegate = self;
}

#pragma mark - MapSearchFliterViewDelegate
- (void)clickTheSearchView {
    [self performSegueWithIdentifier:DCSegueIdPushToAddressSearch sender:self.cityLabel.text];
}

//地图：选中电桩后返回
- (void)deselectPoleAnnotation:(id)sender {
    [self.mapView deselectAnnotation:self.selectedStationAnnotation animated:YES];
    [self hidePoleInfoView];
    [self updateFilerAndBarStateForSearchStyle:self.currentSearchStyle];
}

#pragma mark - Request
- (void)requestStationListDataWithStartIndex:(NSInteger)startIndex {//获取数据列表
    [self.listRequestTask cancel];
    
    MBProgressHUD *hud = self.loadingHUD;
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    CLLocation *centerLocation = self.sharedSearchParam.location;
    if (centerLocation == nil) {
        centerLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    }
    [DCApp sharedApp].centerLocation = [[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    NSString *userId = [DCApp sharedApp].user.userId;
    
    NSString *cityId = self.sharedSearchParam.placeCode;
    
    NSString *longitude = [NSString stringWithFormat:@"%f", self.mapView.centerCoordinate.longitude];
    NSString *latutude = [NSString stringWithFormat:@"%f", self.mapView.centerCoordinate.latitude];
    
    NSNumber *distance = self.sharedSearchParam.distance;
    NSNumber *sort = [NSNumber numberWithInteger:(self.sharedSearchParam.sort - 1)];
    if ([sort integerValue] <= 0) {
        sort = @(0);
    }
    NSString *types = [self.sharedSearchParam stationTypeParam];
    
    NSString *chargeType = [self.sharedSearchParam chargeTypeParam];
    
    BOOL isIdle = [self.sharedSearchParam onlyIdleParam];
    
    DDLogDebug(@"[list] search (coor %f, %f) (distance %@) (cityId %@) ...", centerLocation.coordinate.latitude, centerLocation.coordinate.longitude, distance, cityId);
    
    self.listRequestTask = [DCSiteApi requestListStationsWithLongitude:longitude
                                                              latitude:latutude
                                                                userId:userId
                                                                cityId:cityId
                                                              distance:distance
                                                                  sort:sort
                                                                 types:types
                                                           chargeTypes:chargeType
                                                                isIdle:isIdle
                                                           isFreeOrder:false
                                                                search:NULL
                                                                  page:startIndex
                                                              pageSize:LoadDataCount
                                                            completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if ([self.tableView.header isRefreshing]) {
            [self.tableView.header endRefreshing];
        }
        if ([self.tableView.footer isRefreshing]) {
            [self.tableView.footer endRefreshing];
        }
        
        if (![webResponse isSuccess]) {
            if (error.code == NSURLErrorCancelled) {
                [hud hide:YES];
            } else {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            }
            return;
        }
        NSArray *array = [webResponse.result arrayObject];
        NSMutableArray *stations = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            DCListStation *station = [[DCListStation alloc] initWithDict:dict];
            if (station) {
                [stations addObject:station];
            }
        }
        if (startIndex == 1) {//重新加载
            self.listRequestStartIndex = startIndex;
            self.listRequestStartIndex += 1;
            self.listStations = stations;
        } else {//加载更多
            self.listRequestStartIndex += 1;
            
            NSMutableArray *tempPoles = [NSMutableArray arrayWithArray:self.listStations];
            for (DCListStation *station in stations) {
                if (![tempPoles containsObject:station]) { // filter same pole
                    [tempPoles addObject:station];
                }
            }
            self.listStations = [tempPoles copy];
        }
        
        [self.tableView reloadData]; // self.listPoles
        
        if (array.count < LoadDataCount) {
            [self.tableView.footer noticeNoMoreData];
        } else {
            [self.tableView.footer resetNoMoreData];
        }
        self.emptyTableLabel.hidden = self.listStations.count;
        if (startIndex == 1) {
            self.tableView.contentOffset = CGPointZero;
        }
        
        DDLogDebug(@"[list] [response] success: (%d stations)", (int)stations.count);
        [hud hide:YES];

    }];
}

- (void)requestMapPoles {//获取数据列表for map style
    
    //TODO: 暂时先把菊花hide掉
//    [self.loadingHUD hide:YES];
    [DCSiteApi getMapTopData:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            return ;
        }
        DCMapTopData *data = [[DCMapTopData alloc] initMapDataWithDict:webResponse.result];
        self.stationCountLabel.text = [NSString stringWithFormat:@"%ld", data.stationCount];
        self.pileCountLabel.text = [NSString stringWithFormat:@"%ld", data.pileCount];
        self.spareCountLabel.text = [NSString stringWithFormat:@"%ld", data.idleCount];
        self.busyCountLabel.text = [NSString stringWithFormat:@"%ld", data.noIdleCount];
    }];
    
    self.listPolesDataInvalid = YES;
    [self.mapRequestTask cancel];
    
    CLLocationCoordinate2D coor1 = [_mapView convertPoint:CGPointMake(0, CGRectGetMaxY(_mapView.bounds)) toCoordinateFromView:_mapView];//左下角
    CLLocationCoordinate2D coor2 = [_mapView convertPoint:CGPointMake(CGRectGetMaxX(_mapView.bounds), 0) toCoordinateFromView:_mapView];//右上角
    
    NSDate *startTime = [self.sharedSearchParam startTime];
    NSDate *endTime = [self.sharedSearchParam endTime];
    NSNumber *duration = self.sharedSearchParam.duration;
    
    DDLogDebug(@"[map] [request] (coor1 %f, %f) (coor2 %f, %f) (zoom %f) (startTime %@) (endTime %@) (duration %@) ...", coor1.latitude, coor1.longitude, coor2.latitude, coor2.longitude, _mapView.zoomLevel, [[NSDateFormatter authDateTimeFormatter] stringFromDate:startTime], [[NSDateFormatter authDateTimeFormatter] stringFromDate:endTime], duration);
    
    self.mapRequestTask = [DCSiteApi requestMapStationsWithUserId:[DCApp sharedApp].user.userId coordinate:coor1 coordinate2:coor2 zoom:@(_mapView.zoomLevel) maxLevel:@(_mapView.maxZoomLevel) stationType:[self.sharedSearchParam stationTypeParam] chargeTypes:[self.sharedSearchParam chargeTypeParam] isIdle:self.sharedSearchParam.onlyIdle isFreeOrder:false keyWord:self.sharedSearchParam.keyword completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        if (![webResponse isSuccess]) {
            DDLogDebug(@"[map] [response] fail: %@", webResponse?webResponse.message:error);
            return;
        }
        NSArray *array = [webResponse.result arrayObject];
        NSMutableArray *annotations = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            DCPoleMapAnnotation *annotation = [[DCPoleMapAnnotation alloc] initWithDict:dict isMaxLevel:(_mapView.zoomLevel >= _mapView.maxZoomLevel)];
            if (annotation) {
                if (annotation.station) {
                    annotation.selectedStation = annotation.station;
                }
                [annotations addObject:annotation];
            }
        }
        self.poleAnnotations = annotations;
//        [self hidePoleInfoView];
        [self addPoleAnnotationsOnMap:self.poleAnnotations withCenterPole:nil];
        
        DDLogDebug(@"[map] [response] success: (%d pole annotation)", (int)self.poleAnnotations.count);
    }];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    static CGFloat offsetY = 0;
//    if (scrollView.contentOffset.y == 0) {  // 当偏移量为0时显示(当下拉隐藏之后如果选择城市 偏移量会变为0这个时候就需要这一步)
//        [UIView animateWithDuration:0.3 animations:^{
//            self.listTopBarTop.constant = 0;
//            [self.listContainer layoutSubviews];
//        }];
//    }
//    if (self.listStations.count * self.tableViewCellHeight > self.listContainer.frame.size.height) {   // 当tableView存在高度且大于屏幕显示范围 这个时候我们就需要进行上拉隐藏筛选下拉显示的处理
//        if (scrollView.contentOffset.y > 6 && (scrollView.contentOffset.y < self.listStations.count * self.tableViewCellHeight - self.listContainer.frame.size.height + 38)) {   // 当tableView的在一定的滑动范围内滑动的时候（消除范围外产生的抖动）
//            if (scrollView.contentOffset.y > offsetY && self.listTopBarTop.constant == 0) {
//                [UIView animateWithDuration:0.3 animations:^{
//                    self.listTopBarTop.constant = -self.listTopBar.frame.size.height;
//                    [self.listContainer layoutSubviews];
//                }];
//            }
//            else if(scrollView.contentOffset.y < offsetY && self.listTopBarTop.constant == -self.listTopBar.frame.size.height){
//                [UIView animateWithDuration:0.3 animations:^{
//                    self.listTopBarTop.constant = 0;
//                    [self.listContainer layoutSubviews];
//                }];
//            }
//        }
//    }
//    offsetY = scrollView.contentOffset.y;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listStations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCSearchPoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSearchPoleCell" forIndexPath:indexPath];
    DCListStation *listStation = self.listStations[indexPath.row];
    [cell configureForStation:listStation.station withLocation:[DCApp sharedApp].userLocation.coordinate];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    DCListStation *listStation = self.listStations[indexPath.row];
    [self performSegueWithIdentifier:DCSegueIdPoleInfo sender:listStation.station];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.tableViewCellHeight = [DCSearchPoleCell cellHeightWithTableViewWidth:CGRectGetWidth(tableView.bounds)];
    return self.tableViewCellHeight;
}

#pragma mark - BMKMapViewDelegate
- (void)mapViewDidFinishLoading:(BMKMapView *)mapView {
    DDLogDebug(@"map loading finish");
    self.mapViewDidFinishLoading = YES;
    
    if (![DCMapManager locationServicesAvailable]) {
        DDLogDebug(@"Location Services Disable!!!");
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(_mapView.centerCoordinate, HSSYCityRegionDistance, HSSYCityRegionDistance);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
        self.mapRequestNow = YES;
    } else {
        DDLogDebug(@"startUserLocationService");
        if (self.mapViewDidFinishLoading) {
            _locService.delegate = self;
            [_locService startUserLocationService];
        }
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[DCPoleMapAnnotation class]]) {
        DCPoleMapAnnotation *stationAnnotation = annotation;
        static NSString * const AnnotationViewReuseId = @"DCPoleAnnotationView";
        if (stationAnnotation.stationsCount == 1) {
            DCPoleAnnotationView *annotationView = [[DCPoleAnnotationView alloc] initWithAnnotation:stationAnnotation reuseIdentifier:AnnotationViewReuseId];
            annotationView.selected = [stationAnnotation.station isEqual:self.selectedStationAnnotation.station];
            return annotationView;
        }
        else {
            DCPoleGroupAnnotationView *annotationView = [[DCPoleGroupAnnotationView alloc] initWithAnnotation:stationAnnotation reuseIdentifier:AnnotationViewReuseId];
            [annotationView configureGroupAnnotationViewWithBlock:^(id item) {
                if ([item isKindOfClass:[DCStation class]]) {
                    [self showPoleInfoViewForAnnotation:stationAnnotation];
                }
            }];
                // calculate the max height for cluster list
            CGFloat infoViewHeight = HSSYPoleInfoViewHeight;
            CGFloat heightAboutCenteredCluster = (_mapView.frame.size.height - infoViewHeight) / 2;
            CGFloat offset = 0;
            [annotationView adjustViewMaxHeight:heightAboutCenteredCluster - annotationView.frame.size.height / 2 - offset];
            return annotationView;
        }
    }
    return nil;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    id<BMKAnnotation> annotation = view.annotation;
    if ([annotation isKindOfClass:[DCPoleMapAnnotation class]]) {
        DCPoleMapAnnotation *poleAnnotation = annotation;
        if (poleAnnotation.stationsCount == 1 && poleAnnotation.station) {
            [self showPoleInfoViewForAnnotation:poleAnnotation];
            DDLogDebug(@"select pole %@ (%f, %f)", poleAnnotation.station.stationName, poleAnnotation.coordinate.latitude, poleAnnotation.coordinate.longitude);
            return;
            
        } else {
            
            if (poleAnnotation.isMaxLevel && poleAnnotation.stations && [poleAnnotation.stations count]>0) {// if there stations for this cluster, show the list of stastions
                isMaxLevel = poleAnnotation.isMaxLevel;
                [self showPoleInfoViewForAnnotation:poleAnnotation];
                DDLogDebug(@"select group with poles (%d) (%f, %f)", (int)poleAnnotation.stations.count, poleAnnotation.coordinate.latitude, poleAnnotation.coordinate.longitude);
                
            } else {
                
                [self hidePoleInfoView];
                BMKMapStatus *status = [[BMKMapStatus alloc] init];
                status.fLevel = _mapView.zoomLevel + 2;
                status.targetGeoPt = poleAnnotation.coordinate;
                [_mapView setMapStatus:status withAnimation:YES];
                
                // deselect this cluster
                [_mapView deselectAnnotation:annotation animated:NO];
            }
        
            DDLogDebug(@"select group(%d) (%f, %f)", (int)poleAnnotation.stationsCount, poleAnnotation.coordinate.latitude, poleAnnotation.coordinate.longitude);
            return;
        }
    }
    [self hidePoleInfoView];
    DDLogDebug(@"didSelectAnnotationView %@(%@) (%f, %f)", annotation.title, [annotation class], annotation.coordinate.latitude, annotation.coordinate.longitude);
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
//    isShowPaoWindow = NO;
    mapView.scrollEnabled = YES;
//    if (devicesWindow) {
//        [devicesWindow removeFromSuperview];
//        devicesWindow = nil;
//    }
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    DDLogDebug(@"onClickedMapBlank (%f, %f)", coordinate.latitude, coordinate.longitude);
    [self hidePoleInfoView];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    DDLogDebug(@"onClickedMapPoi %@ (%f, %f)", mapPoi.text, mapPoi.pt.latitude, mapPoi.pt.longitude);
    [self hidePoleInfoView];
}

- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    else if ([overlay isKindOfClass:[BMKPolygon class]]){
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth = 5.0;
        
        return polygonView;
    }
    return nil;
}

-(void)autoZoom {
    if (_mapView.zoomLevel<20) {
        
        BMKMapStatus *status = [[BMKMapStatus alloc] init];
        status.fLevel = _mapView.zoomLevel + 0.001f;
        status.targetGeoPt = _mapView.centerCoordinate;
        [_mapView setMapStatus:status withAnimation:NO];
    }
}
//TODO:移动
- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    DDLogDebug(@"%s", __FUNCTION__);
    self.sharedSearchParam.location = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
    [DCApp sharedApp].centerLocation = self.sharedSearchParam.location;
    
    static CLLocationCoordinate2D lastCoor; static BOOL nofirstIn;
    CLLocationDistance distance = [DCMapManager distanceFromCoor:lastCoor toCoor:mapView.centerCoordinate];
    lastCoor = mapView.centerCoordinate;
    if (distance > 1 && nofirstIn == true) {
        [self reverseCoordinate:mapView.centerCoordinate];
    }
    nofirstIn = true;
    
    if (self.poleInfoView || self.selectedStationAnnotation) {
        DDLogDebug(@"showing pole info don't request");
        return;
    }
    
    self.listPolesDataInvalid = YES;
    
    [self.mapRequestTimer invalidate];
    
    if (self.mapRequestNow) {
        [self requestMapPoles];
        self.mapRequestNow = NO;
    } else {
        self.mapRequestTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(requestMapPoles) userInfo:nil repeats:NO];
    }
}

#pragma mark - CCLocationManagerDelegate 
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status > kCLAuthorizationStatusDenied) {
        //定位服务
        if (self.mapViewDidFinishLoading) {
            _locService.delegate = self;
            [_locService startUserLocationService];
        }
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self disalbeUserInteraction:self.mapView withClassName:@"LocationView"];
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    DDLogDebug(@"didUpdateBMKUserLocation updating:%@ (%f, %f)", userLocation.updating?@"YES":@"NO", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);

    if ([DCApp sharedApp].userLocation == nil) { // first update location move map
        [DCApp sharedApp].userLocation = userLocation.location;
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, HSSYDefaultSearchDistance, HSSYDefaultSearchDistance);
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
        self.mapRequestNow = YES;
    }
    [DCApp sharedApp].userLocation = userLocation.location;
    
    userLocation.title = nil;
    [_mapView updateLocationData:userLocation];
    [self disalbeUserInteraction:self.mapView withClassName:@"LocationView"];
}

- (void)disalbeUserInteraction:(UIView *)view withClassName:(NSString*)className{
    if ([NSStringFromClass([view class]) isEqualToString:className]) {
        view.userInteractionEnabled = NO;
    }
    for (UIView* subView in view.subviews) {
        [self disalbeUserInteraction:subView withClassName:className];
    }
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher
                           result:(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        [[DCMapManager shareMapManager] reversePositionUpdated:result];
        
        self.cityLabel.text = result.addressDetail.city;
        
        // 更新搜索条件中的城市
        City *city = [DCArea findCityByCityName:result.addressDetail.city];
        
        if ((city.cityId != self.sharedSearchParam.placeCode) && (self.currentSearchStyle == DCSearchStyleTable)) { // 首次定位出城市后，请求电桩列表
            DDLogDebug(@"placeCode init request list");
            self.sharedSearchParam.placeCode = city.cityId;
            [self requestStationListDataWithStartIndex:1];
        }
        
        self.sharedSearchParam.placeCode = city.cityId;
        
    } else {
        DDLogDebug(@"onGetReverseGeoCodeResult fail");
        if (self.loadingHUD) {
            [self hideHUD:self.loadingHUD withText:@"定位失败"];
            self.loadingHUD = nil;
            //TODO: 在定位不了的时候默认cityId为上海的
            self.sharedSearchParam.placeCode = @"310000";
            [self requestStationListDataWithStartIndex:1];
        }
    }
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        // map search
        BMKCoordinateRegion region = BMKCoordinateRegionMakeWithDistance(result.location, HSSYCityRegionDistance, HSSYCityRegionDistance);
        [_mapView setRegion:region animated:YES];
        self.mapRequestNow = YES;
        
        // list search
        self.sharedSearchParam.location = [[CLLocation alloc] initWithLatitude:result.location.latitude longitude:result.location.longitude];
        [self requestStationListDataWithStartIndex:1];
    }
}

#pragma mark - Extensions
//列表筛选下拉列表
- (void)dropFilterListView:(DCFilterType)type underButton:(ArrowButton *)button {
    UIWindow *window = [DCApp appDelegate].window;
    CGPoint point = [window convertPoint:CGPointMake(0, CGRectGetMaxY(button.frame)) fromView:button.superview];
    
    [self setListMaskViewHidden:NO];
    
    if (type == DCFilterTypeOther) {
        button.selected = !button.selected;
        
        if (button.selected) {
            PoleFilterListView *filterView = [[PoleFilterListView alloc] init];
            DCSearchParameters *param = self.sharedSearchParam;
            filterView.contentView.poleType = param.stationType;
            filterView.contentView.bookableOnly = param.onlyIdle;
            
            typeof(self) __weak weakSelf = self;
            [filterView setWillDismissHandler:^(DCSearchStationType type, BOOL bookableOnly) {
                [weakSelf setListMaskViewHidden:YES];
                if ((param.stationType != type) || (param.onlyIdle != bookableOnly)) {
                    weakSelf.sharedSearchParam.stationType = type;
                    weakSelf.sharedSearchParam.onlyIdle = bookableOnly;
                    
                    weakSelf.mapPolesDataInvalid = YES;
                    [weakSelf requestStationListDataWithStartIndex:1];
                }
                
                button.selected = !button.selected;
            }];
            
            [filterView.contentView setFilterChanged:^(DCSearchStationType type, BOOL bookableOnly) {
                if ((param.stationType != type) || (param.onlyIdle != bookableOnly)) {
                    weakSelf.sharedSearchParam.stationType = type;
                    weakSelf.sharedSearchParam.onlyIdle = bookableOnly;
                    
                    weakSelf.mapPolesDataInvalid = YES;
                    [weakSelf requestStationListDataWithStartIndex:1];
                }
            }];
            
            [filterView showFromTop:point.y];
        }
        
        return;
    }
    
    [self hideMapFilterContentView:nil];
    
    button.selected = YES;
    DCFilterListView *filterListView = [DCFilterListView loadViewWithNib:@"DCFilterListView"];
    filterListView.filterType = type;
    DCSearchParameters *param = [self.sharedSearchParam copy];
    switch (type) {
        case DCFilterTypeDistance: {
            [filterListView setSelectedIndex:[self.sharedSearchParam distanceFilterIndex]];
            [filterListView setDidSelectFilter:^(DCFilterType type, NSIndexPath *index, NSString *text) {
                [param setDistanceFromFilterIndex:index.row];
                button.title = (index.row > 0) ? text : @"距离";
            }];
            break;
        }
            
        case DCFilterTypeSort: {
            [filterListView setSelectedIndex:[self.sharedSearchParam sortFilterIndex]];
            [filterListView setDidSelectFilter:^(DCFilterType type, NSIndexPath *index, NSString *text) {
                [param setSortFromFilterIndex:index.row];
                button.title = (index.row > 0) ? text : @"排序";
            }];
            break;
        }
            
        case DCFilterTypeOther: {
            break;
        }
            
        default:
            break;
    }

    DropListView *dropListView = [[DropListView alloc] initWithListView:filterListView];
    [dropListView setWillDismiss:^(DropListView *view) {
        [self setListMaskViewHidden:YES];
        if ([param isChangedFrom:self.sharedSearchParam]) {
            self.sharedSearchParam = param;
            self.mapPolesDataInvalid = YES;
            [self requestStationListDataWithStartIndex:1];
        }
        button.selected = NO;
    }];
    [dropListView dropListAtPoint:point];
}

-(BMKPolygon*)polygonRectOfPoint:(CLLocationCoordinate2D)point1 andPoint:(CLLocationCoordinate2D)point2 {
    CLLocationCoordinate2D coordsGiven[4] = {0};
    coordsGiven[0].latitude = point1.latitude ;
    coordsGiven[0].longitude = point1.longitude ;
    coordsGiven[1].latitude = point1.latitude ;
    coordsGiven[1].longitude = point2.longitude ;
    coordsGiven[2].latitude =  point2.latitude;
    coordsGiven[2].longitude = point2.longitude ;
    coordsGiven[3].latitude = point2.latitude;
    coordsGiven[3].longitude = point1.longitude ;
    return [BMKPolygon polygonWithCoordinates:coordsGiven count:4];
}
-(BMKPolygon*)polygonRectOfRegion:(BMKCoordinateRegion)region {
    CLLocationCoordinate2D coordsOrigin[4] = {0};
    coordsOrigin[0].latitude = region.center.latitude + region.span.latitudeDelta;
    coordsOrigin[0].longitude = region.center.longitude + region.span.longitudeDelta;
    coordsOrigin[1].latitude = region.center.latitude + region.span.latitudeDelta;
    coordsOrigin[1].longitude = region.center.longitude - region.span.longitudeDelta;
    coordsOrigin[2].latitude = region.center.latitude - region.span.latitudeDelta;
    coordsOrigin[2].longitude = region.center.longitude - region.span.longitudeDelta;
    coordsOrigin[3].latitude =  region.center.latitude - region.span.latitudeDelta;
    coordsOrigin[3].longitude = region.center.longitude + region.span.longitudeDelta;
    return [BMKPolygon polygonWithCoordinates:coordsOrigin count:4];
}

//增加电桩标注点到地图(居中电桩)
- (void)addPoleAnnotationsOnMap:(NSArray *)annotations withCenterPole:(DCStation *)centerPole {
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView removeOverlays:_mapView.overlays];
    
    
#if defined(DEBUG_CLUSTER_REGION) && DEBUG_CLUSTER_REGION
    if (self.polygons && [self.polygons count] > 0) {
        for (BMKPolygon *polygon in self.polygons) {
            [_mapView addOverlay:polygon];
        }
    }
#endif
    
    DCPoleMapAnnotation *centerAnnotation = nil;
    NSMutableArray *mapAnnotations = [NSMutableArray array];
    for (DCPoleMapAnnotation *annotation in annotations) {
        if ([DCMapManager isCoordinateValid:annotation.coordinate]) {
            [mapAnnotations addObject:annotation];
            if (annotation.station && (annotation.station == centerPole)) {
                centerAnnotation = annotation;
            }
        }
    }
    [_mapView addAnnotations:mapAnnotations];
    
    if (centerAnnotation) {//居中
        [_mapView selectAnnotation:centerAnnotation animated:YES];
        [self showPoleInfoViewForAnnotation:centerAnnotation];
    }
}

//反向地理编码检索
- (void)reverseCoordinate:(CLLocationCoordinate2D)coor {
    DDLogDebug(@"reverse geo coordinate (%f, %f)", coor.latitude, coor.longitude);
    if (self.reverseGeoSearch) {
        self.reverseGeoSearch.delegate = nil;
    }
    self.reverseGeoSearch = [[BMKGeoCodeSearch alloc] init];
    self.reverseGeoSearch.delegate = self;
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = coor;
    BOOL result = [self.reverseGeoSearch reverseGeoCode:reverseGeocodeSearchOption];
    if (!result) {
        
    }
}

- (void)showPoleInfoViewForAnnotation:(DCPoleMapAnnotation *)annotation {
    self.selectedStationAnnotation = annotation;
    
    if (!self.poleInfoView) {
        self.selectedStationAnnotation = annotation;
        self.poleInfoView = [DCPoleInfoView loadViewWithNib:@"DCPoleInfoView"];
        [self.poleInfoView showInView:self.tabBarController.view];
        typeof(self) __weak weakSelf = self;
        [self.poleInfoView setSwipeDownBlock:^(DCPoleInfoView *view) {
            typeof(self) strongSelf = weakSelf;
            [strongSelf deselectPoleAnnotation:nil];
        }];
        [self.poleInfoView setSwipeUpBlock:^(DCPoleInfoView *view) {
            typeof(self) strongSelf = weakSelf;
            [strongSelf presentPoleInfoViewController];
        }];
        [self.poleInfoView setTapGestureViewBlock:^(DCPoleInfoView *view) {
            typeof(self) strongSelf = weakSelf;
            [strongSelf presentPoleInfoViewController];
        }];
        [self.poleInfoView setTapGestureBlock:^(DCPoleInfoView *view) {
            typeof(self) strongSelf = weakSelf;
            [strongSelf presentPoleInfoViewController];
        }];
        [self.poleInfoView setNavigationHandler:^(DCPoleInfoView *view) {
            typeof(self) strongSelf = weakSelf;
            [DCMapManager showNaviActionSheetInView:strongSelf.view withCoordinate:annotation.coordinate];
        }];
//        [self updateNavigationItems];
    }
    self.sharedSearchParam.location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    [DCApp sharedApp].centerLocation = self.sharedSearchParam.location;

    if (!annotation.isOrderStation) {
        if (annotation.stations) {
            [self configurePoleInfoViewWithPole:[annotation.stations firstObject]];
        } else {
            [self configurePoleInfoViewWithPole:annotation.station];
        }
        
        if (annotation.selectedStation) {
            [self configurePoleInfoViewWithPole:annotation.selectedStation];
        }
    } else {
        _mapView.delegate = self;
        [_mapView addAnnotation:annotation];
        [self configurePoleInfoViewWithPole:annotation.station];
    }
    [_mapView setCenterCoordinate:annotation.coordinate animated:YES];
    
//    BMKMapPoint centerPoint = BMKMapPointForCoordinate(annotation.coordinate);
//    CGFloat visibleCenterY = [_mapView convertPoint:self.poleInfoView.frame.origin fromView:self.poleInfoView.superview].y / 2;
//    CGFloat mapCenterY = CGRectGetHeight(_mapView.frame) / 2;
//    centerPoint.y -= BMKMapRectGetHeight(_mapView.visibleMapRect) * (visibleCenterY - mapCenterY) / CGRectGetHeight(_mapView.frame);
//    CLLocationCoordinate2D coor = BMKCoordinateForMapPoint(centerPoint);,
//    [_mapView setCenterCoordinate:coor animated:YES];
}

- (void)configurePoleInfoViewWithPole:(DCStation *)station {
    if (self.poleInfoView) {
        [self.poleInfoView configViewForPole:station withUserLocation:[DCApp sharedApp].userLocation];
    }
}

- (void)hidePoleInfoView {
    if (self.selectedStationAnnotation) {
        self.selectedStationAnnotation = nil;
    }
    
    if (self.poleInfoView) {
        [self.poleInfoView hide];
        self.poleInfoView = nil;
        [self refreshMapPolesAfterPoleInfoViewHide];//释放后 是否需要刷新当前
    }
    
    [self updateNavigationItems];
}

- (void)presentChargingViewContriller{
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        return;
    }
    DCSearchViewController *searchVC = [DCApp sharedApp].rootTabBarController.viewControllers[DCTabIndexSearch];
    [searchVC deselectPoleAnnotation:nil];
    [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
}

- (void)presentPoleInfoViewController {
    DCStation *station = self.selectedStationAnnotation.selectedStation;
    [self performSegueWithIdentifier:DCSegueIdPoleInfo sender:station];
}

- (void)updateNavigationItems {
    if (self.poleInfoView) {
//        self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarItemWithTarget:self action:@selector(deselectPoleAnnotation:)];
        self.navigationItem.titleView = self.searchTitleView;
        self.navigationItem.rightBarButtonItem = self.styleButton;
    } else {
//        self.navigationItem.leftBarButtonItem = self.cityBarButtonItem;
        self.navigationItem.titleView = self.searchTitleView;
        self.navigationItem.rightBarButtonItem = self.styleButton;
    }
    [self.hssy_tabBarController updateNavigationBar];
}

- (IBAction)hideMapFilterContentView:(id)sender {
    //TODO: hide list filter
    self.listFilterButton.selected = NO;
}

- (void)updateFilerAndBarStateForSearchStyle:(DCSearchStyle)style {
    self.mapMaskView.alpha = 0;
    self.listMaskView.alpha = 0;
    self.mapMaskView.hidden = YES;
    self.listMaskView.hidden = YES;
    
    [self updateNavigationItems];
    self.listFilterButton.selected = NO;
}

- (void)setListMaskViewHidden:(BOOL)hidden {
    self.listMaskView.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.listMaskView.alpha = hidden ? 0 : 0.8;
    } completion:^(BOOL finished) {
        self.listMaskView.hidden = hidden;
    }];
}

#pragma mark - refreshMapPolesAfterPoleInfoViewHide
- (void)refreshMapPolesAfterPoleInfoViewHide {
    if (!((fabs(_mapView.centerCoordinate.longitude - self.selectedPiledDetailedCenter.longitude) < 0.000001) && (fabs(_mapView.centerCoordinate.latitude - self.selectedPiledDetailedCenter.latitude) < 0.000001))) {
        [self requestMapPoles];
    }
}

#pragma mark - UITextFieldDelegate
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (self.poleInfoView || self.selectedStationAnnotation) {
//        [self deselectPoleAnnotation:nil];
//    } else {
//        [self updateFilerAndBarStateForSearchStyle:self.currentSearchStyle];
//    }
//
//    [self performSegueWithIdentifier:DCSegueIdPushToAddressSearch sender:self.cityLabel.text];
//    return NO;
//}
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self.view.window endEditing:YES];
//    [self searchAction:textField];
//    return YES;
//}

#pragma mark - SelectCityDelegate
- (void)selectedCity:(City *)city {
    self.sharedSearchParam.placeCode = city.cityId;
    self.cityLabel.text = city.name;
    
    if (!self.cityLocationSearch) {
        self.cityLocationSearch = [[BMKGeoCodeSearch alloc] init];
        self.cityLocationSearch.delegate = self;
    }
    BMKGeoCodeSearchOption *searchOption = [[BMKGeoCodeSearchOption alloc] init];
    searchOption.city = city.name;
    searchOption.address = city.name;
    [self.cityLocationSearch geoCode:searchOption];
}

- (void)selectPoiInfo:(BMKPoiInfo *)info {
    if (info) {
        // map search
        [_mapView setCenterCoordinate:info.pt animated:YES];
        self.mapRequestNow = YES;
        
        // list search
        City *city = [DCArea findCityByCityName:info.city];
        self.sharedSearchParam.placeCode = city.cityId;
        self.cityLabel.text = city.name;
        
        self.sharedSearchParam.location = [[CLLocation alloc] initWithLatitude:info.pt.latitude longitude:info.pt.longitude];
        [self requestStationListDataWithStartIndex:1];
    }
}

#pragma mark - HSSYSearchPoleCellDelegate
- (void)searchStationCellOrderAction:(DCStation *)station {
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        return;
    }
    [self performSegueWithIdentifier:DCSegueIdPoleInfo sender:station];
}

- (void)searchStationCellNavigationAction:(DCStation *)station {
    [DCMapManager showNaviActionSheetInView:self.view withCoordinate:station.coordinate];
}

- (void)stationUpdate:(NSNotification *)note
{
    DCStation *station = [note.userInfo objectForKey:@"DCStation"];
    
    if ([station.stationId isEqualToString:self.selectedStationAnnotation.station.stationId]) {
        if (self.poleInfoView) {
            self.selectedStationAnnotation.station.commentAvgScore = station.commentAvgScore; // 这里是为了重新复制选中的站，防止释放后poleview后还记录着以前的
            [self.poleInfoView configViewForPole:station withUserLocation:[DCApp sharedApp].userLocation];
        }
    }
    for (DCListStation *listStation in self.listStations) { //刷新列表中的站数据
        if([listStation.station.stationId isEqualToString:station.stationId]){
            listStation.station.commentAvgScore = station.commentAvgScore;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - 点击聚合点弹窗的桩回调
//- (void)devicesWindow:(DevicesWindow *)DevicesWindow selectedStation:(DCStation *)station{
//    DCPoleMapAnnotation *stationAnnotation = [DCPoleMapAnnotation new];
//    stationAnnotation.coordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude);
//    stationAnnotation.stations = @[station];
//    [self showPoleInfoViewForAnnotation:stationAnnotation];
//}

#pragma mark -
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

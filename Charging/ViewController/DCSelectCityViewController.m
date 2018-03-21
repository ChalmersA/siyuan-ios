//
//  HSSYSelectCityViewController.m
//  Charging
//
//  Created by xpg on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCSelectCityViewController.h"
#import "Charging-Swift.h"
#import "BaiduMapKits.h"

@interface DCSelectCityViewController () <UITableViewDataSource, UITableViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
@property (weak, nonatomic) IBOutlet UITableView *cityTableView;
@property (nonatomic) NSArray *searchResults;
@property (nonatomic) CitySearchController *citySearchController;
@property (copy, nonatomic) NSString *locationText;
@property (nonatomic) BMKLocationService *locService;
@property (nonatomic) BMKGeoCodeSearch *reverseGeoSearch;
@end

@implementation DCSelectCityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // search bar
    self.searchDisplayController.searchBar.placeholder = @"搜索城市";
    self.searchDisplayController.searchBar.tintColor = [UIColor paletteDCMainColor];
    
    // search controller
    self.citySearchController = [[CitySearchController alloc] initWithCityViewController:self];
    self.searchDisplayController.searchBar.delegate = self.citySearchController;
    self.searchDisplayController.searchResultsDataSource = self.citySearchController;
    self.searchDisplayController.searchResultsDelegate = self.citySearchController;
    self.cityTableView.sectionIndexColor = [UIColor paletteDCMainColor];
    
    // data
    self.locService = [[BMKLocationService alloc] init];
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter = 10;
    
    self.citySelection = [DCCitySelection defaultSelection];
    if (!self.citySelection.isCityDictLoaded) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[DCApp appDelegate].window animated:YES];
        [self.citySelection initCitySelectionCompletion:^{
            [hud hide:YES];
            [self.locService startUserLocationService];
            [self.cityTableView reloadData];
        }];
    } else {
        
    }
    self.locationText = @"定位中...";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.locService.delegate = self;
    if (self.citySelection.isCityDictLoaded) {
        [self.locService startUserLocationService];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.locService.delegate = nil;
    [self.locService stopUserLocationService];
    
    self.reverseGeoSearch.delegate = nil;
    self.reverseGeoSearch = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)selectedCity:(City *)city {
    if (city == nil) {
        if (self.citySelection.isCityDictLoaded) {
            [self.locService stopUserLocationService];
            [self.locService startUserLocationService];
        }
        return;
    }
    [self.delegate selectedCity:city];
    [self navigateBack:nil];
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    if (self.reverseGeoSearch) {
        self.reverseGeoSearch.delegate = nil;
    }
    self.reverseGeoSearch = [[BMKGeoCodeSearch alloc] init];
    self.reverseGeoSearch.delegate = self;
    
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    [self.reverseGeoSearch reverseGeoCode:reverseGeocodeSearchOption];
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    self.locationText = @"定位失败";
    [self.cityTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    [self.citySelection.cities enumerateObjectsUsingBlock:^(City *city, NSUInteger idx, BOOL *stop) {
        if ([city.name rangeOfString:result.addressDetail.city].location != NSNotFound) {
            self.citySelection.locationCity = city;
            *stop = YES;
            [self.locService stopUserLocationService];
        }
    }];
    self.locationText = @"定位失败";
    [self.cityTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.citySelection.isCityDictLoaded) { // when city not load
        return 0;
    }
    return self.citySelection.cityDictKeys.count + 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) { // location & popular city
        return 1;
    }
    NSString *key = self.citySelection.cityDictKeys[section - 2];
    NSArray *cityArray = self.citySelection.cityDict[key];
    return cityArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // location city
        PopularCityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopularCityCell" forIndexPath:indexPath];
        [cell configForLocationCity:self.citySelection.locationCity placeholder:self.locationText];
        cell.delegate = self;
        return cell;
    }
    
    if (indexPath.section == 1) { // popular city
        PopularCityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PopularCityCell" forIndexPath:indexPath];
        [cell configForCities:self.citySelection.popularCities];
        cell.delegate = self;
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    NSString *key = self.citySelection.cityDictKeys[indexPath.section - 2];
    NSArray *cityArray = self.citySelection.cityDict[key];
    City *city = cityArray[indexPath.row];
    cell.textLabel.text = city.name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) { // location city
        return @"定位城市";
    } else if (section == 1) { // popular city
       return @"热门城市";
    }
    NSString *key = self.citySelection.cityDictKeys[section - 2];
    return key;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.citySelection.isCityDictLoaded) { // when city not load
        return nil;
    }
    NSArray *titles = [NSArray arrayWithObjects:@"定", @"热", nil];
    return [titles arrayByAddingObjectsFromArray:self.citySelection.cityDictKeys];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) { // location city
        return [PopularCityCell cellHeightWithCityCount:1];
    } else if (indexPath.section == 1) { // popular city
        return [PopularCityCell cellHeightWithCityCount:self.citySelection.popularCities.count];
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section > 1) {
        NSString *key = self.citySelection.cityDictKeys[indexPath.section - 2];
        City *city = self.citySelection.cityDict[key][indexPath.row];
        [self selectedCity:city];
    }
}

@end

//
//  HSSYSelectAreaViewController.m
//  Charging
//
//  Created by  Blade on 4/1/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCSelectDetailAreaViewController.h"
#import "DCLookingSearchButtonView.h"
#import "DCSiteApi.h"
#import "DCListStation.h"
#import "DCStationDetailViewController.h"
#import "DCMapManager.h"
#import "DCEmptyHistoryDataCell.h"
#import "DCSearchPileNameCell.h"
#import "DCSearchAddressCell.h"

#define SEARCH_COUNTDOWN_INTERVAL 1

//根据tag找控件
#define LOOKINGBUTTONVIEW_PLACE_BUTTON 97 //找地点Button
#define LOOKINGBUTTONVIEW_PILE_BUTTON 98  //找名称

typedef NS_ENUM(NSInteger, HSSYAreaSearchDisplayMode) {
    HSSYAreaSearchDisplayModeHistory,
    HSSYAreaSearchDisplayModeResult
};

NSString * const EmptyHistoryDataCell = @"EmptyHistoryDataCell";
NSString * const SearchPileNameCell = @"SearchPileNameCell";
NSString * const SearchAddressCell = @"SearchAddressCell";

@interface DCSelectDetailAreaViewController () <BMKGeoCodeSearchDelegate>

@property (nonatomic, strong) BMKPoiSearch *searcher;
@property (nonatomic, strong) NSArray *searchHistories;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, weak) NSTimer *searchTimer;
@property HSSYAreaSearchDisplayMode displayMode;

@property (nonatomic) CLLocation *location;
@property (nonatomic, copy) NSString *locationAddress;
@property (nonatomic) BMKGeoCodeSearch *geoCoder;
@property (nonatomic, weak) DCLookingSearchButtonView * lookingButtonView;
@property (nonatomic, strong) UIButton *cleanHistoryTadaButton;

@property (nonatomic, strong) NSArray * pileSearchHistories;
@property (nonatomic, strong) NSArray * pileSearchResults;

@property (nonatomic) NSURLSessionDataTask *pileSearchTask;
@end

@implementation DCSelectDetailAreaViewController
#pragma mark LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.searchView.frameHeight = 44.0;
    self.searchLayoutView.layer.cornerRadius = 6;
    self.searchLayoutView.layer.masksToBounds = YES;
    
    [self commonInit];
    [self configureTableView:self.tableView];
    [self configureSearchBar];
    
    self.location = [DCApp sharedApp].userLocation;
    if (self.location) {
        self.geoCoder = [[BMKGeoCodeSearch alloc] init];
        self.geoCoder.delegate = self;
        
        BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
        reverseGeoCodeSearchOption.reverseGeoPoint = self.location.coordinate;
        [self.geoCoder reverseGeoCode:reverseGeoCodeSearchOption];
    }
    
    [self.lookingSearchButton addTarget:self action:@selector(chooseLooking:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)commonInit {
    self.searchHistories = @[];
    self.pileSearchHistories = @[];
    self.displayMode = HSSYAreaSearchDisplayModeHistory;
    self.searcher = [[BMKPoiSearch alloc] init];
    self.searcher.delegate = self;
    if (self.defaultCity == nil) {
        // default is ShangHai
        self.defaultCity = @"上海";
    }
    // Load the history
    self.pileSearchHistories = [self pileLoadSearchHistories];
    self.searchHistories = [self loadSearchHistories];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searcher.delegate = self;
    
    //返回再刷新搜索DATA
    self.pileSearchResults = @[];
    self.displayMode = HSSYAreaSearchDisplayModeHistory;
    self.pileSearchHistories = [self pileLoadSearchHistories];
    [self.tableView reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchTextFieldBar resignFirstResponder];
    self.searcher.delegate = nil;
    [self stopSearchCountDown];
    [self removeLookingButtonView];
    self.searchTextFieldBar.text = nil;
    
}

#pragma mark - History
- (NSString *)historyFilePath {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"searchHistory"];
    return url.path;
}

- (NSArray *)loadSearchHistories {
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:[self historyFilePath]] arrayObject];
}

- (NSArray *)saveSearchHistoriesWithBMKPOI:(BMKPoiInfo *)poiInfo {
    NSMutableArray *historyPOIs = [NSMutableArray arrayWithArray:self.searchHistories];
    NSArray * ary = self.searchHistories;
    for (int i = 0; i < ary.count; i++) {
        BMKPoiInfo * aryPoi = ary[i];
        if ([aryPoi.name isEqualToString:poiInfo.name]) {
            [historyPOIs removeObject:aryPoi];
        }
    }
    [historyPOIs insertObject:poiInfo atIndex:0];
    if (historyPOIs.count > 10) {
        [historyPOIs removeLastObject];
    }
    [NSKeyedArchiver archiveRootObject:historyPOIs toFile:[self historyFilePath]];
    return [historyPOIs copy];
}

#pragma mark pileHistory
- (NSString *)pileHistoryFilePath {
    NSURL *pileUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    pileUrl = [pileUrl URLByAppendingPathComponent:@"pileSearchHistory"];
    return pileUrl.path;
}

- (NSArray *)pileLoadSearchHistories {
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:[self pileHistoryFilePath]] arrayObject];
}

- (NSArray *)pileSearchHistoriesWithPILE:(DCStation *)stationInfo {
    
    NSMutableArray *pileHistoryPOIs = [NSMutableArray arrayWithArray:self.pileSearchHistories];
    
    NSArray * ary = self.pileSearchHistories;
    for (int i = 0; i < ary.count; i++) {
        DCStation * aryStation = ary[i];
        if ([aryStation.stationId isEqualToString:stationInfo.stationId]) {
            [pileHistoryPOIs removeObject:aryStation];
        }
    }
    [pileHistoryPOIs insertObject:stationInfo atIndex:0];
    if (pileHistoryPOIs.count > 10) {
        [pileHistoryPOIs removeLastObject];
    }
    
    //  归档
    [NSKeyedArchiver archiveRootObject:pileHistoryPOIs toFile:[self pileHistoryFilePath]];
    return [pileHistoryPOIs copy];
}

#pragma mark  clearSearchHistories
- (void)clearSearchHistories:(id)sender {
    if (self.lookingSearchButton.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {
        [NSKeyedArchiver archiveRootObject:nil toFile:[self historyFilePath]];
        self.searchHistories = [self loadSearchHistories];
        [self.tableView reloadData];
    } else {
        [NSKeyedArchiver archiveRootObject:nil toFile:[self pileHistoryFilePath]];
        self.pileSearchHistories = [self pileLoadSearchHistories];
        [self.tableView reloadData];
    }
    [self removeLookingButtonView];
}

#pragma mark - lookingPlacesElectricPile
- (void)lookingPlacesElectricPile:(UIButton*)sender{
    if (!(self.lookingSearchButton.tag == sender.tag)) { // 区别所搜索的条件时TextField要清空
        self.searchTextFieldBar.text = nil;
    }
    self.lookingSearchButton.tag = sender.tag;
    if (sender.tag == LOOKINGBUTTONVIEW_PILE_BUTTON) {
        [self.lookingSearchButton setTitle:@"找名称" forState:UIControlStateNormal];
        [self.lookingButtonView removeFromSuperview];
    }
    else if (sender.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {
        [self.lookingSearchButton setTitle:@"找地点" forState:UIControlStateNormal];
        [self.lookingButtonView removeFromSuperview];
    }
    [self.tableView reloadData];

}

#pragma mark - searchTextFieldBar
-(void)configureSearchBar {
    self.lookingSearchButton.tag = LOOKINGBUTTONVIEW_PLACE_BUTTON;
    self.searchTextFieldBar.tintColor = [UIColor blackColor];
    self.searchTextFieldBar.delegate = self;
    [self.searchTextFieldBar becomeFirstResponder];
}

#pragma mark - Helper
- (void)configureTableView:(UITableView *)tableView {
    tableView.separatorInset = UIEdgeInsetsZero;
}

#pragma mark - TableView
- (void)reloadDataWithDisplayMode:(HSSYAreaSearchDisplayMode) mode {
    self.displayMode = mode;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.lookingSearchButton.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {
        if (HSSYAreaSearchDisplayModeHistory == self.displayMode) {
            return [self.searchHistories count] + 1;
        }
        else {
            return [self.searchResults count] + 1;
        }
    } else {
        if (HSSYAreaSearchDisplayModeHistory == self.displayMode) {
            return [self.pileSearchHistories count] + 1;
        }
        else {
            return [self.pileSearchResults count] + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
/*
 NSString * const HSSYEmptyHistoryDataCell = @"HSSYEmptyHistoryDataCell";
 NSString * const HSSYSearchPileNameCell = @"HSSYSearchPileNameCell";
 NSString * const HSSYSearchAddressCell = @"HSSYSearchAddressCell";
 
 */
    if (self.lookingSearchButton.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {//显示地址
        if (indexPath.row == 0) {
            DCEmptyHistoryDataCell * cell = [tableView dequeueReusableCellWithIdentifier:EmptyHistoryDataCell forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if (self.displayMode == HSSYAreaSearchDisplayModeHistory) {
                cell.searchStatusLabel.text = @"搜索历史";
                if (self.searchHistories == nil || self.searchHistories.count == 0) {
                    [cell.emptyHistoryButton setTitle:@"没有任何搜索历史" forState:UIControlStateNormal];
                } else {
                    [cell.emptyHistoryButton setTitle:@"清除历史数据" forState:UIControlStateNormal];
                    [cell.emptyHistoryButton addTarget:self action:@selector(clearSearchHistories:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else if (self.displayMode == HSSYAreaSearchDisplayModeResult) {
                cell.searchStatusLabel.text = @"搜索结果";
                if (self.searchResults == nil || self.searchResults.count == 0) {
                    [cell.emptyHistoryButton setTitle:@"没有找到相关结果" forState:UIControlStateNormal];
                } else {
                    [cell.emptyHistoryButton setTitle:nil forState:UIControlStateNormal];
                }
            }
            return cell;
        } else {
            
            DCSearchAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchAddressCell forIndexPath:indexPath];
            
            BMKPoiInfo* poiInfo = (HSSYAreaSearchDisplayModeHistory == self.displayMode) ? self.searchHistories[indexPath.row - 1] : self.searchResults[indexPath.row - 1];
            cell.addressName.text = poiInfo.name;
            cell.address.text = poiInfo.address;
            if (_location && [DCMapManager isCoordinateValid:poiInfo.pt]) {
                CLLocationDistance distance = [DCMapManager distanceFromCoor:_location.coordinate toCoor:poiInfo.pt];
                cell.distance.text = [NSString stringWithFormat:@"%.1fkm", distance / 1000];
            } else {
                cell.distance.text = nil;
            }
            return cell;
        }
    } else {
        if (indexPath.row == 0) {
            DCEmptyHistoryDataCell * cell = [tableView dequeueReusableCellWithIdentifier:EmptyHistoryDataCell forIndexPath:indexPath];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            if (self.displayMode == HSSYAreaSearchDisplayModeHistory) {
                cell.searchStatusLabel.text = @"搜索历史";
                if (self.pileSearchHistories == nil || self.pileSearchHistories.count == 0) {
                    [cell.emptyHistoryButton setTitle:@"没有任何搜索历史" forState:UIControlStateNormal];
                } else {
                    [cell.emptyHistoryButton setTitle:@"清除历史数据" forState:UIControlStateNormal];
                    [cell.emptyHistoryButton addTarget:self action:@selector(clearSearchHistories:) forControlEvents:UIControlEventTouchUpInside];
                }
            }
            else if (self.displayMode == HSSYAreaSearchDisplayModeResult) {
                cell.searchStatusLabel.text = @"搜索结果";
                if (self.pileSearchResults == nil || self.pileSearchResults.count == 0) {
                    [cell.emptyHistoryButton setTitle:@"没有找到相关结果" forState:UIControlStateNormal];
                } else {
                    [cell.emptyHistoryButton setTitle:nil forState:UIControlStateNormal];
                }
            }
            return cell;
            
        } else {
            DCSearchPileNameCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchPileNameCell forIndexPath:indexPath];
            
            DCStation *station = (HSSYAreaSearchDisplayModeHistory == self.displayMode) ? self.pileSearchHistories[indexPath.row - 1] : self.pileSearchResults[indexPath.row - 1];
            if (_location && [DCMapManager isCoordinateValid:[station coordinate]]) {
                CLLocationDistance distance = [DCMapManager distanceFromCoor:_location.coordinate toCoor:[station coordinate]];//距离
                cell.pileDistance.text = [NSString stringWithFormat:@"%.1fkm", distance / 1000];
            } else {
                cell.pileDistance.text = nil;
            }
            cell.pileAddress.text = station.addr;
            cell.pileName.text = station.stationName;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.lookingSearchButton.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {
        BMKPoiInfo *poiInfo = nil;
        if (indexPath.row == 0) {
            return;
            
        } else {
            poiInfo = (HSSYAreaSearchDisplayModeHistory == self.displayMode) ? self.searchHistories[indexPath.row -1] : self.searchResults[indexPath.row - 1];
            if (HSSYAreaSearchDisplayModeResult == self.displayMode) {
                [self saveSearchHistoriesWithBMKPOI:poiInfo];
            }
        }
        self.choosenPoiInfo = poiInfo;
        [self performSegueWithIdentifier:@"unWindFromSDA" sender:self];
    } else {
        if (indexPath.row == 0) {
            return;
            
        } else {
            DCStation *stationInfo;
            NSArray *pileArray = self.pileSearchHistories;
            if (self.displayMode == HSSYAreaSearchDisplayModeResult) {
                pileArray = self.pileSearchResults;
                stationInfo = pileArray[indexPath.row - 1];
                [self pileSearchHistoriesWithPILE:stationInfo];
            }
            stationInfo = pileArray[indexPath.row - 1];

            DCStationDetailViewController *vc = [DCStationDetailViewController storyboardInstantiate];
            vc.selectStationInfo = stationInfo;
            vc.segueFromMyFavor = NO;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
        [self removeLookingButtonView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self removeLookingButtonView];
}

#pragma mark - BMKGeoCodeSearchDelegate
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    self.locationAddress = result.address;
}

#pragma mark - chooseLooking Action
- (void)chooseLooking:(id)sender{
    [self.searchTextFieldBar resignFirstResponder];
    if (self.lookingButtonView) {
        [self.lookingButtonView removeFromSuperview];
    }else {
        DCLookingSearchButtonView * lookButView = [[[NSBundle mainBundle]loadNibNamed:@"DCLookingSearchButtonView" owner:nil options:nil]firstObject];
        lookButView.frame = CGRectMake(self.lookingSearchButton.center.x, 54, 100, 81);
        [self.navigationController.view addSubview:lookButView];
        self.lookingButtonView = lookButView;
        self.lookingButtonView.backgroundColor = [UIColor clearColor];
        
        [self.lookingButtonView.LookingElectricPileButton addTarget:self action:@selector(lookingPlacesElectricPile:) forControlEvents:UIControlEventTouchUpInside];
        [self.lookingButtonView.lookingPlacesButton addTarget:self action:@selector(lookingPlacesElectricPile:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - UITextFieldDelegate 
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self removeLookingButtonView];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self removeLookingButtonView];
    [textField resignFirstResponder];
    [self fireCountdown];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self removeLookingButtonView];
    
}

- (void)textFieldDidChanged:(NSNotification *)note {//用通知获取当前输入内容
    [self removeLookingButtonView];
    if (self.lookingSearchButton.tag == LOOKINGBUTTONVIEW_PLACE_BUTTON) {
        if (self.searchTextFieldBar.text.length == 0) {
            [self stopSearchCountDown];
            [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeHistory];
        } else {
            [self startSeachCountDownWithText:self.searchTextFieldBar.text];
        }
    }
    else {
        if (self.searchTextFieldBar.text.length == 0) {
            [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeHistory];
        } else {
            [self.pileSearchTask cancel];
            
            self.pileSearchTask = [DCSiteApi requestListStationsWithLongitude:nil latitude:nil userId:nil cityId:nil distance:nil sort:nil types:nil chargeTypes:nil isIdle:nil isFreeOrder:nil search:self.searchTextFieldBar.text page:1 pageSize:10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    //失败
                } else {
                    NSMutableArray *stations = [NSMutableArray array];
                    for (id object in [webResponse.result arrayObject]) {
                        DCListStation *listStation = [[DCListStation alloc] initWithDict:[object dictionaryObject]];
                        if (listStation.station) {
                            [stations addObject:listStation.station];
                        }
                    }
                    self.pileSearchResults = stations;
                    if (self.searchTextFieldBar.text.length == 0) {
                        [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeHistory];
                    } else {
                        [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeResult];
                    }
                }
            }];
            
//            self.pileSearchTask = [DCSiteApi postPileSearch:self.searchTextFieldBar.text page:@(1) pageSize:@(10) completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//                if (![webResponse isSuccess]) {
//                    //失败
//                } else {
//                    NSMutableArray *stations = [NSMutableArray array];
//                    for (id object in [webResponse.result arrayObject]) {
//                        DCListStation *listStation = [[DCListStation alloc] initWithDict:[object dictionaryObject]];
//                        if (listStation.station) {
//                            [stations addObject:listStation.station];
//                        }
//                    }
//                    self.pileSearchResults = stations;
//                    if (self.searchTextFieldBar.text.length == 0) {
//                        [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeHistory];
//                    } else {
//                        [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeResult];
//                    }
//                }
//            }];
        }
    }
}

#pragma mark - BMKPoiSearch delegate
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    NSMutableArray* newResults = [NSMutableArray array];
    if (error == BMK_SEARCH_NO_ERROR) {
        NSMutableString* result = [[NSMutableString alloc] init];
        for (int i=0; i < poiResultList.poiInfoList.count; i++ ) {
            BMKPoiInfo* poiInfo = poiResultList.poiInfoList[i];
            NSString* aResultStr = [NSString stringWithFormat:@"%@ : %@",poiInfo.name, poiInfo.address];
            [result appendString:aResultStr];
            [newResults addObject:poiInfo];
        }
        DDLogDebug(@"返回结果：%@", result);
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        DDLogDebug(@"起始点有歧义");
    } else {
        DDLogDebug(@"抱歉，未找到结果");
    }
    self.searchResults = newResults;
    if (self.searchTextFieldBar.text.length > 0) {
        [self reloadDataWithDisplayMode:HSSYAreaSearchDisplayModeResult];
    }
}

#pragma mark - Search Timer Func
// start the search countdown timer
- (void)startSeachCountDownWithText:(NSString *)searchText {
    [self stopSearchCountDown];
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:SEARCH_COUNTDOWN_INTERVAL target:self selector:@selector(countdownFinished:) userInfo:searchText repeats:NO];
    [self.searchTimer fire]; // search immediately
}
// stop the search countdown timer
- (void)stopSearchCountDown {
    if (self.searchTimer) {
        [self.searchTimer invalidate];
        self.searchTimer = nil;
    }
}
// fire the timer immediatly
- (void)fireCountdown {
    if (self.searchTimer) {
        [self.searchTimer fire];
        self.searchTimer = nil;
    }
}

- (void)countdownFinished:(NSTimer *)timer {
    NSString *keyword = (NSString *)timer.userInfo;
    BMKCitySearchOption *option = [[BMKCitySearchOption alloc] init];
    option.city = self.defaultCity;
    option.keyword = keyword;
    [self.searcher poiSearchInCity:option];
}

#pragma mark - removeLookingButtonView
- (void)removeLookingButtonView {
    if (self.lookingButtonView) {
        [self.lookingButtonView removeFromSuperview];
    }
}
@end

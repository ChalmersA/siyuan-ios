//
//  DCOrderViewController.m
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCOrderViewController.h"
#import "DCPoleInMapViewController.h"
#import "DCOrderDetailViewController.h"
#import "DCSiteApi.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCOrder.h"
#import "NSDateFormatter+HSSYCategory.h"
#import "ButtonBar.h"
#import "DCDatabaseOrder.h"
#import "DCPayView.h"
#import "PopUpView.h"
#import "DCPayWebViewController.h"
#import "DCPileEvaluationViewController.h"
#import "DCMapManager.h"
#import "DCPaySelectionViewController.h"
#import "Charging-Swift.h"
#import "DropListView.h"
#import "DCChargingViewController.h"
#import "CarouselView.h"
#import "DCSearchViewController.h"
#import "DCPoleMapAnnotation.h"

static int const LoadDataCount = 10; //每次加载的条目数

NSString * const DCSegueIdPushToPoleInMap = @"PushToPoleInMapSegue";
NSString * const DCSegueIdPushToOrderDetail = @"PushToOrderDetail";


@interface DCOrderViewController () <UITableViewDataSource, UITableViewDelegate, ButtonBarDelegate, UIScrollViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet ButtonBar *orderStateBar;
@property (weak, nonatomic) IBOutlet UIView *deleteBar;
@property (weak, nonatomic) IBOutlet UIScrollView *swipeView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBarHeightCons;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet UITableView *table0;
@property (weak, nonatomic) IBOutlet UIView *tablePlaceholder0;
@property (weak, nonatomic) IBOutlet UITableView *table1;
@property (weak, nonatomic) IBOutlet UIView *tablePlaceholder1;

@property (nonatomic) NSArray *tableViews;
@property (nonatomic) NSArray *placeholderViews;

@property (weak, nonatomic) DropListView *timeFilterList;
@property (nonatomic) OrderFilterState filterState;

@property (nonatomic) UIBarButtonItem *timeBarButton;
@property (nonatomic) UIBarButtonItem *deleteBarButton;

@property (strong, nonatomic) NSMutableArray *bookOrders;
@property (strong, nonatomic) NSMutableArray *chargeOrders;
@property (strong, nonatomic) NSMutableArray *bookDeleteOrders;
@property (strong, nonatomic) NSMutableArray *chargeDeleteOrders;

@property (nonatomic) NSArray *ordersArray;

@property (nonatomic) NSInteger chargeStartIndex;
@property (nonatomic) NSInteger bookStartIndex;

@property (nonatomic) DCReserveOrderTab currentTab; //目前的页面

@property (nonatomic) NSURLSessionDataTask *fetchOrderTask;

@property (nonatomic) BOOL editingMode;
@property (nonatomic) NSArray *selectedIndexPaths;

@property(strong, nonatomic) DCStation *orderStation;
@end

@implementation DCOrderViewController
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.initialTab = DCReserveOrderTabUnknow;
        self.currentTab = DCReserveOrderTabCharge;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.currentTab = DCReserveOrderTabCharge;
    
    _bookOrders = [NSMutableArray array];
    _chargeOrders = [NSMutableArray array];
    _bookDeleteOrders = [NSMutableArray array];
    _chargeDeleteOrders = [NSMutableArray array];
    
    self.ordersArray = @[self.bookOrders, self.chargeOrders];
    
    typeof(self) __weak weakSelf = self;
    self.placeholderViews = @[self.tablePlaceholder0, self.tablePlaceholder1];
    self.tableViews = @[self.table0, self.table1];
    for (NSInteger tab = 0; tab < self.tableViews.count; tab++) {
        UITableView *tableView = self.tableViews[tab];
        [tableView registerNib:[UINib nibWithNibName:@"DCChargeEditableCell" bundle:nil] forCellReuseIdentifier:DCCellIdReserveOrderNormal];
        [tableView registerNib:[UINib nibWithNibName:@"DCChargeNormalCell" bundle:nil] forCellReuseIdentifier:@"DCChargeNormalCell"];
        [tableView registerNib:[UINib nibWithNibName:@"DCBookEditableCell" bundle:nil] forCellReuseIdentifier:@"DCBookEditableCell"];
        [tableView registerNib:[UINib nibWithNibName:@"DCBookNormalCell" bundle:nil] forCellReuseIdentifier:@"DCBookNormalCell"];
        
        // refresh header
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf requestDataForTab:tab withStartIndex:1];
        }];
        header.lastUpdatedTimeLabel.hidden = YES;
        tableView.header = header;
        
        // refresh footer
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf requestDataForTab:tab withStartIndex:[weakSelf startIndexForTab:tab]];
        }];
        [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
        tableView.footer = footer;
        tableView.footer.hidden = YES;
        
        tableView.scrollsToTop = (tab == self.currentTab);
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
        
        tableView.rowHeight = UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 100;
    }
    
    self.orderStateBar.delegate = self;
    self.swipeView.delegate = self;
    self.swipeView.scrollsToTop = NO;
    
    // Bar Button
    self.deleteBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(selectOrdersForDelete:)];
    self.timeBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bar_button_time"] style:UIBarButtonItemStylePlain target:self action:@selector(timeFilterAction:)];
    self.navigationItem.rightBarButtonItems = @[self.timeBarButton]; 
    
    self.deleteBar.backgroundColor = [UIColor paletteDCMainColor];
    self.deleteButton.backgroundColor = [UIColor paletteButtonRedColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [self requestDataForTab:self.currentTab withStartIndex:1];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setEditingMode:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([self.swipeView contentSize].height != 0 && self.initialTab != DCReserveOrderTabUnknow) { //Wait Untill the swipeView is expanded then check the initial tab
        DCReserveOrderTab expectedTab = self.initialTab;
        [self.orderStateBar selectButtonIndex:expectedTab animated:NO];
        UITableView *table = self.tableViews[expectedTab];
        [self.swipeView scrollRectToVisible:table.frame animated:NO];
        [self swipeToTable:expectedTab];
        self.initialTab = DCReserveOrderTabUnknow;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request
- (void)requestDataForTab:(DCReserveOrderTab)tab withStartIndex:(NSInteger)startIndex {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.fetchOrderTask cancel];
    
    NSString *actionParam = [self actionParamForTab:tab];
    NSString *startOffset = [DCOrder orderFilterStartOffset:self.filterState];
    NSString *endOffset = [DCOrder orderFilterEndOffset:self.filterState];
    
    self.fetchOrderTask = [DCSiteApi getOrderList:[DCApp sharedApp].user.userId status:actionParam startTime:startOffset endTime:endOffset page:startIndex pageSize:LoadDataCount completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        DCReserveOrderTab tableViewTab;
        if (tab == DCReserveOrderTabBook || tab == DCReserveOrderTabBookDelete) {
            tableViewTab = DCReserveOrderTabBook;
        } else {
            tableViewTab = DCReserveOrderTabCharge;
        }
        
        UITableView *tableView = self.tableViews[tableViewTab];
        if ([tableView.header isRefreshing]) {
            [tableView.header endRefreshing];
        }
        if ([tableView.footer isRefreshing]) {
            [tableView.footer endRefreshing];
        }
        
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }

        NSMutableArray *orders = [NSMutableArray array];
        NSArray *responseOrders = webResponse.result;
        for (NSDictionary *dict in responseOrders) {
            if (dict) {
                DCOrder *order = [[DCOrder alloc] initOrderWithDict:dict];
                DCDatabaseOrder *dbOrder = [order databaseObject];
                [dbOrder saveToDatabase];
                [orders addObject:order];
            }
        }

        [self refreshOrders:orders clear:(startIndex == 1) forTab:tab];
        [self nextPageForTab:tab withStartIndex:startIndex];
        
        [self setNavigationBarButtonWith:tab];
        
        if (responseOrders.count < LoadDataCount) {
            [tableView.footer noticeNoMoreData];
        } else {
            [tableView.footer resetNoMoreData];
        }
        
        if (startIndex == 0) {
            tableView.contentOffset = CGPointZero;
        }
        
        [hud hide:YES];
        
        [self.delegate myOrderRefresh:nil]; // 取消message icon红圈
    }];
    
    /**
     * TEST CODE
     */
//    DCOrder *order = [[DCOrder alloc] init];
//    order.orderState = DCOrderStateExceptionWithNotChargeRecord;
//    [orders addObject:order];
//    [self refreshOrders:orders clear:(startIndex == 1) forTab:tab];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DCSegueIdPushToPoleInMap]) {
        DCPoleInMapViewController *vc = segue.destinationViewController;
        DCOrder *order = sender;
        vc.coordinate = order.stationCoordinate;
        vc.address = order.stationLocation;
        vc.stationName = order.stationName;
    }
    else if ([segue.identifier isEqualToString:DCSegueIdPushToOrderDetail]) {
        DCOrderDetailViewController *vc = segue.destinationViewController;
        vc.orderId = sender;
    }
}

#pragma mark - Aciton
- (void)navigateBack:(id)sender {
    [self.fetchOrderTask cancel];
    [super navigateBack:sender];
}

- (IBAction)orderNow:(id)sender {
    [self jumpToSearchPole];
}

- (void)selectOrdersForDelete:(id)sender {
    if (self.editingMode) {
        [self setEditingMode:NO];
        [self requestDataForTab:self.currentTab withStartIndex:1];
        
    } else {
        self.editingMode = YES;
        DCReserveOrderTab tab;
        if (self.currentTab == DCReserveOrderTabBook) {
            tab = DCReserveOrderTabBookDelete;
        } else {
            tab = DCReserveOrderTabChargeDelete;
        }
        
        [self requestDataForTab:tab withStartIndex:1];        
    }
}

- (IBAction)cancelDelete:(id)sender {
    self.editingMode = NO;
}

- (IBAction)deleteAction:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否删除已选择的订单？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            MBProgressHUD *hud = [self showHUDIndicator];
            UITableView *tableView = self.tableViews[self.currentTab];
            DCReserveOrderTab tab;
            if (self.currentTab == DCReserveOrderTabBook) {
                tab = DCReserveOrderTabBookDelete;
            } else {
                tab = DCReserveOrderTabChargeDelete;
            }
            NSMutableArray *orders = [self arrayByTab:tab];
            NSMutableIndexSet *deleteIndexSet = [NSMutableIndexSet indexSet];
            NSMutableArray *orderIds = [NSMutableArray array];
            for (NSIndexPath *indexPath in self.selectedIndexPaths) {
                [deleteIndexSet addIndex:indexPath.row];
                
                DCOrder *order = orders[indexPath.row];
                if (order.orderId) {
                    [orderIds addObject:order.orderId];
                }
            }
            
            [DCSiteApi postOrderIdsToDeleteOrder:[DCApp sharedApp].user.userId orderIds:orderIds completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                    return;
                }
                
                [orders removeObjectsAtIndexes:deleteIndexSet];
                [self.bookDeleteOrders removeAllObjects];
                self.bookDeleteOrders = orders;
                self.editingMode = NO;
                [tableView reloadData];
                [hud hide:YES];
                
                [self requestDataForTab:self.currentTab withStartIndex:1];
            }];
        }
    }];
}

- (void)timeFilterAction:(id)sender {
    if (self.timeFilterList) {
        [self.timeFilterList dismiss];
    } else {
        ListView *filterList = [[ListView alloc] initWithItems:@[@"显示全部", @"最近3天", @"最近14天", @"最近30天", @"最近90天"] selectedIndex:self.filterState];
        DropListView *dropList = [[DropListView alloc] initWithListView:filterList];
        [dropList dropListAlignRightOnView:self.view topSpace:self.topLayoutGuide.length];
        self.timeFilterList = dropList;
        
        typeof(self) __weak weakSelf = self;
        filterList.didSelectIndex = ^(NSInteger index) {
            [weakSelf.timeFilterList dismiss];
            weakSelf.filterState = index;
            
            [weakSelf requestDataForTab:self.currentTab withStartIndex:1];
        };
    }
}

#pragma mark - ButtonBarDelegate
- (void)buttonBarClick:(NSInteger)tab {
    UITableView *table = self.tableViews[tab];
    [self.swipeView scrollRectToVisible:table.frame animated:YES];
    [self swipeToTable:tab];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.swipeView) {
        if (!decelerate) {
            [self updateOrderStateBar:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.swipeView) {
        [self updateOrderStateBar:scrollView];
    }
}

- (void)updateOrderStateBar:(UIScrollView *)scrollView {
    NSInteger tab = (scrollView.contentOffset.x/scrollView.bounds.size.width + 0.5);
    [self.orderStateBar selectButtonIndex:tab animated:YES];
    
    [self swipeToTable:tab];
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.editingMode) {
        if (self.currentTab == DCReserveOrderTabBook) {
            return self.bookDeleteOrders.count;
        } else if (self.currentTab == DCReserveOrderTabCharge) {
            return self.chargeDeleteOrders.count;
        }
    } else {
        return [self ordersForTableView:tableView].count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.editingMode) {
        DCOrder *order = [self ordersForTableView:tableView][indexPath.row];
        
        if (order.orderState == DCOrderStateNotPayBookfee && order.remainTime4ReserveFee < 1000) {
            order.orderState = DCOrderStateOvevtimeToPayBookfee;
        }
        
        if (order.orderState == DCOrderStateCharging ||
            order.orderState == DCOrderStateNotPayChargefee ||
            order.orderState == DCOrderStateExceptionWithNotChargeRecord ||
            order.orderState == DCOrderStateExceptionWithChargeData ||
            order.orderState == DCOrderStateExceptionWithStartChargeFail ||
            order.orderState == DCOrderStateExceptionWithStartChargeFailAfterBook) {
            DCChargeNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCChargeNormalCell" forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[DCChargeNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCChargeNormalCell"];
            }
            cell.delegate = self;
            [cell configForOrder:order];
            return cell;
        }
        else if (order.orderState == DCOrderStateNotEvaluate ||
                 order.orderState == DCOrderStateEvaluated) {
            DCChargeEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCChargeEditableCell" forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[DCChargeEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCChargeEditableCell"];
            }
            cell.delegate = self;
            [cell configForOrder:order];
            [cell updateEditingState:self.editingMode];
            return cell;
        }
        else if (order.orderState == DCOrderStateNotPayBookfee ||
                 order.orderState == DCOrderStatePaidBookfee) {
            DCBookNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCBookNormalCell" forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[DCBookNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCBookNormalCell"];
            }
            cell.delegate = self;
            cell.myDelegate = self;
            [cell configForOrder:order];
            return cell;
        }
        else if (order.orderState == DCOrderStateCancelBooking ||
                 order.orderState == DCOrderStateOvevtimeToPayBookfee ||
                 order.orderState == DCOrderStateOvertimeToCharge ||
                 order.orderState == DCOrderStateCancelBookingAfterPay) {
            DCBookEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCBookEditableCell" forIndexPath:indexPath];
            if (cell == nil) {
                cell = [[DCBookEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCBookEditableCell"];
            }
            cell.delegate = self;
            [cell configForOrder:order];
            [cell updateEditingState:self.editingMode];
            return cell;
        }
    } else {
        if (self.currentTab == DCReserveOrderTabBook) {
            DCOrder *order = [self.bookDeleteOrders objectAtIndex:indexPath.row];
            
            if (order.orderState == DCOrderStateCancelBooking ||
                order.orderState == DCOrderStateOvevtimeToPayBookfee ||
                order.orderState == DCOrderStateOvertimeToCharge ||
                order.orderState == DCOrderStateCancelBookingAfterPay) {
                DCBookEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCBookEditableCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DCBookEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCBookEditableCell"];
                }
                cell.delegate = self;
                [cell configForOrder:order];
                [cell updateEditingState:self.editingMode];
                return cell;
            }
        }
        else if (self.currentTab == DCReserveOrderTabCharge){
            DCOrder *order = [self.chargeDeleteOrders objectAtIndex:indexPath.row];
            
            if (order.orderState == DCOrderStateNotEvaluate ||
                order.orderState == DCOrderStateEvaluated) {
                DCChargeEditableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCChargeEditableCell" forIndexPath:indexPath];
                if (cell == nil) {
                    cell = [[DCChargeEditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCChargeEditableCell"];
                }
                cell.delegate = self;
                [cell configForOrder:order];
                [cell updateEditingState:self.editingMode];
                return cell;
            }
        }
    }
    return nil;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    DCOrder *order = [self ordersForTableView:tableView][indexPath.row];
//    
//    switch (order.orderState) {
//        case DCOrderStateCharging:
//        case DCOrderStateNotPayChargefee: {
//            return [DCChargeNormalCell cellHeight];
//        }
//            break;
//            
//        case DCOrderStateExceptionWithNotChargeRecord:
//        case DCOrderStateExceptionWithChargeData:
//        case DCOrderStateExceptionWithStartChargeFail: {
//            return [DCChargeNormalCell cellHeight];
//        }
//            break;
//            
//        case DCOrderStateNotEvaluate:
//        case DCOrderStateEvaluated: {
//            return [DCChargeEditableCell cellHeight];
//        }
//            break;
//            
//        case DCOrderStateNotPayBookfee:
//        case DCOrderStatePaidBookfee: {
//            return [DCBookNormalCell cellHeight];
//        }
//            break;
//            
//        case DCOrderStateCancelBooking:
//        case DCOrderStateCancelBookingAfterPay: {
//            return [DCBookEditableCell cellHeight];
//        }
//            break;
//            
//        case DCOrderStateOvevtimeToPayBookfee:
//        case DCOrderStateOvertimeToCharge: {
//            return [DCBookEditableCell cellHeight];
//        }
//            break;
//        default:
//            return 0;
//            break;
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingMode) {
        self.selectedIndexPaths = [tableView indexPathsForSelectedRows];
        return;
    }
    
    DCOrder *order = [self ordersForTableView:tableView][indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:DCSegueIdPushToOrderDetail sender:order.orderId];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingMode) {
        self.selectedIndexPaths = [tableView indexPathsForSelectedRows];
        return;
    }
}

#pragma mark - DCChargeEditableCellDelegate
- (void)cellButtonClicked:(DCOrder *)order tag:(DCOrderButtonTag)tag {
    if (!order) {
        return;
    }
    
    switch (tag) {
        case DCOrderButtonTagNavi: {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [DCSiteApi getStationId:order.stationId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:@"抱歉，获取该电桩经纬度位置未失败"];
                    return;
                }
                [hud hide:YES];
                self.orderStation = [[DCStation alloc] initStationWithDict:webResponse.result];
                order.stationCoordinate = [self.orderStation coordinate];
            
                //跳转到地图
                [self.navigationController popViewControllerAnimated:YES];
                DCSearchViewController *searchVC = [DCApp sharedApp].rootTabBarController.viewControllers[DCTabIndexSearch];
                [searchVC setSearchStyle:DCSearchStyleMap];
                DCPoleMapAnnotation *annotation = [DCPoleMapAnnotation annotationWithStation:self.orderStation];
                annotation.isOrderStation = YES;
                [searchVC showPoleInfoViewForAnnotation:annotation];
                [DCApp sharedApp].rootTabBarController.selectedIndex = 1;
                [[DCApp sharedApp].rootTabBarController updateNavigationBar];
            }];
            break;
        }
            
        case DCOrderButtonTagReschedule: {
            DCStationDetailViewController *vc = [DCStationDetailViewController storyboardInstantiate];
            DCStation *station = [DCStation new];
            station.stationId = order.stationId;
            vc.selectStationInfo = station;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }

        case DCOrderButtonTagJumpToCharingView: {
            //跳到充电页面
            [self.navigationController popToRootViewControllerAnimated:YES];
            [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
            [[DCApp sharedApp].rootTabBarController updateNavigationBar];
        }
            break;
        
        case DCOrderButtonTagPayForBook:
        case DCOrderButtonTagPayForCharge: {
            //跳到支付页面
            [self payWithOrder:order withFinishBlock:^(NSDictionary *resultDic) {
                if (resultDic && [resultDic objectForKey:kPayFinishKeyCode]) {
                    NSNumber *codeNum = [resultDic objectForKey:kPayFinishKeyCode];
                    if ([codeNum isEqualToNumber:@(0)]) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        });
                    }
                }
            }];
        }
            break;
            
        case DCOrderButtonTagEvaluate: {
            DCPileEvaluationViewController *vc = [DCPileEvaluationViewController storyboardInstantiate];
            vc.order = order;
            vc.stationId = order.stationId;
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
            
        case DCOrderButtonTagContactOwner: {
            [[DCApp sharedApp] callPhone:@"4000220288" viewController:self];
            break;
        }
            
        default:
            NSAssert(NO, @"unhandled case");
            break;
    }
}

#pragma mark - DCBookNormalCellDelegate
- (void)timeOut {
    [self requestDataForTab:DCReserveOrderTabBook withStartIndex:1];
}

#pragma mark - Extension
- (void)swipeToTable:(DCReserveOrderTab)tab {
    if (self.currentTab != tab) {
        self.currentTab = tab;
        
        self.filterState = OrderFilterStateAll;
        [self requestDataForTab:tab withStartIndex:1];
        
        for (NSInteger tab = 0; tab < self.tableViews.count; tab++) {
            UITableView *tableView = self.tableViews[tab];
            tableView.scrollsToTop = (tab == self.currentTab);
        }
    }
}

- (void)setNavigationBarButtonWith:(DCReserveOrderTab)tab {
    self.navigationItem.rightBarButtonItems = @[self.timeBarButton];
    if (tab == DCReserveOrderTabBook || tab == DCReserveOrderTabBookDelete) {
        for (DCOrder *order in self.bookOrders) {
            if (order.orderState == DCOrderStateCancelBooking ||
                order.orderState == DCOrderStateOvevtimeToPayBookfee ||
                order.orderState == DCOrderStateCancelBookingAfterPay ||
                order.orderState == DCOrderStateOvertimeToCharge) {
                self.navigationItem.rightBarButtonItems = @[self.timeBarButton, self.deleteBarButton];
            }
        }
    } else {
        for (DCOrder *order in self.chargeOrders) {
            if (order.orderState == DCOrderStateNotEvaluate ||
                order.orderState == DCOrderStateEvaluated) {
                self.navigationItem.rightBarButtonItems = @[self.timeBarButton, self.deleteBarButton];
            }
        }
    }
}

- (NSMutableArray *)ordersForTableView:(UITableView *)tableView {
    NSInteger tab = [self.tableViews indexOfObject:tableView];
    return self.ordersArray[tab];
}

- (UIView *)placeholderForTableView:(UITableView *)tableView {
    NSInteger tab = [self.tableViews indexOfObject:tableView];
    return self.ordersArray[tab];
}

- (void)refreshOrders:(NSArray *)orders clear:(BOOL)clear forTab:(DCReserveOrderTab)tab {
    
    DCReserveOrderTab tableViewTab;
    if (tab == DCReserveOrderTabBook || tab == DCReserveOrderTabBookDelete) {
        tableViewTab = DCReserveOrderTabBook;
    } else {
        tableViewTab = DCReserveOrderTabCharge;
    }
    UITableView *tableView = self.tableViews[tableViewTab];
    
    NSMutableArray *totalOrders = [self arrayByTab:tab];
    
    // 保存已经选择的订单
    NSMutableSet *selectedOrders = [NSMutableSet set];
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        [selectedOrders addObject:totalOrders[indexPath.row]];
    }
    
    // 清除旧订单
    if (clear) {
        [totalOrders removeAllObjects];
    }
    
    if (tab == DCReserveOrderTabBook || tab == DCReserveOrderTabCharge) {
        // 加入新订单
        for (DCOrder *order in orders) {
            
            switch (order.orderState) {
                case DCOrderStateCancelBooking:
                case DCOrderStateOvevtimeToPayBookfee:
                case DCOrderStateCancelBookingAfterPay:
                case DCOrderStateOvertimeToCharge:
                case DCOrderStateNotPayBookfee:
                case DCOrderStatePaidBookfee: {
                    [_bookOrders addObject:order];
                }
                    break;
                    
                case DCOrderStateNotEvaluate:
                case DCOrderStateEvaluated:
                case DCOrderStateCharging:
                case DCOrderStateExceptionWithNotChargeRecord:
                case DCOrderStateExceptionWithChargeData:
                case DCOrderStateExceptionWithStartChargeFail:
                case DCOrderStateExceptionWithStartChargeFailAfterBook:
                case DCOrderStateNotPayChargefee: {
                    [_chargeOrders addObject:order];
                }
                    break;
                    
                default:
                    break;
            }
        }
    } else {
        for (DCOrder *order in orders) {
            
            switch (order.orderState) {
                case DCOrderStateCancelBooking:
                case DCOrderStateOvevtimeToPayBookfee:
                case DCOrderStateCancelBookingAfterPay:
                case DCOrderStateOvertimeToCharge: {
                    [_bookDeleteOrders addObject:order];
                }
                    break;
                    
                case DCOrderStateNotEvaluate:
                case DCOrderStateEvaluated: {
                    [_chargeDeleteOrders addObject:order];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    
//        if (order.orderState == DCOrderStateNotPayBookfee
//            || order.orderState == DCOrderStatePaidBookfee
//            || order.orderState == DCOrderStateCancelBooking
//            || order.orderState == DCOrderStateOvevtimeToPayBookfee
//            || order.orderState == DCOrderStateOvertimeToCharge
//            || order.orderState == DCOrderStateCancelBookingAfterPay) {
//            [_bookOrders addObject:order];
//        } else if (order.orderState == DCOrderStateCharging ||
//                   order.orderState == DCOrderStateExceptionWithNotChargeRecord ||
//                   order.orderState == DCOrderStateExceptionWithChargeData ||
//                   order.orderState == DCOrderStateExceptionWithStartChargeFail ||
//                   order.orderState == DCOrderStateExceptionWithStartChargeFailAfterBook ||
//                   order.orderState == DCOrderStateNotPayChargefee ||
//                   order.orderState == DCOrderStateNotEvaluate ||
//                   order.orderState == DCOrderStateEvaluated) {
//            [_chargeOrders addObject:order];
//        }
//    }
    
    [tableView reloadData];
    
    // 重现订单选择状态
    NSMutableArray *selectedIndexPaths = [NSMutableArray array];
    for (DCOrder *selectedOrder in selectedOrders) {
        NSInteger index = [totalOrders indexOfObject:selectedOrder];
        if (index != NSNotFound) {
            [selectedIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    self.selectedIndexPaths = selectedIndexPaths;
    for (NSIndexPath *indexPath in self.selectedIndexPaths) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    tableView.footer.hidden = (totalOrders.count == 0);
    
    UIView *placeholderView = self.placeholderViews[tableViewTab];
    placeholderView.hidden = (totalOrders.count > 0);
}

- (NSInteger)startIndexForTab:(DCReserveOrderTab)tab {
    switch (tab) {
            
        case DCReserveOrderTabBook:
            return self.bookStartIndex;
            
        case DCReserveOrderTabCharge:
            return self.chargeStartIndex;
        
        default:
            return 0;
    }
}

- (NSString *)actionParamForTab:(DCReserveOrderTab)tab {
    switch (tab) {
            
        case DCReserveOrderTabBook:
            return [@[@(DCOrderStateNotPayBookfee).stringValue,
                      @(DCOrderStatePaidBookfee).stringValue,
                      @(DCOrderStateCancelBooking).stringValue,
                      @(DCOrderStateOvevtimeToPayBookfee).stringValue,
                      @(DCOrderStateOvertimeToCharge).stringValue,
                      @(DCOrderStateCancelBookingAfterPay).stringValue]
                    componentsJoinedByString:@","];
            
        case DCReserveOrderTabCharge:
            return [@[@(DCOrderStateCharging).stringValue,
                      @(DCOrderStateExceptionWithNotChargeRecord).stringValue,
                      @(DCOrderStateExceptionWithChargeData).stringValue,
                      @(DCOrderStateExceptionWithStartChargeFail).stringValue,
                      @(DCOrderStateExceptionWithStartChargeFailAfterBook).stringValue,
                      @(DCOrderStateNotPayChargefee).stringValue,
                      @(DCOrderStateNotEvaluate).stringValue,
                      @(DCOrderStateEvaluated).stringValue]
                    componentsJoinedByString:@","];
            
        case DCReserveOrderTabBookDelete:
            return [@[@(DCOrderStateCancelBooking).stringValue,
                      @(DCOrderStateOvevtimeToPayBookfee).stringValue,
                      @(DCOrderStateOvertimeToCharge).stringValue,
                      @(DCOrderStateCancelBookingAfterPay).stringValue]
                    componentsJoinedByString:@","];
            
        case DCReserveOrderTabChargeDelete:
            return [@[@(DCOrderStateNotEvaluate).stringValue,
                      @(DCOrderStateEvaluated).stringValue]
                    componentsJoinedByString:@","];
            
        default:
            return nil;
    }
}

- (void)nextPageForTab:(DCReserveOrderTab)tab withStartIndex:(NSInteger)startIndex {
    NSInteger index = startIndex + 1;
    switch (tab) {
            
        case DCReserveOrderTabBook:
            self.bookStartIndex = index;
            break;
            
        case DCReserveOrderTabCharge:
            self.chargeStartIndex = index;
            break;

        default:
            break;
    }
}

#pragma mark - Editing
- (void)setEditingMode:(BOOL)editingMode {
    _editingMode = editingMode;
    
    if (editingMode) {
        self.navigationItem.rightBarButtonItems = nil;
    } else {
        self.navigationItem.rightBarButtonItems = @[self.timeBarButton, self.deleteBarButton];
    }
    
    /**
     * TODO: deleteBar not use so hide
     */
//    self.orderStateBar.hidden = editingMode;
    self.orderStateBar.userInteractionEnabled = !editingMode;
    [self setBottomBarHidden:!editingMode];
    self.swipeView.scrollEnabled = !editingMode;
    
    UITableView *tableView = self.tableViews[self.currentTab];
    for (NSIndexPath *indexPath in [tableView indexPathsForSelectedRows]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    self.selectedIndexPaths = [tableView indexPathsForSelectedRows];
    
    [tableView reloadData];
    for (UITableViewCell *cell in [tableView visibleCells]) {
        if ([cell isKindOfClass:[DCChargeEditableCell class]]) {
            DCChargeEditableCell *orderCell = (DCChargeEditableCell *)cell;
            [orderCell updateEditingState:self.editingMode];
        } else if ([cell isKindOfClass:[DCBookEditableCell class]]) {
            DCBookEditableCell *orderCell = (DCBookEditableCell *)cell;
            [orderCell updateEditingState:self.editingMode];
        }
    }
}

- (void)setBottomBarHidden:(BOOL)hidden {
    if (!hidden) {
        self.bottomBar.hidden = hidden;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomBarHeightCons.constant = hidden ? 0 : 60;
        [self.bottomBar updateConstraintsIfNeeded];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.bottomBar.hidden = hidden;
    }];
}

- (void)setSelectedIndexPaths:(NSArray *)selectedIndexPaths {
    _selectedIndexPaths = selectedIndexPaths;
    if (selectedIndexPaths.count == 0) {
        [self.deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        self.deleteButton.enabled = NO;
    } else {
        NSString *title = [NSString stringWithFormat:@"删除（%d）", (int)selectedIndexPaths.count];
        [self.deleteButton setTitle:title forState:UIControlStateNormal];
        self.deleteButton.enabled = YES;
    }
}

#pragma mark - Extend
- (NSMutableArray *)arrayByTab:(DCReserveOrderTab)tab {
    switch (tab) {
        case DCReserveOrderTabBook:
            return self.bookOrders;
            break;
            
        case DCReserveOrderTabCharge:
            return self.chargeOrders;
            break;
            
        case DCReserveOrderTabBookDelete:
            return self.bookDeleteOrders;
            break;
            
        case DCReserveOrderTabChargeDelete:
            return self.chargeDeleteOrders;
            break;
            
        default:
            return nil;
            break;
    }
}

@end

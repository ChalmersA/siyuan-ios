//
//  HSSYIncomePayRecordsViewController.m
//  Charging
//
//  Created by Pp on 15/12/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCIncomePayRecordsViewController.h"
#import "ButtonBar.h"
#import "DCIncomePayTableViewCell.h"
//#import "DCWalletTableView.h"
#import "DCCoinRecord.h"
#import "DCSiteApi.h"
#import "DCApp.h"

static int const LoadDataCount = 10; //每次加载的条目数

@interface DCIncomePayRecordsViewController ()<ButtonBarDelegate, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet ButtonBar *buttonBar; // 顶部按钮
@property (weak, nonatomic) IBOutlet UIScrollView *SwipeView; // 滚动View

@property (weak, nonatomic) IBOutlet UITableView *tableView1;
@property (weak, nonatomic) IBOutlet UITableView *tableView2;
//@property (weak, nonatomic) IBOutlet UITableView *tableView3;

@property (strong, nonatomic) NSArray *tableViews;

@property (strong, nonatomic) NSArray *listArray;
@property (strong, nonatomic) NSMutableArray *rechargeArray;
@property (strong, nonatomic) NSMutableArray *consumeArray;
@property (strong, nonatomic) NSMutableArray *withDrawArray;

@property (assign, nonatomic) DCChargeCoinsTableType currentTab; //目前页面
@property (assign, nonatomic) NSInteger rechargeIndex;
@property (assign, nonatomic) NSInteger consumeIndex;
@property (assign, nonatomic) NSInteger withdrawIndex;

@property (strong, nonatomic) DCCoinRecord *coinRecord;
@property (nonatomic) NSURLSessionDataTask *fetchListTask;

@property (strong, nonatomic) MBProgressHUD *myHub;

@end

@implementation DCIncomePayRecordsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentTab = DCChargeCoinsTableTypeRecharge;
    
    self.rechargeArray = [NSMutableArray array];
    self.consumeArray = [NSMutableArray array];
//    self.withDrawArray = [NSMutableArray array];
    
//    self.listArray = @[self.rechargeArray, self.consumeArray, self.withDrawArray];
//    self.tableViews = @[self.tableView1, self.tableView2, self.tableView3];
    self.listArray = @[self.rechargeArray, self.consumeArray];
    self.tableViews = @[self.tableView1, self.tableView2];
    
    typeof(self) __weak weakSelf = self;
    for (NSInteger tab = 0; tab < self.tableViews.count; tab++) {
        UITableView *tableView = self.tableViews[tab];
        [tableView registerNib:[UINib nibWithNibName:@"DCIncomePayTableViewCell" bundle:nil] forCellReuseIdentifier:@"DCIncomePayTableViewCell"];
        
        // refresh footer
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf requestDataForTab:tab + 1 withStartIndex:[weakSelf startIndexForTab:tab + 1]];
        }];
        [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
        [tableView.footer noticeNoMoreData];
        tableView.footer = footer;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        tableView.scrollsToTop = (tab == self.currentTab);
        tableView.dataSource = self;
        tableView.delegate = self;
    }
    
    self.buttonBar.delegate = self;
    self.SwipeView.delegate = self;
    self.SwipeView.scrollsToTop = NO;
    
    [self requestDataForTab:self.currentTab withStartIndex:1];
}

#pragma mark didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request
- (void)requestDataForTab:(DCChargeCoinsTableType)tab withStartIndex:(NSInteger)startIndex {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.fetchListTask cancel];
    
    self.fetchListTask = [DCSiteApi getChargeCoinRecordListWithUserId:[DCApp sharedApp].user.userId type:tab page:startIndex pageSize:LoadDataCount completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        UITableView *tableView = self.tableViews[tab - 1];
        if ([tableView.footer isRefreshing]) {
            [tableView.footer endRefreshing];
        }
        
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return ;
        }
        
        [hud hide:YES];
        NSMutableArray *dataArray = [NSMutableArray array];
        NSArray *array = webResponse.result;
        for (NSDictionary *dict in array) {
            DCCoinRecord *coinRecord = [[DCCoinRecord alloc] initCoinRecordWithDict:dict];
            [dataArray addObject:coinRecord];
        }
        
        
        /**
         * TEST CODE
         */
//        DCCoinRecord *coinRecord = [[DCCoinRecord alloc] init];
//        coinRecord.orderId = @"123413546575431";
//        coinRecord.userId = @"nick";
//        coinRecord.money = 10.2;
//        coinRecord.type = DCTradeTypePay;
//        coinRecord.channel = DCChannelTypeAlipay;
//        coinRecord.acount = @"acount";
//        coinRecord.createTime = [NSDate date];
//        [dataArray addObject:coinRecord];
//        
//        DCCoinRecord *coinRecord2 = [[DCCoinRecord alloc] init];
//        coinRecord2.orderId = @"123413546575431";
//        coinRecord2.userId = @"nick";
//        coinRecord2.money = 10.2;
//        coinRecord2.type = DCTradeTypeRecharge;
//        coinRecord2.channel = DCChannelTypeAlipay;
//        coinRecord2.acount = @"acount";
//        coinRecord2.createTime = [NSDate date];
//        [dataArray addObject:coinRecord2];
        
        [self refreshRecords:dataArray clear:(startIndex == 1) forTab:tab];
        [self nextPageForTab:tab withStartIndex:startIndex];
        
        if (array.count < LoadDataCount) {
            [tableView.footer noticeNoMoreData];
        } else {
            [tableView.footer resetNoMoreData];
        }
        
        if (startIndex == 0) {
            tableView.contentOffset = CGPointZero;
        }
        
        [tableView reloadData];
    }];
}

#pragma mark - ButtonBarDelegate
- (void)buttonBarClick:(NSInteger)tab {
    // 充值记录tab = 0 消费记录tab = 1 提现记录 = 2
    UITableView *table = self.tableViews[tab];
    [self.SwipeView scrollRectToVisible:table.frame animated:YES];
    [self swipeToTable:tab];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.SwipeView) {
        if (!decelerate) {
            [self updateOrderStateBar:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.buttonBar selectButtonIndex:self.SwipeView.contentOffset.x / self.SwipeView.bounds.size.width animated:YES];
}

- (void)updateOrderStateBar:(UIScrollView *)scrollView {
    NSInteger tab = (scrollView.contentOffset.x/scrollView.bounds.size.width + 0.5);
    [self.buttonBar selectButtonIndex:tab animated:YES];
    
    [self swipeToTable:tab];
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self coinRecordForTableView:tableView].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.coinRecord = [self coinRecordForTableView:tableView][indexPath.row];
    
    DCIncomePayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCIncomePayTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCIncomePayTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCIncomePayTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configViewWithCoinRecord:self.coinRecord];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.coinRecord.type == DCTradeTypeRecharge) {
        return 130;
    } else {
        return 105;
    }
}

#pragma mark Extension
- (void)swipeToTable:(DCChargeCoinsTableType)tab {
    if (self.currentTab != tab + 1) {
        self.currentTab = tab + 1;
        
        [self requestDataForTab:tab + 1 withStartIndex:1];
        
        for (NSInteger tab = 0; tab < self.tableViews.count; tab++) {
            UITableView *tableView = self.tableViews[tab];
            tableView.scrollsToTop = (tab + 1 == self.currentTab);
        }
    }
}

- (NSMutableArray *)coinRecordForTableView:(UITableView *)tableView {
    NSInteger tab = [self.tableViews indexOfObject:tableView];
    return self.listArray[tab];
}

- (NSInteger)startIndexForTab:(DCChargeCoinsTableType)tab {
    switch (tab) {
            
        case DCChargeCoinsTableTypeRecharge:
            return self.rechargeIndex;
            
        case DCChargeCoinsTableTypeConsume:
            return self.consumeIndex;
            
//        case DCChargeCoinsTableTypeWithdraw:
//            return self.withdrawIndex;
            
        default:
            return 0;
    }
    return 0;
}

- (void)refreshRecords:(NSArray *)records clear:(BOOL)clear forTab:(DCChargeCoinsTableType)tab {
    
    UITableView *tableView = self.tableViews[tab - 1];
    NSMutableArray *totalOrders = [self coinRecordForTableView:tableView];
    
    // 清除旧订单
    if (clear) {
        [totalOrders removeAllObjects];
    }
    
    // 加入新订单
    for (DCCoinRecord *record in records) {
        if (record.type == DCTradeTypeRecharge) {
            [_rechargeArray addObject:record];
        }
        else if (record.type == DCTradeTypePay) {
            [_consumeArray addObject:record];
        }
//        else if (record.type == DCTradeTypeWithdraw) {
//            [_withDrawArray addObject:record];
//        }
    }
    
    [tableView reloadData];

    tableView.footer.hidden = (totalOrders.count == 0);
}

- (void)nextPageForTab:(DCChargeCoinsTableType)tab withStartIndex:(NSInteger)startIndex {
    NSInteger index = startIndex + 1;
    switch (tab) {
            
        case DCChargeCoinsTableTypeRecharge:
            self.rechargeIndex = index;
            break;
            
        case DCChargeCoinsTableTypeConsume:
            self.consumeIndex = index;
            break;
        
//        case DCChargeCoinsTableTypeWithdraw:
//            self.withdrawIndex = index;
            
        default:
            break;
    }
}

@end

//
//  DCWalletTableView.m
//  Charging
//
//  Created by Pp on 15/12/12.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCWalletTableView.h"
#import "DCIncomePayTableViewCell.h"
#import "DCCoinRecord.h"
#import "DCSiteApi.h"
#import "DCApp.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"

static int const LoadDataCount = 10; //每次加载的条目数

@interface DCWalletTableView()<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataArray;
//@property (assign, nonatomic) DCChargeCoinsTableType tableType;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger startIndex;
@property (weak, nonatomic) NSURLSessionTask *requestFavoritesTask;

@end

@implementation DCWalletTableView

#pragma mark - 根据数据初始化tableview
//- (void)createTableViewWithType:(DCChargeCoinsTableType)tableType{
//    self.tableType = tableType;
//    self.tableView = [[UITableView alloc]init];
//    [self addSubview:self.tableView];
//    
//    // 约束
//    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSArray *tabConA = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tab]-0-|" options:0 metrics:nil views:@{@"tab":self.tableView}];
//    NSArray *tabConB = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tab]-0-|" options:0 metrics:nil views:@{@"tab":self.tableView}];
//
//    [self addConstraints:tabConA];
//    [self addConstraints:tabConB];
//    
//    self.tableView.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
//    self.tableView.delegate = self;
//    self.tableView.dataSource = self;
//    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    
//    [self requestFavoritesWithStartIndex:0];
//    // refresh footer
//    typeof(self) __weak weakSelf = self;
//    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [weakSelf requestFavoritesWithStartIndex:weakSelf.startIndex];
//    }];
//    [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
//    self.tableView.footer = footer;
//    self.tableView.footer.hidden = YES;
//    [self.tableView reloadData];
//    
//}

#pragma mark - Request
- (void)requestFavoritesWithStartIndex:(NSInteger)start {
//    // 获取充值记录
//    if (self.tableType == DCChargeCoinsTableTypeRecharge) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
//        [DCSiteApi postRechargeRecord:[DCApp sharedApp].user.userId start:@(start) count:@(LoadDataCount) completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            if ([self.tableView.footer isRefreshing]) {
//                [self.tableView.footer endRefreshing];
//            }
//            if (![webResponse isSuccess]) {
//                //获取充值记录失败
//                [hud hide:YES];
//                return;
//            }
//            if (start == 0) {
//                [self.dataArray removeAllObjects];
//            }
//            NSArray *poles = [webResponse.result arrayObject];;
//            self.startIndex = start + poles.count;
//            for (NSDictionary *dict in poles) {
//                if (![dict isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
//                    continue;
//                }
////                DCRechargeRecordModel *model = [DCRechargeRecordModel rechargeRecordWithDict:dict];
////                [self.dataArray addObject:model];
//            }
//            [self.tableView reloadData];
//            if (poles.count < LoadDataCount) {
//                [self.tableView.footer noticeNoMoreData];
//            } else {
//                [self.tableView.footer resetNoMoreData];
//            }
//            [hud hide:YES];
//        }];
//    }
//    // 获取支付记录
//    else if(self.tableType == DCChargeCoinsTableTypeConsume){
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
//        [DCSiteApi postPayRecord:[DCApp sharedApp].user.userId start:@(start) count:@(LoadDataCount) completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            if ([self.tableView.footer isRefreshing]) {
//                [self.tableView.footer endRefreshing];
//            }
//            if (![webResponse isSuccess]) {
//                //获取支付记录失败
//                [hud hide:YES];
//                return;
//            }
//            if (start == 0) {
//                [self.dataArray removeAllObjects];
//            }
//            NSArray *poles = [webResponse.result arrayObject];;
//            self.startIndex = start + poles.count;
//            for (NSDictionary *dict in poles) {
//                if (![dict isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
//                    continue;
//                }
//                DCCoinRecord *model = [DCCoinRecord payRecordWithDict:dict];
//                [self.dataArray addObject:model];
//            }
//            [self.tableView reloadData];
//            if (poles.count < LoadDataCount) {
//                [self.tableView.footer noticeNoMoreData];
//            } else {
//                [self.tableView.footer resetNoMoreData];
//            }
//            [hud hide:YES];
//        }];
//    }
//    else if (self.tableType == DCChargeCoinsTableTypeWithdraw) {
//        
//    }
}

#pragma mark - loadData
- (void)loadData{
    // 获取充值记录
//    if (self.tableType == DCChargeCoinsTableTypeRecharge) {
//        [DCSiteApi postRechargeRecord:[DCApp sharedApp].user.userId start:@0 count:@10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            if ([webResponse isSuccess]) {
//                for (NSDictionary *dic in webResponse.result) {
//                    DCRechargeRecordModel *model = [DCRechargeRecordModel rechargeRecordWithDict:dic];
//                    [self.dataArray addObject:model];
//                    [self.tableView reloadData];
//                }
//            }
//            else{
//                //获取充值记录失败
//            }
//        }];
//    }
//    // 获取支付记录
//    else if(self.tableType == DCChargeCoinsTableTypeConsume){
//        [DCSiteApi postPayRecord:[DCApp sharedApp].user.userId start:@0 count:@10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            if ([webResponse isSuccess]) {
//                for (NSDictionary *dic in webResponse.result) {
//                    DCCoinRecordModel *model = [DCCoinRecordModel payRecordWithDict:dic];
//                    [self.dataArray addObject:model];
//                    [self.tableView reloadData];
//                }
//            }
//            else{
//                //获取支付记录失败
//            }
//        }];
//    }
//    // 提现记录
//    else if (self.tableType == DCChargeCoinsTableTypeWithdraw) {
//        
//    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"DCIncomePayTableViewCell";
    DCIncomePayTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell){
        [tableView registerNib:[UINib nibWithNibName:@"DCIncomePayTableViewCell" bundle:nil] forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (void)setCellWithData{
    
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView willDisplayCell:(DCIncomePayTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (self.tableType == HSSYTableTypePay) {
//        cell.coinImage.image = [UIImage imageNamed:@"wallet_record_number"];
//        cell.wayImage.image = [UIImage imageNamed:@"wallet_record_order"];
//        
//        cell.firstTitle.text = @"支付币数：";
//        cell.secondTitle.text = @"支付时间：";
//        cell.thirdTitle.text = @"订  单  号：";
//    }
//    
//    if (self.tableType == HSSYTableTypeIncome) {
//        DCRechargeRecordModel *model = self.dataArray[indexPath.row];
//        cell.firstLabel.text = [NSString stringWithFormat:@"￥ %.2f", model.rechargeMoney];
//        cell.secondLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.rechargeTime / 1000]];
//        switch ([model.rechargeType integerValue]) {
//            case 1:
//                cell.thirdLabel.text = @"支付宝支付";
//                break;
//            case 2:
//                cell.thirdLabel.text = @"微信支付";
//                break;
//                
//            default:
//                break;
//        }
//    }
//    if (self.tableType == HSSYTableTypePay) {
//        DCCoinRecordModel *model = self.dataArray[indexPath.row];
//        cell.firstLabel.text = [NSString stringWithFormat:@"%.2f 个", model.payMoney];
//        cell.secondLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:model.payTime / 1000]];
//        cell.thirdLabel.text = [NSString stringWithFormat:@"%@", model.orderNo];
//    }
}

#pragma mark -
- (NSMutableArray *)dataArray{
    if (nil ==  _dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end

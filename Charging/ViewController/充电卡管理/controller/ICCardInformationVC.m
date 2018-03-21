//
//  ICCardInformationVC.m
//  aaa
//
//  Created by gaoml on 2018/3/6.
//  Copyright © 2018年 钞王. All rights reserved.
//  充电卡信息

#import "ICCardInformationVC.h"
#import "WCTopTagView.h"
#import "BasicInformationCell.h"
#import "RechargeRecordCell.h"
#import "SlotCardRecordCell.h"
#import "MJRefresh.h"
#import "PrepaidModel.h"
#import "ConsumptionModel.h"
//#import "UITableView+AddForPlaceholder.h"

@interface ICCardInformationVC ()<WCTopTagViewDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIScrollView *scroller;

@property (nonatomic, strong) WCTopTagView *topTagView;     //顶部选择view

@property (nonatomic, strong) NSArray *titleA;

@property (nonatomic, strong) UITableView *baseInformationView; //基本信息view

@property (nonatomic, strong) UITableView *rechargeRecordView; //充值记录view

@property (nonatomic, strong) NSMutableArray *rechargeRecordDataSource;

@property (nonatomic, assign) int rechargeRecordPage;

@property (nonatomic, strong) UITableView *slotCardRecordView; //刷卡记录view

@property (nonatomic, strong) NSMutableArray *slotCardRecordDataSource;

@property (nonatomic, assign) int slotCardRecordPage;

@end

@implementation ICCardInformationVC

- (NSMutableArray *)rechargeRecordDataSource{
    if (!_rechargeRecordDataSource) {
        _rechargeRecordDataSource = [NSMutableArray array];
    }
    return _rechargeRecordDataSource;
}

- (NSMutableArray *)slotCardRecordDataSource{
    if (!_slotCardRecordDataSource) {
        _slotCardRecordDataSource = [NSMutableArray array];
    }
    return _slotCardRecordDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"充电卡信息";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topTagView];
    [self.view addSubview:self.scroller];
    
    [self.scroller addSubview:self.baseInformationView];
    [self.scroller addSubview:self.rechargeRecordView];
    [self.scroller addSubview:self.slotCardRecordView];
    
    [self.scroller setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
    [self getRechargeRecordListWithPage:1];
    [self getSlotCardRecordListWithPage:1];
}

-(NSArray *)titleA
{
    if (_titleA == nil) {
        _titleA = @[@"充值记录",@"基本信息",@"刷卡记录"];
    }
    return _titleA;
}

-(UIScrollView *)scroller
{
    if (_scroller == nil) {
        CGFloat scrollerTop = self.topTagView.frame.size.height + self.topTagView.frame.origin.y;
        _scroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollerTop, self.topTagView.frame.size.width, [UIScreen mainScreen].bounds.size.height - scrollerTop)];
        _scroller.delegate = self;
        _scroller.pagingEnabled = YES;
        _scroller.scrollEnabled = YES;
        _scroller.showsVerticalScrollIndicator = NO;
        _scroller.showsHorizontalScrollIndicator = NO;
        _scroller.alwaysBounceVertical = NO;
        _scroller.bounces = NO;
        _scroller.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1];
        [_scroller setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * self.titleA.count, 0)];
    }
    return _scroller;
}

-(WCTopTagView *)topTagView
{
    if (_topTagView == nil) {
        _topTagView = [[WCTopTagView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
        [_topTagView updateViewWith:self.titleA normalColor:[UIColor colorWithRed:156.0/255.0 green:206/255.0 blue:249/255.0 alpha:1] selectedColor:[UIColor whiteColor]];
        _topTagView.delegate = self;
    }
    return _topTagView;
}

-(UITableView *)baseInformationView
{
    if (_baseInformationView == nil) {
        _baseInformationView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 10, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height - 10) style:UITableViewStylePlain];
        _baseInformationView.delegate = self;
        _baseInformationView.dataSource = self;
        _baseInformationView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _baseInformationView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1];
        [_baseInformationView registerNib:[UINib nibWithNibName:NSStringFromClass(BasicInformationCell.class) bundle:nil] forCellReuseIdentifier:@"BasicInformationCell"];
    }
    return _baseInformationView;
}

-(UITableView *)rechargeRecordView
{
    if (_rechargeRecordView == nil) {
        _rechargeRecordView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height - 10) style:UITableViewStylePlain];
        typeof(self) __weak weakSelf = self;
        // refresh header
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf getRechargeRecordListWithPage:1];
        }];
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf getRechargeRecordListWithPage:self.rechargeRecordPage++];
        }];
        _rechargeRecordView.header = header;
        _rechargeRecordView.footer = footer;
        _rechargeRecordView.delegate = self;
        _rechargeRecordView.dataSource = self;
        _rechargeRecordView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _rechargeRecordView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1];
        [_rechargeRecordView registerNib:[UINib nibWithNibName:NSStringFromClass(RechargeRecordCell.class) bundle:nil] forCellReuseIdentifier:@"RechargeRecordCell"];
    }
    return _rechargeRecordView;
}

-(UITableView *)slotCardRecordView
{
    if (_slotCardRecordView == nil) {
        _slotCardRecordView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 2, 10, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height - 10) style:UITableViewStylePlain];
        // refresh header
        typeof(self) __weak weakSelf = self;
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [weakSelf getSlotCardRecordListWithPage:1];
        }];
        MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [weakSelf getSlotCardRecordListWithPage:self.rechargeRecordPage++];
        }];
        _slotCardRecordView.header = header;
        _slotCardRecordView.footer = footer;
        _slotCardRecordView.delegate = self;
        _slotCardRecordView.dataSource = self;
        _slotCardRecordView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _slotCardRecordView.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:1];
        [_slotCardRecordView registerNib:[UINib nibWithNibName:NSStringFromClass(SlotCardRecordCell.class) bundle:nil] forCellReuseIdentifier:@"SlotCardRecordCell"];
    }
    return _slotCardRecordView;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([tableView isEqual: _baseInformationView]) {
        return 1;

    } else if ([tableView isEqual: _rechargeRecordView]) {
        return self.rechargeRecordDataSource.count;
   } else {
        return self.slotCardRecordDataSource.count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual: _baseInformationView]) {
        return 160;
    } else  if ([tableView isEqual: _rechargeRecordView]) {
        return 150;
    } else {
        return 250;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([tableView isEqual: _baseInformationView]) {
        BasicInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicInformationCell"];
        if (!cell) {
            cell = [[BasicInformationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BasicInformationCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.cardNumLb.text = self.infoModel.card_no;
        cell.phoneNumLb.text = self.infoModel.phone;
        cell.failureDateLb.text = self.infoModel.valid_time;
        cell.addressNameLb.text = self.infoModel.open_branch_name;
        cell.openCardDateLb.text = self.infoModel.open_card_time;
        cell.balanceLb.text = [NSString stringWithFormat:@"%.2f元",self.infoModel.ic_money];
        
        return cell;
        
    } else  if ([tableView isEqual: _rechargeRecordView]) {
        RechargeRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RechargeRecordCell"];
        if (!cell) {
            cell = [[RechargeRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RechargeRecordCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        PrepaidModel *model = self.rechargeRecordDataSource[indexPath.row];
        cell.cardNumLb.text = model.card_no;
        cell.moneyLb.text = [NSString stringWithFormat:@"%.2f元",model.charge_amount];
        cell.rechargeDateLb.text = model.charge_time;
        switch (model.pay_way) {
            case 1:
                cell.rechargeWayLb.text = @"支付宝";
                break;
            case 2:
                cell.rechargeWayLb.text = @"微信";
                break;
            case 3:
                cell.rechargeWayLb.text = @"充电币";
                break;
            default:
                break;
        }
        
        return cell;
        
    } else {

        SlotCardRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SlotCardRecordCell"];
        if (!cell) {
            cell = [[SlotCardRecordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SlotCardRecordCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        ConsumptionModel *mod = self.slotCardRecordDataSource[indexPath.row];
        cell.cardNumLb.text = mod.cardId;
        cell.createTimeLb.text = [self getTimeFromTimestamp:mod.createTime];
        cell.moneyLb.text = [NSString stringWithFormat:@"%.2f元",mod.chargeFee];
        cell.startChargeTimeLb.text = [self getTimeFromTimestamp:mod.stopChargeTime];
        cell.stopChargeTimeLb.text = [self getTimeFromTimestamp:mod.stopChargeTime];
        cell.chargeCountLb.text = [NSString stringWithFormat:@"%.2fkw.h",mod.chargeCount];
        switch (mod.flag) {
            case 0:
                cell.flagLb.text = @"已结算";
                break;
            case 1:
                cell.flagLb.text = @"未找到充电记录";
                break;
            case 99:
                cell.flagLb.text = @"未结算";
                break;
            default:
                break;
        }
        switch (mod.type) {
            case 0:
                cell.comefromLb.text = @"来自充电卡";
                break;
            case 1:
                cell.comefromLb.text = @"来自充电币";
                break;
            default:
                break;
        }

        return cell;
    }
    
}

#pragma mark ---- 将时间戳转换成时间

- (NSString *)getTimeFromTimestamp: (long )longTime{
    
    //将对象类型的时间转换为NSDate类型
    double time = longTime;
    
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //设置时间格式
    
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //将时间转换为字符串
    
    NSString *timeStr=[formatter stringFromDate:myDate];
    
    return timeStr;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == _baseInformationView) {

        
    } else if (tableView == _rechargeRecordView) {
        
    } else {
        
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.scroller]) {
        [self.topTagView updateViewWith:scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width];
        
    }
}

//顶部title点击

-(void)topTagViewClickAction:(int)tag;
{
    [self.scroller setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * tag, 0) animated:YES];
}



- (void)getRechargeRecordListWithPage:(int)page{
    if (page == 1) self.rechargeRecordPage = 1;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"cardNo"] = self.infoModel.card_no;
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    parameters[@"pageSize"] = [NSNumber numberWithInt:10];
    parameters[@"page"] = [NSNumber numberWithInt:page];
    [[DCHTTPSessionManager shareManager] GET:@"api/iccard/record/lists" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [self.rechargeRecordView.header endRefreshing];
        [self.rechargeRecordView.footer endRefreshing];
        if (page == 1){
            self.rechargeRecordDataSource = [PrepaidModel mj_objectArrayWithKeyValuesArray:webResponse.result];
        }else{
            [self.rechargeRecordDataSource addObjectsFromArray:[PrepaidModel mj_objectArrayWithKeyValuesArray:webResponse.result]];
        }
        if (((NSArray *)webResponse.result).count < 10) {
            [self.rechargeRecordView.footer noticeNoMoreData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.rechargeRecordView reloadData];
        });
    }];

}


- (void)getSlotCardRecordListWithPage:(int)page{
    if (page == 1) self.slotCardRecordPage = 1;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"cardNo"] = self.infoModel.card_no;
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    parameters[@"pageSize"] = [NSNumber numberWithInt:10];
    parameters[@"page"] = [NSNumber numberWithInt:page];
    [[DCHTTPSessionManager shareManager] GET:@"api/charge/record/lists" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (page == 1) self.slotCardRecordDataSource = [NSMutableArray array];
        [self.slotCardRecordView.header endRefreshing];
        [self.slotCardRecordView.footer endRefreshing];
        if (page == 1){
            self.slotCardRecordDataSource = [ConsumptionModel mj_objectArrayWithKeyValuesArray:webResponse.result];
        }else{
            [self.slotCardRecordDataSource addObjectsFromArray:[ConsumptionModel mj_objectArrayWithKeyValuesArray:webResponse.result]];
        }
        if (((NSArray *)webResponse.result).count < 10) {
            [self.slotCardRecordView.footer noticeNoMoreData];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.slotCardRecordView reloadData];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    //去掉返回按钮的字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

@end

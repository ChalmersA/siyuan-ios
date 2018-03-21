//
//  WCCardViewController.m
//  aaa
//
//  Created by 钞王 on 2018/3/1.
//  Copyright © 2018年 钞王. All rights reserved.
//
#import "DCSiteApi.h"
#import "WCCardViewController.h"
#import "WCTopTagView.h"
#import "WCCardTopUpView.h"
#import "WCBalanceView.h"
#import "WCCardInputView.h"
#import "InFormationCell.h"
#import "ICCardInformationVC.h"
#import "BindingCardVC.h"
#import "BeeCloud.h"
#import "DCBeeCloudPaymentParams.h"
#import "ICCardModel.h"
#import "DCPopupView.h"
#import "DCOneButtonAlertView.h"
#import "DCSiteApi.h"
#import "SPAlertController.h"
#import "MyCenterView.h"
//#import "UITableView+AddForPlaceholder.h"
#import "MJRefresh.h"
#import "SearchRecordTool.h"

@interface WCCardViewController ()<UIScrollViewDelegate,WCCardTopUpViewDelegate,UITableViewDelegate,UITableViewDataSource,BeeCloudDelegate,WCTopTagViewDelegate,WCBalanceViewDelegate,DCPopupViewDelegate, DCOneButtonAlertViewDelegate>

@property (nonatomic, strong) UIScrollView *scroller;

@property (nonatomic, strong) WCTopTagView *topTagView;     //顶部选择view

@property (nonatomic, strong) NSArray *titleA;

@property (nonatomic, strong) WCCardTopUpView *topupView;   //充电卡充值view

@property (nonatomic, strong) WCBalanceView *balanceView;   //余额查询view

@property (nonatomic, strong) UITableView *informationView; //充电卡信息view

@property (nonatomic, strong) NSMutableArray *informationDataSource;

@property (nonatomic, strong) UIButton *addCardBtn;

@property (strong, nonatomic) DCBeeCloudPaymentParams *payParams;

@property (strong, nonatomic) DCPopupView *warmPopupView;

@property (strong, nonatomic) EmptyView *emptyView;

@property (assign, nonatomic) NSInteger index;

@end

@implementation WCCardViewController
-(EmptyView *)emptyView
{
    if (!_emptyView) {
        _emptyView = [[EmptyView alloc] initWithFrame:self.informationView.bounds];
        [_emptyView showEmptyViewWithImage:[UIImage imageNamed:@"chargeCard_placeholder"] title:@"没有绑定的充电卡，只有绑定后才能查看充电卡充值记录以及消费记录等信息"];
        [self.informationView addSubview:_emptyView];
    }
    return _emptyView;
}
- (NSMutableArray *)informationDataSource{
    if (!_informationDataSource) {
        _informationDataSource = [NSMutableArray array];
    }
    return _informationDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor paletteDCMainColor];
    self.navigationItem.title = @"充电卡管理";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topTagView];
    [self.view addSubview:self.scroller];
    
    [self.scroller addSubview:self.topupView];
    [self.scroller addSubview:self.balanceView];
    [self.scroller addSubview:self.informationView];
    
    [self.scroller addSubview:self.addCardBtn];
    
    [self.scroller setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width, 0)];
    
    [BeeCloud setBeeCloudDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    //去掉返回按钮的字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    [self getLastChargingRecord];
    [self getCardInformations];
}



-(NSArray *)titleA
{
    if (_titleA == nil) {
        _titleA = @[@"充电卡充值",@"余额查询",@"充电卡信息"] ;
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

-(WCCardTopUpView *)topupView
{
    if (_topupView == nil) {
        _topupView = [[WCCardTopUpView alloc] initWithFrame:CGRectMake(0, 10, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height)];
        _topupView.delegate = self;
    }
    return _topupView;
}

-(WCBalanceView *)balanceView
{
    if (_balanceView == nil) {
        _balanceView = [[WCBalanceView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height)];
        _balanceView.delegate = self;
//        if ([SearchRecordTool getAllRecords].count > 0) {

            UIButton *rightCleanButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
            [rightCleanButton setImage:[UIImage imageNamed:@"历史查询"] forState:UIControlStateNormal];
            [rightCleanButton addTarget:self action:@selector(balanceButtonClickAction:) forControlEvents:UIControlEventTouchUpInside];
            _balanceView.inPutView.textField.rightView = rightCleanButton;
            [_balanceView.inPutView.textField setRightViewMode:UITextFieldViewModeAlways];

//        }
     }
    return _balanceView;
}

-(UITableView *)informationView
{
    if (_informationView == nil) {
        _informationView = [[UITableView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 2, 10, [UIScreen mainScreen].bounds.size.width, self.scroller.frame.size.height - 10 - 50) style:UITableViewStylePlain];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self getCardInformations];
        }];
 //       MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
 //           [self getCardInformations];
 //       }];
        self.informationView.header = header;
   //     self.informationView.footer = footer;
        _informationView.delegate = self;
        _informationView.dataSource = self;
        _informationView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_informationView registerNib:[UINib nibWithNibName:NSStringFromClass(InFormationCell.class) bundle:nil] forCellReuseIdentifier:@"InformationCell"];
    }
    return _informationView;
}

-(UIButton *)addCardBtn
{
    if (_addCardBtn == nil) {
        
        _addCardBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * 2, [UIScreen mainScreen].bounds.size.height - (self.topTagView.frame.size.height  + self.topTagView.frame.origin.y) - 50 - self.navigationController.navigationBar.frameHeight - [[UIApplication sharedApplication] statusBarFrame].size.height, [UIScreen mainScreen].bounds.size.width, 50)];
        [_addCardBtn setTitle:@"绑定充电卡" forState:UIControlStateNormal];
        [_addCardBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addCardBtn setBackgroundColor:[UIColor paletteDCMainColor]];
        [_addCardBtn addTarget:self action:@selector(addCardClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _addCardBtn;
}

//绑定充电卡
- (void)addCardClick {
    BindingCardVC *vc = [[BindingCardVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.informationDataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    InFormationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InformationCell"];
    if (!cell) {
        cell = [[InFormationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InformationCell"];
    }
    ICCardModel *model = self.informationDataSource[indexPath.row];
    cell.cardNumLb.text = model.card_no;
    self.index = indexPath.row;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clickButtonBlock = ^{
        //解绑充电卡
        [self popUpWarmView];

    };
    return cell;
}

#pragma mark - public
- (void)popUpWarmView {
    DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeUnbindChargeCard];
    view.delegate = self;
    self.warmPopupView = [DCPopupView popUpWithTitle:@"是否解除充电卡绑定" contentView:view withController:self];
}

- (void)popUpViewDismiss:(DCPopupView *)view {
    [self.warmPopupView dismiss];
}
#pragma mark - 解绑充电卡
- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ICCardModel *model = self.informationDataSource[self.index];
    [DCSiteApi postUnbindChargeCardWithCardId:model.card_no userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self.warmPopupView dismiss];
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [self.warmPopupView dismiss];
        [self hideHUD:hud withDetailsText:@"解绑成功" completion:^{
            
            [self getCardInformations];
        }];
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ICCardModel *model = self.informationDataSource[indexPath.row];
    ICCardInformationVC *vc = [[ICCardInformationVC alloc] init];
    vc.infoModel = model;
    [self.navigationController pushViewController:vc animated:YES];
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



#pragma - mark 充值界面

//确定按钮点击                            金额              卡号
-(void)cardTopUpViewClickWithtitle1:(NSString *)title1 title2:(NSString *)title2 selectIndex:(int)selectIndex;
{
    
    if (title1.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入充值金额";
        [hud hide:YES afterDelay:2];
        return;
    }
    //检测金额
    if (([title1 doubleValue] < 0.01) || ([title1 doubleValue] > 10000)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的充值金额";
        [hud hide:YES afterDelay:2];
        return;
    }
    if ((title2.length == 0) || (title2.length < 14)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的卡号";
        [hud hide:YES afterDelay:2];
        return;
    }
    //获取订单号
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"money"] = [NSNumber numberWithDouble:[title1 doubleValue]];
    parameters[@"cardNo"] = title2;
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    
    MBProgressHUD *loadingHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    loadingHud.mode = MBProgressHUDModeIndeterminate;
    [[DCHTTPSessionManager shareManager] POST:@"api/transaction/icRecharge" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [loadingHud hide:YES];
        if (webResponse.code == 0) {
            //获取充值编号成功
            self.payParams = [[DCBeeCloudPaymentParams alloc] initBeeCloudPaymentParamsWithDict:webResponse.result];
            if (selectIndex == 0) {
                //支付宝
                [self doPay:PayChannelAliApp];
            }
            if (selectIndex == 1) {
                //微信
                [self doPay:PayChannelWxApp];
            }
        }else{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = webResponse.message;
            [hud hide:YES afterDelay:2];
        }
    }];
}

- (void)doPay:(PayChannel)channel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    BCPayReq *payReq = [[BCPayReq alloc] init];
    payReq.channel = channel;
    payReq.title = self.payParams.billTitle;
    payReq.totalFee = [NSString stringWithFormat:@"%@", self.payParams.billRemainFee];
    payReq.billNo = self.payParams.billNum;
    payReq.scheme = @"sychargingzhifubaopay";
    payReq.billTimeOut = 300;
    payReq.viewController = self;
    payReq.optional = dict;
    [BeeCloud sendBCReq:payReq];
}

- (void)onBeeCloudResp:(BCBaseResp *)resp
{
    if (resp.type == BCObjsTypePayResp) {
        //支付响应事件类型，包含微信、支付宝、银联、百度
        BCPayResp *tempResp = (BCPayResp *)resp;
        if (tempResp.resultCode == 0) {
            
            //支付成功
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
            [self showHUDText:@"支付成功" completion:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
        } else {
            //支付取消或者支付失败
            [self showAlertView:[NSString stringWithFormat:@"%@",tempResp.resultMsg]];
        }
    }
}

- (void)showAlertView:(NSString *)msg {
    // 支付失败或者取消支付 解锁订单号
    // 解锁支付状态
    [DCSiteApi postOrderIdForUnlockOrder:self.payParams.billNum userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {

    }];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma - mark 余额查询界面
//获取最后一次充值信息
- (void)getLastChargingRecord{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    [[DCHTTPSessionManager shareManager] GET:@"api/iccard/record/iccardno" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        self.balanceView.inPutView.textField.text = webResponse.result[@"cardNo"];
    }];
}
//点击查询按钮
- (void)balanceViewClick {
    if ((self.balanceView.inPutView.textField.text.length == 0) || (self.balanceView.inPutView.textField.text.length < 14)) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的卡号";
        [hud hide:YES afterDelay:2];
        return;
    }

    if (self.balanceView.inPutView.textField.text.length == 14) {
       self.balanceView.inPutView.textField.text = [self.balanceView.inPutView.textField.text stringByAppendingString:@"00"];
    }

    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"cardNo"] = self.balanceView.inPutView.textField.text;
    [[DCHTTPSessionManager shareManager] GET:@"api/iccard/charge/money" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        if ([webResponse isSuccess]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"充电卡余额" message:[NSString stringWithFormat:@"%.2f元",[webResponse.result[@"icMoney"] doubleValue]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            
            [SearchRecordTool insertRecord:self.balanceView.inPutView.textField.text];

            
        } else {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = webResponse.message;
            [hud hide:YES afterDelay:2];
        }
        

    }];
}

// 弹出历史记录view
- (void)balanceButtonClickAction:(UIButton *)sender
{
    // 自定义中间的view，这种自定义下:如果是SPAlertControllerStyleAlert样式，action个数不能大于maxNumberOfActionHorizontalArrangementForAlert,超过maxNumberOfActionHorizontalArrangementForAlert的action将不显示,如果是SPAlertControllerStyleActionSheet样式,action必须为取消样式才会显示
    MyCenterView *centerView = [[MyCenterView alloc] initWithFrame:CGRectMake(0, 0, KSW-40, 300)];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请选择要查询的卡号" message:@"" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault customCenterView:centerView];
     __weak typeof(self) weakself = self;
    centerView.seletedRowBlock = ^(NSString * str){
        weakself.balanceView.inPutView.textField.text = str;
        [alertController dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 充电卡信息

- (void)getCardInformations{
    MBProgressHUD *loadingHud = [MBProgressHUD showHUDAddedTo:self.informationView animated:YES];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"userId"] = [DCApp sharedApp].user.userId;
    [[DCHTTPSessionManager shareManager] GET:@"api/iccard/card/lists" parameters:parameters completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        [loadingHud hide:YES];
        [self.informationView.header endRefreshing];

        self.informationDataSource = [ICCardModel mj_objectArrayWithKeyValuesArray:webResponse.result];
//        __weak typeof(self) weakself = self;
        if (self.informationDataSource.count == 0) {
            // 展示空白视图
            [self.emptyView setHidden:NO];

        } else {
            [self.emptyView setHidden:YES];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.informationView reloadData];
        });
    }];
}


@end

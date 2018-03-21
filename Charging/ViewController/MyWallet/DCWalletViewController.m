//
//  HSSYWalletViewController.m
//  Charging
//
//  Created by Pp on 15/12/10.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCWalletViewController.h"
#import "DCWalletCell.h"
#import "DCOrderViewController.h"
#import "DCIncomePayRecordsViewController.h"
#import "DCTopUpCoinViewController.h"
#import "DCIntroduceCoinViewController.h"
#import "DCWithDrawViewController.h"
#import "DCOneButtonAlertView.h"
#import "DCTwoButtonAlertView.h"
#import "DCPopupView.h"

@interface DCWalletViewController ()<UITableViewDataSource, UITableViewDelegate, MyOrderRefreshDelegate, DCOneButtonAlertViewDelegate, DCTwoButtonAlertViewDelegate, DCPopupViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *walletTableView;
@property (weak, nonatomic) IBOutlet UILabel *coinNum;
@property (strong, nonatomic) DCPopupView *popUpView;

@end

@implementation DCWalletViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:.9 blue:.9 alpha:1];
    
    self.walletTableView.dataSource = self;
    self.walletTableView.delegate = self;
    self.walletTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(successForRecharge) name:@"DCRechargeCoinSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failForRecharge) name:@"DCRechargeCoinFail" object:nil];
    
//    self.resultView = [[HSSYWalletRechargeResultView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    [[UIApplication sharedApplication].keyWindow addSubview:self.resultView];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    MBProgressHUD *myHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    myHud.labelText = @"正在加载充电币";
    myHud.removeFromSuperViewOnHide = YES;
    
    [DCSiteApi getChargeCoinInfoWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if ([webResponse isSuccess]) {
            self.coinNum.text = [NSString stringWithFormat:@"%.2f", [[webResponse.result objectForKey:@"remain"] doubleValue]];
            [myHud hide:YES];
        }
        else{
            myHud.labelText = @"充电币加载失败";
            [myHud hide:YES afterDelay:1];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotification
- (void)successForRecharge{
    DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypePayForWithdraw_Success];
    view.delegate = self;
    self.popUpView = [DCPopupView popUpWithTitle:@"支付" contentView:view withController:self];
}

- (void)failForRecharge{
    DCTwoButtonAlertView *view = [DCTwoButtonAlertView viewWithAlertType:DCTwoButtonAlertTypePayFault];
    view.delegate = self;
    self.popUpView = [DCPopupView popUpWithTitle:@"支付" contentView:view withController:self];
}

#pragma mark - DCOneButtonAlertViewDelegate
- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    [self.popUpView dismiss];
}

#pragma mark - DCTwoButtonAlertViewDelegate
- (void)clickTheLeftButton:(DCTwoButtonAlertType)type {
    [self.popUpView dismiss];
}
- (void)clickTheRightButton:(DCTwoButtonAlertType)type {
    [self.popUpView dismiss];
}

#pragma mark - PopUpViewDelegate
- (void)popUpViewDismiss:(DCPopupView *)view {
    [view dismiss];
}

- (void)otherWay{
//    [self.resultView removeFromSuperview];
    DCTopUpCoinViewController *topUpVC = [DCTopUpCoinViewController storyboardInstantiate];
    [self.navigationController pushViewController:topUpVC animated:YES];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DCIncomePayRecordsViewController *recordsVC = [DCIncomePayRecordsViewController storyboardInstantiate];
    [self.navigationController pushViewController:recordsVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"DCWalletCell";
    DCWalletCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell) {
        cell = [[DCWalletCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

#pragma mark - 点击立即使用按钮
- (IBAction)useCoin {
    DCWithDrawViewController *vc = [DCWithDrawViewController storyboardInstantiate];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - MyOrderRefreshDelegate
- (void)myOrderRefresh:(id)sender {
}

#pragma mark - 点击充值按钮
- (IBAction)topUp {
    DCTopUpCoinViewController *topUpVC = [DCTopUpCoinViewController storyboardInstantiate];
    [self.navigationController pushViewController:topUpVC animated:YES];
}

#pragma mark - 如何使用充电币
- (IBAction)introduceCoin {
    DCIntroduceCoinViewController *introVC = [DCIntroduceCoinViewController storyboardInstantiate];
    [self.navigationController pushViewController:introVC animated:YES];
}

@end

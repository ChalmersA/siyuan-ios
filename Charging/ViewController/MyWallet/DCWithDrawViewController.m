//
//  DCWithDrawViewController.m
//  Charging
//
//  Created by kufufu on 16/5/13.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCWithDrawViewController.h"
#import "DCPopupView.h"
#import "DCWithDrawPopupView.h"
#import "DCTwoButtonAlertView.h"
#import "DCWithDrawSuccessPopupView.h"
#import "DCCoinRecord.h"

@interface DCWithDrawViewController ()<DCWithDrawPopupViewDelegate, DCTwoButtonAlertViewDelegate, DCWithDrawSuccessPopupViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *zfbAccountTextField;
@property (weak, nonatomic) IBOutlet UITextField *coinsTextField;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *allBalanceButton;

@property (assign, nonatomic) double costCoin;

@property (strong, nonatomic) DCPopupView *popUpView;


@end

@implementation DCWithDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self requestChargeCoins];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestChargeCoins {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DCSiteApi getChargeCoinInfoWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        [hud hide:YES];
        self.costCoin = [[webResponse.result objectForKey:@"remain"] doubleValue];
        self.balanceLabel.text = [NSString stringWithFormat:@"%0.2f", self.costCoin];
    }];
}

- (IBAction)allBalanceButton:(id)sender {
    self.coinsTextField.text = self.balanceLabel.text;
}

- (IBAction)nextStepButton:(id)sender {
    if (!(self.zfbAccountTextField.text.length > 0) || [NSString isStringContainsEmoji:self.zfbAccountTextField.text]) {
        [self showHUDText:@"请输入正确的支付宝账号"];
        return;
    }
    
    double first = [self.balanceLabel.text doubleValue];
    double second = [self.coinsTextField.text doubleValue];
    BOOL isBiger = second > first;
    if (!(self.coinsTextField.text.length > 0)) {
        [self showHUDText:@"请输入提现金额"];
        return;
    }
    if (isBiger) {
        [self showHUDText:@"输入金额数不能比余额高"];
        return;
    }
    
    DCWithDrawPopupView *view = [DCWithDrawPopupView viewWithWithChargeCoins:self.coinsTextField.text];
    view.delegate = self;
    self.popUpView = [DCPopupView popUpWithTitle:@"提现充电币" contentView:view];
}

#pragma mark - DCWithDrawPopupViewDelegate
- (void)clickTheConfirmButton:(NSString *)password {
    [DCSiteApi postDrawTheCashWithUserId:[DCApp sharedApp].user.userId costCoin:self.costCoin password:password completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self.popUpView dismiss];
            
            DCTwoButtonAlertView *view = [DCTwoButtonAlertView viewWithAlertType:DCTwoButtonAlertTypePasswordError];
            view.delegate = self;
            self.popUpView = [DCPopupView popUpWithTitle:@"密码错误" contentView:view withController:self];
            return;
        }
        
        DCCoinRecord *coinRecord = [[DCCoinRecord alloc] initCoinRecordWithDict:webResponse.result];
        DCWithDrawSuccessPopupView *view = [DCWithDrawSuccessPopupView viewWithWithChargeCoins:[NSString stringWithFormat:@"%0.2f",coinRecord.coin] withAccount:coinRecord.acount];
        self.popUpView = [DCPopupView popUpWithTitle:@"提现" contentView:view withController:self];
    }];
}

#pragma mark - DCWithDrawSuccessPopupViewDelegate
- (void)confirmButton {
    [self.popUpView dismiss];
}

#pragma mark - DCTwoButtonAlertViewDelegate
- (void)clickTheLeftButton:(DCTwoButtonAlertType)type {
    [self.popUpView dismiss];
    
    DCWithDrawPopupView *view = [DCWithDrawPopupView viewWithWithChargeCoins:self.coinsTextField.text];
    view.delegate = self;
    self.popUpView = [DCPopupView popUpWithTitle:@"提现充电币" contentView:view];
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

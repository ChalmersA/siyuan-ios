//
//  DCTopUpCoinViewController.m
//  Charging
//
//  Created by Pp on 15/12/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCTopUpCoinViewController.h"
#import "DCTopUpCell.h"
#import "DCPayWayModel.h"
#import "BeeCloud.h"
#import "DCBeeCloudPaymentParams.h"
#import "WCCardTopUpView.h"

@interface DCTopUpCoinViewController ()<UITableViewDelegate, UITableViewDataSource, BeeCloudDelegate, UITextFieldDelegate,WCCardTopUpViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *topUpTF;//金额输入框
@property (weak, nonatomic) IBOutlet UITableView *topUpTab;
@property (strong, nonatomic) NSArray *dataArray;
@property (assign, nonatomic) CGFloat money;
@property (assign, nonatomic) NSInteger chosenItem;
@property (strong, nonatomic) DCBeeCloudPaymentParams *payment;

@end

@implementation DCTopUpCoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    
    self.topUpTab.delegate = self;
    self.topUpTab.dataSource = self;
    self.topUpTab.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [BeeCloud setBeeCloudDelegate:self];
    
    self.chosenItem = 0;
    
    self.topUpTF.delegate = self;
}

- (CGFloat)money{
    return [self.topUpTF.text floatValue];
}

#pragma mark - 确定
- (IBAction)clickPayButton {
    if (self.money == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入充值金额";
        [hud hide:YES afterDelay:2];
        return;
    }
    if (self.money >= 10000) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"最大金额不得超过10000" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    //检测金额
    if (self.money < 0.01) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入正确的充值金额";
        [hud hide:YES afterDelay:2];
        return;
    }

    DCPayWayModel *item = self.dataArray[self.chosenItem];
    if (item) {
        if ([item.text isEqualToString:@"支付宝"]) {
            MBProgressHUD *hud = [self showHUDIndicator];
            [DCSiteApi postRechargeWithUserId:[DCApp sharedApp].user.userId rechargeCoins:self.money completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    if (webResponse.message) {
                        hud.mode = MBProgressHUDModeText;
                        hud.detailsLabelFont = hud.labelFont;
                        hud.detailsLabelText = webResponse.message;
                        [hud hide:YES afterDelay:3];
                    }
                    else {
                        [self hideHUD:hud withText:@"获取支付信息失败"];
                    }
                    return;
                }
                self.payment = [[DCBeeCloudPaymentParams alloc] initWithDict:webResponse.result];
                if ([self.payment isAvailable]) {
                    [self beeCloudAliPay:self.payment];
                    [hud hide:YES];
                }
                else {
                    [self hideHUD:hud withText:@"支付信息无效"];
                }
            }];
        }
        else if ([item.text isEqualToString:@"微信支付"]){
            MBProgressHUD *hud = [self showHUDIndicator];
            [DCSiteApi postRechargeWithUserId:[DCApp sharedApp].user.userId rechargeCoins:self.money completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    if (webResponse.message) {
                        hud.mode = MBProgressHUDModeText;
                        hud.detailsLabelFont = hud.labelFont;
                        hud.detailsLabelText = webResponse.message;
                        [hud hide:YES afterDelay:3];
                    }
                    else {
                        [self hideHUD:hud withText:@"获取支付信息失败"];
                    }
                    return;
                }
                self.payment = [[DCBeeCloudPaymentParams alloc] initBeeCloudPaymentParamsWithDict:webResponse.result];
                if ([self.payment isAvailable]) {
                    [self beeCloudAliPay:self.payment];
                    [hud hide:YES];
                }
                else {
                    [self hideHUD:hud withText:@"支付信息无效"];
                }
            }];
        }
    }
}

- (void)beeCloudAliPay:(DCBeeCloudPaymentParams *)payment{
    DCPayWayModel *item = self.dataArray[self.chosenItem];
    if (item) {
        if ([item.text isEqualToString:@"支付宝"]) {
            [self doPay:PayChannelAliApp];
        }
        else if ([item.text isEqualToString:@"微信支付"]){
            [self doPay:PayChannelWxApp];
        }
    }
}


#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp
{
    //支付响应事件类型，包含微信、支付宝、银联、百度
    BCPayResp *tempResp = (BCPayResp *)resp;
    if (tempResp.resultCode == 0) {
        [self.navigationController popViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DCRechargeCoinSuccess" object:self];
        
    } else {
        if ([tempResp.resultMsg isEqualToString:@"支付取消"]) {
            [self showAlertView:[NSString stringWithFormat:@"取消充值"]];
        }
        else{
            [self.navigationController popViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DCRechargeCoinFail" object:self];
        }
    }
}

- (void)showAlertView:(NSString *)msg {
    // 支付失败或者取消支付 解锁订单号
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)doPay:(PayChannel)channel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
    
    BCPayReq *payReq = [[BCPayReq alloc] init];
    
//    payReq.channel = channel;
//    payReq.title = @"哈哈";
//    payReq.totalFee = @"1";
//    payReq.billNo = @"adfa123412aa3";
//    payReq.scheme = @"zhifubaoPay";
//    payReq.billTimeOut = 300;
//    payReq.viewController = self;
//    payReq.optional = dict;
    
    payReq.channel = channel;
    payReq.title = self.payment.billTitle;
    payReq.totalFee = [NSString stringWithFormat:@"%@", self.payment.billRemainFee];
    payReq.billNo = self.payment.billNum;
    payReq.scheme = @"sychargingzhifubaopay";
    payReq.billTimeOut = 300;
    payReq.viewController = self;
    payReq.optional = dict;
    [BeeCloud sendBCReq:payReq];
}

#pragma mark - Baidu Delegate
//- (void)BDWalletPayResultWithCode:(int)statusCode payDesc:(NSString *)payDescs {
//    NSString *status = @"";
//    switch (statusCode) {
//        case 0:
//            status = @"充值成功";
//            [self.navigationController popViewControllerAnimated:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DCRechargeCoinSuccess" object:self];
//            break;
//        case 1:
//            status = @"充值中";
//            [self.navigationController popViewControllerAnimated:NO];
//            [self showAlertView:status];
//            break;
//        case 2:
//            status = @"取消充值";
//            [self showAlertView:status];
//            break;
//        default:
//            [self.navigationController popViewControllerAnimated:NO];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"DCRechargeCoinFail" object:self];
//            break;
//    }
//}

#pragma mark - BDWalletSDKMainManagerDelegate
//- (void)logEventId:(NSString*)eventId eventDesc:(NSString*)eventDesc{
//}

#pragma mark - touchesBegan
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.topUpTF endEditing:YES];
}

#pragma mark - dataArray
- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"paySelection.plist" ofType:nil];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        
        NSMutableArray *pArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            DCPayWayModel *payWay = [DCPayWayModel payWayWithDict:dict];
            [pArray addObject:payWay];
        }
        _dataArray = pArray;
    }
    return _dataArray;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *str = [textField.text stringByAppendingString:string];
    NSPredicate *keyPre = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", @"^0$|^[1-9]+\\d*$|^0\\.\\d{0,2}$|^[1-9]+\\d*\\.\\d{0,2}$"];
    return [keyPre evaluateWithObject:str];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    self.topUpTab.userInteractionEnabled = NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.topUpTab.userInteractionEnabled = YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.topUpTF endEditing:YES];
    for (int i = 0; i < self.dataArray.count; i++) {
        DCPayWayModel *model = self.dataArray[i];
        if (i == indexPath.row) {
            model.chosen = YES;
            self.chosenItem = i;
        }
        else{
            model.chosen = NO;
        }
    }
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"DCTopUpCell";
    DCTopUpCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (nil == cell){
        [tableView registerNib:[UINib nibWithNibName:@"DCTopUpCell" bundle:nil] forCellReuseIdentifier:ID];
        cell = [tableView dequeueReusableCellWithIdentifier:ID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DCPayWayModel *model = self.dataArray[indexPath.row];
    cell.payImage.image = [UIImage imageNamed:model.imageName];
    cell.payLabel.text = model.text;
    cell.payBut.selected = model.chosen;
    
    return cell;
}

-(void)cardTopUpViewClickWithtitle1:(NSString *)title1 title2:(NSString *)title2 selectIndex:(int)selectIndex{
    if (title1.length && title2.length) {
        
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

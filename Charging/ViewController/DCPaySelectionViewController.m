//
//  DCPaySelectionViewController.m
//  Charging
//
//  Created by xpg on 15/2/4.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPaySelectionViewController.h"
#import "DCOptionItem.h"
#import "DCPayWebViewController.h"
#import "BeeCloud.h"
#import "DCBeeCloudPaymentParams.h"
#import "DCUseCoinPayDoneInfo.h"
#import "DCColorButton.h"
#import "DCOneButtonAlertView.h"
#import "DCPopupView.h"

@interface DCPaySelectionViewController () <UITableViewDelegate, BeeCloudDelegate,  UINavigationControllerDelegate, DCPopupViewDelegate, DCOneButtonAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *useCoinBut;
@property (weak, nonatomic) IBOutlet UILabel *chargeCoinNum;
@property (weak, nonatomic) IBOutlet UILabel *payTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *PayLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *finalPayment;

@property (strong, nonatomic) DCOptionList *selectionList;
@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) DCBeeCloudPaymentParams *payParams;
@property (assign, nonatomic) double remain4Pay;
@property (assign, nonatomic) CGFloat finalMoney;// 还需支付
@property (strong, nonatomic) NSNumber *coinNum;// 充电币数
@property (strong, nonatomic) DCUseCoinPayDoneInfo *resultView;
@property (weak, nonatomic) IBOutlet DCColorButton *nextStepButton;

@property (strong, nonatomic) DCPopupView *popUpView;

@end

@implementation DCPaySelectionViewController

+ (instancetype)storyboardInstantiate {
    UIStoryboard *payStoryboard = [UIStoryboard storyboardWithName:@"Pay" bundle:nil];
    return [payStoryboard instantiateViewControllerWithIdentifier:@"DCPaySelectionViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    // Do any additional setup after loading the view.
    self.selectionList = [DCOptionList loadPaySelection];
    self.dataSource = [ArrayDataSource dataSourceWithItems:self.selectionList.items
                                            cellIdentifier:@"DCOptionCell"
                                        configureCellBlock:^(DCOptionCell *cell, DCOptionItem *item) {
                                            [cell configureForPayItem:item];
                                        }];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.navigationController.delegate = self;
    
    //BeeCloudDelegate
    [BeeCloud setBeeCloudDelegate:self];
    
    if (self.isReserverFee) {
        self.payTitleLabel.text = @"预约费用";
    }
    
    if (self.chargePrice == 0) {
        self.nextStepButton.enabled = NO;
        self.nextStepButton.selected = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PushPayWeb"]) {
        DCPayWebViewController *payWeb = [segue destinationViewController];
        payWeb.payment = sender;
    }
}

- (void)navigateBack:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - viewWillAppear
- (void)viewWillAppear:(BOOL)animated{
    //loadCoins
    [self getCoins];
}

#pragma mark - Fetch Coin
- (void)getCoins {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"正在加载充电币";
    
    [DCSiteApi getChargeCoinInfoWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if ([webResponse isSuccess]) {
            self.coinNum = [webResponse.result objectForKey:@"remain"];
            self.chargeCoinNum.text = [NSString stringWithFormat:@"%.2f 个", [self.coinNum floatValue]];
            [hud hide:YES];
        }
        else {
            hud.labelText = @"充电币加载失败";
            self.coinNum = 0;
            [hud hide:YES afterDelay:1];
        }
        [self showPrice];
    }];
}

#pragma mark - showPrice
- (void)showPrice {
    
    if ([self.coinNum doubleValue] == 0) {
        self.useCoinBut.selected = NO;
        self.useCoinBut.userInteractionEnabled = NO;
    }
    else{
        self.useCoinBut.selected = YES;
        self.useCoinBut.userInteractionEnabled = YES;
    }
    
    self.orderIdLabel.text = self.orderId;
    self.PayLabel.text = [NSString stringWithFormat:@"%.2f 元", self.chargePrice];
    self.finalMoney = self.chargePrice - [self.coinNum floatValue];
    if (self.finalMoney < 0.0001) {
        self.finalMoney = 0;
    }
    self.finalPayment.text = [NSString stringWithFormat:@"%.2f 元", self.finalMoney];
    if (self.finalMoney == 0) {
        [self.selectionList singleChooseNo];
        [self.tableView reloadData];
    }
}

#pragma mark - Action
- (IBAction)nextStep:(id)sender {
    DCOptionItem *item = [self.selectionList chosenItem];
    MBProgressHUD *hud = [self showHUDIndicator];

    if (item == nil && !self.useCoinBut.selected) {
        [self hideHUD:hud withText:@"请选择一种支付方式"];
        //            [self unlockChargeRecordIds];
        return;
    }
    
    NSNumber *costCoin = @(0);
    if (self.useCoinBut.isSelected) {
        costCoin = self.coinNum;
    }
    
    [DCSiteApi postPayWithUserId:[DCApp sharedApp].user.userId orderId:self.orderId costCoin:costCoin completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            if (webResponse.message) {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            }
            else{
                [self hideHUD:hud withText:@"获取支付信息失败"];
            }
            return;
        }
        
        //扣除指定数量的充电币后，剩余需要在线支付的金额 remain4Pay
        if ([webResponse.result objectForKey:@"remain4Pay"]) {
            self.remain4Pay = [[webResponse.result objectForKey:@"remain4Pay"] intValue];
        }
        
        if (self.remain4Pay == 0) {
            //纯充电币扣款 成功
//            [self hideHUD:hud withText:@"支付成功"];
            
            
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypePayForChargeFee_Success];

            view.delegate = self;
            self.popUpView = [DCPopupView popUpWithTitle:@"温馨提示" contentView:view withController:self];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
            
            if (self.payFinishBlock) {
                self.payFinishBlock(@{kPayFinishKeyCode:@(0)});
            }
        }
        else {
            [hud hide:YES];
            
            self.payParams = [[DCBeeCloudPaymentParams alloc] initBeeCloudPaymentParamsWithDict:[webResponse.result objectForKey:@"beeCloudPaymentParams"]];
            if ([item.text isEqualToString:@"支付宝"]) {
                if ([self.payParams isAvailable]) {
                    [self beeCloudPay:self.payParams];
                }
            }
            
            if ([item.text isEqualToString:@"微信支付"]) {
                if ([self.payParams isAvailable]) {
                    [self beeCloudPay:self.payParams];
                }
            }
            
            /* TODO:暂时把充电币支付成功的view不展示
             if (self.useCoinBut.isSelected && self.coinNum > 0) {
                self.resultView = [[DCUseCoinPayDoneInfo alloc]initWithFrame:[UIScreen mainScreen].bounds];
                [[UIApplication sharedApplication].keyWindow addSubview:self.resultView];
                [self performSelector:@selector(resultViewSetHidden) withObject:webResponse afterDelay:2];
            }
            if ([item.text isEqualToString:@"支付宝"]) {
                self.payParams = [[DCBeeCloudPaymentParams alloc] initWithDict:webResponse.result];
                if ([self.payParams isAvailable]) {
                    [self beeCloudAliPay:self.payParams];
                    [hud hide:YES];
                }
                else {
                    [self hideHUD:hud withText:@"支付信息无效"];
                }
            }*/
        }

    }];
}

//- (void)resultViewSetHidden{
//    [self.resultView removeFromSuperview];
//}

- (void)beeCloudPay:(DCBeeCloudPaymentParams *)payment{
    DCOptionItem* item = [self.selectionList chosenItem];
    if (item) {
        if ([item.text isEqualToString:@"支付宝"]) {
            [self doPay:PayChannelAliApp];
        }
        else if ([item.text isEqualToString:@"微信支付"]){
            [self doPay:PayChannelWxApp];
        }
    }
}


- (void)doPay:(PayChannel)channel {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value",@"key", nil];
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

#pragma mark - BeeCloudDelegate
- (void)onBeeCloudResp:(BCBaseResp *)resp
{
    if (resp.type == BCObjsTypePayResp) {
        //支付响应事件类型，包含微信、支付宝、银联、百度
        BCPayResp *tempResp = (BCPayResp *)resp;
        if (tempResp.resultCode == 0) {
            
            //支付成功
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
            [self showHUDText:@"支付成功" completion:^{
                [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
                if (self.payFinishBlock) {
                    self.payFinishBlock(@{kPayFinishKeyCode:@(0)});
                }
            }];
        } else {
            //支付取消或者支付失败
            [self showAlertView:[NSString stringWithFormat:@"%@",tempResp.resultMsg]];
        }
    }
}

//- (void)unlockChargeRecordIds
//{
//    [DCSiteApi getcancleChargeRecordIds:self.chargeRecordIds completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//    }];
//}

- (void)showAlertView:(NSString *)msg {
    // 支付失败或者取消支付 解锁订单号
    // 解锁支付状态
    [DCSiteApi postOrderIdForUnlockOrder:self.orderId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        /**
         *  TODO: Don't do any action
         **/
    }];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UITableViewDelegate
//- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row) {
//        [self showHUDText:@"本支付方式暂未开通，敬请期待"];
//        return nil;
//    }
//    return indexPath;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.finalMoney > 0) {
        [self.selectionList singleChooseIndex:indexPath.row];
    self.finalPayment.text = [NSString stringWithFormat:@"￥ %.2f", self.chargePrice];
        [tableView reloadData];
    self.useCoinBut.selected = NO;
//    }
}

#pragma mark - AliSDK
//- (void)payBySDK:(PaymentObject*)payment {
//    //应用注册scheme,在Info.plist定义URL types
//    NSString *appScheme = @"alisdkdemo";
////    [payment resign];
//    //将签名成功字符串格式化为订单字符串,请严格按照该格式
//    if ([payment isAvailable] && payment.signedOrderStr != nil) {
//        [[AlipaySDK defaultService] payOrder:payment.signedOrderStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            NSLog(@"reslut = %@",resultDic);
//            
//
//            
////            reslut = {
////                memo = "";
////                result = "partner=\"2088911205944812\"&seller_id=\"2088911205944812\"&out_trade_no=\"1014447277668487264\"&subject=\"charging\"&body=\"\U8be5\U6d4b\U8bd5\U5546\U54c1\U7684\U8be6\U7ec6\U63cf\U8ff0\"&total_fee=\"0.01\"&notify_url=\"http://222.128.77.155:3152/charge/pay/notify\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&return_url=\"m.alipay.com\"&success=\"true\"&sign_type=\"RSA\"&sign=\"bJN+kzog4qgMM7Nxe12JovkKhLj/jnuqv7EWiYIxX7BdOJ7+ndCkAVDHhJmcMtvkQqxLy0dE8JWP5p3VK86G9LEYVEqNMch8No6wM+kFx2YSYiAEuH1yGfwOClUEn+wESJshw1bBvTVMLNRoASUpAfaseT6HNvBgbqNth+XbBOo=\"";
////                resultStatus = 9000;
////            }
//            
//            
//            //TODO: process with the result of payment
//            id resultStatus = [resultDic objectForKey:@"resultStatus"];
//            if ( ([resultStatus isKindOfClass:[NSNumber class]] && [resultStatus isEqualToNumber:@9000])
//                || ([resultStatus isKindOfClass:[NSString class]] && [resultStatus isEqualToString:@"9000"])) {
//                // pay successfully
//                
//            }
//            else {
//                
//            }
//            
//            // jump back to order list and refresh it
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
//                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//                if (self.payFinishBlock) {
//                    self.payFinishBlock(@{kPayFinishKeyCode:@([resultStatus isEqualToNumber:@9000])});
//                }
//            });
//        }];
//    }
//    // TODO: what is 'else'??
//}

//#pragma mark - 绑定百度钱包完成
//- (void)baiduPayBingingSuccessBack
//{
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
//    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
//    if (self.payFinishBlock) {
//        self.payFinishBlock(@{kPayFinishKeyCode:@(0)});
//    }
//}
//
//#pragma mark - 绑定百度钱包失败
//- (void)baiduPayBingingFailureBack
//{
//    [self unlockChargeRecordIds];
//}
//
//#pragma mark - 获取百度钱包代扣Url
//- (NSString *)getBaiduUrl:(NSString *)secret
//{
//    return [BaiduPayUrl stringByAppendingString:secret];
//}

#pragma mark - DCPopUpViewDelegate
- (void)popUpViewDismiss:(DCPopupView *)view {
    [view dismiss];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    [self.popUpView dismiss];
    [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - userCoinButSelect
- (IBAction)userCoinButSelect {
    self.useCoinBut.selected = !self.useCoinBut.isSelected;
    if (self.useCoinBut.isSelected) {
        self.finalMoney = self.chargePrice - [self.coinNum floatValue];
        if (self.finalMoney <= 0) {
            self.finalMoney = 0;
            [self.selectionList singleChooseNo];
        }
        self.finalPayment.text = [NSString stringWithFormat:@"￥ %.2f", self.finalMoney];
    }
    else{
        self.finalMoney = self.chargePrice;
        self.finalPayment.text = [NSString stringWithFormat:@"￥ %.2f", self.finalMoney];
        [self.selectionList singleChooseIndex:0];
    }
    if (self.finalMoney == 0) {
        [self.selectionList singleChooseNo];
    }

    [self.tableView reloadData];
}

@end

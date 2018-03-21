//
//  DCChargeDoneViewController.m
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCChargeDoneViewController.h"
#import "UIBarButtonItem+HSSYExtensions.h"
#import "DCOneButtonAlertView.h"
#import "DCPopupView.h"

NSString * const ChargingDoneCell = @"ChargingInformationCell";

@interface DCChargeDoneViewController ()<DCPopupViewDelegate, DCOneButtonAlertViewDelegate>
{
    int requestOrderCount;
}

@property (weak, nonatomic) DCPopupView *popUpView;

@property(nonatomic) BOOL isTenant; //是否租户
@property(nonatomic, retain) DCOrder* order;
@property(nonatomic) IBOutlet UILabel *consumeElectricityLabel;

@property(nonatomic, strong) NSArray * tenantArray;
@property(nonatomic, strong) NSArray * userArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UIView *electricityBackgroupView;//电量view
//@property (weak, nonatomic) IBOutlet UIView *buttonBackgroupView;

@property (weak, nonatomic) IBOutlet UIView *warmView;
@property (weak, nonatomic) IBOutlet UIButton *warmConfirmButton;

@property (strong, nonatomic) NSTimer *requestOrderStateTimer;              //获取order
@property (strong, nonatomic) NSURLSessionDataTask *requestGprsOrderTask; //获取GPRS桩的充电记录Task

@property (weak, nonatomic) MBProgressHUD *hud;
@end

@implementation DCChargeDoneViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.electricityBackgroupView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.confirmButton setCornerRadius:3];
    self.confirmButton.backgroundColor = [UIColor paletteButtonRedColor];
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarItemWithTarget:self action:@selector(popViewControllerAnimated)];
    
    self.warmView.hidden = YES;
    self.tableView.hidden = NO;
    self.confirmButton.hidden = NO;
    
    [self.tableView reloadData];
}

#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    requestOrderCount = 0;
    if (self.requestOrderStateTimer == nil) {
        self.requestOrderStateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(requestOrderDetail) userInfo:nil repeats:YES];
        [self.requestOrderStateTimer fire];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.popUpView dismiss];
}

- (void)requestOrderDetail {
    [self.requestGprsOrderTask cancel];
    
    NSLog(@"~~~~~~requestOrderCount:%d", requestOrderCount);
    
    typeof(self) __weak weakSelf = self;
    self.requestGprsOrderTask = [DCSiteApi getOrderInfo:self.orderId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        typeof(weakSelf) __strong strongSelf = weakSelf;
        requestOrderCount++;
        if (![webResponse isSuccess]) {
            [strongSelf hideHUD:self.hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            [self stopRequestOrderState];
            return;
        }
        
        strongSelf.order = [[DCOrder alloc] initOrderWithDict:[webResponse.result objectForKey:@"order"]];
        if (self.order.orderState == DCOrderStateNotPayChargefee || self.order.orderState == DCOrderStateNotEvaluate) {
            [self.hud hide:YES];
            [self stopRequestOrderState];
            if (strongSelf.order) {
                [self.consumeElectricityLabel setText:[NSString stringWithFormat:@"%0.2f", self.order.chargeEnergy]];
                
                if (self.order.chargeTotalFee > 0) {
                    [self.confirmButton setTitle:@"支付费用" forState:UIControlStateNormal];
                } else {
                    [self.confirmButton setTitle:@"确定" forState:UIControlStateNormal];
                }
                
                [self.tableView reloadData];
                
                if ([self.delegate respondsToSelector:@selector(chargeDoneViewShow)]) {
                    [self.delegate chargeDoneViewShow];
                }
            }
        }
        else {
            if (requestOrderCount > 6) {
                [self.hud hide:YES];
                [self stopRequestOrderState];
                self.tableView.hidden = YES;
                self.confirmButton.hidden = YES;
                self.warmView.hidden = NO;
                if ([self.delegate respondsToSelector:@selector(chargeDoneViewShow)]) {
                    [self.delegate chargeDoneViewShow];
                }
                return;
            }
        }
    }];
}

- (void)stopRequestOrderState {
    [self.requestOrderStateTimer invalidate];
    self.requestOrderStateTimer = nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 10-1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [tableView setSeparatorInset:UIEdgeInsetsZero];
    
    DCChargingDoneCell *cell = [tableView dequeueReusableCellWithIdentifier:ChargingDoneCell forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == 0) {
        cell.titleLable.text = @"交易单号";
        cell.detailTitleLabel.text = self.order.orderId;
        
    }else if (indexPath.row == 1){
        cell.titleLable.text = @"电桩名称";
        cell.detailTitleLabel.text = [NSString stringWithFormat:@"%@ 枪%ld",self.order.pileName, self.order.chargePortIndex];
    
    } else if (indexPath.row == 2) {
        cell.titleLable.text = @"充电时段";
        NSString *startTime = [[NSDateFormatter reserveEndTimeFormatter] stringFromDate:self.order.chargeStartTime];
        NSString *endTime = [[NSDateFormatter reserveEndTimeFormatter] stringFromDate:self.order.chargeEndTime];
        cell.detailTitleLabel.text = [[startTime stringByAppendingString:@"-"] stringByAppendingString:endTime];
        
    } else if (indexPath.row == 3) {
        cell.titleLable.text = @"充电时长";
        cell.detailTitleLabel.text = [NSDate timeLengthFromStartTime:self.order.chargeStartTime toEndTime:self.order.chargeEndTime];
        
    }
//    else if (indexPath.row == 4){
//        cell.titleLable.text = @"充电单价";
//        cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元/kWh", self.order.serviceFee];
//        
//    }
    else if (indexPath.row == 4){
        cell.titleLable.hidden = YES;
        cell.detailTitleLabel.hidden = YES;
        cell.lineImageView.hidden = NO;
        
    }else if (indexPath.row == 5){
        cell.titleLable.text = @"充电金额";
        cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元", self.order.chargeTotalFee];
        
    }else if (indexPath.row == 6){
        cell.titleLable.text = @"预约费用";//(充电后返还)
        if (self.order.onTimeChargeRet == DCChargeRefundTypeNeed) {
            NSString *str = [NSString stringWithFormat:@"(充电后返还) %.2f 元", self.order.reserveFee];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor paletteFontDarkGrayColor] range:NSMakeRange(0, 7)];
            cell.detailTitleLabel.attributedText = attrStr;
        } else{
            cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元", self.order.reserveFee];
        }
        
    }else if (indexPath.row == 7) {
        cell.titleLable.hidden = YES;
        cell.detailTitleLabel.hidden = YES;
        cell.lineImageView.hidden = NO;
        
    }else if (indexPath.row == 8){
        cell.titleLable.text = @"实际支付";
        [self setFeeLabel:cell.detailTitleLabel withFee:self.order.chargeTotalFee];
    }
//    else if (indexPath.row == 4){
//        cell.titleLable.text = @"充电单价";
//        cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元/kWh", self.order.serviceFee];
//        
//    }else if (indexPath.row == 5){
//        cell.titleLable.hidden = YES;
//        cell.detailTitleLabel.hidden = YES;
//        cell.lineImageView.hidden = NO;
//        
//    }else if (indexPath.row == 6){
//        cell.titleLable.text = @"充电金额";
//        cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元", self.order.chargeTotalFee];
//        
//    }else if (indexPath.row == 7){
//        cell.titleLable.text = @"预约费用";//(充电后返还)
//        if (self.order.onTimeChargeRet == DCChargeRefundTypeNeed) {
//            NSString *str = [NSString stringWithFormat:@"(充电后返还) %.2f 元", self.order.reserveFee];
//            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
//            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor paletteFontDarkGrayColor] range:NSMakeRange(0, 7)];
//            cell.detailTitleLabel.attributedText = attrStr;
//        } else{
//            cell.detailTitleLabel.text = [NSString stringWithFormat:@"%.2f 元", self.order.reserveFee];
//        }
//    
//    }else if (indexPath.row == 8) {
//        cell.titleLable.hidden = YES;
//        cell.detailTitleLabel.hidden = YES;
//        cell.lineImageView.hidden = NO;
//        
//    }else if (indexPath.row == 9){
//        cell.titleLable.text = @"实际支付";
//        [self setFeeLabel:cell.detailTitleLabel withFee:self.order.chargeTotalFee];
//    }
    return cell;
    
}
-(void)setFeeLabel:(UILabel*)label withFee:(double)fee {
    NSString *defaultStr = @"";
    NSString *feePrefix = @"";
    
    // define colors
//    UIColor *normalColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
    UIColor *numberColor = [UIColor palettePriceRedColor];

    // define font
    UIFont *normalFont = [UIFont systemFontOfSize:16];
    UIFont *numberFont = [UIFont systemFontOfSize:27];
    // define attribute
    NSDictionary *normalAttribs = @{NSForegroundColorAttributeName:numberColor, NSFontAttributeName:normalFont};
    NSDictionary *numberAttribs = @{NSForegroundColorAttributeName:numberColor, NSFontAttributeName:numberFont};
    
    if (fee >= 0) {
        
        NSMutableArray *strArr = [NSMutableArray array];
        NSMutableArray *attriArr = [NSMutableArray array];
        
        [strArr addObject:feePrefix];
        [attriArr addObject:normalAttribs];
        
        [strArr addObject:[NSString stringWithFormat:@" %.2f元", fee]];
        [attriArr addObject:numberAttribs];
        
        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
    }
    else {
        [self joidStrings:@[defaultStr] withAttributes:@[normalAttribs] tolabel:label];
    }
}

- (void)joidStrings:(NSArray*)strArr withAttributes:(NSArray*)attrArr tolabel:(UILabel*)targeLabel {
    if ([strArr count] != [attrArr count]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i< strArr.count; i++) {
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strArr[i] attributes:attrArr[i]];
        [attributedText appendAttributedString:attrStr];
    }
    
    if ([targeLabel respondsToSelector:@selector(setAttributedText:)]) {
        targeLabel.attributedText = attributedText;
    }
    else {
        [targeLabel setText:attributedText.string];
    }
}

#pragma mark - 充电完成确认
- (IBAction)confirmRecord:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.currentTitle isEqualToString:@"确定"]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    [self payWithOrder:self.order showFinishBlock:^{
        //把充电页面的数据清空
        
    } PayFinishBlock:^(NSDictionary *resultDic) {
        // deal with  payment finish
        if (resultDic && [resultDic objectForKey:kPayFinishKeyCode]) {
            NSNumber *codeNum = [resultDic objectForKey:kPayFinishKeyCode];
            if ([codeNum isEqualToNumber:@(0)]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }
    }];
}
- (IBAction)clickWarmConfirmButton:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 页面返回
- (void)popViewControllerAnimated {
    if (self.order.orderState == DCOrderStateNotPayChargefee) {
        DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeNotPay];
        view.delegate = self;
        self.popUpView = [DCPopupView popUpWithTitle:@"温馨提示" contentView:view withController:self];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark DCOneButtonAlertViewDelegate
- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    [self.popUpView dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark PopupViewDelegate
- (void)popUpViewDismiss:(DCPopupView *)view {
    [view dismiss];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

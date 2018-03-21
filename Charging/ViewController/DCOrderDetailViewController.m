//
//  DCOrderDetailViewController.m
//  Charging
//
//  Created by kufufu on 16/4/21.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCOrderDetailViewController.h"
#import "DCOrderDetailSectionHeader.h"
#import "DCOrderDetailItemInfoCell.h"
#import "DCOrderDetailInfoItem.h"
#import "DCChargeEditableCell.h"
#import "DCSiteApi.h"
#import "DCSearchViewController.h"
#import "DCPoleMapAnnotation.h"
#import "DCTwoButtonView.h"
#import "DCPopupView.h"
#import "DCArticle.h"

NSString * const SegueIdPushToPoleInMap = @"PushToPoleInMapSegue";

@interface DCOrderDetailViewController () <UITableViewDelegate, UITableViewDataSource, DCTwoButtonViewDelegate, DCPopupViewDelegate, DCPileEvaluationViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *oneButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *payButton;

@property (weak, nonatomic) IBOutlet UIView *oneButtonView;
@property (weak, nonatomic) IBOutlet UIView *twoButtonView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) DCOrder *order;
@property (strong, nonatomic) DCArticle *article;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger remainTime;

@property (strong, nonatomic) DCPopupView *popUpView;

@end

@implementation DCOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestOrderByOrderId];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DCOrderDetailItemInfoCell" bundle:nil] forCellReuseIdentifier:@"DCOrderDetailItemInfoCell"];
    [self.tableView reloadData];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(<#selector#>) name:NOTIFICATION_ORDER_UPDATE object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigateBack:(id)sender {
    if (self.presentingViewController != nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [super navigateBack:sender];
    }
}

- (void)requestOrderByOrderId {
    typeof(self) __weak weakSelf = self;
    [DCSiteApi getOrderInfo:self.orderId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [weakSelf hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        weakSelf.order = [[DCOrder alloc] initOrderWithDict:[webResponse.result objectForKey:@"order"]];
        weakSelf.order.hasArticle = false;
        if ([[webResponse.result objectForKey:@"article"] dictionaryObject]) {
            weakSelf.article = [[DCArticle alloc] initWithDict:[webResponse.result objectForKey:@"article"]];
            weakSelf.order.hasArticle = true;
        }
        self.remainTime = weakSelf.order.remainTime4ReserveFee / 1000;
        if (weakSelf.order.remainTime4ReserveFee > 1000) {
            [self timerStart];
        }
        
        if (weakSelf.order.orderState == DCOrderStateNotPayBookfee && weakSelf.order.remainTime4ReserveFee < 1000) {
            weakSelf.order.orderState = DCOrderStateOvevtimeToPayBookfee;
        }
        
        [self setBottomViewButton:self.order.orderState];
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.order orderForState:self.order.orderState].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [[self.order orderForState:self.order.orderState] objectAtIndex:section];
    return array.count-1-1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *sectionArray = [[self.order orderForState:self.order.orderState] objectAtIndex:indexPath.section];
    DCOrderDetailInfoItem *item = [sectionArray objectAtIndex:indexPath.row + 1];
    
    DCOrderDetailItemInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCOrderDetailItemInfoCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCOrderDetailItemInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"DCOrderDetailItemInfoCell"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.itemContentLabel.hidden = NO;
    cell.starView.hidden = YES;
    
    cell.itemTitleLabel.text = item.title;
    cell.itemContentLabel.text = item.content;
    
    if ([cell.itemTitleLabel.text isEqualToString:@"预约费用"] ||
        [cell.itemTitleLabel.text isEqualToString:@"充电金额"]) {
        cell.itemContentLabel.attributedText = [self setDifferentColerWithString:item.content type:ParamTypePrice];
    }
    
//    if ([cell.itemTitleLabel.text isEqualToString:@"充电单价"]) {
//        cell.itemContentLabel.text = [item.content stringByAppendingString:@" 元/kWh"];
//    }
    
    if ([cell.itemTitleLabel.text isEqualToString:@"充电电量"]) {
        cell.itemContentLabel.attributedText = [self setDifferentColerWithString:item.content type:ParamTypePower];
    }
    
    if (self.order.orderState == DCOrderStateExceptionWithNotChargeRecord ||
        self.order.orderState == DCOrderStateExceptionWithChargeData ||
        self.order.orderState == DCOrderStateExceptionWithStartChargeFail) {
        if ([cell.itemTitleLabel.text isEqualToString:@"结束时间"] ||
            [cell.itemTitleLabel.text isEqualToString:@"充电时长"] ||
            [cell.itemTitleLabel.text isEqualToString:@"充电电量"] ||
            [cell.itemTitleLabel.text isEqualToString:@"充电金额"] ||
            [cell.itemTitleLabel.text isEqualToString:@"异常状态"]) {
            cell.itemContentLabel.attributedText = [self setDifferentColerWithString:item.content type:ParamTypeException];
        }
    }
    
    if ([cell.itemTitleLabel.text isEqualToString:@"评价时间"]) {
        cell.itemContentLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.article.createTime];
    }
    if ([cell.itemTitleLabel.text isEqualToString:@"评价星数"]) {
        cell.itemContentLabel.hidden = YES;
        cell.starView.hidden = NO;
        cell.starView.starRateView.scorePercent = [self.article.starScore doubleValue] / 5;
    }
    if ([cell.itemTitleLabel.text isEqualToString:@"评价内容"]) {
//        if (self.article.content.length > 0) {
            cell.itemContentLabel.text = self.article.content;
//        } else {
//            cell.itemContentLabel.text = @"该桩群的评论已被删除";
//        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DCOrderDetailSectionHeader *view = [DCOrderDetailSectionHeader loadView];
    
    NSArray *sectionArray = [[self.order orderForState:self.order.orderState] objectAtIndex:section];
    NSString *string = [sectionArray firstObject];
    [view imageViewForTitle:string];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 35;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static float defaultHeight = 35.0f;
    NSArray *sectionArray = [[self.order orderForState:self.order.orderState] objectAtIndex:indexPath.section];
    DCOrderDetailInfoItem *item = [sectionArray objectAtIndex:indexPath.row + 1];
    if ([item.title isEqualToString:@"评价内容"]) {
        CGFloat height = [self sizeForNoticeTitle:self.article.content font:[UIFont systemFontOfSize:17] width:([UIScreen mainScreen].bounds.size.width - 78 - 10 - 30)].height + 12;
        if (height > defaultHeight) {
            return height;
        }
    }
    return defaultHeight;
}

- (CGSize)sizeForNoticeTitle:(NSString*)text font:(UIFont*)font width:(CGFloat)width{
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    
    CGSize textSize = CGSizeZero;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin |
    NSStringDrawingUsesFontLeading;
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    
    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
    
    CGRect rect = [text boundingRectWithSize:maxSize
                                     options:opts
                                  attributes:attributes
                                     context:nil];
    textSize = rect.size;
    
    return textSize;
}

- (IBAction)clickTheOneButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
        case DCOrderButtonTagNavi: {
            //跳转到地图
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [DCSiteApi getStationId:self.order.stationId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self hideHUD:hud withText:@"抱歉，获取该电桩经纬度位置未失败"];
                    return;
                }
                [hud hide:YES];
                DCStation *orderStation = [[DCStation alloc] initStationWithDict:webResponse.result];
                //跳转到地图
                [self.navigationController popViewControllerAnimated:YES];
                DCSearchViewController *searchVC = [DCApp sharedApp].rootTabBarController.viewControllers[DCTabIndexSearch];
                [searchVC setSearchStyle:DCSearchStyleMap];
                DCPoleMapAnnotation *annotation = [DCPoleMapAnnotation annotationWithStation:orderStation];
                annotation.isOrderStation = YES;
                [searchVC showPoleInfoViewForAnnotation:annotation];
                [DCApp sharedApp].rootTabBarController.selectedIndex = 1;
                [[DCApp sharedApp].rootTabBarController updateNavigationBar];
            }];
            break;
        }
            break;
            
        case DCOrderButtonTagReschedule: {
            DCStationDetailViewController *vc = [DCStationDetailViewController storyboardInstantiate];
            DCStation *station = [DCStation new];
            station.stationId = self.order.stationId;
            vc.selectStationInfo = station;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case DCOrderButtonTagJumpToCharingView: {
            //跳到充电页面
            [self.navigationController popToRootViewControllerAnimated:YES];
            [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
            [[DCApp sharedApp].rootTabBarController updateNavigationBar];
        }
            break;
            
        case DCOrderButtonTagContactOwner: {
            [[DCApp sharedApp] callPhone:@"4000220288" viewController:self];
        }
            break;
            
        case DCOrderButtonTagPayForCharge: {
            //跳到支付页面
            [self payWithOrder:self.order withFinishBlock:^(NSDictionary *resultDic) {
                if (resultDic && [resultDic objectForKey:kPayFinishKeyCode]) {
                    NSNumber *codeNum = [resultDic objectForKey:kPayFinishKeyCode];
                    if ([codeNum isEqualToNumber:@(0)]) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self requestOrderByOrderId];
                        });
                    }
                }
            }];
        }
            break;
            
        case DCOrderButtonTagEvaluate: {
            DCPileEvaluationViewController *vc = [DCPileEvaluationViewController storyboardInstantiate];
            vc.order = self.order;
            vc.stationId = self.order.stationId;
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - PileEvaluationViewController
- (void)pileDidEvaluated {
    [self requestOrderByOrderId];
}

#pragma mark - BottomTwoButton_Action
- (IBAction)clickTheCancelButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定要取消订单吗?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alertView show];
    [alertView setClickedButtonHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [DCSiteApi postOrderIdToCancelOrder:[DCApp sharedApp].user.userId orderId:self.order.orderId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                if (![webResponse isSuccess]) {
                    [self showHUDText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                    return;
                }
                
                [self showHUDText:@"取消订单成功" completion:^{
                    //            [self.navigationController popViewControllerAnimated:YES];
                    [self requestOrderByOrderId];
                }];
            }];
        }
    }];
}

- (void)clickTheForgetButton {
    [self.popUpView dismiss];
    [DCSiteApi postOrderIdToCancelOrder:[DCApp sharedApp].user.userId orderId:self.order.orderId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self showHUDText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [self showHUDText:@"取消订单成功" completion:^{
            //            [self.navigationController popViewControllerAnimated:YES];
            [self requestOrderByOrderId];
        }];
    }];
}
- (void)clickTheReturnButton {
    [self.popUpView dismiss];
}

- (void)popUpViewDismiss:(DCPopupView *)view {
    [view dismiss];
}

- (IBAction)clickThePayOrRebookButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"导航"]) {
        //跳转到地图
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [DCSiteApi getStationId:self.order.stationId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withText:@"抱歉，获取该电桩经纬度位置未失败"];
                return;
            }
            [hud hide:YES];
            DCStation *orderStation = [[DCStation alloc] initStationWithDict:webResponse.result];
            //跳转到地图
            [self.navigationController popToRootViewControllerAnimated:YES];
            DCSearchViewController *searchVC = [DCApp sharedApp].rootTabBarController.viewControllers[DCTabIndexSearch];
            [searchVC setSearchStyle:DCSearchStyleMap];
            DCPoleMapAnnotation *annotation = [DCPoleMapAnnotation annotationWithStation:orderStation];
            annotation.isOrderStation = YES;
            [searchVC showPoleInfoViewForAnnotation:annotation];
            [DCApp sharedApp].rootTabBarController.selectedIndex = 1;
            [[DCApp sharedApp].rootTabBarController updateNavigationBar];
        }];
        
    } else {
        //跳到支付页面
        [self payWithOrder:self.order withFinishBlock:^(NSDictionary *resultDic) {
            if (resultDic && [resultDic objectForKey:kPayFinishKeyCode]) {
                NSNumber *codeNum = [resultDic objectForKey:kPayFinishKeyCode];
                if ([codeNum isEqualToNumber:@(0)]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [self requestOrderByOrderId];
                    });
                }
            }
        }];
    }
}

#pragma mark -Extent
- (NSMutableAttributedString *)setDifferentColerWithString:(NSString *)string type:(ParamType)type {
    NSString *str = nil;
    int i = 0;
    
    if (type == ParamTypePrice) {
        str = [string stringByAppendingString:@" 元"];
        i = 1;
    } else if (type == ParamTypeCoins) {
        str = [string stringByAppendingString:@" 个"];
        i = 1;
    } else if (type == ParamTypePower) {
        str = [string stringByAppendingString:@" kWh"];
        i = 3;
    } else if (type == ParamTypeException) {
        str = string;
        i = 0;
    }
    
    NSMutableAttributedString *fee = [[NSMutableAttributedString alloc] initWithString:str];
    [fee addAttribute:NSForegroundColorAttributeName value:[UIColor palettePriceRedColor] range:NSMakeRange(0, str.length - i)];
    return fee;
}

- (void)setBottomViewButton:(DCOrderState)state {
    if (state == DCOrderStateEvaluated) {
        self.bottomConstraint.constant = 0;
        self.oneButtonView.hidden = YES;
        self.twoButtonView.hidden = YES;
    }
    else if (state == DCOrderStateNotPayBookfee ||
             state == DCOrderStatePaidBookfee) {
        self.twoButtonView.hidden = NO;
        self.oneButtonView.hidden = YES;
    }
    else {
        self.oneButtonView.hidden = NO;
        self.twoButtonView.hidden = YES;
    }
    
    switch (state) {
        case DCOrderStateNotPayBookfee: {
            
        }
            break;
            
        case DCOrderStatePaidBookfee: {
            self.payButton.backgroundColor = [UIColor paletteDCMainColor];
            [self.payButton setTitle:@"导航" forState:UIControlStateNormal];
        }
            break;
            
        case DCOrderStateCancelBooking:
        case DCOrderStateOvevtimeToPayBookfee:
        case DCOrderStateCancelBookingAfterPay:
        case DCOrderStateOvertimeToCharge: {
            [self setButtonWithTitle:@"重新预约" withColor:[UIColor paletteDCMainColor] tag:DCOrderButtonTagReschedule];
        }
            break;
            
        case DCOrderStateCharging: {
            [self setButtonWithTitle:@"查看充电页面" withColor:[UIColor paletteButtonLightBlueColor] tag:DCOrderButtonTagJumpToCharingView];
        }
            break;
            
        case DCOrderStateExceptionWithNotChargeRecord:
        case DCOrderStateExceptionWithChargeData:
        case DCOrderStateExceptionWithStartChargeFail:
        case DCOrderStateExceptionWithStartChargeFailAfterBook: {
            [self setButtonWithTitle:@"联系客服" withColor:[UIColor paletteButtonRedColor] tag:DCOrderButtonTagContactOwner];
        }
            break;
            
        case DCOrderStateNotPayChargefee: {
            [self setButtonWithTitle:@"支付充电费" withColor:[UIColor paletteButtonRedColor] tag:DCOrderButtonTagPayForCharge];
        }
            break;
            
        case DCOrderStateNotEvaluate: {
            [self setButtonWithTitle:@"去评价" withColor:[UIColor paletteButtonYellowColor] tag:DCOrderButtonTagEvaluate];
        }
            break;
            
        default:
            break;
    }
}
             
- (void)setButtonWithTitle:(NSString *)title withColor:(UIColor *)color tag:(DCOrderButtonTag)tag{
    [self.oneButton setTitle:title forState:UIControlStateNormal];
    self.oneButton.backgroundColor = color;
    self.oneButton.tag = tag;
}

#pragma mark - 支付倒数定时器
- (void)timerStart {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(overTime) userInfo:nil repeats:YES];
        [self.timer fire];
    }
}

- (void)overTime {
    if (self.remainTime > 0) {
        NSString *str1 = @"支付预约费用";
        
        NSString *min = self.remainTime / 60 >= 10 ? [NSString stringWithFormat:@" (%ld:", self.remainTime / 60] : [NSString stringWithFormat:@" (0%ld:", self.remainTime / 60];
        NSString *second = self.remainTime % 60 >= 10 ? [NSString stringWithFormat:@"%lds) ", self.remainTime % 60] : [NSString stringWithFormat:@"0%lds) ", self.remainTime % 60];
        NSString *str2 = [min stringByAppendingString:second];
        
        NSString *string = [str1 stringByAppendingString:str2];
        [self.payButton setTitle:string forState:UIControlStateNormal];
//        [self.bottomButton setTitle:string forState:UIControlStateNormal];
        self.remainTime--;
        
    } else {
        [self.timer invalidate];
        self.timer = nil;
        [self.payButton setTitle:@"支付预约费用" forState:UIControlStateNormal];
        [self requestOrderByOrderId];
    }
}

@end

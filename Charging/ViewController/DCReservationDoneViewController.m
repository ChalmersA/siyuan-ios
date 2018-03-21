//
//  DCReservationDoneViewController.m
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCReservationDoneViewController.h"
#import "DCStationDetailViewController.h"
#import "DCOrderDetailViewController.h"

@interface DCReservationDoneViewController ()
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveTotalFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveLimitLabel;

@property (weak, nonatomic) IBOutlet UIButton *collectStationButton;
@property (weak, nonatomic) IBOutlet UIButton *payBookFeeButton;
@end

@implementation DCReservationDoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.payBookFeeButton.layer.cornerRadius = 6;
    self.payBookFeeButton.layer.masksToBounds = YES;
    
    if (self.bookOrder) {
        [self configForBookOrder:self.bookOrder];
    }
    if (self.bookStation.favor) {
        [self.collectStationButton setImage:[UIImage imageNamed:@"find_collect02"] forState:UIControlStateNormal];
    }
}

- (void)navigateBack:(id)sender {
    [self popToStationDetailVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configForBookOrder:(DCOrder *)order {
    self.orderIdLabel.text = order.orderId;
    self.stationNameLabel.text = order.stationName;
    self.pileLocationLabel.text = order.stationLocation;
    self.pileNameLabel.text = [self pileNameDescription:order];
    self.pileTypeLabel.text = (order.pileType == DCPileTypeAC) ? @"交流桩" : @"直流桩";
    self.reserveTimeLabel.text = order.bookingTimeDescription;
    self.reserveFeeLabel.text = [NSString stringWithFormat:@"%0.2f 元/kWh", order.serviceFee];
    self.reserveTotalFeeLabel.text = [NSString stringWithFormat:@"%.2f 元", order.reserveFee];
    self.reserveLimitLabel.text = [order onTimeChargeRetDescription];
    if (order.hasPayReserveFee) {
        [self.payBookFeeButton setTitle:@"支付预约费用" forState:UIControlStateNormal];
    } else{
        [self.payBookFeeButton setTitle:@"确定" forState:UIControlStateNormal];
    }
}

- (IBAction)collectTheStaion:(id)sender {
    int collect = 1;
    if ([self.bookStation isCollect]) {
        collect = 2;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSArray *stationIdArray = [NSArray arrayWithObject:self.bookOrder.stationId];
    [DCSiteApi postFavoritesStations:stationIdArray userId:[DCApp sharedApp].user.userId favorites:collect completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        NSString *text;
        if (self.bookStation.favor) {
            text = @"取消收藏成功";
            self.bookStation.favor = NO;
            [self.collectStationButton setSelected:NO];
        } else {
            text = @"收藏成功";
            self.bookStation.favor = YES;
            [self.collectStationButton setSelected:YES];
        }
        [self hideHUD:hud withText:text];
    }];
}


- (IBAction)payForBookFee:(id)sender {
    if (self.bookOrder.hasPayReserveFee) {
        [self payWithOrder:self.bookOrder withFinishBlock:^(NSDictionary *resultDic) {
            if (resultDic && [resultDic objectForKey:kPayFinishKeyCode]) {
                NSNumber *codeNum = [resultDic objectForKey:kPayFinishKeyCode];
                if ([codeNum isEqualToNumber:@(0)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ORDER_UPDATE object:nil];
                        [self popToStationDetailVC];
                    });
                }
            }
        }];
    } else{
        [self popToStationDetailVC];
    }
}

- (void)popToStationDetailVC {
    for (UIViewController *vc in self.navigationController.viewControllers.reverseObjectEnumerator) {
        if ([vc isKindOfClass:[DCStationDetailViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            break;
        }
    }
}

- (NSString *)pileNameDescription:(DCOrder *)order {
    NSString *chargePort = nil;
    switch (order.chargePortIndex) {
        case 1:
            chargePort = @" 枪1";
            break;
        case 2:
            chargePort = @" 枪2";
            break;
        case 3:
            chargePort = @" 枪3";
            break;
        case 4:
            chargePort = @" 枪4";
            break;
        default:
            break;
    }
    NSString *string = [order.pileName stringByAppendingString:chargePort];
    return string;
}

@end

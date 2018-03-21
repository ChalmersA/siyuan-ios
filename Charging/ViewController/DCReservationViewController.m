//
//  DCReservationDoneViewController.m
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCReservationViewController.h"
#import "NSDate+HSSYDate.h"
#import "DCOrder.h"
#import "DCSiteApi.h"
#import "DCReservationDoneViewController.h"

@interface DCReservationViewController ()
{
    NSArray *buttonArray;
    DCPileType pileType;
    NSInteger duration;
}
@end

@implementation DCReservationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Default
    pileType = DCPileTypeAC;
    duration = 30;
    
    self.endTimeLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:3 * 10 *60]];
    self.reserveFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:(self.staion.bookFee * 3) type:ParamTypePrice];
    
    NSString *string = @"元/10分钟";
    self.bookFeeLabel.text = [[NSString stringByDoubleValue:self.staion.bookFee] stringByAppendingString:string];
    
    if (self.staion.refundState == DCOnTimeChargeRefundStateNotRefund) {
        self.reserveTipLabel.text = @"预约费用作为预留电桩的费用，充电后不再返还。";
    } else {
        self.reserveTipLabel.text = @"如果您在预约时段内启动，系统将返还预约费用。";
    }
    
    buttonArray = [NSArray arrayWithObjects:self.halfHourButton, self.oneHourButton, self.oneHalfHourButton, self.twoHourButton, nil];
    for (UIButton *button in buttonArray) {
        button.layer.borderColor = [UIColor paletteButtonBoradColor].CGColor;
        button.layer.borderWidth = 1;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DCReservationDoneViewController *vc = segue.destinationViewController;
    vc.bookOrder = sender;
    vc.bookStation = self.staion;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)acTypeButton:(id)sender {
    [self.ACTypeButton setImage:[UIImage imageNamed:@"book_icon_select"] forState:UIControlStateNormal];
    [self.DCTypeButton setImage:[UIImage imageNamed:@"book_icon_unselect"] forState:UIControlStateNormal];
    pileType = DCPileTypeAC;
}

- (IBAction)dcTypeButton:(id)sender {
    [self.DCTypeButton setImage:[UIImage imageNamed:@"book_icon_select"] forState:UIControlStateNormal];
    [self.ACTypeButton setImage:[UIImage imageNamed:@"book_icon_unselect"] forState:UIControlStateNormal];
    pileType = DCPileTypeDC;
}


- (IBAction)halfHourButton:(id)sender {
    duration = 30;
    [self setButtonValue:sender time:3];
}

- (IBAction)oneHourButton:(id)sender {
    duration = 60;
    [self setButtonValue:sender time:6];
}

- (IBAction)oneHalfHourButton:(id)sender {
    duration = 90;
    [self setButtonValue:sender time:9];
}

- (IBAction)twoHourButton:(id)sender {
    duration = 120;
    [self setButtonValue:sender time:12];
}

- (IBAction)confirmToBook:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        [hud hide:YES];
        return;
    }
    else {
        [DCSiteApi postBookingOrderWithUserId:[DCApp sharedApp].user.userId stationId:self.staion.stationId chargeType:pileType orderDuration:duration completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                return;
            }
            
            [hud hide:YES];
            DCOrder *order = [[DCOrder alloc] initOrderWithDict:webResponse.result];
            [self performSegueWithIdentifier:@"reservationSuccess" sender:order];
        }];
    }
}

- (void)setButtonValue:(UIButton *)button time:(NSInteger)time{
    button.selected = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor paletteDCMainColor]];
    
    for (UIButton *b in buttonArray) {
        if (![b isEqual:button]) {
            b.selected = NO;
            [b setTitleColor:[UIColor paletterFontGreyColor] forState:UIControlStateNormal];
            [b setBackgroundColor:[UIColor whiteColor]];
        }
    }
    self.endTimeLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:[NSDate dateWithTimeIntervalSinceNow:time * 10 *60]];
    self.reserveFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:(self.staion.bookFee * time) type:ParamTypePrice];
}

@end


@interface CheckoutOrderSegue : UIStoryboardSegue

@end

@implementation CheckoutOrderSegue

- (void)perform {
    UIViewController *sourceVC = self.sourceViewController;
    [sourceVC.navigationController setViewControllers:@[sourceVC.navigationController.hssy_firstViewController, self.destinationViewController] animated:YES];
}

@end

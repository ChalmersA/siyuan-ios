//
//  DCOrderCell.m
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCChargeEditableCell.h"
#import "CWStarRateView.h"
#import "Charging-Swift.h"

@interface DCChargeEditableCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewEditWidthCons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starViewBottomCons;

@property (strong, nonatomic) NSArray *dataArray;
@end

@implementation DCChargeEditableCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    self.bottomButton.layer.cornerRadius = 6;
    self.bottomButton.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.topViewEditWidthCons.constant = 10;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectImageView.highlighted = selected;
    // Configure the view for the selected state
}

#pragma mark - Action
- (IBAction)buttonClicked:(UIButton *)sender {
    [self.delegate cellButtonClicked:self.order tag:sender.tag];
}

#pragma mark - Extension
- (void)updateEditingState:(BOOL)editing {
    self.topViewEditWidthCons.constant = editing ? 39 : 10;
    self.selectImageView.hidden = editing ? NO : YES;
}

- (void)configForOrder:(DCOrder *)order {
    self.order = order;
    
    [order stateForStateLabel:self.order.orderState];
    self.orderStatusLabel.text = order.state;
    self.orderTimeLabel.text = order.orderTimeDescription;
    
    self.orderIdLabel.text = order.orderId;
    self.stationNameLabel.text = order.stationName;
    self.pileNameLabel.text = [order pileNameDescription:order];
    self.startModeLabel.text = [order startTypeDescription];
    self.payMoneyLabel.text = [NSString stringWithFormat:@"%.2f", order.payChargeFee];
    self.payCoinsLabel.text = [NSString stringWithFormat:@"%.2f", order.coinsChargeFee];
    
    switch (order.orderState) {
            
        case DCOrderStateNotEvaluate: {
            self.statusImageView.image = [UIImage imageNamed:@"order_list_pay"];
            self.starViewBottomCons.constant = 30;
            self.bottomButton.backgroundColor = [UIColor paletteButtonYellowColor];
            self.bottomButton.hidden = NO;
            self.starView.hidden = YES;
            [self.bottomButton setTitle:@"去评价" forState:UIControlStateNormal];
            self.bottomButton.tag = DCOrderButtonTagEvaluate;
        }
            break;
            
        case DCOrderStateEvaluated: {
            self.statusImageView.image = [UIImage imageNamed:@"order_list_evaluated"];
            self.starViewBottomCons.constant = 10;
            self.bottomButton.hidden = YES;
            self.starView.hidden = NO;
            self.starView.starRateView.scorePercent = order.totalScore/5;
        }
            break;
            
        default:
            break;
    }
}

- (NSString *)stateForStateLabel:(DCOrderState)state {
    switch (state) {
        case DCOrderStateOvertimeToCharge:
        case DCOrderStateOvevtimeToPayBookfee:
            return @"已过期";
            break;
            
        case DCOrderStateNotPayBookfee:
            return @"待支付预约费用";
            break;
            
        case DCOrderStatePaidBookfee:
            return @"已预约";
            break;
            
        case DCOrderStateCancelBooking:
            return @"已取消";
            break;
            
        case DCOrderStateCharging:
            return @"充电中";
            break;
            
        case DCOrderStateNotPayChargefee:
           return @"待支付";
            break;
            
        case DCOrderStateNotEvaluate:
            return @"已支付";
            
        case DCOrderStateEvaluated:
            return @"已评价";
            break;
            
        case DCOrderStateExceptionWithChargeData:
        case DCOrderStateExceptionWithNotChargeRecord:
        case DCOrderStateExceptionWithStartChargeFail:
            return @"异常订单";
            break;
            
        default:
            return @"未知";
            break;
    }
}

+ (CGFloat)cellHeight {
    return cellHeight;
}

@end

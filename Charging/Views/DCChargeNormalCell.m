//
//  DCChargeNormalCell.m
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargeNormalCell.h"

@interface DCChargeNormalCell ()
{
    __weak IBOutlet NSLayoutConstraint *exceptionConstraint;
    __weak IBOutlet UILabel *title1;
    __weak IBOutlet UILabel *title2;
    __weak IBOutlet UILabel *title3;
}

@end

@implementation DCChargeNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    self.bottomButton.layer.cornerRadius = 6;
    self.bottomButton.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(UIButton *)sender {
    [self.delegate cellButtonClicked:self.order tag:sender.tag];
}

- (void)configForOrder:(DCOrder *)order {
    self.order = order;
    
    [order stateForStateLabel:self.order.orderState];
    self.statusLabel.text = order.state;
    self.orderTimeLabel.text = order.orderTimeDescription;
    
    self.orderIdLabel.text = order.orderId;
    self.stationNameLabel.text = order.stationName;
    self.pileNameLabel.text = [order pileNameDescription:order];
    self.startModeLabel.text = order.startTypeDescription;
    
    if (order.orderState == DCOrderStateCharging) {
        
        self.statusImageView.image = [UIImage imageNamed:@"order_list_charing"];
        self.statusLabel.attributedText = [NSAttributedString setDifferentColorWithString:order.state color:[UIColor paletteButtonLightBlueColor]];
        self.chargeModeLabel.text = order.chargeModeDescription;
        self.chargingTimeLabel.text = order.chargeStartTimeDescription;
        self.chargeFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:order.serviceFee type:ParamTypePower];
        
        self.bottomButton.tag = DCOrderButtonTagJumpToCharingView;
        [self setBottomButtonWithTitle:@"查看充电页面" color:[UIColor paletteButtonLightBlueColor]];
        
        self.bottomButtonConstraint.constant = 10;
        self.bottomTipLabel.hidden = YES;
        cellHeight = 350;
    }
    else if (order.orderState == DCOrderStateNotPayChargefee) {
        
        title1.text = @"充电时段";
        title2.text = @"充电单价";
        title3.text = @"充电金额";
        
        self.statusImageView.image = [UIImage imageNamed:@"order_list_notPay"];
        self.statusLabel.attributedText = [NSAttributedString setDifferentColorWithString:order.state color:[UIColor palettePriceRedColor]];
        self.chargeModeLabel.text = order.chargeTimeDescription;
        self.chargingTimeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:order.serviceFee type:ParamTypePower];
        self.chargeFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:order.chargeTotalFee type:ParamTypePrice];
        
        self.bottomButton.tag = DCOrderButtonTagPayForCharge;
        [self setBottomButtonWithTitle:@"支付充电费" color:[UIColor paletteButtonRedColor]];
        
        self.bottomButtonConstraint.constant = 10;
        self.bottomTipLabel.hidden = YES;
        cellHeight = 350;
    }
    else if (order.orderState == DCOrderStateExceptionWithNotChargeRecord ||
               order.orderState == DCOrderStateExceptionWithChargeData ||
               order.orderState == DCOrderStateExceptionWithStartChargeFail) {
        
        self.statusImageView.image = [UIImage imageNamed:@"order_list_exception"];
        self.chargeModeLabel.text = order.chargeModeDescription;
        self.chargingTimeLabel.text = order.chargeTimeDescription;
        self.chargeFeeView.hidden = YES;
        
        self.bottomButton.tag = DCOrderButtonTagContactOwner;
        [self setBottomButtonWithTitle:@"联系客服" color:[UIColor paletteButtonRedColor]];
        cellHeight = 318;
        exceptionConstraint.constant = 0;
    }
}

#pragma mark Extension
- (void)setBottomButtonWithTitle:(NSString *)title color:(UIColor *)color {
    [self.bottomButton setTitle:title forState:UIControlStateNormal];
    self.bottomButton.backgroundColor = color;
}

+ (CGFloat)cellHeight {
    return cellHeight;
}

@end

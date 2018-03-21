//
//  DCSelectChargeModeView.m
//  Charging
//
//  Created by kufufu on 16/3/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCSelectChargeModeView.h"

@implementation DCSelectChargeModeView

+ (instancetype)selectChargeModeViewWithStartChargeParams:(DCStartChargeParams *)params {
    DCSelectChargeModeView *view = [DCSelectChargeModeView loadViewWithNib:@"DCSelectChargeModeView"];
    view.pileNameLabel.text = params.pileName;
    view.pileTypeLabel.text = (params.pileType == DCPileTypeAC) ? @"交流桩" : @"直流桩";
    view.chargeFeeLabel.text = [NSString stringWithFormat:@"%.2f", params.chargeFee];
    
    if (!params.isHasFloorLock) {
        view.lockButton.backgroundColor = [UIColor paletteBottomBtnLightGrayColor];
        view.lockButton.enabled = NO;
    }
    
    if (params.isHasChargePort) {
        switch (params.chargePortIndex) {
            case 1:
                view.chargePortNameLabel.text = @"枪1";
                break;
            case 2:
                view.chargePortNameLabel.text = @"枪2";
                break;
            case 3:
                view.chargePortNameLabel.text = @"枪3";
                break;
            case 4:
                view.chargePortNameLabel.text = @"枪4";
                break;
            default:
                break;
        }
    } else {
        view.startButton.enabled = false;
        view.fullButton.enabled = NO;
        [view.fullButton setImage:[UIImage imageNamed:@"charge_mode_gray_full"] forState:UIControlStateNormal];
        
        view.timeButton.enabled = NO;
        [view.timeButton setImage:[UIImage imageNamed:@"charge_mode_gray_time"] forState:UIControlStateNormal];
        
        view.moneyButton.enabled = NO;
        [view.moneyButton setImage:[UIImage imageNamed:@"charge_mode_gray_money"] forState:UIControlStateNormal];
        
        view.powerButton.enabled = NO;
        [view.powerButton setImage:[UIImage imageNamed:@"charge_mode_gray_power"] forState:UIControlStateNormal];
        
        view.changeChargePortButton.backgroundColor = [UIColor paletteButtonBackgroundColor];
        view.changeChargePortButton.enabled = NO;
        view.lockButton.backgroundColor = [UIColor paletteButtonBackgroundColor];
        view.lockButton.enabled = NO;
    }
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.changeChargePortButton.layer.cornerRadius = 3;
    self.changeChargePortButton.layer.masksToBounds = YES;
    self.lockButton.layer.cornerRadius = 3;
    self.lockButton.layer.masksToBounds = YES;
}

#pragma mark - Delegate
- (IBAction)clickTheLockButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheLockButton)]) {
        [self.delegate clickTheLockButton];
    }
}

- (IBAction)chargeByFullButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheChargeByMode:chargePort:)]) {
        [self.delegate clickTheChargeByMode:DCChargeModeTypeByFull chargePort:self.chargePort];
    }
}

- (IBAction)chargeByTimeButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheChargeByMode:chargePort:)]) {
        [self.delegate clickTheChargeByMode:DCChargeModeTypeByTime chargePort:self.chargePort];
    }
}

- (IBAction)chargeByMoneyButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheChargeByMode:chargePort:)]) {
        [self.delegate clickTheChargeByMode:DCChargeModeTypeByMoney chargePort:self.chargePort];
    }
}

- (IBAction)chargeByPowerButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheChargeByMode:chargePort:)]) {
        [self.delegate clickTheChargeByMode:DCChargeModeTypeByPower chargePort:self.chargePort];
    }
}
- (IBAction)changeOtherChargePortButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(changeOtherChargePort)]) {
        [self.delegate changeOtherChargePort];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

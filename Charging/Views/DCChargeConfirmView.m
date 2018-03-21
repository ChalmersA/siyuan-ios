
//
//  DCChargeConfirmView.m
//  Charging
//
//  Created by kufufu on 16/3/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargeConfirmView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DCChargeConfirmView ()
{
    NSInteger min;
}

@end

@implementation DCChargeConfirmView

+ (instancetype)chargeConfirmViewWithType:(DCChargeModeType)type {
    DCChargeConfirmView *view = [DCChargeConfirmView loadViewWithNib:@"DCChargeConfirmView"];
    view.modeType = type;
    switch (type) {
        case DCChargeModeTypeByTime: {
            view.timeView.hidden = NO;
            [view.moneyView removeFromSuperview];
            [view.powerView removeFromSuperview];
        }
            break;
         
        case DCChargeModeTypeByMoney: {
            view.moneyView.hidden = NO;
            [view.timeView removeFromSuperview];
            [view.powerView removeFromSuperview];
        }
            break;
            
        case DCChargeModeTypeByPower: {
            view.powerView.hidden = NO;
            [view.moneyView removeFromSuperview];
            [view.timeView removeFromSuperview];
        }
            break;
            
        default:
            break;
    }
    return view;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.powerTextfield resignFirstResponder];
    [self.moneyTextfield resignFirstResponder];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.confrimButton.layer.cornerRadius = 6;
    self.backButton.layer.cornerRadius = 6;
    self.confrimButton.layer.masksToBounds = YES;
    self.backButton.layer.masksToBounds = YES;
    [self.backButton setBorderColor:[UIColor paletteButtonBoradColor] width:1];
    min = 3;
    NSTimeInterval aNewDuration = 180;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timePicker.countDownDuration = (NSTimeInterval)aNewDuration ;
    });
}

- (IBAction)getTimeToCharge:(id)sender {
    min = self.timePicker.countDownDuration / 60;
    if (min < 3) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"充电时长不能少于3分钟";
        [hud hide:YES afterDelay:2];
        hud.completionBlock = ^ {
            min = 3;
            self.timePicker.countDownDuration = 180;
        };
    }
    NSLog(@"%ld", (long)min);
}

- (IBAction)confrimToCharge:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickConfirmChargeButton:chargeLimit:)]) {
        double chargeLimit = 0;
        
        if (self.modeType == DCChargeModeTypeByTime) {
            chargeLimit = min;
        }
        else if (self.modeType == DCChargeModeTypeByMoney) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.mode = MBProgressHUDModeText;
            
            if (!(self.moneyTextfield.text.length > 0)) {
                hud.labelText = @"请输入充电金额";
                [hud hide:YES afterDelay:2];
                return;
            }
            
            if (![self isMoney:self.moneyTextfield.text] || [self.moneyTextfield.text doubleValue] < 0.01 || [self.moneyTextfield.text doubleValue] > 1000) {
                hud.labelText = @"请输入正确的充电金额";
                [hud hide:YES afterDelay:2];
                return;
            }
            chargeLimit = [self.moneyTextfield.text doubleValue] * 100;
        }
        else if (self.modeType == DCChargeModeTypeByPower) {
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            hud.mode = MBProgressHUDModeText;
            
            if (!(self.powerTextfield.text.length > 0)) {
                hud.labelText = @"请输入充电电量";
                [hud hide:YES afterDelay:2];
                return;
            }
            
            if (![self isQuantity:self.powerTextfield.text] || [self.powerTextfield.text doubleValue] < 0.1 || [self.powerTextfield.text integerValue] > 500) {
                hud.labelText = @"请输入正确的充电电量";
                [hud hide:YES afterDelay:2];
                return;
            }
            chargeLimit = [self.powerTextfield.text doubleValue] * 100;
        }
        [self.delegate clickConfirmChargeButton:self.modeType chargeLimit:chargeLimit];
    }
}

- (IBAction)chooseOtherChargeMode:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickOhterChargeModeButton)]) {
        [self.delegate clickOhterChargeModeButton];
    }
}

#pragma mark - TextField
- (BOOL)isMoney:(NSString *)money {
    NSString *regex = @"^0$|^[1-9]+\\d*$|^0\\.\\d{0,2}$|^[1-9]+\\d*\\.\\d{0,2}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:money];
}

- (BOOL)isQuantity:(NSString *)quantity {
    NSString *regex = @"^0$|^[1-9]+\\d*$|^0\\.\\d?$|^[1-9]+\\d*\\.\\d?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:quantity];
}

@end

//
//  DCOneButtonAlertView.m
//  Charging
//
//  Created by kufufu on 16/4/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCOneButtonAlertView.h"

@implementation DCOneButtonAlertView

+ (instancetype)viewWithAlertType:(DCAlertType)alertType {
    DCOneButtonAlertView *view = [DCOneButtonAlertView loadViewWithNib:@"DCOneButtonAlertView"];
    [view viewByAlertType:alertType];
    return view;
}

- (void)awakeFromNib {
    self.confirmButton.layer.cornerRadius = 3;
    self.confirmButton.layer.masksToBounds = YES;
}

- (void)viewByAlertType:(DCAlertType)alertType {
    self.alertType = alertType;
    switch (alertType) {
        case DCAlertTypeFault: {
            [self setImageView:@"charing_warm_warm" withTip:@"设备故障，请你尝试其他充电桩或联系客服\n021-616-10101"];
        }
            break;
            
        case DCAlertTypeBooked: {
            [self setImageView:@"charing_warm_booked" withTip:@"您尚未授权，无法启动充电"];
        }
            break;
            
        case DCAlertTypeCharging: {
            [self setImageView:@"charing_warm_charging" withTip:@"设备正在被占用"];
        }
            break;
            
        case DCAlertTypeExtract: {
            [self setImageView:@"charing_warm_warm" withTip:@"充电枪未连接"];
        }
            break;
            
        case DCAlertTypeError: {
            [self setImageView:@"charing_warm_exception" withTip:@"很抱歉，设备发生异常"];
        }
            break;
            
        case DCAlertTypeException: {
            [self setImageView:@"charing_warm_exception" withTip:@"很抱歉，设备发生异常，已中断充电，请检查"];
        }
            break;
            
        case DCAlertTypeNotPay: {
            [self setImageView:@"charing_warm_pay" withTip:@"本次充电已完成，尚未付款，充电信息已保存到“我的订单”里"];
        }
            break;
            
        case DCAlertTypePayForWithdraw_Success: {
            [self setImageView:@"wallet_pay_success" withTip:@"充值成功!"];
            [self.confirmButton setTitle:@"知道了" forState:UIControlStateNormal];
        }
            break;
            
        case DCAlertTypePayForChargeFee_Success: {
            [self setImageView:@"wallet_pay_success" withTip:@"支付成功!"];
            [self.confirmButton setTitle:@"知道了" forState:UIControlStateNormal];
        }
            break;
            
        case DCAlertTypeNoChargePort: {
            [self setImageView:@"charing_warm_charging" withTip:@"当前没有可用充电枪口，请您尝试其他充电桩"];
        }
            break;
         
        case DCAlertTypeUnbindChargeCard: {
            [self setImageView:@"chargeCard_icon_warm" withTip:@"解绑后您将不能在 “易卫充” 里查看充电卡相关的电卡的余额、电卡状态、充电记录及电卡启动后的充电情况。"];
        }
            break;
            
        case DCAlertTypeWithoutFreeChargePort: {
            [self setImageView:@"charing_warm_charging" withTip:@"设备正在被占用"];
        }
            break;
            
        case DCAlertTypeGunLockOpen: {
            [self setImageView:@"charing_warm_exception" withTip:@"枪锁已打开，请检查"];
        }
             break;
            
        case DCAlertTypeDoorLockOpen: {
            [self setImageView:@"charing_warm_exception" withTip:@"门锁已打开，请检查"];
        }
            break;
            
        default:
            break;
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setImageView:(NSString *)imageName withTip:(NSString *)tip {
    self.topImageView.image = [UIImage imageNamed:imageName];
    self.tipLabel.text = tip;
}

#pragma mark - Delegate
- (IBAction)clickTheConfirmButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(oneButtonAlertViewConfrimButton:)]) {
        [self.delegate oneButtonAlertViewConfrimButton:self.alertType];
    }
}

@end

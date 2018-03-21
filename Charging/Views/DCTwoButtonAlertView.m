//
//  DCTwoButtonAlertView.m
//  Charging
//
//  Created by kufufu on 16/4/27.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCTwoButtonAlertView.h"

@implementation DCTwoButtonAlertView

- (void)awakeFromNib {
    self.leftButton.layer.cornerRadius = 3;
    self.leftButton.layer.masksToBounds = YES;
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.masksToBounds = YES;
}

+ (instancetype)viewWithAlertType:(DCTwoButtonAlertType)alertType {
    DCTwoButtonAlertView *view = [DCTwoButtonAlertView loadViewWithNib:@"DCTwoButtonAlertView"];
    [view viewByAlertType:alertType];
    view.type = alertType;
    return view;
}

- (void)viewByAlertType:(DCTwoButtonAlertType)type {
    [self.topImageView setImage:[UIImage imageNamed:@"wallet_pay_fault"]];
    if (type == DCTwoButtonAlertTypePayFault) {
        self.tipLabel.text = @"充值失败!";
        [self.leftButton setTitle:@"重新选取充值方式" forState:UIControlStateNormal];
        [self.rightButton setTitle:@"取消充值" forState:UIControlStateNormal];
        return;
    }
    
    if (type == DCTwoButtonAlertTypePasswordError) {
        self.tipLabel.text = @"登录密码错误，请重试!";
        [self.leftButton setTitle:@"重试" forState:UIControlStateNormal];
        [self.rightButton setTitle:@"忘记密码" forState:UIControlStateNormal];
        return;
    }
    
}

- (IBAction)clickLeftButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheLeftButton:)]) {
        [self.delegate clickTheLeftButton:self.type];
    }
}
- (IBAction)clickRightButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheRightButton:)]) {
        [self.delegate clickTheRightButton:self.type];
    }
}
@end

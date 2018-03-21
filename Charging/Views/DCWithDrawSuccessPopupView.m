//
//  DCWithDrawSuccessPopupView.m
//  Charging
//
//  Created by kufufu on 16/5/13.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCWithDrawSuccessPopupView.h"

@implementation DCWithDrawSuccessPopupView

+ (instancetype)viewWithWithChargeCoins:(NSString *)chargeCoins withAccount:(NSString *)account {
    DCWithDrawSuccessPopupView *view = [DCWithDrawSuccessPopupView loadViewWithNib:@"DCWithDrawSuccessPopupView"];
    view.accountLabel.text = account;
    view.coinLabel.text = chargeCoins;
    return view;
}

- (IBAction)confirmButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(confirmButton)]) {
        [self.delegate confirmButton];
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

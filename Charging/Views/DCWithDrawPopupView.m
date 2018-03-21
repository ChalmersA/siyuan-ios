//
//  DCWithDrawPopupView.m
//  Charging
//
//  Created by kufufu on 16/5/13.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCWithDrawPopupView.h"

@implementation DCWithDrawPopupView

+ (instancetype)viewWithWithChargeCoins:(NSString *)chargeCoins {
    DCWithDrawPopupView *view = [DCWithDrawPopupView loadViewWithNib:@"DCWithDrawPopupView"];
    view.withDrawLabel.text = chargeCoins;
    return view;
}

- (IBAction)confirmButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheConfirmButton:)]) {
        [self.delegate clickTheConfirmButton:self.passWordTextField.text];
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

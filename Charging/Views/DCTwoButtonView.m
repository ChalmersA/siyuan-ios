//
//  DCTwoButtonView.m
//  Charging
//
//  Created by kufufu on 16/5/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCTwoButtonView.h"

@implementation DCTwoButtonView

+ (instancetype)loadTwoButtonViewWithType:(DCTwoButtonType)type {
    DCTwoButtonView *view = [DCTwoButtonView loadViewWithNib:@"DCTwoButtonView"];
    view.returnButton.layer.borderWidth = 1;
    view.returnButton.layer.borderColor = [UIColor paletteButtonBoradColor].CGColor;
    if (type == DCTwoButtonTypeCancelOrder) {
        view.tipLabel.hidden = NO;
    }
    return view;
}

- (IBAction)forgetButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheForgetButton)]) {
        [self.delegate clickTheForgetButton];
    }
}
- (IBAction)returnButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheReturnButton)]) {
        [self.delegate clickTheReturnButton];
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

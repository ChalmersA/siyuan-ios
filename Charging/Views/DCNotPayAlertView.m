//
//  DCNotPayAlertView.m
//  Charging
//
//  Created by kufufu on 16/4/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCNotPayAlertView.h"

@implementation DCNotPayAlertView

+ (instancetype)loadWithNotPayOrder:(DCOrder *)order {
    DCNotPayAlertView *view = [DCNotPayAlertView loadViewWithNib:@"DCNotPayAlertView"];
    view.orderIdLabel.text = order.orderId;
    view.orderId = order.orderId;
    view.orderTimeLabel.text = [order chargeTimeDescription];
    view.orderFeeLabel.tintColor = [UIColor palettePriceRedColor];
    view.orderFeeLabel.text = [NSString stringWithFormat:@"%0.2f", order.chargeTotalFee];
    return view;
}

- (void)awakeFromNib {
    self.orderIdLabel.text = nil;
    self.orderTimeLabel.text = [self chargeTime:nil];
    self.orderFeeLabel.text = nil;
}

- (NSString *)chargeTime:(NSDate *)time {
    if (time) {
        NSString *chargeTime = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:time];
        return chargeTime;
    }
    return nil;
}
- (IBAction)clickToPay:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickToPayWithOrderId:)]) {
        [self.delegate clickToPayWithOrderId:self.orderId];
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

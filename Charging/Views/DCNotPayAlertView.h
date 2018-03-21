//
//  DCNotPayAlertView.h
//  Charging
//
//  Created by kufufu on 16/4/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCOrder.h"

@protocol DCNotPayAlertViewDelegate <NSObject>

- (void)clickToPayWithOrderId:(NSString *)orderId;

@end

@interface DCNotPayAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderFeeLabel;
@property (weak, nonatomic) IBOutlet UIButton *goToPay;
@property (strong, nonatomic) NSString *orderId;

@property (weak, nonatomic) id <DCNotPayAlertViewDelegate> delegate;

+ (instancetype)loadWithNotPayOrder:(DCOrder *)order;

@end

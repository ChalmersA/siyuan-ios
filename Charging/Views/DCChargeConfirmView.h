//
//  DCChargeConfirmView.h
//  Charging
//
//  Created by kufufu on 16/3/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

@protocol ChargeConfirmViewDelegate <NSObject>

- (void)clickConfirmChargeButton:(DCChargeModeType)chargeModeType chargeLimit:(double)chargeLimit;
- (void)clickOhterChargeModeButton;

@end

@interface DCChargeConfirmView : UIView

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@property (weak, nonatomic) IBOutlet UIView *moneyView;
@property (weak, nonatomic) IBOutlet UITextField *moneyTextfield;

@property (weak, nonatomic) IBOutlet UIView *powerView;
@property (weak, nonatomic) IBOutlet UITextField *powerTextfield;

@property (weak, nonatomic) IBOutlet UIButton *confrimButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (assign, nonatomic) DCChargeModeType modeType;

@property (weak, nonatomic) id<ChargeConfirmViewDelegate> delegate;
+ (instancetype)chargeConfirmViewWithType:(DCChargeModeType)type;
@end

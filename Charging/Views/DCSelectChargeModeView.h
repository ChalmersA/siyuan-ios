//
//  DCSelectChargeModeView.h
//  Charging
//
//  Created by kufufu on 16/3/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStartChargeParams.h"
#import "DCChargePort.h"

@protocol SelectChargeModeViewDelegate <NSObject>

- (void)clickTheChargeByMode:(DCChargeModeType)chargeModeType chargePort:(DCChargePort *)chargePort;
- (void)changeOtherChargePort;
- (void)clickTheLockButton;

@end

@interface DCSelectChargeModeView : UIView
//@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileTypeLabel;

@property (weak, nonatomic) IBOutlet UILabel *chargePortNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *changeChargePortButton;

@property (weak, nonatomic) IBOutlet UILabel *chargeFeeLabel;

@property (weak, nonatomic) IBOutlet UIButton *lockButton;


@property (weak, nonatomic) IBOutlet UIButton *fullButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *moneyButton;
@property (weak, nonatomic) IBOutlet UIButton *powerButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (strong, nonnull) DCChargePort *chargePort;
@property (weak, nonatomic) id<SelectChargeModeViewDelegate> delegate;

+ (instancetype)selectChargeModeViewWithStartChargeParams:(DCStartChargeParams *)params;

@end

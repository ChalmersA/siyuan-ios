//
//  chargePortView.h
//  Charging
//
//  Created by kufufu on 16/3/8.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

typedef NS_ENUM(NSInteger, DCChargePortButton) {
    DCChargePortButtonA = 1,
    DCChargePortButtonB,
    DCChargePortButtonC,
    DCChargePortButtonD,
};

@protocol ChargePortViewDelegate <NSObject>

- (void)clickChargePortButton:(DCChargePortButton)chargePort;

@end

@interface ChargePortView : UIView

@property (weak, nonatomic) IBOutlet UIButton *chargePortA;
@property (weak, nonatomic) IBOutlet UIButton *chargePortB;
@property (weak, nonatomic) IBOutlet UIButton *chargePortC;
@property (weak, nonatomic) IBOutlet UIButton *chargePortD;

@property (weak, nonatomic) id<ChargePortViewDelegate>delegate;
+ (instancetype)chargePortViewWithChargePorts:(NSArray *)chargePorts chooseIndex:(NSInteger)chooseIndex;
@end

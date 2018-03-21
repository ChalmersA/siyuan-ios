//
//  HSSYChargeTwoButtonAlertView.h
//  Charging
//
//  Created by kufufu on 15/10/28.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

typedef NS_ENUM(NSInteger, HSSYChargeTwoButtonAlertViewStyle) {
    HSSYChargeTwoButtonAlertViewStyleGprsOwner,
    HSSYChargeTwoButtonAlertViewStyleGprsTenant,
    HSSYChargeTwoButtonAlertViewStyleOther,
};

@protocol HSSYChargeTwoButtonAlertViewDelegate <NSObject>

- (void)cancelButtonClick:(HSSYChargeTwoButtonAlertViewStyle)style;
- (void)confirmButtonClick:(HSSYChargeTwoButtonAlertViewStyle)style;

@end

@interface DCChargeTwoButtonAlertView : UIView

@property (nonatomic) HSSYChargeTwoButtonAlertViewStyle style;

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) id <HSSYChargeTwoButtonAlertViewDelegate> delegate;

- (void)setTitle:(NSString *)title content:(NSString *)content cancelButton:(NSString *)cancelButton confirmbutton:(NSString *)confirmButton;

- (void)setTitle:(NSString *)title pileName:(NSString *)pileName ownerName:(NSString *)ownerName price:(NSString *)price cancelButton:(NSString *)cancelButton confirmbutton:(NSString *)confirmButton;

@end

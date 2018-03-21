//
//  HSSYChargeOneButtonAlertView.h
//  Charging
//
//  Created by kufufu on 15/10/31.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

@protocol HSSYChargeOneButtonAlertViewDelegate <NSObject>

- (void)confirmButtonClick;

@end

@interface DCChargeOneButtonAlertView : UIView

@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) id<HSSYChargeOneButtonAlertViewDelegate>delegate;

- (void)setTitle:(NSString *)title content:(NSString *)content confirmbutton:(NSString *)confirmButton;
@end

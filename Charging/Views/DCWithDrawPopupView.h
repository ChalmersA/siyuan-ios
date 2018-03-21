//
//  DCWithDrawPopupView.h
//  Charging
//
//  Created by kufufu on 16/5/13.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCWithDrawPopupViewDelegate <NSObject>

- (void)clickTheConfirmButton:(NSString *)password;

@end

@interface DCWithDrawPopupView : UIView

@property (weak, nonatomic) IBOutlet UILabel *withDrawLabel;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) id <DCWithDrawPopupViewDelegate> delegate;

+ (instancetype)viewWithWithChargeCoins:(NSString *)chargeCoins;
@end

//
//  DCWithDrawSuccessPopupView.h
//  Charging
//
//  Created by kufufu on 16/5/13.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DCWithDrawSuccessPopupViewDelegate <NSObject>

- (void)confirmButton;

@end

@interface DCWithDrawSuccessPopupView : UIView
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *coinLabel;

@property (weak, nonatomic) id <DCWithDrawSuccessPopupViewDelegate> delegate;

+ (instancetype)viewWithWithChargeCoins:(NSString *)chargeCoins withAccount:(NSString *)account;

@end

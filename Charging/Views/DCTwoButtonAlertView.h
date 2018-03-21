//
//  DCTwoButtonAlertView.h
//  Charging
//
//  Created by kufufu on 16/4/27.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DCTwoButtonAlertType) {
    DCTwoButtonAlertTypePayFault,
    DCTwoButtonAlertTypePasswordError,
};

@protocol DCTwoButtonAlertViewDelegate <NSObject>

- (void)clickTheLeftButton:(DCTwoButtonAlertType)type;
- (void)clickTheRightButton:(DCTwoButtonAlertType)type;

@end

@interface DCTwoButtonAlertView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (assign, nonatomic) DCTwoButtonAlertType type;

@property (weak, nonatomic) id <DCTwoButtonAlertViewDelegate> delegate;

+ (instancetype)viewWithAlertType:(DCTwoButtonAlertType)alertType;
@end

//
//  DCPopupView.h
//  Charging
//
//  Created by kufufu on 16/4/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCPopupView;

@protocol DCPopupViewDelegate <NSObject>

- (void)popUpViewDismiss:(DCPopupView *)view;

@optional
- (void)clickForResignFirstResponse;

@end

@interface DCPopupView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *replaceView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (assign, nonatomic) BOOL backgroundDismissEnable;
@property (assign, nonatomic) CGPoint contentOffset;
@property (assign, nonatomic) CGFloat realityHeight;
@property (assign, nonatomic) CGFloat realityWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;

@property (weak, nonatomic) id<DCPopupViewDelegate>delegate;

+ (instancetype)popUpWithTitle:(NSString *)title contentView:(UIView *)contentView withController:(UIViewController *)controller;
+ (instancetype)popUpWithTitle:(NSString *)title contentView:(UIView *)contentView;
- (void)dismiss;

@end

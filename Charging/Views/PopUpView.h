//
//  PopUpView.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopUpView;

@protocol PopUpViewDelegate <NSObject>
@optional
- (void)popUpViewDidDismiss:(PopUpView *)view;
@end

@interface PopUpView : UIView 
@property (weak, nonatomic) id <PopUpViewDelegate> delegate;
@property (assign, nonatomic) BOOL backgroundDismissEnable;
@property (assign, nonatomic) CGPoint contentOffset;
+ (instancetype)popUpWithContentView:(UIView *)contentView;
+ (instancetype)popUpWithContentView:(UIView *)contentView withController:(UIViewController *)controller;
- (instancetype)initWithContentView:(UIView *)contentView;
- (void)dismiss;
@end



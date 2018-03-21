//
//  HSSYPayView.h
//  Charging
//
//  Created by xpg on 15/1/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopUpView.h"

@class DCPayView;

@protocol HSSYPayViewDelegate <NSObject>
@optional
- (void)payViewDidCancel:(DCPayView *)view;
- (void)payView:(DCPayView *)view didInputPassword:(NSString *)password;
@end

@interface DCPayView : UIView
@property (weak, nonatomic) id <HSSYPayViewDelegate> delegate;
@property (copy, nonatomic) NSString *password;
@end

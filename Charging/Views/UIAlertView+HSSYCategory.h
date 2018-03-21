//
//  UIAlertView+HSSYCategory.h
//  Charging
//
//  Created by xpg on 15/1/13.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (HSSYCategory)
+ (UIAlertView *)showAlertMessage:(NSString *)message buttonTitles:(NSArray *)titles;
+ (UIAlertView *)showAlertMessage:(NSString *)message hideAfter:(NSTimeInterval)delay completion:(void(^)())completion;
+ (UIAlertView *)showAlertMessage:(NSString *)message title:(NSString*)title buttonTitles:(NSArray *)titles;
- (void)setClickedButtonHandler:(void(^)(NSInteger buttonIndex))handler;
@end

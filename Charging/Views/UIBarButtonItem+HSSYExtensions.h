//
//  UIBarButtonItem+HSSYExtensions.h
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (HSSYExtensions)
+ (instancetype)buttonBarItemWithTarget:(id)target action:(SEL)action icon:(UIImage *)icon;
+ (instancetype)backBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)menuBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)bluetoothBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)searchBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)alarmBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)shareBarItemWithTarget:(id)target action:(SEL)action;
+ (instancetype)favoBarItemWithTarget:(id)target action:(SEL)action;
- (void)setSelected:(BOOL)selected;
- (BOOL)selected;
+ (instancetype)logoBarItem;
@end

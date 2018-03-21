//
//  HSSYTabBarController.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DCTabIndex) {
    DCTabIndexCharge,
    DCTabIndexSearch,
    DCTabIndexCircle,
    DCTabIndexUser,
};

@interface DCTabBarController : UITabBarController
- (void)updateNavigationBar;
@end

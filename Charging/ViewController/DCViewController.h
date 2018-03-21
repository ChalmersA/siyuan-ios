//
//  HSSYViewController.h
//  Charging
//
//  Created by xpg on 14/12/9.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCApp.h"
#import "DCSiteApi.h"
#import "UIViewController+HSSYExtensions.h"
#import "UIBarButtonItem+HSSYExtensions.h"
#import "UIAlertView+HSSYCategory.h"
#import "UIActionSheet+HSSYCategory.h"
#import "UIView+HSSYView.h"
#import "UITableView+HSSYCategory.h"
#import "NSDateFormatter+HSSYCategory.h"
#import "UIColor+HSSYColor.h"
#import "UIImage+HSSYCategory.h"
#import "DCTextView.h"
#import <MJRefresh/MJRefresh.h>
#import "UIImageView+WebCache.h"
#import "NSString+HSSY.h"

@interface DCViewController : UIViewController
- (void)navigateBack:(id)sender;
- (void)themeDidChange:(HSSYTheme)theme;

//注册页面的圆角主题色边框
- (void)drawBorderAndRoundCorner:(UIView *)view;
@end

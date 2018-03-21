//
//  HSSYPoleInfoView.h
//  Charging
//
//  Created by xpg on 15/4/23.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DCStation.h"

@class DCPole;
extern const CGFloat HSSYPoleInfoViewHeight;
@interface DCPoleInfoView : UIView
@property (copy, nonatomic) void (^swipeDownBlock)(DCPoleInfoView *view);
@property (copy, nonatomic) void (^swipeUpBlock)(DCPoleInfoView *view);
@property (copy, nonatomic) void (^tapGestureBlock)(DCPoleInfoView *view);
@property (copy, nonatomic) void (^tapGestureViewBlock)(DCPoleInfoView *view);
@property (copy, nonatomic) void (^navigationHandler)(DCPoleInfoView *view);
- (void)configViewForPole:(DCStation *)station withUserLocation:(CLLocation *)userLocation;
- (void)showInView:(UIView *)view;
- (void)hide;
@end

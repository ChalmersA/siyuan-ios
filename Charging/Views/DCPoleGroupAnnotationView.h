//
//  HSSYPoleGroupAnnotationView.h
//  Charging
//
//  Created by xpg on 15/4/30.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "BaiduMapKits.h"
#import "DCClusterPopoverVIew.h"
#import "DCStation.h"

@interface DCPoleGroupAnnotationView : BMKAnnotationView
- (void)configureGroupAnnotationViewWithBlock:(ClusterItemSelctedBlcok)block;
- (DCStation*)selectedStation;
- (DCStation*)selectStation:(DCStation*)station;
- (void)adjustViewMaxHeight:(CGFloat)height;
@end

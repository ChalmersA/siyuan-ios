//
//  HSSYSearchViewController.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "PopUpView.h"
#import "BaiduMapKits.h"

@class DCPoleMapAnnotation;

typedef NS_ENUM(NSInteger, DCSearchStyle) {
    DCSearchStyleTable,
    DCSearchStyleMap,
};

@class BMKMapView;

@interface DCSearchViewController : DCViewController
- (void)setSearchStyle:(DCSearchStyle)style;
- (DCSearchStyle)currentSearchStyle;
- (void)deselectPoleAnnotation:(id)sender;
- (void)selectPoiInfo:(BMKPoiInfo *)info;
- (void)showPoleInfoViewForAnnotation:(DCPoleMapAnnotation *)annotation;
@end

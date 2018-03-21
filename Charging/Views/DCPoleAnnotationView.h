//
//  HSSYPoleAnnotationView.h
//  Charging
//
//  Created by xpg on 15/4/23.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "BaiduMapKits.h"

@class DCPoleMapAnnotation;

@protocol PaopaoViewAction <NSObject>
@optional
- (void)paopaoViewClicked:(id)sender;
@end

@interface DCPoleAnnotationView : BMKAnnotationView
@property (readonly, nonatomic) DCPoleMapAnnotation *poleAnnotation;
@end

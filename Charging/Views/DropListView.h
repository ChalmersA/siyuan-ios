//
//  DropListView.h
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropListView : UIView
@property (copy, nonatomic) void (^willDismiss)(DropListView *view);
- (instancetype)initWithListView:(UIView *)listView;
- (void)dropListAtPoint:(CGPoint)point;
- (void)dropListAlignRightOnView:(UIView *)view topSpace:(CGFloat)topSpace;
- (void)dismiss;
@end

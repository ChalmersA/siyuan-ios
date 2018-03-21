//
//  UIView+HSSYView.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HSSYView)
- (void)setCornerRadius:(CGFloat)radius;
- (void)setBorderColor:(UIColor *)color width:(CGFloat)width;
+ (instancetype)loadViewWithNib:(NSString *)nib;
- (void)removeAllSubviews;
- (void)traverseSubviewsWithBlock:(void(^)(UIView *view))block;
- (void)recursiveTraverseViewsWithBlock:(void(^)(UIView *view))block;

- (void)debugDrawBorder:(NSInteger)depth;

#pragma mark - Animation
-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
-(void)stopLayer:(CALayer*)layer;

@property (nonatomic) CGFloat frameHeight;
@property (nonatomic) CGFloat frameWidth;
@end

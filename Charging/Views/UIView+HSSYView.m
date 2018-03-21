//
//  UIView+HSSYView.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIView+HSSYView.h"

@implementation UIView (HSSYView)

#pragma mark - UI
- (void)setCornerRadius:(CGFloat)radius {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = radius;
}

- (void)setBorderColor:(UIColor *)color width:(CGFloat)width {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
}

#pragma mark - Frame
- (CGFloat)frameHeight {
    return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)frameHeight {
    CGRect frame = self.frame;
    frame.size.height = frameHeight;
    self.frame = frame;
}

- (CGFloat)frameWidth {
    return self.frame.size.width;
}

- (void)setFrameWidth:(CGFloat)frameWidth {
    CGRect frame = self.frame;
    frame.size.width = frameWidth;
    self.frame = frame;
}

#pragma mark - Subview
- (void)removeAllSubviews {
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }
}

- (void)traverseSubviewsWithBlock:(void(^)(UIView *view))block {
    for (UIView *view in self.subviews) {
        block(view);
    }
}

- (void)recursiveTraverseViewsWithBlock:(void(^)(UIView *view))block {
    block(self);
    for (UIView *view in self.subviews) {
        [view recursiveTraverseViewsWithBlock:block];
    }
}

#pragma mark - nib
+ (instancetype)loadViewWithNib:(NSString *)nib {
    return [self loadViewWithNib:nib index:0];
}

+ (instancetype)loadViewWithNib:(NSString *)nib index:(NSUInteger)index {
    return [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil][index];
}

#pragma mark - Animation
-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(void)stopLayer:(CALayer*)layer
{
    layer.speed = 0.0;
    layer.timeOffset = 0.0;
}


#pragma mark - Debug
- (void)debugDrawBorder:(NSInteger)depth {
#if DEBUG
    static NSUInteger i = 0;
    NSArray *colors = @[@"redColor", @"greenColor", @"blueColor", @"cyanColor", @"yellowColor", @"magentaColor", @"orangeColor", @"purpleColor", @"brownColor"];
    i = i % [colors count];
    UIColor *color = [UIColor performSelector:NSSelectorFromString(colors[i++])];
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 2;
    if (depth > 0) {
        for (UIView *subview in self.subviews) {
            [subview debugDrawBorder:depth - 1];
        }
    }
#endif
}

- (void)debugDrawBorderWithRange:(NSRange)range {
#if DEBUG
    if (range.length > 0) {
        if (range.location == 0) {
            [self debugDrawBorder:range.length - 1];
        }
        else if (range.location > 0) {
            for (UIView *subview in self.subviews) {
                [subview debugDrawBorderWithRange:NSMakeRange(range.location - 1, range.length)];
            }
        }
    }
#endif
}

@end

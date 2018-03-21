//
//  ArcLayer.h
//  Charging
//
//  Created by xpg on 15/5/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface ArcLayer : CAShapeLayer
+ (instancetype)layerWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle strokeColor:(UIColor *)color;
@end

@interface GradientArcLayer : CAShapeLayer
+ (instancetype)layerWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle startColor:(UIColor *)startColor endColor:(UIColor *)endColor;
@end

//
//  ArcLayer.m
//  Charging
//
//  Created by xpg on 15/5/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "ArcLayer.h"

@implementation ArcLayer
+ (instancetype)layerWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle strokeColor:(UIColor *)color {
    assert(endAngle >= startAngle);
    
    ArcLayer *layer = [ArcLayer layer];
    layer.path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES].CGPath;
    layer.lineWidth = 8;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = color.CGColor;
    return layer;
}
@end

@implementation GradientArcLayer

+ (instancetype)layerWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle startColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    assert(endAngle >= startAngle);
    
    GradientArcLayer *layer = [GradientArcLayer layer];
    
    CGFloat startColorRed, startColorGreen, startColorBlue, startColorAlpha;
    [startColor getRed:&startColorRed green:&startColorGreen blue:&startColorBlue alpha:&startColorAlpha];
    
    CGFloat endColorRed, endColorGreen, endColorBlue, endColorAlpha;
    [endColor getRed:&endColorRed green:&endColorGreen blue:&endColorBlue alpha:&endColorAlpha];
    
    int pieces = 60;
    CGFloat deltaAngle = (endAngle - startAngle) / pieces;
    
    for (int i = 0; i < pieces; i++) {
        CGFloat angle1 = startAngle + deltaAngle * i;
        CGFloat angle2 = startAngle + deltaAngle * (i + 1);
        UIColor *strokeColor = startColor;
        if (pieces > 1) {
            strokeColor = [UIColor colorWithRed:startColorRed + (endColorRed - startColorRed) * i / (pieces - 1)
                                          green:startColorGreen + (endColorGreen - startColorGreen) * i / (pieces - 1)
                                           blue:startColorBlue + (endColorBlue - startColorBlue) * i / (pieces - 1)
                                          alpha:1];
        }
        ArcLayer *sublayer = [ArcLayer layerWithCenter:center radius:radius startAngle:angle1 endAngle:angle2 strokeColor:strokeColor];
        [layer addSublayer:sublayer];
    }
    return layer;
}

@end

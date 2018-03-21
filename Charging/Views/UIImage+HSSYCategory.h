//
//  UIImage+HSSYCategory.h
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HSSYCategory)
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithBase64String:(NSString *)string;
- (NSString *)base64String;
- (UIImage *)imageScaled:(CGFloat)scale;
- (UIImage *)squareImage;
- (UIImage *)imageChangeOrientation:(UIImageOrientation)orientation;
- (UIImage *)imageWithFillColor:(UIColor *)color;
@end

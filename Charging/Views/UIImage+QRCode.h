//
//  UIImage+QRCode.h
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)
+ (UIImage *)qrcodeImageForString:(NSString *)string;
+ (UIImage *)qrcodeImageForString:(NSString *)string withScale:(CGFloat)scale;
+ (UIImage *)qrcodeImageForString:(NSString *)string withTintColor:(UIColor *)tintColor;
+ (UIImage *)qrcodeImageForString:(NSString *)string withTintColor:(UIColor *)tintColor scale:(CGFloat)scale;
@end

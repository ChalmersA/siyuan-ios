//
//  UIImage+HSSYCategory.m
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIImage+HSSYCategory.h"

@implementation UIImage (HSSYCategory)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [self imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithBase64String:(NSString *)string {
    if (string == nil) {
        return nil;
    }
    @try {
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [UIImage imageWithData:decodedImageData];
    }
    @catch (NSException *exception) {
        DDLogDebug(@"Cannot get the Image from Base64 with Error {%@}", exception.description);
        return nil;
    }
}

- (NSString *)base64String {
    NSData *data = UIImageJPEGRepresentation(self, 1);
    return [data base64EncodedStringWithOptions:0];
}

#pragma mark - Resize
- (UIImage *)imageScaled:(CGFloat)scale {
    CGSize size = CGSizeApplyAffineTransform(self.size, CGAffineTransformMakeScale(scale, scale));
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (UIImage *)imageResize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (UIImage *)squareImage {
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    CGFloat length = MIN(width, height);
    CGRect cropRect = CGRectMake((width - length)/2.0, (height - length)/2.0, length, length);
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *squareImage = [UIImage imageWithCGImage:imageRef];//[UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return squareImage;
}

#pragma mark - Orientation
- (UIImage *)imageChangeOrientation:(UIImageOrientation)orientation {
    UIImage *rotatedImage = [UIImage imageWithCGImage:self.CGImage scale:self.scale orientation:orientation];
    return rotatedImage;
}

- (UIImage *)imageWithFillColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

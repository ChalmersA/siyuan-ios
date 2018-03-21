//
//  UIImage+QRCode.m
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIImage+QRCode.h"

@implementation UIImage (QRCode)
+ (UIImage *)qrcodeImageForString:(NSString *)string {
    DDLogDebug(@"[[UIScreen mainScreen] scale] %f", [[UIScreen mainScreen] scale]);
    return [self qrcodeImageForString:string withScale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)qrcodeImageForString:(NSString *)string withScale:(CGFloat)scale {
    CIImage *ciImage = [self createQRForString:string];
    return [self createNonInterpolatedUIImageFromCIImage:ciImage withScale:scale];
}

+ (UIImage *)qrcodeImageForString:(NSString *)string withTintColor:(UIColor *)tintColor {
    DDLogDebug(@"[[UIScreen mainScreen] scale] %f", [[UIScreen mainScreen] scale]);
    return [self qrcodeImageForString:string withTintColor:tintColor scale:[[UIScreen mainScreen] scale]];
}

+ (UIImage *)qrcodeImageForString:(NSString *)string withTintColor:(UIColor *)tintColor scale:(CGFloat)scale {
    CIColor *ciForegroundColor = [self ciColorWithUIColor:tintColor];
    CIColor *ciBackgroundColor = [self ciColorWithUIColor:[UIColor whiteColor]];
    CIImage *ciImage = [self createQRForString:string];
    
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor" keysAndValues:@"inputImage", ciImage, @"inputColor0", ciForegroundColor, @"inputColor1", ciBackgroundColor, nil];
    ciImage = colorFilter.outputImage;
    colorFilter = [CIFilter filterWithName:@"CIMaskToAlpha" keysAndValues:@"inputImage", ciImage, nil];
    ciImage = colorFilter.outputImage;

    return [self createNonInterpolatedUIImageFromCIImage:ciImage withScale:scale];
}

+ (CIColor *)ciColorWithUIColor:(UIColor *)color {
    CGFloat red, green, blue, alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    return [CIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

#pragma mark - Utility methods
+ (CIImage *)createQRForString:(NSString *)qrString
{
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

+ (UIImage *)createNonInterpolatedUIImageFromCIImage:(CIImage *)image withScale:(CGFloat)scale
{
    // Render the CIImage into a CGImage
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:image fromRect:image.extent];
    
    // Now we'll rescale using CoreGraphics
    UIGraphicsBeginImageContext(CGSizeMake(image.extent.size.width * scale, image.extent.size.width * scale));
    CGContextRef context = UIGraphicsGetCurrentContext();
    // We don't want to interpolate (since we've got a pixel-correct image)
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    // Get the image out
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // Tidy up
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    // Need to set the image orientation correctly
    UIImage *flippedImage = [UIImage imageWithCGImage:[scaledImage CGImage]
                                                scale:scaledImage.scale
                                          orientation:UIImageOrientationDownMirrored];
    
    return flippedImage;
}

@end

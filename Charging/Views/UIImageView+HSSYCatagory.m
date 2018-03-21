//
//  UIImageView+HSSYCatagory.m
//  Charging
//
//  Created by  Blade on 5/29/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "UIImageView+HSSYCatagory.h"
#import "UIImageView+WebCache.h"
#import <objc/runtime.h>
#import "UIColor+HSSYColor.h"

static void * ProgressViewPropertyKey = &ProgressViewPropertyKey;

@implementation UIImageView (HSSYCatagory)
- (MBProgressHUD *)progressView {
    return objc_getAssociatedObject(self, ProgressViewPropertyKey);
}

- (void)setProgressView:(MBProgressHUD *)progressView {
    objc_setAssociatedObject(self, ProgressViewPropertyKey, progressView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark SDWebImage
- (void)customSd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    if (self.progressView) {
        [self.progressView hide:YES];
        self.progressView = nil;
    }
    self.progressView = [MBProgressHUD showHUDAddedTo:self animated:YES];
    self.progressView.activityIndicatorColor = [UIColor lightGrayColor];
    self.progressView.color = [UIColor clearColor];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *paramDic  = [NSDictionary dictionaryWithObjectsAndKeys:self.progressView,@"progressView", self, @"self", nil];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progressView(==self)]" options:0 metrics:0 views:paramDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[progressView(==self)]" options:0 metrics:0 views:paramDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[progressView]-0-|" options:0 metrics:0 views:paramDic]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[progressView]-0-|" options:0 metrics:0 views:paramDic]];
    [self sd_setImageWithURL:url placeholderImage:placeholder completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (self.progressView) {
            [self.progressView hide:NO];
            self.progressView = nil;
        }
        
//        if (error) {
//            self.image = nil;
//            UILabel* label =  [[UILabel alloc] init];
//            label.userInteractionEnabled = NO;
//            label.textColor = [UIColor grayColor];
//            label.text = @"加载图片出错";
//            label.textAlignment = NSTextAlignmentCenter;
//            label.translatesAutoresizingMaskIntoConstraints = NO;
//            [self addSubview:label];
//            NSDictionary *viewDic  = [NSDictionary dictionaryWithObjectsAndKeys:label,@"label", self, @"self", nil];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[label(==self)]" options:0 metrics:0 views:viewDic]];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label(==self)]" options:0 metrics:0 views:viewDic]];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|" options:0 metrics:0 views:viewDic]];
//            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:0 views:viewDic]];
//        }
        
    }];
}
@end

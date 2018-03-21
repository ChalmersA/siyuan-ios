//
//  UIImageView+HSSYSDWebImageCategory.m
//  Charging
//
//  Created by kufufu on 15/12/10.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "UIImageView+HSSYSDWebImageCategory.h"
#import "Reachability.h"
#import "DCApp.h"
#import <objc/runtime.h>

static const char *isLoadKey = "isLoadKey";

@implementation UIImageView (HSSYSDWebImageCategory)

- (void)hssy_sd_setImageWithURL:(NSURL *)url {
    [self hssy_sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self hssy_sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self hssy_sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self hssy_sd_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self hssy_sd_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self hssy_sd_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    
    NetworkStatusx reach = [DCApp sharedApp].networkStatus;
    
    NSUserDefaults *wifeMode = [NSUserDefaults standardUserDefaults];
    if ([[wifeMode objectForKey:@"saveGPRSMode"] isEqualToString:@"On"]) {
        if ([self.isLoad  isEqualToNumber: @(NO)]) {
            if (reach == ReachableViaWWAN) { // Assume the network is out
                if (!(options & SDWebImageDelayPlaceholder)) {
                    dispatch_main_async_safe(^{
                        self.image = placeholder;
                    });
                }
                
                __weak UIImageView *wself = self;
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
                __block UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
                __block SDImageCacheType cacheType = SDImageCacheTypeDisk;
                __block NSURL* imageUrl = url;
                if (!image) {
                    image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
                    cacheType = SDImageCacheTypeMemory;
                }
                dispatch_main_sync_safe(^{
                    if (!wself) return;
                    NSError* error = nil;
                    if (image) {
                        wself.image = image;
                        [wself setNeedsLayout];
                        return;
                    } else {
                        if ((options & SDWebImageDelayPlaceholder)) {
                            wself.image = placeholder;
                            [wself setNeedsLayout];
                        }
                        cacheType = SDImageCacheTypeNone;
                        error = [[NSError alloc] initWithDomain:NSURLErrorDomain code:-1004 userInfo:nil];
                    }
                    
                    if (completedBlock) {
                        completedBlock(image, error, cacheType, imageUrl);
                    }
                });
            } else {
                 [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
            }
        } else {
            [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
        }
    } else {
        [self sd_setImageWithURL:url placeholderImage:placeholder options:options progress:progressBlock completed:completedBlock];
    }
}

// get方法
- (NSNumber *)isLoad {
    return (NSNumber *)objc_getAssociatedObject(self, &isLoadKey);
}

// set方法
- (void)setIsLoad:(NSNumber *)newIsLoad {
    objc_setAssociatedObject(self, &isLoadKey, newIsLoad, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

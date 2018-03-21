//
//  UIImageView+HSSYSDWebImageCategory.h
//  Charging
//
//  Created by kufufu on 15/12/10.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (HSSYSDWebImageCategory)

@property (nonatomic, strong) NSNumber *isLoad;

- (void)hssy_sd_setImageWithURL:(NSURL *)url;

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;

- (void)hssy_sd_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;

- (void)hssy_sd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;
@end

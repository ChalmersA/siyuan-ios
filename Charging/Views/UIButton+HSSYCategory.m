//
//  UIButton+HSSYCategory.m
//  Charging
//
//  Created by xpg on 15/1/27.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "UIButton+HSSYCategory.h"
#import "UIButton+WebCache.h"
#import "UIImageView+HSSYSDWebImageCategory.h"

@implementation UIButton (HSSYCategory)

- (void)setCircleAvatarURL:(NSURL *)URL andImage:(UIImage *)image {
    if (URL) {
        self.layer.borderWidth = 0;
        typeof(self) __weak weakSelf = self;
        [self sd_setImageWithURL:URL forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_user_avatar_white"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                [weakSelf setRoundBorder];
            }
        }];
    } else if (image) {
        [self setImage:image forState:UIControlStateNormal];
        [self setRoundBorder];
    } else {
        self.layer.borderWidth = 0;
        [self setImage:[UIImage imageNamed:@"default_user_avatar_white"] forState:UIControlStateNormal];
    }
}

- (void)setRoundBorder {
    self.layer.cornerRadius = CGRectGetMidX(self.bounds);
    self.layer.borderColor = [UIColor colorWithWhite:204/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 2;
    self.layer.masksToBounds = YES;
}

@end

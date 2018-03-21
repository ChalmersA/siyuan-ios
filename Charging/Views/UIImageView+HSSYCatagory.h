//
//  UIImageView+HSSYCatagory.h
//  Charging
//
//  Created by  Blade on 5/29/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface UIImageView (HSSYCatagory)
@property (nonatomic, retain) MBProgressHUD* progressView;
- (void)customSd_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
@end

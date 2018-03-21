//
//  HSSYPoleImageControl.h
//  Charging
//
//  Created by xpg on 5/28/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPoleImageControl : UIControl
@property (copy, nonatomic) NSString *imageUrl;
@property (strong, nonatomic) UIImageView *imageView;
//@property (strong, nonatomic) CAShapeLayer *borderLayer;
//@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *bkImageView;

- (void)setImageUrl:(NSString *)url placeholderImage:(UIImage *)placeholder;
- (BOOL)hasImage;
@end

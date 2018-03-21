//
//  HSSYPoleImageControl.m
//  Charging
//
//  Created by xpg on 5/28/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCPoleImageControl.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "NSURL+HSSYImage.h"

@interface DCPoleImageControl ()
@end

@implementation DCPoleImageControl

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    
//    CAShapeLayer *borderLayer = [CAShapeLayer layer];
//    borderLayer.fillColor = [UIColor clearColor].CGColor;
//    borderLayer.strokeColor = [UIColor lightGrayColor].CGColor;
//    borderLayer.lineWidth = 1;
//    borderLayer.lineDashPattern = @[@4, @4];
//    [self.layer addSublayer:borderLayer];
//    self.borderLayer = borderLayer;
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
//    label.textColor = [UIColor lightGrayColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.numberOfLines = 2;
//    label.text = @"添加\n图片";
//    [self addSubview:label];
//    self.label = label;
//    
    UIImageView * bkImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    bkImageView.contentMode = UIViewContentModeScaleToFill;
    bkImageView.clipsToBounds = YES;
    bkImageView.image = [UIImage imageNamed:@"icon_addpic_unfocused"];
    [self addSubview:bkImageView];
    self.bkImageView = bkImageView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.clipsToBounds = YES;
    imageView.hidden = YES;
//    imageView. = [UIImage imageNamed:@"icon_addpic_unfocused"];
    [self addSubview:imageView];
    self.imageView = imageView;
    self.imageView.isLoad = @(NO);
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4].CGPath;
//    self.borderLayer.frame = self.bounds;
//    
//    self.label.frame = self.bounds;
    
    self.bkImageView.frame = self.bounds;
    
    self.imageView.frame = self.bounds;
    
    
}

#pragma mark - Public
- (void)setImageUrl:(NSString *)url placeholderImage:(UIImage *)placeholder {
    if (url.length) {
        self.imageUrl = url;
        [self.imageView hssy_sd_setImageWithURL:[NSURL URLWithImagePath:url] placeholderImage:placeholder];
    } else {
        self.imageUrl = nil;
        [self.imageView sd_setImageWithURL:nil placeholderImage:nil];
    }
    
    self.imageView.hidden = (self.imageUrl == nil);
//    self.borderLayer.hidden = !self.imageView.hidden;
//    self.label.hidden = !self.imageView.hidden;
    self.bkImageView.hidden = !self.imageView.hidden;
}

- (BOOL)hasImage {
    return !self.imageView.hidden;
}

@end

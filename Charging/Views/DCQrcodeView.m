//
//  HSSYQrcodeView.m
//  Charging
//
//  Created by Ben on 14/12/25.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCQrcodeView.h"

@interface DCQrcodeView ()
@property (nonatomic,weak) IBOutlet UIImageView *qrcodeImageView;
@end

@implementation DCQrcodeView

+ (instancetype)viewWithQrcodeImage:(UIImage *)image {
    DCQrcodeView *view = [DCQrcodeView loadViewWithNib:@"DCQrcodeView"];
    view.qrcodeImageView.image = image;
    return view;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
}

@end

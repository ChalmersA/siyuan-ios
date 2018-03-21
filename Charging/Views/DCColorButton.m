//
//  HSSYColorButton.m
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCColorButton.h"
#import "UIImage+HSSYCategory.h"

@implementation DCColorButton

//- (void)drawRect:(CGRect)rect {
//    
//}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = self.backgroundColor;
    [self setColorImage:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    [self setCornerRadius:6];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self setColorImage:backgroundColor forState:UIControlStateNormal];
}

- (void)setColorImage:(UIColor *)color forState:(UIControlState)state {
    UIImage *image = [UIImage imageWithColor:color];
    [self setBackgroundImage:image forState:state];
}

@end

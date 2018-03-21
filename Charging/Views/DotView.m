//
//  DotView.m
//  Charging
//
//  Created by xpg on 15/3/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DotView.h"

@interface DotView ()
@end

@implementation DotView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor paletteDCMainColor];
    [self setCornerRadius:CGRectGetMidX(self.bounds)];
}

@end

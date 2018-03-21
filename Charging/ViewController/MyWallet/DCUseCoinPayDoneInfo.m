//
//  HSSYUseCoinPayDoneInfo.m
//  Charging
//
//  Created by Pp on 15/12/17.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCUseCoinPayDoneInfo.h"

@implementation DCUseCoinPayDoneInfo

- (instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"DCUseCoinPayDoneInfo" owner:self options:nil];
        self = [views firstObject];
        self.frame = frame;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return self;
}

@end

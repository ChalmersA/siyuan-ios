//
//  HSSYSeparateLine.m
//  Charging
//
//  Created by  Blade on 8/13/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCSeparateLine.h"
#import "UIColor+HSSYColor.h"

@implementation DCSeparateLine

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib {
    [super awakeFromNib];
    if(self.DefaultLineColor) {
        self.backgroundColor = self.DefaultLineColor;
    }
    else {
        self.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    }
}

@end

//
//  HSSYWeekButton.m
//  Charging
//
//  Created by Ben on 15/1/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCWeekButton.h"
#import "UIColor+HSSYColor.h"

@implementation DCWeekButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor paletteDCMainColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
    [self.delegate weekButtonSelectedChange];
}

@end

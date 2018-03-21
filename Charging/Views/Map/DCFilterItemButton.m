//
//  DCFilterItemButton.m
//  Charging
//
//  Created by Ben on 4/29/16.
//  Copyright © 2016 xpg. All rights reserved.
//

#import "DCFilterItemButton.h"
#import "Charging-Swift.h"

@implementation DCFilterItemButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setCornerRadius];
        [self setBorderColor:[UIColor paletterFontGreyColor]];
    }
    return self;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    [self setBackgroundColor:selected ? [UIColor paletteDCMainColor] : [UIColor whiteColor]];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor paletterFontGreyColor] forState:UIControlStateNormal];
}
@end

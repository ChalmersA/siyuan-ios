//
//  HSSYPeriodTableViewCell.m
//  Charging
//
//  Created by  Blade on 8/20/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCPeriodTableViewCell.h"

@implementation DCPeriodTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    static UIColor *fontMainGreen;
    static UIColor *fontDarkGray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        fontMainGreen = [UIColor paletteDCMainColor];
        fontDarkGray = [UIColor paletteFontDarkGrayColor];
    });
    [self.periodLabel setTextColor:selected ? fontMainGreen : fontDarkGray];
    
    // Configure the view for the selected state
}

@end

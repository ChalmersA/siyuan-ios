//
//  DevicesWindowTableViewCell.m
//  GuoBangCleaner
//
//  Created by Ben on 15/8/27.
//  Copyright (c) 2015年 com.xpg. All rights reserved.
//

#import "DevicesWindowTableViewCell.h"

@implementation DevicesWindowTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)updateViewWithStation:(DCStation *)station{
    self.deviceNameLabel.text = station.stationName;
}

@end

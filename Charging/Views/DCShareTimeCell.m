//
//  HSSYShareTimeCell.m
//  Charging
//
//  Created by xpg on 5/21/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCShareTimeCell.h"
#import "DCTime.h"

@implementation DCShareTimeCell

- (void)awakeFromNib {
    // Initialization code
    self.tintColor = [UIColor paletteDCMainColor];
    self.titleLabel.textColor = [UIColor paletteDCMainColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configForShareTime:(DCTime *)shareTime {
    self.shareTime = shareTime;
    self.titleLabel.text = @"时间段";
    self.timeLabel.text = shareTime.timeFrameString;
    self.weekLabel.text = shareTime.weekStringCN;
}

- (void)configForShareTime:(DCTime *)shareTime title:(NSString *)title color:(UIColor *)color {
    self.shareTime = shareTime;
    self.timeLabel.text = shareTime.timeFrameString;
    self.weekLabel.text = shareTime.weekStringCN;
    
    self.titleLabel.text = title;
    
    if (color) {
        self.titleLabel.textColor = color;
        self.timeLabel.textColor = color;
        self.weekLabel.textColor = color;
    } else {
        self.titleLabel.textColor = [UIColor paletteDCMainColor];
        self.timeLabel.textColor = [UIColor blackColor];
        self.weekLabel.textColor = [UIColor darkGrayColor];
    }
}

@end

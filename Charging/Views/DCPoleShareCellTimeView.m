//
//  HSSYPoleShareCellTimeView.m
//  Charging
//
//  Created by xpg on 5/21/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCPoleShareCellTimeView.h"

@implementation DCPoleShareCellTimeView

+ (instancetype)loadFromNib {
    return [self loadViewWithNib:@"DCPoleShareCellTimeView"];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLabel.textColor = [UIColor paletteDCMainColor];
}

@end

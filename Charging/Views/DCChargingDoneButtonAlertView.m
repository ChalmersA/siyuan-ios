//
//  HSSYChargingDoneButtonAlertView.m
//  Charging
//
//  Created by hxcui on 15/8/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCChargingDoneButtonAlertView.h"

@implementation DCChargingDoneButtonAlertView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleView.backgroundColor = [UIColor paletteDCMainColor];
//    [self.doneButton setTitleColor:[UIColor paletteOrangeColor] forState:UIControlStateNormal];
    self.doneButton.layer.masksToBounds = YES;
    self.doneButton.layer.cornerRadius = 4;
}
@end

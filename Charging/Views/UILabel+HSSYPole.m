//
//  UILabel+HSSYPole.m
//  Charging
//
//  Created by chenzhibin on 15/10/30.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "UILabel+HSSYPole.h"

@implementation UILabel (HSSYPole)

- (void)configForStationStatus:(HSSYStationIsIdle)status {
    self.text = @"未知";
    self.textColor = [UIColor paletteFontDarkGrayColor];
    switch (status) {
        case HSSYStationIsIdleFree:
            self.text = @"有空闲";
            self.textColor = [UIColor paletteDCMainColor];
            break;
        case HSSYStationIsIdleFullLoad:
            self.text = @"满载";
            self.textColor = [UIColor paletteOrangeColor];
            break;
        case HSSYStationIsIdleOffline:
            self.text = @"离网";
            break;
        default: break;
    }
}

@end

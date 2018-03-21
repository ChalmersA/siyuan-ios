//
//  HSSYPoleSettingCell.m
//  Charging
//
//  Created by xpg on 14/12/22.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCPoleSettingCell.h"

@implementation DCPoleSettingCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.titleLabel.textColor = [UIColor blackColor];
    self.settingLabel.textColor = [UIColor colorWithWhite:0.525 alpha:1.000];
    self.settingSwitch.onTintColor = [UIColor paletteDCMainColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIEdgeInsets)layoutMargins {
    return UIEdgeInsetsZero;
}

- (IBAction)settingSwitchChanged:(UISwitch *)sender {
    if ([_delegate respondsToSelector:@selector(settingSwitchButtonClick:buttonTag:)]) {
        [_delegate settingSwitchButtonClick:self.item buttonTag:sender.tag];
    }
}

@end

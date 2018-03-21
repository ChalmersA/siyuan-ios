//
//  HSSYChargeOneButtonAlertView.m
//  Charging
//
//  Created by kufufu on 15/10/31.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCChargeOneButtonAlertView.h"

@implementation DCChargeOneButtonAlertView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self newInit];
    }
    return self;
}

- (void)newInit {
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleView.backgroundColor = [UIColor paletteDCMainColor];
    [self.confirmButton setTitleColor:[UIColor paletteDCMainColor] forState:UIControlStateNormal];
}

#pragma mark - Action
- (IBAction)confrimButtonClick:(id)sender {
    [self.delegate confirmButtonClick];
}

#pragma mark - Public
- (void)setTitle:(NSString *)title content:(NSString *)content confirmbutton:(NSString *)confirmButton {
    self.titleLabel.text = title;
    self.contentLabel.text = content;
    [self.confirmButton setTitle:confirmButton forState:UIControlStateNormal];
}

@end

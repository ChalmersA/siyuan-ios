//
//  HSSYChargeTwoButtonAlertView.m
//  Charging
//
//  Created by kufufu on 15/10/28.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCChargeTwoButtonAlertView.h"

@implementation DCChargeTwoButtonAlertView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
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

#pragma mark Action
- (IBAction)cancelButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(cancelButtonClick:)]) {
        [self.delegate cancelButtonClick:self.style];
    }
}

- (IBAction)confirmButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(confirmButtonClick:)]) {
        [self.delegate confirmButtonClick:self.style];
    }
}

#pragma mark public
- (void)setTitle:(NSString *)title pileName:(NSString *)pileName ownerName:(NSString *)ownerName price:(NSString *)price cancelButton:(NSString *)cancelButton confirmbutton:(NSString *)confirmButton {
    
    self.titleLabel.text = title;
    self.pileNameLabel.text = pileName;
    self.ownerNameLabel.text = ownerName;
    self.priceLabel.text = price;
    [self.cancelButton setTitle:cancelButton forState:UIControlStateNormal];
    [self.confirmButton setTitle:confirmButton forState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title content:(NSString *)content cancelButton:(NSString *)cancelButton confirmbutton:(NSString *)confirmButton {
    
    self.titleLabel.text = title;
    self.detailLabel.text = content;
    [self.cancelButton setTitle:cancelButton forState:UIControlStateNormal];
    [self.confirmButton setTitle:confirmButton forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  InFormationCell.m
//  Charging
//
//  Created by 陈志强 on 2018/3/6.
//  Copyright © 2018年 xpg. All rights reserved.
//  充电卡信息

#import "InFormationCell.h"

@implementation InFormationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.blueView.layer setCornerRadius:8];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//删除充电卡 的点击事件
- (IBAction)deletedButtonClick:(UIButton *)sender {
    
    if (self.clickButtonBlock) {
        self.clickButtonBlock();
    }
    
}

@end

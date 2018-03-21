//
//  HSSYQuickShareCell.m
//  Charging
//
//  Created by xpg on 14/12/25.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCQuickShareCell.h"

NSString * const kQuickShareCellName = @"NameCell";
NSString * const kQuickShareCellTime = @"TimeCell";
NSString * const kQuickShareCellUpdate = @"UpdateCell";
NSString * const kQuickShareCellShare = @"ShareCell";

@implementation DCQuickShareCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)shareAction:(id)sender {//马上发布
    if ([self.delegate respondsToSelector:@selector(quickShare:withInfo:)]) {
        [self.delegate quickShare:HSSYQuickShareRelease withInfo:self.cellInfo];
    }
}

- (IBAction)updateAction:(id)sender {//更新发布
    if ([self.delegate respondsToSelector:@selector(quickShare:withInfo:)]) {
        [self.delegate quickShare:HSSYQuickShareUpdate withInfo:self.cellInfo];
    }
}

- (IBAction)cancelAction:(id)sender {//取消发布
    if ([self.delegate respondsToSelector:@selector(quickShare:withInfo:)]) {
        [self.delegate quickShare:HSSYQuickShareCancel withInfo:self.cellInfo];
    }
}

@end

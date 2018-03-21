//
//  HSSYBleListTableViewCell.m
//  Charging
//
//  Created by Ben on 14/12/19.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCBleListTableViewCell.h"

@implementation DCBleListTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end

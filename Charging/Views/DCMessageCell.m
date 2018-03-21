//
//  HSSYMessageCell.m
//  Charging
//
//  Created by xpg on 15/3/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCMessageCell.h"
#import "NSDateFormatter+HSSYCategory.h"
#import "NSDate+HSSYDate.h"

@implementation DCMessageCell

- (void)awakeFromNib {
    // Initialization code
    self.titleLabel.textColor = [UIColor paletteDCMainColor];
    self.contentLabel.textColor = [UIColor darkGrayColor];
    self.timeLabel.textColor = [UIColor darkGrayColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - HSSYMessage
- (void)configureForMessage:(DCMessage *)message {
    self.dotView.hidden = (message.status == DCMessageStatusRead);
    self.titleLabel.text = message.title;
    self.contentLabel.text = message.content;
    self.timeLabel.text = [NSDate stringDateFromNow:message.createTime];
}

@end

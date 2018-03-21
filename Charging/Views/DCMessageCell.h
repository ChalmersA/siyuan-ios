//
//  HSSYMessageCell.h
//  Charging
//
//  Created by xpg on 15/3/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCMessage.h"
#import "DotView.h"

@interface DCMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet DotView *dotView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (void)configureForMessage:(DCMessage *)message;
@end

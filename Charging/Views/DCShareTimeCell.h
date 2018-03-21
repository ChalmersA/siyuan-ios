//
//  HSSYShareTimeCell.h
//  Charging
//
//  Created by xpg on 5/21/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCTime;

@interface DCShareTimeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (strong, nonatomic) DCTime *shareTime;
- (void)configForShareTime:(DCTime *)shareTime;
- (void)configForShareTime:(DCTime *)shareTime title:(NSString *)title color:(UIColor *)color;
@end

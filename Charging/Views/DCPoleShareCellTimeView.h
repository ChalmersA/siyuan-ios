//
//  HSSYPoleShareCellTimeView.h
//  Charging
//
//  Created by xpg on 5/21/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DCPoleShareCellTimeView : UIView
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
+ (instancetype)loadFromNib;
@end

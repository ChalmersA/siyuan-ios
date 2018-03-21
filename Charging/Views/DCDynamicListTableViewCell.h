//
//  DCDynamicListTableViewCell.h
//  Charging
//
//  Created by xpg on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCDynamicDetailsList.h"

@interface DCDynamicListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *dynamicImageView;
@property (weak, nonatomic) IBOutlet UILabel *dynamicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dynamicTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dynamicTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkNumber;

@property (strong, nonatomic) DCDynamicDetailsList *dynamicDetailsList;

- (void)configureForDynamicDetailsList:(DCDynamicDetailsList *)DynamicDetailsList;
@end

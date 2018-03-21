//
//  DCIncomePayTableViewCell.h
//  Charging
//
//  Created by Pp on 15/12/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCoinRecord.h"

@interface DCIncomePayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *secondTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondContentLabel;

@property (weak, nonatomic) IBOutlet UILabel *thirdTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdContentLabel;

@property (weak, nonatomic) IBOutlet UIView *forthView;
@property (weak, nonatomic) IBOutlet UILabel *forthContentLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

- (void)configViewWithCoinRecord:(DCCoinRecord *)coinRecord;

@end
//
//  DCBookEditableCell.h
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCChargeEditableCell.h"

static float cellHeight;
@interface DCBookEditableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookingTime;
@property (weak, nonatomic) IBOutlet UILabel *reserveFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *returnFeeLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomTipLabel;

@property (weak, nonatomic) IBOutlet UIView *returnTimeView;
@property (weak, nonatomic) IBOutlet UIView *returnFeeView;

@property (strong, nonatomic) DCOrder *order;


@property (weak, nonatomic) id <DCChargeEditableCellDelegate> delegate;

- (void)configForOrder:(DCOrder *)order;
+ (CGFloat)cellHeight;
- (void)updateEditingState:(BOOL)editing;

@end

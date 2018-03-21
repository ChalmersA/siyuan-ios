//
//  DCChargeNormalCell.h
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCChargeEditableCell.h"

static float cellHeight;
@interface DCChargeNormalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeFeeLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet UILabel *bottomTipLabel;

@property (weak, nonatomic) IBOutlet UIView *chargeFeeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonConstraint;

@property (strong, nonatomic) DCOrder *order;

@property (weak, nonatomic) id<DCChargeEditableCellDelegate>delegate;
- (void)configForOrder:(DCOrder *)order;

+ (CGFloat)cellHeight;
@end

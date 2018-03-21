//
//  HSSYChargeDoneViewController.h
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCChargingDoneCell.h"
#import "NSDate+HSSYDate.h"
#import "DCChargingDoneButtonAlertView.h"

@protocol ChargeDoneViewDelegate <NSObject>

- (void)chargeDoneViewShow;

@end

@interface DCChargeDoneViewController : DCViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHintHeight;
@property (weak, nonatomic) id <ChargeDoneViewDelegate> delegate;
@property (strong, nonatomic) DCUser *user;
@property (copy, nonatomic) NSString *orderId;
@end


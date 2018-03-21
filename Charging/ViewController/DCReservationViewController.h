//
//  DCReservationDoneViewController.h
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCColorButton.h"
#import "DCStation.h"

@interface DCReservationViewController : DCViewController
@property (weak, nonatomic) IBOutlet UIButton *ACTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *DCTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *halfHourButton;
@property (weak, nonatomic) IBOutlet UIButton *oneHourButton;
@property (weak, nonatomic) IBOutlet UIButton *oneHalfHourButton;
@property (weak, nonatomic) IBOutlet UIButton *twoHourButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bookFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveTipLabel;


@property (strong, nonatomic) DCStation *staion;

@end



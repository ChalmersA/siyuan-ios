//
//  DCReservationDoneViewController.h
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCStation.h"

@interface DCReservationDoneViewController : DCViewController

@property (strong, nonatomic) DCOrder *bookOrder;
@property (strong, nonatomic) DCStation *bookStation;

@end

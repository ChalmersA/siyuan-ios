//
//  DCStartChargeParams.h
//  Charging
//
//  Created by kufufu on 16/4/8.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCStartChargeParams : DCModel

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *deviceId;
@property (assign, nonatomic) NSInteger chargePortIndex;
@property (assign, nonatomic) DCChargeModeType chargeModeType;
@property (assign, nonatomic) double chargeLimit;

@property (copy, nonatomic) NSString *pileName;
@property (assign, nonatomic) DCPileType pileType;
@property (assign, nonatomic) double chargeFee;

@property (assign, nonatomic) BOOL isHasChargePort;
@property (assign, nonatomic) BOOL isHasFloorLock;

@end

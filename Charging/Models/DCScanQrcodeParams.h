//
//  DCScanQrcodeParams.h
//  Charging
//
//  Created by kufufu on 16/4/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCPile.h"

@interface DCScanQrcodeParams : DCModel

@property (strong, nonatomic) DCPile *pile;
@property (assign, nonatomic) double chargeFee;
@property (assign, nonatomic) BOOL isOrder;
@property (assign, nonatomic) NSInteger orderChargePort;

- (instancetype) initScanQrcodeParamsWithDict:(NSDictionary *)dict;

@end

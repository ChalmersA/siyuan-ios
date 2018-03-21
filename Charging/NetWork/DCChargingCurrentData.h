//
//  DCChargingCurrentData.h
//  Charging
//
//  Created by kufufu on 16/3/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCChargingCurrentData : DCModel

@property (copy, nonatomic) NSString *device_status;
@property (copy, nonatomic) NSString *device_type;
@property (copy, nonatomic) NSString *device_number;
@property (copy, nonatomic) NSString *gun_number;
@property (assign, nonatomic) double voltage;
@property (assign, nonatomic) double current;
@property (assign, nonatomic) double consumtion;
@property (assign, nonatomic) double soc;
@property (copy, nonatomic) NSString *order_id;
@property (copy, nonatomic) NSString *order_type;

- (instancetype)initChargingCurrentDataWithDict:(NSDictionary *)dict;

@end

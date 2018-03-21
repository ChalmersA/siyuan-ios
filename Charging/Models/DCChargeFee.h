//
//  DCChargeFee.h
//  Charging
//
//  Created by kufufu on 16/3/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCChargeFee : DCModel

@property (copy, nonatomic) NSString *defaultFee;
@property (strong, nonatomic) NSArray *timeQuantum;

- (instancetype)initChargeFeeWithDict:(NSDictionary *)dict;

@end

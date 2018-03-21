//
//  DCChargingCurrentData.m
//  Charging
//
//  Created by kufufu on 16/3/11.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargingCurrentData.h"

@implementation DCChargingCurrentData

- (instancetype)initChargingCurrentDataWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isKindOfClass:[NSString class]]) {
        if ([key isEqualToString:@"device_type"] ||
            [key isEqualToString:@"order_type"]) {
            value = @([value integerValue]);
        }
    }
    [super setValue:value forKey:key];
}

@end

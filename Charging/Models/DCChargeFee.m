//
//  DCChargeFee.m
//  Charging
//
//  Created by kufufu on 16/3/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargeFee.h"

@implementation DCChargeFee

- (instancetype)initChargeFeeWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"timeQuantum"]) {
                self.timeQuantum = [dict objectForKey:@"timeQuantum"];
            }
        }
    }
    return self;
}

@end

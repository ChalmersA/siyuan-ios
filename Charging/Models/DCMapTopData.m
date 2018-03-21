//
//  DCMapTopData.m
//  Charging
//
//  Created by kufufu on 16/5/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCMapTopData.h"

@implementation DCMapTopData

- (instancetype)initMapDataWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"stationTotal"]) {
                self.stationCount = [[dict objectForKey:@"stationTotal"] integerValue];
            }
            if ([dict objectForKey:@"pileTotal"]) {
                self.pileCount = [[dict objectForKey:@"pileTotal"] integerValue];
            }
            if ([dict objectForKey:@"idlePileTotal"]) {
                self.idleCount = [[dict objectForKey:@"idlePileTotal"] integerValue];
            }
            if ([dict objectForKey:@"noIdlePileTotal"]) {
                self.noIdleCount = [[dict objectForKey:@"noIdlePileTotal"] integerValue];
            }
        }
    }
    return self;
}

@end

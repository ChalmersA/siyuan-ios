//
//  HSSYListPole.m
//  Charging
//
//  Created by xpg on 15/5/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCListStation.h"

@implementation DCListStation

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if (![dict isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        _station = [[DCStation alloc] initStationWithDict:dict];
        
        _isIdle = [[dict stringForKey:@"hasFreePile"] isEqualToString:@"0"];
    }
    return self;
}
@end

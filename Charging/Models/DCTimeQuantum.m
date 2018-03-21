//
//  DCTimeQuantum.m
//  Charging
//
//  Created by kufufu on 16/4/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCTimeQuantum.h"

@implementation DCTimeQuantum

- (instancetype)initTimeQuantumWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict objectForKey:@"start"]) {
            self.startTime = [dict objectForKey:@"start"];
        }
        if ([dict objectForKey:@"end"]) {
            self.endTime = [dict objectForKey:@"end"];
        }
    }
    return self;
}

@end

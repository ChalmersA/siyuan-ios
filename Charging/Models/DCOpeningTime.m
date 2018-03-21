//
//  DCOpeningTime.m
//  Charging
//
//  Created by kufufu on 16/3/5.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCOpeningTime.h"

@implementation DCOpeningTime

- (instancetype)initOpeningAtWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"openType"]) {
                self.openType = [dict integerForKey:@"openType"];
            }
            if ([dict objectForKey:@"start"]) {
                self.startTime = [dict objectForKey:@"start"];
            }
            if ([dict objectForKey:@"end"]) {
                self.endTime = [dict objectForKey:@"end"];
            }
        }
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.openType forKey:@"openType"];
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _openType = [aDecoder decodeIntegerForKey:@"openType"];
        _startTime = [aDecoder decodeObjectForKey:@"startTime"];
        _endTime = [aDecoder decodeObjectForKey:@"endTime"];
    }
    return self;
}

@end

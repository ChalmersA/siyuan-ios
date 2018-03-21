//
//  HSSYStationPile.m
//  Charging
//
//  Created by Pp on 15/10/23.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCStationPile.h"

@implementation DCStationPile

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if ([super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)StationPileWithDict:(NSDictionary *)dict
{
     return [[self alloc]initWithDict:dict];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

@end

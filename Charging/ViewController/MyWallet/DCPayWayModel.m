//
//  HSSYPayWayModel.m
//  Charging
//
//  Created by Pp on 15/12/14.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCPayWayModel.h"

@implementation DCPayWayModel

+ (instancetype)payWayWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
}


@end

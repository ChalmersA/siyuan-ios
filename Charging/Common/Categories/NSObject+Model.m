//
//  NSObject+Model.m
//  Charging
//
//  Created by xpg on 15/4/30.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "NSObject+Model.h"

@implementation NSObject (Model)

- (NSDictionary *)dictionaryObject {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)self;
    }
    return nil;
}

- (NSArray *)arrayObject {
    if ([self isKindOfClass:[NSArray class]]) {
        return (NSArray *)self;
    }
    return nil;
}

- (NSString *)stringObject {
    if ([self isKindOfClass:[NSString class]]) {
        return (NSString *)self;
    } else if ([self isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)self;
        return number.stringValue;
    }
    return nil;
}

- (NSNumber *)numberObject {
    if ([self isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)self;
    }
    return nil;
}

@end

//
//  NSDictionary+Model.m
//  Charging
//
//  Created by xpg on 15/4/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "NSDictionary+Model.h"

@implementation NSDictionary (Model)

- (NSDictionary *)dictionaryForKey:(id)key {
    id obj = self[key];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return obj;
    }
    return nil;
}

- (NSArray *)arrayForKey:(id)key {
    id obj = self[key];
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }
    return nil;
}

- (NSString *)stringForKey:(id)key {
    id obj = self[key];
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj respondsToSelector:@selector(stringValue)]) {
        return [obj stringValue];
    }
    return nil;
}

- (NSNumber *)numberForKey:(id)key {
    id obj = self[key];
    if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }
    return nil;
}

- (NSInteger)integerForKey:(id)key {
    id obj = self[key];
    if ([obj respondsToSelector:@selector(integerValue)]) {
        return [obj integerValue];
    }
    return 0;
}

- (double)doubleForKey:(id)key {
    id obj = self[key];
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    }
    return 0;
}

@end

@implementation NSMutableDictionary (Model)

- (void)setDictionary:(NSDictionary *)dict forKey:(id)key {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        [self setObject:dict forKey:key];
    }
}

- (void)setArray:(NSArray *)array forKey:(id)key {
    if ([array isKindOfClass:[NSArray class]]) {
        [self setObject:array forKey:key];
    }
}

- (void)setString:(NSString *)string forKey:(id)key {
    if ([string isKindOfClass:[NSString class]]) {
        [self setObject:string forKey:key];
    }
}

- (void)setNumber:(NSNumber *)number forKey:(id)key {
    if ([number isKindOfClass:[NSNumber class]]) {
        [self setObject:number forKey:key];
    }
}

- (void)setInteger:(NSInteger)integer forKey:(id)key {
    [self setNumber:@(integer) forKey:key];
}

@end

//
//  HSSYModel.m
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"
#import <objc/runtime.h>

@implementation DCModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                //DDLogDebug(@"key:%@    value:%@(%@)", key, obj, [obj class]);
                [self setValue:obj forKey:key];
            }];
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if (value == [NSNull null]) {
        return;
    }
    
    objc_property_t property = class_getProperty([self class], key.UTF8String);
    if (property) {
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
//        DDLogDebug(@"%@: %@", key, attributes);
        if ([attributes rangeOfString:@"T@\"NSString\""].location != NSNotFound) {
            value = [value stringObject];
        }
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    DDLogError(@"setValue:forUndefinedKey: %@ %@ %@", [self class], key, value);
}

#pragma mark - Extension
+ (NSArray *)loadArrayFromPlist:(NSString *)plist {
    NSArray *dictArray = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:plist withExtension:@"plist"]];
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in dictArray) {
        DCModel *item = [[self alloc] initWithDict:dict];
        [items addObject:item];
    }
    return [items copy];
}

@end

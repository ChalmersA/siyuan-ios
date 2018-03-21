//
//  DCCoinRecord.m
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCCoinRecord.h"

@implementation DCCoinRecord

- (instancetype)initCoinRecordWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"money"] ||
        [key isEqualToString:@"coin"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    else if ([key isEqualToString:@"createTime"]) {
        if ([value respondsToSelector:@selector(doubleValue)]) {
            value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000];
        }
    }
    [super setValue:value forKey:key];
}



@end

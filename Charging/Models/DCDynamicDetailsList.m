//
//  HSSYDynamicDetailsList.m
//  Charging
//
//  Created by xpg on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDynamicDetailsList.h"
#import "NSDate+HSSYDate.h"

@implementation DCDynamicDetailsList

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        key = @"dynamicId";
    }
    
    else if ([key isEqualToString:@"createTime"] ||
             [key isEqualToString:@"updateTime"]) {
        if ([value respondsToSelector:@selector(longLongValue)]) {
            value = [NSDate dateWithTimestamp:[value longLongValue]];
        } else {
            value = nil;
        }
    }
    
    [super setValue:value forKey:key];
}
@end
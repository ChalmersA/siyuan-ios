//
//  NSMutableArray+HSSY.m
//  Charging
//
//  Created by xpg on 15/4/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "NSMutableArray+HSSY.h"

@implementation NSMutableArray (HSSY)

- (void)addObject:(id)anObject limitCount:(NSUInteger)count {
    [self addObject:anObject];
    if (self.count > count) {
        [self removeObjectsInRange:NSMakeRange(0, self.count - count)];
    }
}

@end

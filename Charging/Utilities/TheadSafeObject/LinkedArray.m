//
//  LinkedArray.m
//  xUntility
//
//  Created by Angus on 14-6-25.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#import "LinkedArray.h"

@implementation LinkedArray
{
    NSMutableArray *controllerObj;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        controllerObj = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addObject:(id)anObject
{
    @synchronized(self)
    {
        [controllerObj addObject:anObject];
    }
    
}

-(void)addObjectsFromArray:(NSArray*)objectArr
{
    @synchronized(self)
    {
        if (!objectArr) {
            return;
        }
        for (id anObject in objectArr) {
            [controllerObj addObject:anObject];
        }
    }
    
}

- (void)removeAllObjects
{
    @synchronized(self)
    {
        [controllerObj removeAllObjects];
    }
}

- (void)removeObjectAtIndex:(NSInteger)index
{
    @synchronized(self)
    {
        [controllerObj removeObjectAtIndex:index];
    }
}
- (void)removeObject:(id)object
{
    @synchronized(self)
    {
        [controllerObj removeObject:object];
    }
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    @synchronized(self)
    {
        [controllerObj insertObject:anObject atIndex:index];
    }
}

- (id)objectAtIndex:(NSInteger)index
{
    @synchronized(self)
    {
        return [controllerObj objectAtIndex:index];
    }
}

- (BOOL)containsObject:(id) anObject {
    @synchronized(self)
    {
        return [controllerObj containsObject:anObject];
    }
}

- (NSUInteger)count
{
    @synchronized(self)
    {
        return [controllerObj count];
    }
}

- (NSArray *)array
{
    return [controllerObj copy];
}

@end

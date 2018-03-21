//
//  LinkedArray.h
//  xUntility
//
//  Created by Angus on 14-6-25.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#import <Foundation/Foundation.h>

// 线程安全对象
// LinkedArray 处理对象NSMutableArray
@interface LinkedArray : NSObject

- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray*)objectArr;
- (void)removeAllObjects;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)removeObject:(id)object;
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSInteger)index;
- (BOOL)containsObject:(id) anObject;
- (NSUInteger)count;
- (NSArray *)array;
@end

//
//  NSDictionary+Model.h
//  Charging
//
//  Created by xpg on 15/4/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Model)
- (NSDictionary *)dictionaryForKey:(id)key;
- (NSArray *)arrayForKey:(id)key;
- (NSString *)stringForKey:(id)key;
- (NSNumber *)numberForKey:(id)key;
- (NSInteger)integerForKey:(id)key;
- (double)doubleForKey:(id)key;
@end

@interface NSMutableDictionary (Model)
- (void)setDictionary:(NSDictionary *)dict forKey:(id)key;
- (void)setArray:(NSArray *)array forKey:(id)key;
- (void)setString:(NSString *)string forKey:(id)key;
- (void)setNumber:(NSNumber *)number forKey:(id)key;
- (void)setInteger:(NSInteger)integer forKey:(id)key;
@end

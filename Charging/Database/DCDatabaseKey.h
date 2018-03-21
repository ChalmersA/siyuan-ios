//
//  HSSYDatabaseKey.h
//  Charging
//
//  Created by xpg on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseKey : NSObject
@property (assign, nonatomic)   int64_t         user_id;
@property (assign, nonatomic)   int8_t          user_role;
@property (copy, nonatomic)     NSString        *pole_no;
@property (assign, nonatomic)   NSTimeInterval  add_time;
@property (copy, nonatomic)     NSString        *key;
@property (assign, nonatomic)   int8_t          key_type;   //1：主人key 2：家人key 3：一次性（租户订单）key 4：重置key 5：工厂key
@property (assign, nonatomic)   NSTimeInterval  valid_time_start;
@property (assign, nonatomic)   NSTimeInterval  valid_time_end;
@property (assign, nonatomic)   int64_t         order_id;

+ (NSArray *)keysWithUserId:(int64_t)user_id;
+ (NSArray *)keysWithUserId:(int64_t)user_id poleNo:(NSString *)pole_no;
+ (NSArray *)keysWithUserId:(int64_t)user_id poleNo:(NSString *)pole_no keyType:(int8_t)key_type;
+ (void)cleanAllKeysInDataBase;
- (void)insertKeyToDatabase;
- (BOOL)isSameAs:(DCDatabaseKey *)key;
@end
 
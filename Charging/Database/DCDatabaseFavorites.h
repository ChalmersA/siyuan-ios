//
//  HSSYDatabaseFavorites.h
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseFavorites : NSObject

@property (assign, nonatomic) int64_t user_id;
@property (copy, nonatomic) NSString *pole_no;
@property (assign, nonatomic) int8_t collection_state;//0.已取消收藏，1.已收藏

+ (BOOL)isPole:(NSString *)poleNo favorByUserId:(int64_t)userId;
+ (void)favor:(BOOL)favor withPoleNo:(NSString *)poleNo userId:(int64_t)userId;

@end

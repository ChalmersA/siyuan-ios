//
//  City.h
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface City : DCModel <NSCoding>
@property (copy, nonatomic) NSString *cityId;
@property (copy, nonatomic) NSString *name;
@property (nonatomic, readonly) NSString *pinyin;
- (instancetype)initWithCityId:(NSString *)cityId name:(NSString *)name;
@end

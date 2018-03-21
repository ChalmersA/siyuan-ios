//
//  DCTimeQuantum.h
//  Charging
//
//  Created by kufufu on 16/4/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCTimeQuantum : DCModel

@property (copy, nonatomic) NSString *startTime;
@property (copy, nonatomic) NSString *endTime;
@property (copy, nonatomic) NSString *fee;

- (instancetype)initTimeQuantumWithDict:(NSDictionary *)dict;

@end

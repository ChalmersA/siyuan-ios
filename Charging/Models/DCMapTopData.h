//
//  DCMapTopData.h
//  Charging
//
//  Created by kufufu on 16/5/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCMapTopData : DCModel

@property (assign, nonatomic) NSInteger stationCount;
@property (assign, nonatomic) NSInteger pileCount;
@property (assign, nonatomic) NSInteger idleCount;
@property (assign, nonatomic) NSInteger noIdleCount;

- (instancetype)initMapDataWithDict:(NSDictionary *)dict;

@end

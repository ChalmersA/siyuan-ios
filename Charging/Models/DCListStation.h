//
//  HSSYListPole.h
//  Charging
//
//  Created by xpg on 15/5/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCPole.h"
#import "DCStation.h"

@interface DCListStation : NSObject
//@property (strong, nonatomic) DCPole *pole;
@property (strong, nonatomic) DCStation *station;
@property (assign, nonatomic) BOOL isIdle;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end

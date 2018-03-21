//
//  HSSYPoleShareForm.h
//  Charging
//
//  Created by xpg on 15/5/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCPole.h"

@interface DCPoleShareForm : NSObject
@property (copy, nonatomic) NSString *contactName;
@property (copy, nonatomic) NSString *contactPhone;
@property (copy, nonatomic) NSArray *shareTimeArray;
@property (copy, nonatomic) DCUVPrice *price;
@property (assign, nonatomic) HSSYPoleType type;
@property (assign, nonatomic) double power;
@property (assign, nonatomic) double voltage;
@property (assign, nonatomic) double current;
- (instancetype)initWithPole:(DCPole *)pole;
@end

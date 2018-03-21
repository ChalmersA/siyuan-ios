//
//  HSSYPoleShareForm.m
//  Charging
//
//  Created by xpg on 15/5/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleShareForm.h"

@implementation DCPoleShareForm

- (instancetype)initWithPole:(DCPole *)pole {
    self = [super init];
    if (self) {
        _contactName = pole.contactName;
        _contactPhone = pole.contactPhone;
        _shareTimeArray = pole.shareTimeArray;
        _price = pole.price;
        _type = pole.type;
        _power = pole.power;
        _voltage = pole.ratedVoltage;
        _current = pole.ratedCurrent;
    }
    return self;
}

@end

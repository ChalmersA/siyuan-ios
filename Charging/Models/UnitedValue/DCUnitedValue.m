//
//  HSSYUnitedValue.m
//  Charging
//
//  Created by Blade on 15/12/18.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCUnitedValue.h"
@interface DCUnitedValue () 
@end

@implementation DCUnitedValue 
//@synthesize max_Mantissa;
//@synthesize UV_Value;

#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        //TODO: initialize the this class
        UV_Value = 0.0f;
        max_Mantissa = 0;
    }
    return self;
}

// In the implementation
-(id) copyWithZone: (NSZone *) zone
{
    DCUnitedValue *copy = [[DCUnitedValue allocWithZone:zone] init];
    return copy;
}

#pragma mark - Params Setting
- (void)setMax_Mantissa:(NSInteger)mantissa {
    max_Mantissa = mantissa;
}
- (void)setUV_Value:(double)value {
    UV_Value = value;
}



@end

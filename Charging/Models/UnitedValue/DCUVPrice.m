//
//  HSSYUVPrice.m
//  Charging
//
//  Created by Blade on 15/12/18.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCUVPrice.h"
#define MAX_PRICE_Mantissa_COUNT 2
@implementation DCUVPrice
#pragma mark - Class Mathod
+ (instancetype)priceWithDouble:(double)value {
    DCUVPrice *price = [[DCUVPrice alloc] init];
    if (price) {
        [price setMax_Mantissa:MAX_PRICE_Mantissa_COUNT];
        [price setUV_Value:value];
    }
    return price;
}

+ (instancetype)priceWithNumber:(NSNumber*)number {
    DCUVPrice *price = [[DCUVPrice alloc] init];
    if (price) {
        [price setMax_Mantissa:MAX_PRICE_Mantissa_COUNT];
        [price setUV_Value:number.doubleValue];
    }
    return price;
}

#pragma mark - Life Cycle
- (NSString*)description {
    return [self stringOfPrice];
}
// In the implementation
-(id) copyWithZone: (NSZone *) zone
{
    DCUVPrice *copy = [[DCUVPrice allocWithZone:zone] init];
    [copy setUV_Value:self.UVPrice];
    [copy setMax_Mantissa:self.max_Mantissa];
    return copy;
}
#pragma mark - Params Setting

- (void)setMax_Mantissa:(NSInteger)mantissa {
    max_Mantissa = mantissa;
}
- (NSInteger)max_Mantissa {
    return max_Mantissa;
}
- (void)setUV_Value:(double)value {
    UV_Value = value;
}
- (double)UV_Value {
    return UV_Value;
}

- (void)setUVPrice:(double)value {
    [self setUV_Value:value];
}
- (double)UVPrice {
    return self.UV_Value;
}
#pragma mark - Showing
- (NSString*)stringOfPrice {
    NSString *priceStr;
    
//    NSString* formatStr = [NSString stringWithFormat:@"%%.%ldf",(long)self.max_Mantissa];
//    priceStr = [NSString stringWithFormat:formatStr, self.numberValue];

    
    NSMutableString *formatStr = [NSMutableString stringWithFormat:@""];
    if (max_Mantissa == 0) { // Only the Integer part
        [formatStr appendString:@"#"];
    }
    else if (max_Mantissa > 0) { // print mantissa part as many as setted
        [formatStr appendString:@"#."];
        for (NSInteger i = max_Mantissa; i > 0; i--) {
            [formatStr appendString:@"#"];
        }
    }
    else { // default Print all
        //
    }
    NSNumberFormatter* nf = [[NSNumberFormatter alloc] init];
    nf.positiveFormat = [formatStr copy];
    priceStr = [nf stringFromNumber:@(self.UV_Value)];
    return priceStr;
}
#pragma mark - Processing

@end

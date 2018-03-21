//
//  HSSYUVPrice.h
//  Charging
//
//  Created by Blade on 15/12/18.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCUnitedValue.h"

@interface DCUVPrice : DCUnitedValue {
    
}
+ (instancetype)priceWithDouble:(double)value;
+ (instancetype)priceWithNumber:(NSNumber*)number;

- (void)setMax_Mantissa:(NSInteger)mantissa;
- (NSInteger)max_Mantissa;
- (void)setUVPrice:(double)value;
- (double)UVPrice;
- (NSString*)stringOfPrice;
@end

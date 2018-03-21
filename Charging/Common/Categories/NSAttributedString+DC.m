//
//  NSAttributedString+DC.m
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "NSAttributedString+DC.h"

@implementation NSAttributedString (DC)

+ (NSAttributedString *)setDifferentColorWithParam:(double)param type:(ParamType)type {
    NSString *string = nil;
    int i = 0;
    if (type == ParamTypePrice) {
        string = [NSString stringWithFormat:@"%.2f 元", param];
        i = 1;
    } else if (type == ParamTypeCoins) {
        string = [NSString stringWithFormat:@"%.2f 个", param];
        i = 1;
    } else if (type == ParamTypePower) {
        string = [NSString stringWithFormat:@"%.2f 元/kWh", param];
        i = 5;
    } else if (type == ParamTypeCount) {
        NSInteger p = param;
        string = [NSString stringWithFormat:@"%ld 条", (long)p];
        i = 1;
    }
    NSMutableAttributedString *fee = [[NSMutableAttributedString alloc] initWithString:string];
    [fee addAttribute:NSForegroundColorAttributeName value:[UIColor palettePriceRedColor] range:NSMakeRange(0, string.length - i)];
    return fee;
}

+ (NSAttributedString *)setDifferentColorWithString:(NSString *)str color:(UIColor *)color {
    NSMutableAttributedString *fee = [[NSMutableAttributedString alloc] initWithString:str];
    [fee addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, str.length)];
    return fee;
}

@end

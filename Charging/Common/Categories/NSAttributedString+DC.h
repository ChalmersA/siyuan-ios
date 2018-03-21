//
//  NSAttributedString+DC.h
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (DC)

typedef NS_ENUM(NSInteger, ParamType) {
    ParamTypePrice,
    ParamTypeCoins,
    ParamTypePower,
    ParamTypeCount,
    ParamTypeException,
};

+ (NSAttributedString *)setDifferentColorWithParam:(double)param type:(ParamType)type;
+ (NSAttributedString *)setDifferentColorWithString:(NSString *)str color:(UIColor *)color;
@end

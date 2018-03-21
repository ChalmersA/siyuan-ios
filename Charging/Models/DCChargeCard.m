//
//  DCChargeCard.m
//  Charging
//
//  Created by kufufu on 16/5/9.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargeCard.h"

@implementation DCChargeCard

- (instancetype)initWithChargeCardWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"id"]) {
                self.cardId = [dict objectForKey:@"id"];
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"bindTime"] ||
        [key isEqualToString:@"createTime"] ||
        [key isEqualToString:@"freezeTime"]) {
        if ([value respondsToSelector:@selector(doubleValue)]) {
            value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
        }
    } else if ([key isEqualToString:@"remain"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value doubleValue]);
        }
    }
    [super setValue:value forKey:key];
}

#pragma mark - Extension
- (NSString *)useStatusForStatusLabel {
    switch (self.useStatus) {
        case DCChargeCardUseStatusInit:
            return @"初始卡";
            break;
            
        case DCChargeCardUseStatusUsing:
            return @"正常";
            break;
            
        case DCChargeCardUseStatusFreeze:
            return @"已冻结";
            break;
        
        default:
            break;
    }
}

//- (NSString *)loseStatusForStatusLabel {
//    switch (self.loseStatus) {
//        case DCChargeCardLoseStatusLose:
//            return @"挂失中";
//            break;
//            
//        case DCChargeCardLoseStatusUnlose:
//            return @"解绑电卡";
//            break;
//
//        default:
//            break;
//    }
//}

@end

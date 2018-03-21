//
//  HSSYFavoritesRequestObject.m
//  Charging
//
//  Created by chenshuxian on 15/5/25.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCFavoritesRequestObject.h"
#import "NSDictionary+Model.h"

@implementation DCFavoritesRequestObject

- (NSDictionary *)jsonObject {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setString:self.pileId forKey:@"pileId"];
    [dict setString:self.userid forKey:@"userid"];
    [dict setInteger:self.favor forKey:@"favor"];
    return [dict copy];
}

+ (NSDictionary *)jsonObjectWithArray:(NSArray *)array {
    NSMutableArray *favorites = [NSMutableArray array];
    for (DCFavoritesRequestObject *obj in array) {
        [favorites addObject:[obj jsonObject]];
    }
    return [NSDictionary dictionaryWithObject:favorites forKey:@"favorites"];
}

@end

//
//  DCScanQrcodeParams.m
//  Charging
//
//  Created by kufufu on 16/4/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCScanQrcodeParams.h"

@implementation DCScanQrcodeParams

- (instancetype)initScanQrcodeParamsWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"pile"]) {
                self.pile = [[DCPile alloc] initPileWithDict:[dict objectForKey:@"pile"]];
            }
        }
    }
    return self;
}

@end

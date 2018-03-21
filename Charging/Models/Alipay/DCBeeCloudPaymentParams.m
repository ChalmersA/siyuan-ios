//
//  DCBeeCloudPaymentParams.m
//  Charging
//
//  Created by kufufu on 15/11/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCBeeCloudPaymentParams.h"

@implementation DCBeeCloudPaymentParams

- (instancetype)initBeeCloudPaymentParamsWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    return self;
}

- (BOOL)isAvailable{
    if (self.billNum && self.billNum.length > 0 &&
        self.billTitle && self.billTitle.length > 0 &&
        self.billRemainFee && self.billRemainFee.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@end


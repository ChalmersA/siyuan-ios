//
//  DCBeeCloudPaymentParams.h
//  Charging
//
//  Created by kufufu on 15/11/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCModel.h"

@interface DCBeeCloudPaymentParams : DCModel

@property (nonatomic, copy) NSString *billTitle;
@property (nonatomic, copy) NSString *billRemainFee;
@property (nonatomic, copy) NSString *billNum;

- (instancetype)initBeeCloudPaymentParamsWithDict:(NSDictionary *)dict;
- (BOOL)isAvailable;

@end

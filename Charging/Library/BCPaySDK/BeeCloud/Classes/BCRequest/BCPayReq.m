//
//  BCPayReq.m
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCPayReq.h"

#pragma mark pay request
@implementation BCPayReq

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = BCObjsTypePayReq;
        self.billTimeOut = 0;
    }
    return self;
}
@end

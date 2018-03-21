//
//  PayApiClient.h
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "PaymentObject.h"

@interface PayApiClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

- (NSURLSessionDataTask *)postPayment:(PaymentObject *)payment
                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end

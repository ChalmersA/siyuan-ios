//
//  PayApiClient.m
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "PayApiClient.h"

static NSString * const PayApiBaseUrl = @"http://203.130.42.199/autopay/";

@implementation PayApiClient

+ (instancetype)sharedClient {
    static PayApiClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:PayApiBaseUrl]];
        AFHTTPResponseSerializer *serializer = sharedClient.responseSerializer;
        serializer.acceptableContentTypes = [serializer.acceptableContentTypes setByAddingObject:@"text/html"];
    });
    
    return sharedClient;
}

- (NSURLSessionDataTask *)postPayment:(PaymentObject *)payment
                              success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                              failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure {
    NSURLSessionDataTask *task = [super POST:@"paymentinfo" parameters:[payment joinOrderParams] success:success failure:failure];
    DDLogDebug(@"postPayment %@", [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    return task;
}

@end

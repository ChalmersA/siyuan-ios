//
//  HSSYHTTPSessionManager.m
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCHTTPSessionManager.h"
#import "DCApp.h"
#import "DCUser.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "DCCommon.h"
#import "UIDeviceHardware.h"
#import "UIAlertView+HSSYCategory.h"

@implementation DCHTTPSessionManager

+ (instancetype)shareManager {
    static DCHTTPSessionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *conf = [NSURLSessionConfiguration defaultSessionConfiguration];
        conf.timeoutIntervalForRequest = 30;
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        NSURL *url = [NSURL URLWithString:SERVER_URL];
        DDLogDebug(@"SERVER_URL %@", SERVER_URL);
        manager = [[DCHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:conf];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    [manager configHeaders];
    return manager;
}

- (void)configHeaders {
    if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.xpg.siyuan.charging"]) {
        [self.requestSerializer setValue:@"ios" forHTTPHeaderField:@"OS"];
    }
    
    [self.requestSerializer setValue:[DCApp sharedApp].user.token forHTTPHeaderField:@"Token"];
    [self.requestSerializer setValue:appVersion() forHTTPHeaderField:@"App-Version"];
    
    [self.requestSerializer setValue:@"0" forHTTPHeaderField:@"Client-Id"];
    static NSString *device = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = [[UIDeviceHardware new] platformString];
    });
    [self.requestSerializer setValue:device forHTTPHeaderField:@"Device"];
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"checkcode"];
}

#pragma mark - checkcode
+ (instancetype)shareManagerWithVerification:(NSString *)verification {
    DCHTTPSessionManager *managerForRegister = [self shareManager];
    [managerForRegister.requestSerializer setValue:verification forHTTPHeaderField:@"checkcode"];
    return managerForRegister;
}

#pragma mark - form-data
+ (instancetype)uploadImageManager {
    DCHTTPSessionManager *manager = [[DCHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]];
    [manager configHeaders];
    [manager.requestSerializer setValue:nil forHTTPHeaderField:@"Content-Type"];
    return manager;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error))completion {
    NSURLSessionDataTask *task = [super GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"[response] %@ success %@", URLString, prettyPrintedstringForJSONObject(responseObject));
        DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
        [self handleErrorCode:webResponse.code withTask:task];
        
        if (completion) {
            completion(task, YES, webResponse, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logRequestFailure:error withURLString:URLString];
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    DDLogVerbose(@"[request] %@ (GET) parameters %@", URLString, prettyPrintedstringForJSONObject(parameters));
    return task;
}

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error))completion {
    NSURLSessionDataTask *task = [super POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"[response] %@ success %@", URLString, prettyPrintedstringForJSONObject(responseObject));
        DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
        [self handleErrorCode:webResponse.code withTask:task];
        
        if (completion) {
            completion(task, YES, webResponse, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logRequestFailure:error withURLString:URLString];
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    DDLogVerbose(@"[request] %@ (POST) parameters %@", URLString, prettyPrintedstringForJSONObject(parameters));
    return task;
}

- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *, BOOL, DCWebResponse *, NSError *))completion {
    NSURLSessionDataTask *task = [super DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        DDLogVerbose(@"[response] %@ success %@", URLString, prettyPrintedstringForJSONObject(responseObject));
        DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
        [self handleErrorCode:webResponse.code withTask:task];
        
        if (completion) {
            completion(task, YES, webResponse, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logRequestFailure:error withURLString:URLString];
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    DDLogVerbose(@"[request] %@ (DELETE) parameters %@", URLString, prettyPrintedstringForJSONObject(parameters));
    return task;
}

- (void)handleErrorCode:(int)code withTask:(NSURLSessionDataTask *)task {
    if (code == RESPONSE_CODE_TOKEN_EXPIRED) {
        DDLogVerbose(@"[error] expired token %@", task.currentRequest.allHTTPHeaderFields);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TOKEN_EXPIRED object:task];
    } else if (code == RESPONSE_CODE_REFRESH_TOKEN_EXPIRED) {
        DDLogVerbose(@"[error] expired refresh_token %@", task.currentRequest.allHTTPHeaderFields);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_REFRESH_TOKEN_EXPIRED object:task];
    } else if (code == RESPONSE_CODE_INVALID_TOKEN) {
        DDLogVerbose(@"[error] invalid token %@", task.currentRequest.allHTTPHeaderFields);
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TOKEN_INVALID object:task];
    } else if (code == RESPONSE_CODE_VERSION_TOO_LOW) {
        DDLogVerbose(@"[error] unsupport version %@", task.currentRequest.allHTTPHeaderFields);
        [[DCApp sharedApp] showUpdateAppAlert];
    }
}

- (void)logRequestFailure:(NSError *)error withURLString:(NSString *)URLString {
    if (error.code == NSURLErrorCancelled) {
        DDLogVerbose(@"[response] %@    cancelled ~~~", URLString);
    } else if (error.code == NSURLErrorTimedOut) {
        DDLogVerbose(@"[response] %@    timeout ~~~", URLString);
    } else if (error.code == NSURLErrorCannotConnectToHost) {
        DDLogVerbose(@"[response] %@    cannot connect to host ~~~", URLString);
    }
    else {
        DDLogVerbose(@"[response] %@    fail %@", URLString, [error localizedDescription]);
    }
}

@end

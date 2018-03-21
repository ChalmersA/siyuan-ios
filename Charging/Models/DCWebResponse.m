//
//  HSSYWebResponse.m
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCWebResponse.h"
#import "NSObject+Model.h"
#import "NSDictionary+Model.h"
#import "DCHTTPSessionManager.h"

NSString * const HSSYDefaultRequestFailMessage = @"服务器请求失败，请稍后再试";

@implementation DCWebResponse

- (instancetype)initWithData:(id)responseObject {
    self = [super init];
    if (self) {
        NSDictionary *responseDict = [responseObject dictionaryObject];
        if (responseDict) {
            _code = (int)[responseDict integerForKey:@"code"];
            _message = [responseDict stringForKey:@"message"];
            id result = [responseDict objectForKey:@"result"];
            if (result != [NSNull null]) {
                _result = result;
            }
        } else {
            _code = -1;
        }
    }
    return self;
}

- (BOOL)isSuccess {
    return (self.code == 0);
}

+ (NSString *)errorMessage:(DCWebResponse *)response withPlaceholder:(NSString *)placeholder {
    if (response) {
        switch (response.code) {
            case RESPONSE_CODE_INVALID_TOKEN:
            case RESPONSE_CODE_TOKEN_EXPIRED:
            case RESPONSE_CODE_VERSION_TOO_LOW:
                return nil;
                
            case RESPONSE_CODE_ERROR_CLIENTID:
            case RESPONSE_CODE_INVALID_USERID:
            case RESPONSE_CODE_INVALID_RETOKEN:
            case RESPONSE_CODE_INVALID_CLIENTID:
//            case RESPONSE_CODE_ILLEGAL_DATA:
//            case RESPONSE_CODE_ERROR_DATA:
//            case RESPONSE_CODE_SYSTEM_ERROR:
//            case RESPONSE_CODE_SYSTEM_BUSY:
                return HSSYDefaultRequestFailMessage;
                
            default:
                break;
        }
    }
    
    if (response.message.length > 0) {
        return response.message;
    }
    if (placeholder.length > 0) {
        return placeholder;
    }
    return HSSYDefaultRequestFailMessage;
}

+ (NSString *)errorMessage:(NSError *)error withResponse:(DCWebResponse *)response {
    if (error) {
        switch (error.code) {
            case NSURLErrorCancelled:
                return nil;
                
            case NSURLErrorTimedOut:
            case NSURLErrorCannotConnectToHost:
            default:
                return HSSYDefaultRequestFailMessage;
        }
    }
    return [self errorMessage:response withPlaceholder:nil];
}

- (NSString *)description {
    NSString *codeMsg = [NSString stringWithFormat:@"code:%d message:%@ ", self.code, self.message];
    if (!self.result) {
        return codeMsg;
    }
    NSString *result = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self.result options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    return [codeMsg stringByAppendingString:result];
}

@end

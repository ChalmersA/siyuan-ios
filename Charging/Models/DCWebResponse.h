//
//  HSSYWebResponse.h
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const HSSYDefaultRequestFailMessage;

@interface DCWebResponse : NSObject
@property (assign,nonatomic) int code;
@property (copy,nonatomic) NSString *message;
@property (strong,nonatomic) id result;
- (instancetype)initWithData:(id)responseObject;
- (BOOL)isSuccess;
//+ (NSString *)errorMessage:(HSSYWebResponse *)response withPlaceholder:(NSString *)placeholder;
+ (NSString *)errorMessage:(NSError *)error withResponse:(DCWebResponse *)response;
@end

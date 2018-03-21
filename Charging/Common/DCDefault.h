//
//  HSSYDefault.h
//  Charging
//
//  Created by xpg on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DCUser;
@class DCSearchParameters;

@interface DCDefault : NSObject

@property DCUser *loginedUser;

+ (void)saveLoginedUser:(DCUser *)user;
+ (DCUser *)loadLoginedUser;
+ (NSString *)loadLastLoginUserPhoneNum;

+ (void)saveAutoConnectUUID:(NSString *)uuid forUserId:(NSString *)userId;
+ (NSString *)loadAutoConnectUUIDForUserId:(NSString *)userId;

#pragma mark - SearchParam
+ (void)saveSearchParam:(DCSearchParameters *)param;
+ (DCSearchParameters *)loadSearchParam;

#pragma mark - NewMessage
+ (void)saveNewMessageCount:(NSInteger)count;
+ (NSInteger)loadNewMessageCount;

#pragma mark - InstalledVersion
+ (void)saveInstalledVersion:(NSString *)version;
+ (NSString *)loadInstalledVersion;
@end

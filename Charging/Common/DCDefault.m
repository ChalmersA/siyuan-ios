//
//  HSSYDefault.m
//  Charging
//
//  Created by xpg on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDefault.h"
#import "DCUser.h"
#import "DCSearchParameters.h"

static NSString *HSSYLoginedUser = @"LoginedUser";
static NSString *HSSYLastLoginedUserPhone = @"HSSYLastLoginedUserPhone";
static NSString *HSSYAutoConnectUUID = @"AutoConnectUUID";
static NSString *HSSYSearchParam = @"SearchParam";
static NSString *HSSYDefaultNewMessageCount = @"NewMessageCount";
static NSString *HSSYDefaultInstalledVersion = @"InstalledVersion";

@implementation DCDefault

+ (void)saveObject:(id)object forKey:(NSString *)key {
    if (object) {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)loadObjectForKey:(NSString *)key  {
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return object;
}

//NSKeyedArchiver
+ (void)archiveObject:(id)object forKey:(NSString *)key {
    if (object) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:key];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//NSKeyedUnarchiver
+ (id)unarchiveObjectForKey:(NSString *)key  {
    id object = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (object) {
        object = [NSKeyedUnarchiver unarchiveObjectWithData:object];
    }
    return object;
}

#pragma mark - LoginedUser
+ (void)saveLoginedUser:(DCUser *)user {
    [self archiveObject:user forKey:HSSYLoginedUser];
    
    if(user && user.phone) {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        [userDef setObject:user.phone forKey:HSSYLastLoginedUserPhone];
        [userDef synchronize];
    }
}

+ (DCUser *)loadLoginedUser {
    return [self unarchiveObjectForKey:HSSYLoginedUser];
}

+ (NSString *)loadLastLoginUserPhoneNum {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    if (!userDef) {
        return nil;
    }
    return [userDef objectForKey:HSSYLastLoginedUserPhone];
}

#pragma mark - AutoConnectUUID
+ (void)saveAutoConnectUUID:(NSString *)uuid forUserId:(NSString *)userId {
    if (!uuid || !userId) {
        return;
    }
    DDLogDebug(@"[AutoConnect] save uuid %@ userId %@", uuid, userId);
    NSDictionary *uuidDict = [self loadObjectForKey:HSSYAutoConnectUUID];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([uuidDict isKindOfClass:[NSDictionary class]]) {
        dict = [uuidDict mutableCopy];
    }
    dict[userId] = uuid;
    [self saveObject:dict forKey:HSSYAutoConnectUUID];
}

+ (NSString *)loadAutoConnectUUIDForUserId:(NSString *)userId {
    if (!userId) {
        return nil;
    }
    NSDictionary *uuidDict = [self loadObjectForKey:HSSYAutoConnectUUID];
    NSString *uuid = nil;
    if ([uuidDict isKindOfClass:[NSDictionary class]]) {
        uuid = uuidDict[userId];
    }
    DDLogDebug(@"[AutoConnect] load uuid %@ userId %@", uuid, userId);
    return uuid;
}

#pragma mark - SearchParam
+ (void)saveSearchParam:(DCSearchParameters *)param {
    [self archiveObject:param forKey:HSSYSearchParam];
}

+ (DCSearchParameters *)loadSearchParam {
    return [self unarchiveObjectForKey:HSSYSearchParam];
}

#pragma mark - NewMessage
+ (void)saveNewMessageCount:(NSInteger)count {
    [self saveObject:@(count) forKey:HSSYDefaultNewMessageCount];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_UPDATE object:nil];
}

+ (NSInteger)loadNewMessageCount {
    NSNumber *count = [self loadObjectForKey:HSSYDefaultNewMessageCount];
    return [count integerValue];
}

#pragma mark - InstalledVersion
+ (void)saveInstalledVersion:(NSString *)version {
    [self saveObject:version forKey:HSSYDefaultInstalledVersion];
}

+ (NSString *)loadInstalledVersion {
    return [self loadObjectForKey:HSSYDefaultInstalledVersion];
}

#pragma mark - Default Pile Image
//TODO: make get default Pile Image. for pile list, for loading pole image in pile detail view

@end

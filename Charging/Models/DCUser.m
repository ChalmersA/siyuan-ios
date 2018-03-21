//
//  DCUser.m
//  Charging
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCUser.h"
#import "UIImage+HSSYCategory.h"

@implementation DCUser

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.refreshToken forKey:@"refreshToken"];
    
    [aCoder encodeObject:self.userId forKey:@"userId"];
    
    [aCoder encodeObject:self.thirdUuid forKey:@"thirdUuid"];
    [aCoder encodeInteger:self.bindType forKey:@"bindType"];
    
    [aCoder encodeObject:self.avatarUrl forKey:@"avatarUrl"];
    
    [aCoder encodeDouble:self.createAt forKey:@"createAt"];
    
    [aCoder encodeObject:self.nickName forKey:@"nickName"];
    [aCoder encodeObject:self.phone forKey:@"phone"];
    [aCoder encodeInteger:self.gender forKey:@"gender"];
    
    [aCoder encodeObject:self.alipayAcc forKey:@"alipayAcc"];
    [aCoder encodeObject:self.alipayName forKey:@"alipayName"];
    [aCoder encodeDouble:self.chargingConis forKey:@"chargingCoins"];
    
    [aCoder encodeObject:self.pushId forKey:@"pushId"];
    [aCoder encodeInteger:self.pushType forKey:@"pushType"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _token = [coder decodeObjectForKey:@"token"];
        _refreshToken = [coder decodeObjectForKey:@"refreshToken"];
        
        _userId = [coder decodeObjectForKey:@"userId"];
        
        _thirdUuid = [coder decodeObjectForKey:@"thirdUuid"];
        _bindType = [coder decodeIntegerForKey:@"bindType"];
        
        _avatarUrl = [coder decodeObjectForKey:@"avatarUrl"];
        
        _createAt = [coder decodeDoubleForKey:@"createAt"];
        
        _nickName = [coder decodeObjectForKey:@"nickName"];
        _phone = [coder decodeObjectForKey:@"phone"];
        _gender = [coder decodeIntegerForKey:@"gender"];
        
        _alipayAcc = [coder decodeObjectForKey:@"alipayAcc"];
        _alipayName = [coder decodeObjectForKey:@"alipayName"];
        _chargingConis = [coder decodeDoubleForKey:@"chargingCoins"];
        
        _pushId = [coder decodeObjectForKey:@"pushId"];
        _pushType = [coder decodeIntegerForKey:@"pushType"];
    }
    return self;
}

#pragma mark - NSCopy
- (id)copyWithZone:(NSZone *)zone {
    DCUser *user = [[DCUser alloc] init];
    user.token = self.token;
    user.refreshToken = self.refreshToken;
    
    user.userId = self.userId;
    
    user.thirdUuid = self.thirdUuid;
    user.bindType = self.bindType;
    
    user.avatarUrl = self.avatarUrl;
    
    user.createAt = self.createAt;
    
    user.nickName = self.nickName;
    user.phone = self.phone;
    user.gender = self.gender;
    
    user.alipayAcc = self.alipayAcc;
    user.alipayName = self.alipayName;
    user.chargingConis = self.chargingConis;
    
    user.pushId = self.pushId;
    user.pushType = self.pushType;
    
    return user;
}

#pragma mark - KVC
- (void)setValue:(id)value forKey:(NSString *)key { //为了防止后台传回来的字段名与app端定义的不同作一个转换
    if ([key isEqualToString:@"avatar"]) {
        key = @"avatarUrl";
    }
    [super setValue:value forKey:key];
}

#pragma mark - Login
- (instancetype)initWithLoginResponse:(NSDictionary *)resultDict {
    self = [super init];
    if (self) {
        NSDictionary *userDict = [resultDict dictionaryForKey:@"user"];
        [userDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self setValue:obj forKey:key];
        }];
        
        self.token = [resultDict stringForKey:@"accessToken"];
        self.refreshToken = [resultDict stringForKey:@"refreshToken"];
        NSLog(@"token:%@", self.token);
        NSLog(@"refreshToken:%@", self.refreshToken);
    }
    return self;
}

#pragma mark - Database
+ (instancetype)convertFromDatabaseUser:(DCDatabaseUser *)dbUser {
    DCUser *user = [self new];
    user.userId = dbUser.user_id;
    user.avatarUrl = [[NSString alloc] initWithData:dbUser.user_portrait encoding:NSUTF8StringEncoding];
    user.thirdUuid = dbUser.user_thirdUuid;
    user.phone = dbUser.user_phone;
    user.nickName = dbUser.user_nickName;
    user.bindType = dbUser.user_bindType;
    user.gender = dbUser.user_gender;
    user.createAt = dbUser.user_createAt;
    user.pushId = dbUser.user_pushId;
    user.pushType = dbUser.user_pushType;
    //    user.token?? UserDefault...
    return user;
}

- (void)saveUserToDatabase {
    DCDatabaseUser *dbUser = [DCDatabaseUser new];
    dbUser.user_id = self.userId;
    dbUser.user_portrait = [self.avatarUrl dataUsingEncoding:NSUTF8StringEncoding];
    dbUser.user_thirdUuid = self.thirdUuid;
    dbUser.user_phone = self.phone;
    dbUser.user_nickName = self.nickName;
    dbUser.user_bindType = self.bindType;
    dbUser.user_createAt = self.createAt;
    dbUser.user_gender = self.gender;
    dbUser.user_pushId = self.pushId;
    dbUser.user_pushType = self.pushType;
    //    token?? UserDefault...
    [dbUser saveToDatabase];
}

#pragma mark - Avatar
- (NSURL *)avatarImageURL {
    return [NSURL URLWithImagePath:self.avatarUrl];
}

@end

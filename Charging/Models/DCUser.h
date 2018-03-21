//
//  DCUser.h
//  Charging
//
//  Created by xpg on 14/12/30.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCDatabaseUser.h"

typedef NS_ENUM(NSInteger, DCUserGender) {
    DCUserGenderUnknown,
    DCUserGenderMale,
    DCUserGenderFemale,
};

typedef NS_ENUM(NSInteger, DCUserBindType) {
    DCBindTypeWeChat = 3,
    DCBindTypeQQ,
};

typedef NS_ENUM(NSInteger , DCPushTyep) {
    DCPushTyepNone,             //不接受推送
    DCPushTyepPushAll,          //接受推送
    DCPushTyepOnlyPushMessage,  //只接受社交消息等
};

@interface DCUser : DCModel <NSCoding, NSCopying>

@property (copy, nonatomic) NSString *token; // 用于登录
@property (copy, nonatomic) NSString *refreshToken; // 用于登录

@property (copy, nonatomic) NSString *userId;

//第三方登录
@property (copy, nonatomic) NSString *thirdUuid; //第三方登录id
@property (assign, nonatomic) DCUserBindType bindType; //第三方账号类型

@property (copy, nonatomic) NSString *avatarUrl; // 头像 url "users\/3\/9ad59fa9a7b642ee64.jpg"

@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *nickName; //昵称
@property (assign, nonatomic) DCUserGender gender;

@property (assign, nonatomic) double createAt; //创建时间

@property (copy, nonatomic) NSString *alipayAcc; //支付宝账号
@property (copy, nonatomic) NSString *alipayName; //支付宝真实姓名
@property (assign, nonatomic) double chargingConis; //充点币余额

@property (copy, nonatomic) NSString *pushId; //推送
@property (assign, nonatomic) DCPushTyep pushType; //推送类型

- (NSURL *)avatarImageURL; // 头像 url

- (instancetype)initWithLoginResponse:(NSDictionary *)resultDict;
@end

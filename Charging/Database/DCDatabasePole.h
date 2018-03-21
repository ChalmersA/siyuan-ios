//
//  HSSYDatabasePole.h
//  Charging
//
//  Created by xpg on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCDatabaseKey.h"

typedef NS_ENUM(int, HSSYPoleShareAppointManageType) {
    HSSYPoleShareAppointManageTypeNone,       //不开放预约
    HSSYPoleShareAppointManageTypeOwner,      //业主管理
    HSSYPoleShareAppointManageTypePlatform,   //平台管理
};

@interface DCDatabasePole : NSObject
@property (copy, nonatomic) NSString *pole_no;
@property (copy, nonatomic) NSString *nick_name;
@property (assign, nonatomic) int8_t pole_type;
@property (copy, nonatomic) NSString *location;
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) double latitude;
@property (assign, nonatomic) double altitude;
@property (assign, nonatomic) double rated_cur;
@property (assign, nonatomic) double rated_volt;
@property (assign, nonatomic) double price;
@property (copy, nonatomic) NSString *contact_name;
@property (copy, nonatomic) NSString *contact_phone_no;
@property (assign,nonatomic) HSSYPoleShareAppointManageType appointManageType; //授权运营平台管理

+ (instancetype)poleWithPoleNo:(NSString *)pole_no;
/**
 *  根据桩编号来获取桩数据
 *
 *  @param poleNOs 桩编号集合
 *
 *  @return 桩集合
 */
+ (NSArray*)dbPolesWithPoleNOs:(NSArray *)poleNOs;

// 用户是业主的桩
+ (NSArray *)polesOfUserAsOwner:(int64_t)user_id;

// 用户是家人的桩
+ (NSArray *)polesOfUserAsFamily:(int64_t)user_id;

// 用户是租户的桩
+ (NSArray *)polesOfUserAsTenant:(int64_t)user_id;

/**
 *  清空所有数据库的桩
 */
+ (void)cleanAllPolesInDataBase;
+ (void)deleteWithPoleNo:(NSString *)pole_no;
- (void)saveToDatabase;
- (BOOL)isSameAs:(DCDatabasePole *)pole;
@end

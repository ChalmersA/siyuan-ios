//
//  DCChargeCard.h
//  Charging
//
//  Created by kufufu on 16/5/9.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

typedef NS_ENUM(NSInteger, DCChargeCardUseStatus) {     //使用状态
    DCChargeCardUseStatusInit,      //初始卡
    DCChargeCardUseStatusUsing,     //使用中
    DCChargeCardUseStatusFreeze,    //冻结
};

//typedef NS_ENUM(NSInteger, DCChargeCardLoseStatus) {    //挂失状态
//    DCChargeCardLoseStatusUnlose,   //无挂失
//    DCChargeCardLoseStatusLose,     //挂失中
//};

@interface DCChargeCard : DCModel

@property (copy, nonatomic) NSString *cardId;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *userName;
@property (assign, nonatomic) DCChargeCardUseStatus useStatus;
//@property (assign, nonatomic) DCChargeCardLoseStatus loseStatus;
@property (assign, nonatomic) double remain;
@property (strong, nonatomic) NSDate *bindTime;         //绑定时间
@property (strong, nonatomic) NSDate *createTime;       //录入时间
@property (strong, nonatomic) NSDate *freezeTime;       //冻结时间
@property (assign, nonatomic) NSInteger chargeCount;    //相关的充电记录条数

- (instancetype)initWithChargeCardWithDict:(NSDictionary *)dict;

- (NSString *)useStatusForStatusLabel;
//- (NSString *)loseStatusForStatusLabel;

@end

//
//  DCMessage.h
//  Charging
//
//  Created by xpg on 15/3/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"

typedef NS_ENUM(NSInteger, DCMessageType) {
    DCMessageTypeOrder = 1,     //订单消息
    DCMessageTypeCharge,        //充电消息
    DCMessageTypeAddStation,    //上报桩群审核消息
    DCMessageTypeArticle,       //充电圈消息
    DCMessageTypeChargeCoin,    //充电币消息
};

@interface DCMessage : DCModel 
@property (copy, nonatomic) NSString *messageId;//map to id
@property (copy, nonatomic) NSString *userId;

@property (assign, nonatomic) DCMessageType type;
@property (copy, nonatomic) NSString *typeId;

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *createTime;
@property (assign, nonatomic) DCMessageStatus status;

- (instancetype)initWithNotificationInfo:(NSDictionary *)info;

#if DEBUG
+ (instancetype)debugMessage;
#endif
@end

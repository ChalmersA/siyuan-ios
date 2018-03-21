//
//  DCCoinRecord.h
//  Charging
//
//  Created by kufufu on 16/4/26.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"

typedef NS_ENUM(NSInteger, DCTradeType) {
    DCTradeTypeRecharge = 1,
    DCTradeTypePay,
    DCTradeTypeWithdraw,
};

typedef NS_ENUM(NSInteger, DCChannelType) {
    DCChannelTypeAlipay = 1,
    DCChannelTypeWechat,
};

@interface DCCoinRecord : DCModel

@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *userId;
@property (assign, nonatomic) double money;
@property (assign, nonatomic) double coin;
@property (assign, nonatomic) DCTradeType type;
@property (assign, nonatomic) DCChannelType channel;
@property (copy, nonatomic) NSString *acount;
@property (strong, nonatomic) NSDate *createTime;

- (instancetype)initCoinRecordWithDict:(NSDictionary *)dict;

@end

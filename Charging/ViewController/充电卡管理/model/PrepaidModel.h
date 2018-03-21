//
//  PrepaidModel.h
//  Charging
//
//  Created by 陈志强 on 2018/3/11.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrepaidModel : NSObject

@property (nonatomic, strong) NSString *ID;

@property (nonatomic, strong) NSString *userId;

/**
 * 金额
 */
@property (nonatomic, assign) double charge_amount;
/**
 * 充值来源
 */
@property (nonatomic, assign) int pay_way;
/**
 * 订单Id
 */
@property (nonatomic, strong) NSString *orderId;
/**
 * 订单时间
 */
@property (nonatomic, strong) NSString *charge_time;
/**
 * IC卡号
 */
@property (nonatomic, strong) NSString *card_no;



@end

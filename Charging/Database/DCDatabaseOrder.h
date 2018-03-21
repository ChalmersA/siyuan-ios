//
//  HSSYDatabaseOrder.h
//  Charging
//
//  Created by xpg on 15/1/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCOrder.h"

@interface DCDatabaseOrder : NSObject
@property (copy, nonatomic) NSString *orderId;      //订单id
@property (copy, nonatomic) NSString *pileId;       //电桩id
@property (copy, nonatomic) NSString *ownerId;      //运营商id
@property (copy, nonatomic) NSString *tenantId;     //租户id
@property (copy, nonatomic) NSString *stationId;    //所属站id
@property (assign, nonatomic) NSTimeInterval schedule_start_t;
@property (assign, nonatomic) NSTimeInterval schedule_end_t;
@property (assign, nonatomic) NSTimeInterval create_time;
@property (assign, nonatomic) DCOrderState orderState; 
@property (assign, nonatomic) double serviceFee;

+ (DCDatabaseOrder *)ordersWithOrderId:(NSString *)orderId;

+ (NSArray *)ordersWithUserId:(int64_t)user_id;
+ (NSArray *)ordersWithPoleNo:(NSString *)poleNo;
- (void)saveToDatabase;
@end

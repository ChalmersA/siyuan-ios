//
//  DCDatabaseChargePort.h
//  Charging
//
//  Created by kufufu on 16/3/2.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseChargePort : NSObject

@property (copy, nonatomic) NSString *index;                //充电口在桩内的编号
@property (copy, nonatomic) NSString *pileId;               //所属桩的id
@property (copy, nonatomic) NSString *orderId;              //充电订单
@property (assign, nonatomic) int8_t runStatus;             //运行状态
@property (assign, nonatomic) int8_t chargePortType;        //电口类型
@property (assign, nonatomic) int8_t chargeStartType;       //电口启动类型
@property (assign, nonatomic) int8_t chargeMode;            //充电模式

+ (instancetype)chargePortWithIndex:(NSString *)index;

/**
 *  根据pileId获取chargePort
 */
+ (NSArray *)chargePortsWithPileId:(NSString *)pileId;

- (void)saveChargePortToDatabase;

- (BOOL)isSameAs:(DCDatabaseChargePort *)chargePort;
@end

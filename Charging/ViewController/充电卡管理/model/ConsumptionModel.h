//
//  ConsumptionModel.h
//  Charging
//
//  Created by 陈志强 on 2018/3/11.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConsumptionModel : NSObject

@property (nonatomic, assign) double chargeCount; //充电电量

@property (nonatomic, assign)double chargeFee; //充电费用

@property (nonatomic, assign)int flag; //结算信息 0:已结算 99:未结算 1:未找到充电记录

@property (nonatomic, assign)long createTime;

@property (nonatomic, strong) NSString *cardId;

@property (nonatomic, assign)long startChargeTime;

@property (nonatomic, assign)int type; //充电记录类型,0来自充电卡, 1来自充电币

@property (nonatomic, assign)long stopChargeTime;



@end

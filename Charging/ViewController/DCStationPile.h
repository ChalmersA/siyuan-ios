//
//  HSSYStationPile.h
//  Charging
//
//  Created by Pp on 15/10/23.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HSSYPileType) {//桩的电流类型
    HSSYPoleTypeDirect = 1,       // 直流
    HSSYPoleTypeAlter,   // 交流
};
// 1：空闲桩 ，2：只连接未充电，3：充电进行中, 4：GPRS通讯中断, 5：检修中, 6：预约, 7：故障, 8:自动充满/充电完成
typedef NS_ENUM(NSInteger, HSSYPileStatus) {//桩运行状态
    HSSYPileStatusFree = 1, //空闲
    HSSYPileStatusConnection, //只连接未充电
    HSSYPileStatusCharging, //充电进行中
    HSSYPileStatusOut, //GPRS通讯中断
    HSSYPileStatusOverhaul, //检修中
    HSSYPileStatusOrder, //预约
    HSSYPileStatusFault, //故障
    HSSYPileStatusAuto, //自动充满/充电完成
};

@interface DCStationPile : NSObject

@property (nonatomic, copy) NSString *pileId;             // 桩id
@property (nonatomic, copy) NSString *pileName;           // 桩名称
@property (nonatomic, assign) HSSYPileType pileType;      // 桩类型
@property (nonatomic, assign) HSSYPileStatus runStatus;      // 桩运行状态
@property (nonatomic, copy) NSNumber *chargingProgress; // 桩充电进度

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)StationPileWithDict:(NSDictionary *)dict;

@end

//
//  DCPile.h
//  Charging
//
//  Created by kufufu on 16/2/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCDatabasePile.h"

typedef NS_ENUM(NSInteger, DCDeviceStatus) {    //电桩设备状态
   DCDeviceStatusOnLine = 1,
   DCDeviceStatusOffLine,
};

@interface DCPile : DCModel <NSCoding>

@property (copy, nonatomic) NSString *pileId;               //电桩唯一标识
@property (copy, nonatomic) NSString *deviceId;             //出厂编号
@property (copy, nonatomic) NSString *stationId;            //所属电站编号
@property (copy, nonatomic) NSString *pileName;             //电桩名字
@property (assign, nonatomic) DCPileType pileType;          //电桩类别

@property (assign, nonatomic) double ratePower;             //额定功率
@property (assign, nonatomic) double ratedVoltage;          //额定电压
@property (assign, nonatomic) double ratedCurrent;          //额定电流

@property (assign, nonatomic) BOOL hasFloorLock;            //是否含有地锁

@property (assign, nonatomic) NSInteger chargerNum;         //充电口数量
@property (strong, nonatomic) NSArray *chargePort;          //充电口列表

@property (assign, nonatomic) DCRunStatus runStatus;        //运行状态
@property (assign, nonatomic) DCDeviceStatus devStatus;     //设备状态
@property (assign, nonatomic) DCManStatus manStatus;          //人工设置状态

@property (copy, nonatomic) NSString *remark;               //备注

- (instancetype)initPileWithDict:(NSDictionary *)dict;

+ (instancetype)pileFromDatabase:(DCDatabasePile *)dbPile;

- (void)savePileToDatabase;
@end

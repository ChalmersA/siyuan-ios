//
//  DCDatabaseStation.h
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseStation : NSObject

@property (copy, nonatomic) NSString *station_id;             //电站唯一标识
@property (copy, nonatomic) NSString *station_stationName;    //电站名称
@property (assign, nonatomic) int8_t station_stationType;     //电站类型
@property (assign, nonatomic) int8_t station_stationStatus;   //电站状态

@property (copy, nonatomic) NSString *address;                //地址
@property (assign, nonatomic) double longitude;               //经度
@property (assign, nonatomic) double latitude;                //纬度

@property (assign, nonatomic) int16_t station_directNum;      //直流桩数
@property (assign, nonatomic) int16_t station_alterNum;       //交流桩数
@property (copy, nonatomic) NSString *ownerId;                //运营商Id
@property (copy, nonatomic) NSString *ownerName;              //运营商名字
@property (copy, nonatomic) NSString *ownerPhone;             //运营商电话

@property (assign, nonatomic) double bookFee;                 //预约费用(每10分钟)
@property (assign, nonatomic) int8_t outBookWaitTime;         //超时未充电惩罚时间(小时)
@property (assign, nonatomic) int8_t refundState;             //是否返还预约费用
@property (assign, nonatomic) int8_t allowBookNum;            //允许预约最大数

+ (instancetype)stationWithStationId:(NSString *)stationId;
/**
 *  根据桩编号来获取桩数据
 *
 *  @param stationIds 桩编号集合
 *
 *  @return 桩集合
 */
+ (NSArray*)dbStationsWithStationIds:(NSArray *)stationIds;

/**
 *  清空所有数据库的桩
 */
+ (void)cleanAllStationsInDataBase;

/**
 *  根据桩编号来删除数据
 */
+ (void)deleteWithStationId:(NSString *)stationId;

/**
 *  保存到数据库
 */
- (void)saveToDatabase;
- (BOOL)isSameAs:(DCDatabaseStation *)station;
@end

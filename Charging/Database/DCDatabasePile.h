//
//  DCDatabasePile.h
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabasePile : NSObject

@property (copy, nonatomic) NSString *pile_id;          //电桩唯一标识
@property (copy, nonatomic) NSString *pile_deviceId;    //出厂编号
@property (copy, nonatomic) NSString *pile_stationId;   //所属电站编号
@property (copy, nonatomic) NSString *pile_pileName;    //电桩名字
@property (assign, nonatomic) int8_t pile_pileType;     //电桩类型
@property (assign, nonatomic) double ratePower;         //额定功率
@property (assign, nonatomic) double rateVoltage;       //额定电压
@property (assign, nonatomic) double rateCurrent;       //额定电流
@property (assign, nonatomic) int8_t chargerNum;        //充电数量

+ (instancetype)pileWithPileId:(NSString *)pileId;

/**
 *  根据stationId来获取pile数据
 */
+ (NSArray *)pileWithStationId:(NSString *)station_id;

/**
 *  根据桩编号来获取桩数据
 *
 *  @param pileIds 桩编号集合
 *
 *  @return 桩集合
 */
+ (NSArray*)dbPilesWithPileIds:(NSArray *)pileIds;

/**
 *  清空所有数据库的桩
 */
+ (void)cleanAllPilesInDataBase;

/**
 *  根据桩编号来删除数据
 */
+ (void)deleteWithPileId:(NSString *)pileId;

/**
 *  保存到数据库
 */
- (void)saveToDatabase;
- (BOOL)isSameAs:(DCDatabasePile *)pile;
@end

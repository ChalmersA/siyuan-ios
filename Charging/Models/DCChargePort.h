//
//  DCChargePort.h
//  Charging
//
//  Created by kufufu on 16/3/1.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCDatabaseChargePort.h"

typedef NS_ENUM(NSInteger, DCChargePortType) {  //电口类型
    DCChargePortTypeAC,                         //0: 交流
    DCChargePortTypeDC,                         //1: 直流
};

typedef NS_ENUM(NSInteger, DCChargePortStartType) {  //电口启动类型
    DCChargePortStartTypeScanQrcode = 1,    //1: 扫码启动
    DCChargePortStartTypeCard,              //2: 刷卡启动
};

@interface DCChargePort : DCModel <NSCoding>

@property (copy, nonatomic) NSString *index;                        //充电口在桩内的编号
@property (copy, nonatomic) NSString *pileId;                       //所属桩的id
@property (assign, nonatomic) DCChargePortType chargePortType;      //电口类型
@property (assign, nonatomic) double voltage;                       //实时电压
@property (assign, nonatomic) double current;                       //实时电流
@property (assign, nonatomic) double electricQuantity;              //实时电量
@property (copy, nonatomic) NSString *orderId;                      //充电订单
@property (assign, nonatomic) DCRunStatus runStatus;                //电桩口运行状态
@property (assign, nonatomic) DCManStatus manStatus;                //人工设置状态
@property (assign, nonatomic) DCChargePortStartType chargeStartType;    //电口启动类型
@property (assign, nonatomic) DCChargeModeType chargeMode;              //充电模式

/**
 * 充电当充电模式为1时，代表约定充电时长，单位：分钟。
 * 当充电模式为2时，代表约定充电电量，单位：kWh。
 * 当充电模式为3时，代表约定充电金额，单位：元。
 * 实际数值乘以100传到后台，后台取到的数除100显示。，两位有效小数，根据mode类型来显示不同单位
 */
@property (copy, nonatomic) NSString *chargeLimit;                  //充电模式参数

- (instancetype)initChargePortWithDictionary:(NSDictionary *)dictionary;

- (void)chargePortFromDatabase:(DCDatabaseChargePort *)chargePort;

- (void)saveChargePortToDatabase;
@end

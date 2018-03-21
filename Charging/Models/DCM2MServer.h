//
//  DCM2MStart.h
//  Charging
//
//  Created by kufufu on 16/3/10.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "AsyncSocket.h"
#import "DCChargePort.h"

extern NSString * const SPARE;                          //空闲
extern NSString * const BOOKED;                         //预约
extern NSString * const CHARGE;                         //开始放电
extern NSString * const CHARGING;                       //充电进行中
extern NSString * const OVER_VOLTAGE;                   //过压
extern NSString * const UNDER_VOLTAGE;                  //欠压
extern NSString * const OVER_CURRENT;                   //过流
extern NSString * const SCRAM;                          //急停
extern NSString * const FINISH_CHARGE;                  //充电完成
extern NSString * const CHARGE_CONNECT_ABNORMAL;        //充电连接异常
extern NSString * const CHARGE_UNIT_ERROR; 				//充电机故障
extern NSString * const BMS_ERROR;                      //BMS通信故障
extern NSString * const DEVICE_STATUS_BMS_CONNECTED;    //BMS已连接
extern NSString * const GUN_LOCK_OPEN;                  //枪锁已打开
extern NSString * const DOOR_LOCK_OPEN;                 //门锁已打开

extern NSString * const POWER_OFF;                      //断电

typedef NS_ENUM(NSInteger, SocketOfflineType) {
    SocketOfflineByServer,          //服务器掉线
    SocketOfflineByUser,            //用户主动掉线
    SocketOfflineByAfterConnect,    //连接后掉线
};

typedef NS_ENUM(NSInteger, ErrorType) {
    ErrorTypeForStart,
    ErrorTypeForEnd,
};

@protocol DCM2MServerDelegate <NSObject>

- (void)connectSuccess:(BOOL)success message:(NSString *)message;
- (void)connectError:(NSString *)message socketOfflineType:(SocketOfflineType)type;
- (void)authoriseSuccess:(BOOL)succeess message:(NSString *)message;
- (void)receiveChargeCurrentDataWithDict:(NSDictionary *)dict;
- (void)chargeingError:(NSString *)message errorType:(ErrorType)errorType;

@end

@interface DCM2MServer : DCModel

@property (copy, nonatomic) NSString *orderId;
@property (copy, nonatomic) NSString *ip;
@property (copy, nonatomic) NSString *port;
@property (strong, nonatomic) NSDictionary *sign;

@property (strong, nonatomic) AsyncSocket *socket;
@property (copy, nonatomic) NSString *socketHost;
@property (assign, nonatomic) UInt16 socketPort;
@property (strong, nonatomic) DCChargePort *chargePort;

@property (copy, nonatomic) NSString *stationName;
@property (copy, nonatomic) NSString *pileName;

@property (weak, nonatomic) id<DCM2MServerDelegate> delegate;

/*
 *  初始化M2M服务器 包括socket服务
 */
- (instancetype)initWithDict:(NSDictionary *)dict isCharing:(BOOL)isCharging;

- (void)cutOffSocket;
@end

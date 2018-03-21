//
//  DCYOrder.h
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"
#import <CoreLocation/CLLocation.h>

@class DCDatabaseOrder;

typedef NS_ENUM(NSInteger, DCOrderState) {
    DCOrderStateNotPayBookfee = 10,             //已预约,未支付预约费
    DCOrderStatePaidBookfee,                    //已预约,已支付预约费
    DCOrderStateCancelBooking,                  //用户取消预约
    DCOrderStateOvevtimeToPayBookfee,           //超时未支付预约费，系统自动取消
    DCOrderStateCancelBookingAfterPay,          //已付预约费后用户取消预约
    
    DCOrderStateOvertimeToCharge = 20,          //过期未充电（预约超时罚单)
    
    DCOrderStateCharging = 30,                          //充电中
    DCOrderStateExceptionWithNotChargeRecord,           //异常，未收到充电数据（停止充电后，无数据上报）
    DCOrderStateExceptionWithChargeData,                //异常，数据上报异常
    DCOrderStateExceptionWithStartChargeFail,           //异常，启动充电失败
    DCOrderStateExceptionWithStartChargeFailAfterBook,  //异常，预约启动失败
    
    DCOrderStateNotPayChargefee = 40,           //待支付充电费（充电完成）
    DCOrderStateNotEvaluate,                    //已支付充电费（未评价）
    DCOrderStateEvaluated,                      //已评价
};

typedef NS_ENUM(NSInteger, DCChargeStartType) {  //电口启动类型
    DCChargeStartTypeScanQrcode = 1,    //1: 扫码启动
    DCChargeStartTypeCard,              //2: 刷卡启动
};

typedef NS_ENUM(NSInteger, DCPayType) {  //支付类型
    DCPayTypeCard = 1,      //刷卡付费
    DCPayTypeChargeCoins,   //充电币
    DCPayTypeAlipay,        //支付宝
    DCPayTypeWechat,        //微信支付
    DCPayTypeVisa,          //银联支付
};

typedef NS_ENUM(NSInteger, DCChargeRefundType) {  //退费类型
    DCChargeRefundTypeNotNeed,          //不需退还预约费
    DCChargeRefundTypeNeed,             //需要退还预约费
    DCChargeRefundTypeHasRefund = 10,   //已经退还预约费
};

typedef NS_ENUM(NSInteger, DCOrderType) {
    DCOrderTypeOwner = 1, //业主
    DCOrderTypeFamily, //家人
    DCOrderTypeTenant, //普通租户
};

@interface DCOrder : DCModel
@property (copy, nonatomic) NSString *orderId;               //订单id
@property (copy, nonatomic) NSString *pileId;                //电桩id
@property (copy, nonatomic) NSString *ownerId;               //运营商id
@property (copy, nonatomic) NSString *tenantId;              //租户id
@property (copy, nonatomic) NSString *stationId;             //所属站id

@property (copy, nonatomic) NSString *pileName;              //电桩名称
@property (assign, nonatomic) NSInteger pileType;            //电桩类别
@property (copy, nonatomic) NSString *stationName;           //桩群名称
@property (copy, nonatomic) NSString *stationLocation;       //桩群地址

@property (assign, nonatomic) NSInteger chargePortIndex;     //充电口编号
@property (assign, nonatomic) NSInteger orderState;          //订单状态
@property (assign, nonatomic) NSInteger chargeMode;          //充电模式
@property (copy, nonatomic) NSString *chargeLimit;           //充电模式参数

@property (strong, nonatomic) NSDate *reserveStartTime;      //预约开始时间
@property (strong, nonatomic) NSDate *reserveEndTime;        //预约结束时间

@property (assign, nonatomic) int remainTime4ReserveFee;     //剩余时间毫秒数(用于限制支付预约费用)

@property (strong, nonatomic) NSDate *chargeStartTime;       //充电开始时间
@property (strong, nonatomic) NSDate *chargeEndTime;         //充电结束时间

@property (strong, nonatomic) NSDate *cancelTime;            //退费时间
@property (assign, nonatomic) double cancelFee;              //退费费用

@property (strong, nonatomic) NSDate *payTime;               //付款时间
@property (assign, nonatomic) double chargeEnergy;           //充电电量
@property (assign, nonatomic) double reserveFee;             //总预约费
@property (assign, nonatomic) double chargeTotalFee;         //总充电费用
@property (assign, nonatomic) double beforeModifyTotalFee;   //人工修改前的充电费
@property (assign, nonatomic) double serviceFee;             //充电价格

@property (assign, nonatomic) double coinsReserveFee;        //已支付的充电币(预约费)
@property (assign, nonatomic) double coinsChargeFee;         //已支付的充电币(充电费)
@property (assign, nonatomic) double payReserveFee;          //已支付的第三方平台费用(预约费)
@property (assign, nonatomic) double payChargeFee;           //已支付的第三方平台费用(充电费)

@property (assign, nonatomic) DCChargeStartType chargeType;  //启动充电类型
@property (assign, nonatomic) double totalScore;             //整体评分
@property (strong, nonatomic) NSDate *createTime;            //创建时间
@property (assign, nonatomic) DCPayType payType;             //支付类型
@property (assign, nonatomic) DCChargeRefundType onTimeChargeRet;   //退费类型

@property (strong, nonatomic) NSDate *evaluationTime;        //评论时间
@property (copy, nonatomic) NSString *evaluateDetial;        // 评价内容

@property (copy, nonatomic) NSString *orderTimeDescription;
@property (copy, nonatomic) NSString *cancelTimeDescription;
@property (copy, nonatomic) NSString *chargeStartTimeDescription;
@property (copy, nonatomic) NSString *chargeTimeDescription;
@property (copy, nonatomic) NSString *bookingTimeDescription;
@property (nonatomic, assign) BOOL hasPayReserveFee;//有预约费用

@property (nonatomic, assign) CLLocationCoordinate2D stationCoordinate;
@property (nonatomic, assign) BOOL hasArticle;//存在话题
/**
 * For orderCell to show the stateLabel
 */
@property (copy, nonatomic) NSString *state;

- (instancetype)initOrderWithDict:(NSDictionary *)dict;
+ (instancetype)orderWithDatabaseOrder:(DCDatabaseOrder *)dbOrder;
- (DCDatabaseOrder *)databaseObject;
/**
 *  根据state返回order
 **/
- (NSArray *)orderForState:(DCOrderState)state;

/**
 *  根据state返回startMode
 **/
- (NSString *)chargeModeDescription;

/**
 *  根据startType返回
 **/
- (NSString *)startTypeDescription;

/**
 *  返回state
 **/
- (void)stateForStateLabel:(DCOrderState)state;

/**
 *  返回预约条件
 **/
- (NSString *)onTimeChargeRetDescription;

/**
 *  返回电桩名称和电桩枪口
 **/
- (NSString *)pileNameDescription:(DCOrder *)order;

@end

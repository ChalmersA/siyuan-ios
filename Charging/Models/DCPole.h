//
//  HSSYPole.h
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCTime.h"
#import "DCDatabasePole.h"
#import <CoreLocation/CoreLocation.h>
#import "DCUVPrice.h"

typedef NS_ENUM(NSInteger, HSSYStationIsIdle) { //电站是否空闲
    HSSYStationIsIdleUnknow = 0,    //未知
    HSSYStationIsIdleFree,          //空闲
    HSSYStationIsIdleFullLoad,      //满载
    HSSYStationIsIdleOffline,       //离网
};

typedef NS_ENUM(NSInteger, HSSYGPRSType) { //充电模块类型
    HSSYGPRSTypeGPRS = 0, //GPRS
    HSSYGPRSTypeGPRSBluetooth,  //GPRS+蓝牙
    HSSYGPRSTypeBluetooth,  //蓝牙
    HSSYGPRSTypeStationNoGPRS = 2,  //全是蓝牙桩的站
};

typedef NS_ENUM(NSInteger, HSSYStationPayment) { // 计费方式
    HSSYStationPaymentCard = 1,//刷卡
    HSSYStationPaymentCash,//现金
    HSSYStationPaymentOnline,//在线支付
    HSSYStationPaymentFree,//免费
    HSSYStationPaymentOther,//其他
};

typedef NS_ENUM(NSInteger, HSSYStationType) { // 桩群类型
    HSSYStationTypePublic = 1,//公共开放站
    HSSYStationTypeSpecial,//专用站
    HSSYStationTypeOther,//其他桩群
};

typedef NS_ENUM(NSInteger, HSSYPoleType) {
    HSSYPoleTypeDC = 1,//直流
    HSSYPoleTypeAC = 2,//交流
};

typedef NS_ENUM(NSInteger, HSSYShareState) {
    
    HSSYShareStateNotShare,//未发布
    HSSYShareStateShared,//已发布
    HSSYShareStateUnknown,
};

typedef NS_ENUM(NSInteger, HSSYFavorType) {
    
    HSSYHasNotFavor = 0, //未收藏
    HSSYHasFavor, //收藏
    HSSYFavorUnknown,
};

typedef NS_ENUM(NSInteger, HSSYOperatorType) {//operator：0：个人，1：华商三优，2、国家电网）
    HSSYOperatorPrivate,
    HSSYOperatorHssy,
    HSSYOperatorNation,
};

typedef NS_ENUM(NSInteger, HSSYDeviceStatus) {
    HSSYDeviceStatusUnDisplay,           //未知
    HSSYDeviceStatusSpare,               //空闲
    HSSYDeviceStatusConnectNotCharge,    //只连接未充电
    HSSYDeviceStatusCharging,            //充电进行中
    HSSYDeviceStatusGPRSOff,             //GPRS通讯中断
    HSSYDeviceStatusRepairing,           //检修中
    HSSYDeviceStatusOrder,               //预约
    HSSYDeviceStatusFault,               //故障
    HSSYDeviceStatusFinishCharge,        //充电完成
};

@interface DCPole : DCModel <NSCoding>
@property (copy, nonatomic) NSString *coverImg;
@property (copy, nonatomic) NSString *coverCropImg;
@property (copy, nonatomic) NSArray *introImgs;

@property (copy,nonatomic) NSString *pileId;            //电桩
@property (copy,nonatomic) NSString *pileName;          //电桩名称
@property (copy,nonatomic) NSString *userId;            //业主id
@property (copy,nonatomic) NSString *ownerAvatar;       //桩主头像

@property (copy, nonatomic) NSString *pileCode;         //运行编码

@property (copy, nonatomic) NSString *ownerName;         //所属业主

@property (assign, nonatomic) HSSYPoleType type;

@property (assign,nonatomic) double longitude;          //经度
@property (assign,nonatomic) double latitude;           //纬度
@property (assign,nonatomic) double altitude;           //高度
@property (assign,nonatomic) double ratedCurrent;       //额定电流
@property (assign,nonatomic) double ratedVoltage;       //额定电压
@property (assign,nonatomic) double power;              //额定功率
@property (copy,nonatomic) DCUVPrice *price;          //充电价格
@property (assign,nonatomic) HSSYPoleShareAppointManageType appointManage; //授权运营平台管理
@property (assign,nonatomic) double avgLevel;           //评分
@property (assign,nonatomic) NSInteger acount;          //评价人数
@property (copy, nonatomic) NSString *location;         //地址
@property (copy, nonatomic) NSNumber *chargerNum;       //充电口数

@property (copy,nonatomic) NSString *cityId;                    //城市id
@property (copy,nonatomic) NSString *cityName;                  //城市名称
@property (copy,nonatomic) NSString *contactName;               //联系人
@property (copy,nonatomic) NSString *contactPhone;              //联系电话
@property (assign, nonatomic) HSSYShareState shareState;        //分享状态
@property (strong,nonatomic) NSMutableArray *shareTimeArray;    //分享时间 HSSYTime
@property (assign,nonatomic) HSSYFavorType favor; //收藏
@property (assign, nonatomic) NSInteger familyNumber;
@property (assign, nonatomic) HSSYStationIsIdle isIdle;
@property (assign, nonatomic) HSSYGPRSType gprsType;
@property (assign, nonatomic) HSSYDeviceStatus runStatus;       //桩运行状态
@property (assign, nonatomic) HSSYDeviceStatus status;          //设备状态
@property (copy, nonatomic) NSNumber *chargingProgress;         //电桩充电进度

// 临时站点相关
@property (assign, nonatomic) HSSYOperatorType operatorType;
@property (copy, nonatomic) NSString *annotation;               //站点注释
@property (copy, nonatomic) NSString *poleDescription;          //桩详细说明
@property (copy, nonatomic) NSString *stationDescription;       //站详细说明
@property (copy, nonatomic) NSNumber *occuNum;                  //占用数
@property (copy, nonatomic) NSNumber *freeNum;                  //空闲数
@property (copy, nonatomic) NSNumber *gprsNum;                  //占用数
@property (copy, nonatomic) NSNumber *alterNum;                 //交流电桩数量
@property (copy, nonatomic) NSNumber *directNum;                //直流电桩数量
@property (assign, nonatomic) HSSYStationType stationType;      //站点类型
@property (copy, nonatomic) NSString *payment;                  //计费方式(数据以字符串传过来 需要转为数组)
@property (assign, nonatomic) HSSYStationPayment stationPayment;//计费方式
@property (copy, nonatomic) NSString *funcType;                 //功能区
@property (copy, nonatomic) NSString *facilities;               //便利设施
@property (copy, nonatomic) NSString *factotry;                 //生产厂家

// 电站
- (instancetype)initWithStationDict:(NSDictionary *)dict;

- (CLLocationCoordinate2D)coordinate;

//数据库 自己是业主或家人的桩
+ (NSArray *)userAccessiblePolesFromDatabase:(NSString *)userId;

//数据库 自己是业主的桩
+ (NSArray *)userOwnedPolesFromDatabase:(NSString *)userId;

/**
 *  根据桩编号来取得桩
 *
 *  @param poleNOs 桩编号集合
 *
 *  @return 桩集合
 */
+ (NSArray *)polesWithPoleNOsFromDatabase:(NSArray *)poleNOs;

+ (instancetype)poleFromDatabase:(DCDatabasePole *)dbPole;
- (void)savePoleToDatabase;

/**
 *  获取所有电桩图片的URL，包括所谓的封面图
 *
 *  @return 所有电桩图片的URL, nil for no pictures
 */
- (NSArray *)pileImagesUrl;


#pragma mark -- Template Station
/**
 *  返回临时站点类型的实时状态
 *
 *  @return 固定的实时状态字符串
 */
- (NSString*)stationRealTimeInfo;


#pragma mark - Utilities
/**
 *  返回是否有电桩（有可能是站点）
 *
 *  @return YES for sharing， NO for NO sharing
 */
- (BOOL)isPole;

/**
 *  返回是否有分享
 *
 *  @return YES for sharing， NO for NO sharing
 */
- (BOOL)isSharing;

/**
 *  返回是否可以预约
 *
 *  @return YES for bookable， NO for NO booking
 */
- (BOOL)isBookable;
@end

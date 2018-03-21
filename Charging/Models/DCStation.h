//
//  DCStation.h
//  Charging
//
//  Created by kufufu on 16/2/29.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DCDatabaseStation.h"
#import "DCOpeningTime.h"
#import "DCTimeQuantum.h"

typedef NS_ENUM(NSInteger, DCStationType) {     //电站类型
    DCStationTypePublic = 1,                    //1: 公共站
    DCStationTypeSpecial,                       //2: 专用站
    DCStationTypeOther,                         //3: 其他
};

typedef NS_ENUM(NSInteger, DCStationStatus) {   //电站状态
    DCStationStatusOther,                       //0: 其他
    DCStationStatusOperation,                   //1: 已投运
    DCStationStatusUnoperation,                 //2: 未投运
    DCStationStatusBuilding,                    //3: 建设中
    DCStationStatusPlanning,                    //4: 规划中
};

typedef NS_ENUM(NSInteger, DCStationHasFreePile) {   //电站是否有空闲电桩
    DCStationHasFreePileNO,                          //0: 没有
    DCStationHasFreePileYES,                         //1: 有
};

typedef NS_ENUM(NSInteger, DCStationFuncType) { //功能区
    DCStationFuncTypeOther,                     //0: 其他
    DCStationFuncTypeTraffic,                   //1: 交通枢纽
    DCStationFuncTypeHouse,                     //2: 住宅小区
    DCStationFuncTypeSuperMarket,               //3: 大型商场
    DCStationFuncType4S,                        //4: 4S店
    DCStationFuncTypeSchool,                    //5: 学校
    DCStationFuncTypeScenic,                    //6: 景区
    DCStationFuncTypeHighwayService,            //7: 高速服务区
    DCStationFuncTypeOffice,                    //8: 办公场所
};

typedef NS_ENUM(NSInteger, DCFacilityType) { //设施
    DCFacilityTypeWIFI = 1,
    DCFacilityTypeCarmera,
    DCFacilityTypePaking,
    DCFacilityTypeCVS,
    DCFacilityTypeMarket,
    DCFacilityTypeRestaurant,
    DCFacilityTypeHotel
};

typedef NS_ENUM(NSInteger, DCStationShareState) {   //电站是否对外开放
    DCStationShareStateNotShare,                    //0: 否
    DCStationShareStateShare,                       //1: 是
};

typedef NS_ENUM(NSInteger, DCOnTimeChargeRefundState) {
    DCOnTimeChargeRefundStateNotRefund,
    DCOnTimeChargeRefundStateRefund,
};

@interface DCStation : DCModel <NSCoding>

@property (copy, nonatomic) NSString *stationId;                  //电站唯一标识
@property (copy, nonatomic) NSString *stationName;                //电站名称
@property (assign, nonatomic) DCStationType stationType;          //电站类型
@property (assign, nonatomic) DCStationStatus stationStatus;      //电站状态
@property (assign, nonatomic) DCStationHasFreePile hasFreePile;  //是否有空闲电桩

@property (copy, nonatomic) NSString *facilities;                 //便利设施
@property (assign, nonatomic) DCFacilityType facilityType;        //便利设施
@property (assign, nonatomic) DCStationFuncType funcType;         //功能区

@property (copy, nonatomic) NSString *province;         //省
@property (copy, nonatomic) NSString *provinceId;       //省id
@property (copy, nonatomic) NSString *city;             //市
@property (copy, nonatomic) NSString *cityId;           //市id
@property (copy, nonatomic) NSString *district;         //区
@property (copy, nonatomic) NSString *districtId;       //区id
@property (copy, nonatomic) NSString *addr;             //地址
@property (assign, nonatomic) double longitude;         //经度
@property (assign, nonatomic) double latitude;          //纬度

@property (copy, nonatomic) NSString *coverImageUrl;    //封面URL
@property (strong, nonatomic) NSArray *detailImageUrl;  //详情图URL

@property (assign, nonatomic) NSInteger commentNum;     //评价数
@property (assign, nonatomic) double commentAvgScore;   //总平均分
@property (assign, nonatomic) double envirAvgScore;     //环境平均分
@property (assign, nonatomic) double devAvgScore;       //设备情况平均分
@property (assign, nonatomic) double cspeedAvgScore;    //充电速度平均分

@property (assign, nonatomic) NSInteger directNum;      //直流桩数
@property (assign, nonatomic) NSInteger alterNum;       //交流桩数

@property (assign, nonatomic) NSInteger dcGunIdleNum;     //直流桩空闲数量
@property (assign, nonatomic) NSInteger dcGunBookableNum; //直流桩可预约数量
@property (assign, nonatomic) NSInteger acGunIdleNum;     //交流桩空闲数量
@property (assign, nonatomic) NSInteger acGunBookableNum; //交流桩可预约数量

@property (copy, nonatomic) NSString *ownerId;          //运营商Id
@property (copy, nonatomic) NSString *ownerName;        //运营商名字
@property (copy, nonatomic) NSString *ownerPhone;       //运营商电话

@property (assign, nonatomic) DCStationShareState stationShareState;    //是否对外开放
@property (strong, nonatomic) DCOpeningTime *openingAt;                 //开放时间
@property (strong, nonatomic) NSDictionary *chargeFee;                  //充电费用

@property (assign, nonatomic) double bookFee;                           //预约费用(每10分钟)
@property (assign, nonatomic) NSInteger outBookWaitTime;                //超时未充电惩罚时间(小时)
@property (assign, nonatomic) DCOnTimeChargeRefundState refundState;    //是否返还预约费用
@property (assign, nonatomic) NSInteger allowBookNum;                   //允许预约最大数
@property (assign, nonatomic) NSInteger hadBookNum;                     //当前已预约数量
@property (assign, nonatomic) double deposit;                           //充电费押金
@property (assign, nonatomic) BOOL favor;                               //是否收藏
@property (copy, nonatomic) NSString *remark;                           //电站描述

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;      //经纬度

- (instancetype)initStationWithDict:(NSDictionary *)dict;

- (CLLocationCoordinate2D)coordinate;

+ (instancetype)stationFromDatabase:(DCDatabaseStation *)dbStation;

- (void)saveStationToDatabase;

/**
 *  返回便利设施
 *
 *  @return 直接返回所展示的设施
 */
- (NSString *)facilityLabelDescription;

/**
 *  比较当前时间与开放充电时间段的时间
 *
 *  @return 当时时段的充电费用
 */
- (NSString *)chargeFeeDescription;

/**
 *  获取所有电桩图片的URL，包括所谓的封面图
 *
 *  @return 所有电桩图片的URL, nil for no pictures
 */
- (NSArray *)stationImagesUrl;

/**
 *  返回是否有分享
 *
 *  @return YES for sharing， NO for NO sharing
 */
- (BOOL)isSharing;

/**
 *  返回是否有空闲的桩
 *
 *  @return YES for have free， NO for NO sharing
 */
- (BOOL)isHasFreePile;

/**
 *  返回是否是收藏的站
 *
 *  @return YES for have free， NO for NO sharing
 */
- (BOOL)isCollect;

@end

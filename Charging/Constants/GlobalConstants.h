//
//  GlobalConstants.h
//  Innostor_usb
//
//  Created by Angus on 14-6-25.
//  Copyright (c) 2014年 XPG. All rights reserved.
//

#ifndef GlobalConstants_h
#define GlobalConstants_h

#pragma mark - BLE Defines
#define BLE_SHOW_SERVICE_CHARATERISTIC true
#define BLE_DEVICE_CONNECT_TIMEOUT 10
#define BLE_INTERVAL_RETRY  2.0f
#define BLE_TIMES_RETRY_MAX  3
#define BLE_MTU 20
#define BLE_USING_MTU_WITH_SAFER_WAY true
#define BLE_USING_MTU_WITH_DIRECT_WAY false

#pragma mark - BLE ERROR INFO
#define BLE_CMD_INVALIDATEED @"BLE_CMD_INVALIDATEED"
#define BLE_CMD_TIMEOUT @"BLE_CMD_TIMEOUT"
#define BLE_CMD_REACH_RETRY_MAX @"BLE_CMD_REACH_RETRY_MAX"


#pragma mark - 
static const double KeyHoldingTime = 3*24*60.f*60.f;

#pragma mark - DATABASE
static const unsigned int Record_Post_RetryTimes = 3;


#pragma mark - Notifications
#define NOTIFICATION_LOGOUT @"NOTIFICATION_LOGOUT"
#define NOTIFICATION_POLE_MEMBER_CHANGE @"NOTIFICATION_POLE_MEMBER_CHANGE"
#define NOTIFICATION_POLE_SHARESTATE_CHANGE @"NOTIFICATION_POLE_SHARESTATE_CHANGE"
#define NOTIFICATION_TOKEN_EXPIRED @"NOTIFICATION_TOKEN_EXPIRED"
#define NOTIFICATION_REFRESH_TOKEN_EXPIRED @"NOTIFICATION_REFRESH_TOKEN_EXPIRED"
#define NOTIFICATION_TOKEN_INVALID @"NOTIFICATION_TOKEN_INVALID"
#define NOTIFICATION_MESSAGE_DID_READ @"NOTIFICATION_MESSAGE_DID_READ"
#define NOTIFICATION_POLE_ORDERS_REFRESH @"NOTIFICATION_POLE_ORDERS_REFRESH"
#define NOTIFICATION_USER_DID_CHANGE @"NOTIFICATION_USER_DID_CHANGE"
#define NOTIFICATION_USER_LOGINVIEW_WILL_SHOW @"NOTIFICATION_USER_LOGINVIEW_WILL_SHOW"
#define NOTIFICATION_MESSAGE_UPDATE @"NOTIFICATION_MESSAGE_UPDATE"
#define NOTIFICATION_ORDER_UPDATE @"NOTIFICATION_ORDER_UPDATE"
#define NOTIFICATION_STATION_UPDATE @"NOTIFICATION_STATION_UPDATE"
#define NOTIFICATION_RECORD_POSTED @"NOTIFICATION_RECORD_POSTED"
#define NOTIFICATION_NETWORK_CHANGE_FAUTL @"NOTIFICATION_NETWORK_CHANGE_FAULT"
#define NOTIFICATION_NETWORK_CHANGE_SUCCESS @"NOTIFICATION_NETWORK_CHANGE_SUCCESS"

#pragma mark - Enum
typedef NS_ENUM(NSInteger, HSSYKeyType) {
    HSSYKeyTypeNone = 0,
    HSSYKeyTypeOwner = 1,               //桩主KEY
    HSSYKeyTypeFamilyWhiteList = 2,     //家人（白名单）
    HSSYKeyTypeTenant = 3,              //租户KEY
    HSSYKeyTypeReset = 4,               //重置
    HSSYKeyTypeFactory = 5,             //工厂
    HSSYKeyTypeRecordReceipt = 6,       //充电记录回执
    HSSYKeyTypeFamilyPeriod = 7         //家人（时效）
};

typedef NS_ENUM(NSInteger, DCPileType) {    //电桩类别
    DCPileTypeAC,   //0: 交流
    DCPileTypeDC    //1: 直流
};

typedef NS_ENUM(NSInteger, DCRunStatus) {   //电桩运行状态
    DCRunStatusSpare = 1,           //空闲
    DCRunStatusConnectNotCharge,    //只连接未充电
    DCRunStatusCharging,            //充电进行中
    DCRunStatusOffLine,             //GPRS通讯中断
    DCRunStatusRepairing,           //检修中
    DCRunStatusBooking,             //预约
    DCRunStatusFault                //故障
};

typedef NS_ENUM(NSInteger, DCChargeModeType) {  //充电模式
    DCChargeModeTypeByFull,         //自然充满
    DCChargeModeTypeByTime,         //按时间
    DCChargeModeTypeByPower,        //按电量
    DCChargeModeTypeByMoney         //按金额
};

typedef NS_ENUM(NSInteger, DCManStatus) {   //人工设置状态
    DCManStatusFault = -1,       //故障
    DCManStatusOffline = -2,     //未设置
};

typedef NS_ENUM(NSInteger, HSSYUserType) {
    HSSYUserTypeNone = 0,
    HSSYUserTypeOwner = 1,
    HSSYUserTypeFamily = 2,
    HSSYUserTypeTenant = 3,
    HSSYUserTypeFactory = 4
};

typedef NS_ENUM(NSInteger, DCMessageStatus) {   //消息状态
    DCMessageStatusAll,         //全部
    DCMessageStatusUnread,      //未读
    DCMessageStatusRead         //已读
};

typedef NS_ENUM(NSInteger, DCMessageSetType) {   //消息设置方式
    DCMessageSetTypeAll = 0,         //将所有消息设置为指定状态
    DCMessageSetTypeSpecial = 3,     //将指定id设置为指定状态
};

typedef NS_ENUM(NSInteger, DCMessageDeleteType) {   //消息删除方式
    DCMessageDeleteTypeAll,     //0：将全部的消息删除
    DCMessageDeleteTypeUnread,  //1：将未读的消息删除
    DCMessageDeleteTypeRead,    //2：将已读的消息删除
    DCMessageDeleteTypeSpecial  //3：将指定的消息删除
};

typedef NS_ENUM(NSInteger, DCNewType) {   //资讯类别
    DCNewTypeAll,       //全面资讯
    DCNewTypeTop,       //置顶资讯
    DCNewTypeNormal     //普通资讯
};

typedef NS_ENUM(NSInteger, DCArticleListType) {    //获取文章列表
    DCArticleListTypeAllArticle,    //全部文章
    DCArticleListTypeAllTopic,      //全部话题
    DCArticleListTypeAllEvaluate,   //全部评价
    DCArticleListTypeMyTopic,       //我的话题
    DCArticleListTypeMyEvaluate     //我的评价
};


typedef void(^PayFinishBlock)(NSDictionary *resultDic);
const static NSString *kPayFinishKeyCode = @"kPayFinishKeyCode";
const static NSString *kPayFinishKeyMessage = @"kPayFinishKeyMessage";
const static NSString *defaultType = @"其他";

typedef void(^PayViewShowFinish)();

#pragma mark - URLs
#define SERVER_URL_RELEASE          @"http://api.yiweichong.com:3105/"    //正式
//#define SERVER_URL_RELEASE          @"http://210.13.73.251:3105/"    //正式
//#define SERVER_URL_DEV              @"http://120.26.236.231:6080/"  //测试
#define SERVER_URL_DEV              @"http://120.26.236.231:8082/charge/"  //测试


#if DEBUG
    #define SERVER_URL SERVER_URL_RELEASE             //正式环境
//    #define SERVER_URL SERVER_URL_DEV                   //测试环境


#else //Release，APPSTORE，ENTERPRISE
    #define SERVER_URL SERVER_URL_RELEASE               //正式环境
//    #define SERVER_URL SERVER_URL_DEV                 //测试环境
#endif


#pragma mark - Umeng
#ifdef DEBUG
    #define UmengChannelId @"Develop"//开发
#elif defined(RELEASE)
    #define UmengChannelId @"Release"//发布
#elif defined(APPSTORE)
    #define UmengChannelId @""//App Store
#elif defined(ENTERPRISE)
    #define UmengChannelId @"X_Distribution"//企业发布
#endif



#endif

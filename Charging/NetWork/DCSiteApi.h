//
//  DCSiteApi.h
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCUser.h"
#import "DCPole.h"
#import "DCWebResponse.h"
#import "GlobalConstants.h"
#import "DCUVPrice.h"

typedef void(^HSSYApiCompletionBlock)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error);

typedef NS_ENUM(NSInteger, DCSmsType) {
    DCSmsTypeRegister = 1,
    DCSmsTypeResetPassword = 2,
    DCSmsTypeWithDrawCash = 3
};

@interface DCSiteApi : NSObject

#pragma mark - user : UserController 相关操作
//登录
+ (NSURLSessionDataTask *)postLoginWithAccount:(NSString *)account password:(NSString *)password accType:(NSInteger)accType pushId:(NSString *)pushId completion:(HSSYApiCompletionBlock)completion;

// 刷新Token api/user/refresh_token
+ (NSURLSessionDataTask *)refreshToken:(NSString *)refreshToken userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//登出账号
+ (NSURLSessionDataTask *)postLogOut:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - smssendcontroller : 短信相关操作
//POST //tplsendsms 获取短信验证码
+ (NSURLSessionDataTask *)postSendSms:(NSString *)phone type:(DCSmsType)type completion:(HSSYApiCompletionBlock)completion;

//检查验证码
+ (NSURLSessionDataTask *)postExamineVerification:(NSString *)phone captcha:(NSString *)captcha completion:(HSSYApiCompletionBlock)completion;

//第三方账号的绑定
+ (NSURLSessionDataTask *)postBindUserId:(NSString *)userId thirdAccUid:(NSString *)thirdAccUid thirdAccToken:(NSString *)thirdAccToken thirdAccType:(NSString *)thirdAccType completion:(HSSYApiCompletionBlock)completion;

//第三方账号的解绑
+ (NSURLSessionDataTask *)postUnbindUserId:(NSString *)userId thirdAccType:(NSString *)thirdAccType completion:(HSSYApiCompletionBlock)completion;

//注册
+ (NSURLSessionDataTask *)postUserRegister:(NSString *)phone password:(NSString *)password accType:(NSInteger)accType nickName:(NSString *)nickName gender:(NSInteger)gender captcha:(NSString *)captcha thirdAccUid:(NSString *)thirdAccUid thirdAccToken:(NSString *)thirdAccToken pushId:(NSString *)pushId completion:(HSSYApiCompletionBlock)completion;
//重置密码
+ (NSURLSessionDataTask *)postReSetPassword:(NSString *)phone password:(NSString *)password captcha:(NSString *)captcha completion:(HSSYApiCompletionBlock)completion;
//修改密码
+ (NSURLSessionDataTask *)postChangePasswordUserId:(NSString *)userId currentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completion:(HSSYApiCompletionBlock)completion;

//3.6. 修改个人信息
+ (NSURLSessionDataTask *)postUpdateUserInfo:(DCUser *)userInfo completion:(HSSYApiCompletionBlock)completion;

// 修改个人头像
+ (NSURLSessionDataTask *)postAvatar:(NSData *)avatar userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - station&pile SearchViewController相关操作
//GET  station/list 获取电站列表信息
+ (NSURLSessionDataTask *)requestListStationsWithLongitude:(NSString *)longitude
                                                  latitude:(NSString *)latitude
                                                    userId:(NSString *)userId
                                                    cityId:(NSString *)cityId
                                                  distance:(NSNumber *)distance
                                                      sort:(NSNumber *)sort
                                                     types:(NSString *)types
                                               chargeTypes:(NSString *)chargeTypes
                                                    isIdle:(BOOL)isIdle
                                               isFreeOrder:(BOOL)isFreeOrder
                                                    search:(NSString *)search
                                                      page:(NSInteger)page
                                                  pageSize:(NSInteger)pageSize
                                                completion:(HSSYApiCompletionBlock)completion;

/*
 * 地图查找桩接口
 * @parame coordinate 左上角坐标
 * @parame coordinate2 右上角坐标
 * @parame zoom 地图当前缩放等级
 * @parame maxLevel 地图最大缩放等级
 * @parame idOthersNeed 其他桩群
 * @parame isPublicNeed 公共桩群
 * @parame isSpecialNeed 专用桩群
 * @parame isIdle 筛选出空闲的桩群，也就是至少有一个充电口是空闲状态的桩群
 * @parame isFreeOrder 筛选出免收或返回预约费的桩群
 * @parame keyWord 搜索关键字
 *
 */
//GET 获取桩群地图聚合点
+ (NSURLSessionDataTask *)requestMapStationsWithUserId:(NSString *)userId coordinate:(CLLocationCoordinate2D)coordinate
                                        coordinate2:(CLLocationCoordinate2D)coordinate2
                                               zoom:(NSNumber *)zoom
                                           maxLevel:(NSNumber *)maxLevel
                                        stationType:(NSString *)stationType
                                        chargeTypes:(NSString *)chargeTypes
                                             isIdle:(BOOL)isIdle
                                        isFreeOrder:(BOOL)isFreeOrder
                                            keyWord:(NSString *)keyWord
                                         completion:(HSSYApiCompletionBlock)completion;

//GET 获取电站详情
+ (NSURLSessionDataTask *)getStationId:(NSString *)stationId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//GET 获取站内电桩列表
+ (NSURLSessionDataTask *)getPileList:(NSString *)stationId completion:(HSSYApiCompletionBlock)completion;

//POST station/favor 收藏电桩或者取消收藏电桩
+ (NSURLSessionDataTask *)postFavoritesStations:(NSArray *)stationIds userId:(NSString *)userId favorites:(NSInteger)favorites completion:(HSSYApiCompletionBlock)completion;

//GET 获取电站收藏列表
+ (NSURLSessionDataTask *)getFavoritesStationList:(NSString *)userId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//POST 上报电站
+ (NSURLSessionDataTask *)postAddStation:(NSString *)userId address:(NSString *)address longitude:(double)longitude latitude:(double)latitude stationStatus:(NSInteger)stationStatus stationType:(NSInteger)stationType images:(NSArray *)images stationName:(NSString *)stationName desp:(NSString *)desp completion:(HSSYApiCompletionBlock)completion;

// 获取地图上方4个桩群数的数据
+ (NSURLSessionDataTask *)getMapTopData:(HSSYApiCompletionBlock)completion;

#pragma mark - charge ChargingViewController相关操作
//GET 检查用户是否充电中
+ (NSURLSessionDataTask *)getUserChargingStatus:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//GET /pile/scan_info 获取扫码后电桩详细信息
+ (NSURLSessionDataTask *)getPileInfoAfterScan:(NSString *)pileId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST /pile/floor_lock 地锁控制
+ (NSURLSessionDataTask *)postCommandToDownFloorLockWithPileId:(NSString *)pileId userId:(NSString *)userId chargePortIndex:(NSInteger)chargePortIndex control:(NSInteger)control completion:(HSSYApiCompletionBlock)completion;

//POST /pile/control 开始充电
+ (NSURLSessionDataTask *)postStartCharging:(NSString *)userId
                                   pileId:(NSString *)pileId
                          chargePortIndex:(NSInteger)chargePortIndex
                               chargeMode:(NSInteger)chargeMode
                              chargeLimit:(double)chargeLimit
                               completion:(HSSYApiCompletionBlock)completion;

//POST /pile/control 停止充电
+ (NSURLSessionDataTask *)postStopCharging:(NSString *)userId
                                     pileId:(NSString *)pileId
                            chargePortIndex:(NSInteger)chargePortIndex
                                 completion:(HSSYApiCompletionBlock)completion;

#pragma mark - order OrderViewController相关操作
// POST api/order/sub 预约订单
+ (NSURLSessionDataTask *)postBookingOrderWithUserId:(NSString *)userId stationId:(NSString *)stationId chargeType:(NSInteger)chargeType orderDuration:(NSInteger)orderDuration completion:(HSSYApiCompletionBlock)completion;

// GET api/order/list 获取订单列表
+ (NSURLSessionDataTask *)getOrderList:(NSString *)userId status:(NSString *)status startTime:(NSString *)startTime endTime:(NSString *)endTime page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//GET api/order/info 根据订单id来获取订单详情
+ (NSURLSessionDataTask *)getOrderInfo:(NSString *)orderId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/order/delete 删除订单
+ (NSURLSessionDataTask *)postOrderIdsToDeleteOrder:(NSString *)userId orderIds:(NSArray *)orderIds completion:(HSSYApiCompletionBlock)completion;

//POST api/order/cancel 取消订单
+ (NSURLSessionDataTask *)postOrderIdToCancelOrder:(NSString *)userId orderId:(NSString *)orderId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - ChargeCoins
//GET api/coin/info 获取充电币数量
+ (NSURLSessionDataTask *)getChargeCoinInfoWithUserId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//GET api/coin/record/list 获取充电币列表
+ (NSURLSessionDataTask *)getChargeCoinRecordListWithUserId:(NSString *)userId type:(NSInteger)type page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//GET api/coin/record/info 获取充电币详情
+ (NSURLSessionDataTask *)getChargeCoinRecordInfoWithId:(NSString *)coinRecordId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - BeeCloudPay
//POST api/transaction/recharge 在线充值
+ (NSURLSessionDataTask *)postRechargeWithUserId:(NSString *)userId rechargeCoins:(CGFloat)rechargeCoins completion:(HSSYApiCompletionBlock)completion;

//POST api/transaction/pay 在线支付
+ (NSURLSessionDataTask *)postPayWithUserId:(NSString *)userId orderId:(NSString *)orderId costCoin:(NSNumber *)constCoin completion:(HSSYApiCompletionBlock)completion;

//POST api/transaction/cash 在线提现
+ (NSURLSessionDataTask *)postDrawTheCashWithUserId:(NSString *)userId costCoin:(CGFloat)costCoin password:(NSString *)password completion:(HSSYApiCompletionBlock)completion;

//POST api/transaction/unlock 解锁支付
+ (NSURLSessionDataTask *)postOrderIdForUnlockOrder:(NSString *)orderId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - ChargeCard
//GET api/card/info 充电卡基本信息
+ (NSURLSessionDataTask *)getChargeCardInfoWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//GET api/card/list 获取充电卡列表
+ (NSURLSessionDataTask *)getChargeCardListWithUserId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/card/bind 绑定电卡
+ (NSURLSessionDataTask *)postBindChargeCardWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/card/unbind 解绑电卡
+ (NSURLSessionDataTask *)postUnbindChargeCardWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - Social社交
//GET api/social/news/list 获取资讯列表
+ (NSURLSessionDataTask *)getNewsListWithNewType:(DCNewType)type page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//GET api/social/article/list 获取文章列表
+ (NSURLSessionDataTask *)getArticleListWithArticleType:(DCArticleListType)type page:(NSInteger)page pageSize:(NSInteger)pageSize userId:(NSString *)userId stationId:(NSString *)stationId completion:(HSSYApiCompletionBlock)completion;

//GET api/social/article/info 获取文章详情
+ (NSURLSessionDataTask *)getArticleInfo:(NSString *)articleId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//GET api/social/comment/list 获取评论列表
+ (NSURLSessionDataTask *)getCommentListWithArticleId:(NSString *)articleId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//GET api/social/like/list 获取点赞列表
+ (NSURLSessionDataTask *)getCommnetLikeListWithArticleId:(NSString *)articleId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion;

//POST api/social/evaluate 发表评价
+ (NSURLSessionDataTask *)postEvaluate:(NSString *)userId orderId:(NSString *)orderId starScore:(NSInteger)starScore envirScore:(NSInteger)envirScore facadeScore:(NSInteger)facadeScore speedScore:(NSInteger)speedScore content:(NSString *)content images:(NSArray *)images cityId:(NSString *)cityId completion:(HSSYApiCompletionBlock)completion;

//POST api/social/topic 发表话题
+ (NSURLSessionDataTask *)postTopic:(NSString *)userId content:(NSString *)content images:(NSArray *)images cityId:(NSString *)cityId completion:(HSSYApiCompletionBlock)completion;

//POST api/social/like 点赞
+ (NSURLSessionDataTask *)postCommentLikeWithArticleId:(NSString *)articleId userId:(NSString *)userId like:(BOOL)like completion:(HSSYApiCompletionBlock)completion;

//POST api/social/comment 评论/回复评论
+ (NSURLSessionDataTask *)postComment:(NSString *)userId content:(NSString *)content replyArticleId:(NSString *)replyArticleId replyCommentId:(NSString *)replyCommentId completion:(HSSYApiCompletionBlock)completion;

//POST api/social/article/delete 删除文章
+ (NSURLSessionDataTask *)postDeleteArticleWithArticleId:(NSString *)articleId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/social/comment/delete 删除评论
+ (NSURLSessionDataTask *)postDeleteCommentWithCommentId:(NSString *)commentId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - Message消息中心
//POST api/message/pushId 绑定推送ID
+ (NSURLSessionDataTask *)postBindPushId:(NSString *)pushId userId:(NSString *)userId pushEnable:(BOOL)pushEnable completion:(HSSYApiCompletionBlock)completion;

//GET api/message/list 获取消息列表
+ (NSURLSessionDataTask *)getMessageListWithStatus:(DCMessageStatus)status userId:(NSString *)userId page:(NSNumber *)page pageSize:(NSNumber *)pageSize completion:(HSSYApiCompletionBlock)completion;

//GET api/message/unread_num 获取未读消息数量
+ (NSURLSessionDataTask *)getUnreadMessageCount:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/message/status 设置消息状态
+ (NSURLSessionDataTask *)postMessageIds:(NSArray *)messageIds status:(DCMessageStatus)status type:(DCMessageSetType)type userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

//POST api/message/delete 删除消息
+ (NSURLSessionDataTask *)postClearMessageListWithMessageIds:(NSArray *)messageIds type:(DCMessageDeleteType)type userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion;

#pragma mark - System 系统
//POST api/system/feedback
+ (NSURLSessionDataTask *)postFeedback:(NSString *)feedback userid:(NSString *)userid images:(NSArray *)images completion:(HSSYApiCompletionBlock)completion;

//GET api/system/check_res_update
+ (NSURLSessionDataTask *)getUpdateMessageWithCompletion:(HSSYApiCompletionBlock)completion;

@end

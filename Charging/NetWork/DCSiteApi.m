//
//  DCSiteApi.m
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCSiteApi.h"
#import "DCHTTPSessionManager.h"
#import "DCTime.h"
#import "DCWebTime.h"
#import "NSDate+HSSYDate.h"

// User
NSString * const CheckUserExistUrl = @"api/user/acount/exist"; //用户是否存在
NSString * const LoginInUrl = @"api/user/login"; //用户登录
NSString * const RefreshTokenUrl = @"api/user/refresh_token"; //刷新token
NSString * const LogOutUrl = @"api/user/logout"; //用户登出
NSString * const RegisterUrl = @"api/user/register"; //用户注册
NSString * const FetchCaptchaUrl = @"api/user/captcha/send"; //获取验证码
NSString * const CheckTheCaptchaUrl = @"api/user/captcha/check"; //检验验证码
NSString * const ReSetPasswordUrl = @"api/user/password/reset"; //重置密码
NSString * const ChangePasswordUrl = @"api/user/password/modify"; //修改密码
NSString * const UserInfoUrl = @"api/user/info"; //修改/获取个人信息
NSString * const UserAvatarUrl = @"api/user/avatar"; //修改个人头像
NSString * const BindThirdIdUrl = @"api/user/third_account/bind"; //第三方绑定
NSString * const UnbindThirdIdUrl = @"api/user/third_account/unbind"; //第三方解绑

// Station&pile&chargePort
NSString * const ListStationsUrl = @"api/station/list"; //获取电站列表信息
// 获取电站地图聚合点
NSString * const MapStationsUrl = @"api/station/map"; //地图查找桩接口
NSString * const StationInfoUrl = @"api/station/info"; //获取电站详情
NSString * const PileListUrl = @"api/station/pile_list"; //获取充电桩列表
NSString * const AddOrCancelFavorStationUrl = @"api/station/favor"; //添加或取消收藏电站
NSString * const GetFavorStationsUrl = @"api/station/favorites"; //获取已收藏的电桩
NSString * const ReportStationUrl = @"api/station/report"; //上报电站
NSString * const MapDataUrl = @"api/pile/grantTotal"; //获取地图顶部4个数据

// 充电
NSString * const CheckCharingStatusUrl = @"api/pile/user_charging"; //自检用户是否正在充电
NSString * const FloorLockUrl = @"api/pile/floor_lock"; //地锁控制
NSString * const StartChargingUrl = @"api/pile/charge/start"; //开始充电
NSString * const StopChargingUrl = @"api/pile/charge/stop"; //停止充电
NSString * const PileScanInfoUrl = @"api/pile/scan_info"; //获取扫码后电桩详细信息

// Order
NSString * const BookingUrl = @"api/order/sub"; //预约充电
NSString * const OrderListUrl = @"api/order/list";  //获取我的订单列表
NSString * const OrderInfoUrl = @"api/order/info"; //获取订单详情
NSString * const DeleteOrdersUrl = @"api/order/delete"; //删除订单
NSString * const CancelOrderUrl = @"api/order/cancel";  //取消订单

// ChargeCoin充电币
NSString * const ChargeCoinInfoUrl = @"api/coin/info";  //获取充电币基本信息
NSString * const ChargeCoinRecordListUrl = @"api/coin/record/list"; //获取充电币交易记录列表
NSString * const ChargeCoinRecordInfoUrl = @"/api/coin/record/info"; //获取充电币交易记录详情

// BeeCloud
NSString * const RechargeUrl = @"api/transaction/recharge"; //在线充值
NSString * const PayUrl = @"api/transaction/pay";  //在线支付
NSString * const CaseUrl = @"api/transaction/cash"; //在线提现
NSString * const UnlockOrderUrl = @"api/transaction/unlock";  //解锁支付状态

// ChargeCard充电卡
NSString * const ChargeCardInfoUrl = @"api/card/info";  //获取电卡基本信息
NSString * const ChargeCardListUrl = @"api/card/list";  //获取我的电卡列表
NSString * const ChargeCardBindUrl = @"api/card/bind";  //绑定电卡
NSString * const ChargeCatdUnbindUrl = @"api/iccard/card/iccardunbind";  //解绑电卡

// Message消息中心
NSString * const PushBindingUrl = @"api/message/push_id"; //绑定推送ID
NSString * const PushListUrl = @"api/message/list"; //获取消息列表
NSString * const PushUnreadUrl = @"api/message/unread_num"; //获取未读消息数量
NSString * const PushStatusUrl = @"api/message/status"; //设置消息状态
NSString * const PushDeleteUrl = @"api/message/delete"; //删除消息

// Social社交
NSString * const SocialNewsListUrl = @"api/social/news/list"; //获取资讯列表
NSString * const SocialArticleListUrl = @"api/social/article/list"; //获取文章列表
NSString * const SocialArticleInfoUrl = @"api/social/article/info"; //获取文章详情
NSString * const SocialCommentListUrl = @"api/social/comment/list"; //获取评论列表
NSString * const SocialLikeListUrl = @"api/social/like/list"; //获取点赞列表
NSString * const SocialEvaluateUrl = @"api/social/evaluate"; //发表评价
NSString * const SocialTopicUrl = @"api/social/topic"; //发表话题
NSString * const SocialLikeUrl = @"api/social/like";  //点赞
NSString * const SocialCommentUrl = @"api/social/comment"; //评论/回复评价
NSString * const SocialDeleteArticleUrl = @"api/social/article/delete";  //删除文章
NSString * const SocialDeleteCommentUrl = @"api/social/comment/delete";  //删除评论

// System系统
NSString * const SystemFeedbackUrl = @"api/system/feedback";  //建议反馈
NSString * const SystemUpdateUrl = @"api/system/check_res_update";  //检查资源更新







//NSString * const StationPileList = @"station/pileState/"; //获取站内桩状态
//NSString * const PollUrl = @"pile/ctrl_res"; //轮询获取充电状态
//
//NSString * const PileFavorUrl = @"favorites"; //收藏电桩
//NSString * const FavorStateUrl = @"pile/hadcollect";//电桩是否被用户收藏
//NSString * const GetAccessPilesUrl = @"pile/access"; //获取有权限的桩（主人、家人）
//NSString * const UpdatePileInfoUrl = @"pile/modify"; //修改电桩信息
//NSString * const CheckSharePriceUrl = @"pile/set_price"; //分享价格检查
//NSString * const GetMemberUrl = @"pile/member"; //获取家人列表
//NSString * const AuthUrl = @"pile/authorization"; //授权给家人
//NSString * const ShareUrl = @"pile/share"; //设置分享（开关、分享时段、。。。。。。。）
//NSString * const OrderUrl = @"order"; //下订单（预约时间、租户信息）
//NSString * const OrderModifyUrl = @"order/modify"; //处理订单（主动取消、拒绝、同意）
//NSString * const ChargeRecordUrl = @"pile/chargerecord"; //获取充电记录
//NSString * const LastChargeRecordUrl = @"order/from-pile"; //直接问桩拿获取充电记录
//NSString * const PostChargeRecordUrl = @"pile/record/setrecord"; //上传orderId
//NSString * const ReqKeyDataUrl = @"key"; //获取授权key
//NSString * const EvaluateUrl = @"evaluate/add"; //添加评价
//NSString * const EvaluateListUrl = @"moment/pile_info/list"; //获取评价
//NSString * const CommentDetailUrl = @"moment/info/"; //获取评论详细
//NSString * const UserExistUrl = @"user/exist/"; //检查是否已经注册过
//NSString * const UserAlipayUrl = @"order/aliname/";
//NSString * const OrderEvaluateUrl = @"order/evalute";
//NSString * const PushSettingUrl = @"push/set";//推送消息开关
//
//NSString * const NewOrderInfoUrl = @"order/charge_end";//查询GPRS单条订单
//
//NSString * const ShareDetailUrl = @"pile/sharedetail";//分享时间拆分接口
//
//NSString * const ParkingLockInfoUrl = @"thirds/locks";//地锁信息
//
//NSString * const FavoritesBatchUrl = @"favorites/batch";//批量收藏电桩或者批量取消收藏电桩
//
//NSString * const ServerTimeUrl = @"sys/curtime";//获取服务器时间
//NSString * const PoleAlarmUrl = @"sys/pile/alarm";//获取服务器时间
//
//NSString * const DynamiclistUrl = @"news/list";//获取动态列表
//NSString * const DynamicDetailsUrl = @"news/view";//动态详情
//NSString * const ShareImageUrl = @"sys/qrcode";//分享图片
//
//NSString * const BaidupayInfo = @"pay/baidu/info";//获取百度钱包签名(签约并代扣)
//NSString * const BaiduBing = @"user/baidu_bing/";//获取绑定信息
//NSString * const BaiduBingSign = @"pay/baidu/sign/";//百度钱包独立签约接口 获取签名信息(只签约)
//NSString * const BaiduWithholding = @"pay/baidu/pay_money";//百度代扣(充电后直接代扣)
//NSString * const CanclePay = @"pay/charge/cancle_lock";//取消支付解除锁定
//
//NSString * const StationTypeUrl = @"sys/commonitem/stationType";//桩群类型
//NSString * const PoleTypeUrl = @"sys/commonitem/pileType";//桩类型
//
//NSString * const ChargeCoinNumUrl = @"user/charging_coins/";//获取充电币数量
//NSString * const ChargeCoinRecharge = @"pay/beecloud/recharge/recharge_count";//充电币充值
//NSString * const RechargeRecord = @"charging_coins/recharge_record"; //获取充值记录
//NSString * const PayRecord = @"charging_coins/pay_record";//获取支付记录
//NSString * const payParameter = @"pay/beecloud/money";//请求支付参数
//NSString * const CancleBanding = @"pay/baidu/cancle_banding/";//百度钱包解除绑定
//
//
//
////warm
//NSString * const GetFavorPilesUrl = @"favorites/list"; //获取已收藏的电桩
//NSString * const ListPolesUrl = @"pile/newlist";//获取电桩列表信息

@implementation DCSiteApi

#pragma mark 检查账号是否存在
//GET 检查账号是否存在
+ (NSURLSessionDataTask *)getAccountIsExist:(NSString *)account accType:(NSString *)accType completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (account) {
        [parameters setObject:account forKey:@"account"];
    }
    if (accType) {
        [parameters setObject:accType forKey:@"accType"];
    }
    return [manager GET:CheckUserExistUrl parameters:parameters completion:completion];
}

#pragma mark 用户登录
+(NSURLSessionDataTask *)postLoginWithAccount:(NSString *)account password:(NSString *)password accType:(NSInteger)accType pushId:(NSString *)pushId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (account) {
        [parameters setObject:account forKey:@"account"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (accType) {//用户类型 1:手机号；2:用户名 3:微信 4:QQ
        [parameters setObject:@(accType) forKey:@"accType"];
    }
    if (pushId) {
        [parameters setObject:pushId forKey:@"pushId"];
    }
    return [manager POST:LoginInUrl parameters:parameters completion:completion];
}

//刷新Token
+ (NSURLSessionDataTask *)refreshToken:(NSString *)refreshToken userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (refreshToken) {
        [parameters setObject:refreshToken forKey:@"refreshToken"];
    }
    return [manager POST:RefreshTokenUrl parameters:parameters completion:completion];
}

#pragma mark - smssendcontroller : 短信相关操作
//POST /tplsendsms 获取短信验证码
//state: 1:注册; 2:代表重置密码 3.充电币提现
+ (NSURLSessionDataTask *)postSendSms:(NSString *)phone type:(DCSmsType)type completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (phone) {
        [parameters setObject:phone  forKey:@"phone"];
    }
    [parameters setObject:@(type)  forKey:@"type"];
    
    return [manager POST:FetchCaptchaUrl parameters:parameters completion:completion];
}

//POST 检查验证码是否正确
+ (NSURLSessionDataTask *)postExamineVerification:(NSString *)phone captcha:(NSString *)captcha completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (phone) {
        [parameters setObject:phone forKey:@"phone"];
    }
    if (captcha) {
        [parameters setObject:captcha forKey:@"captcha"];
    }
    return [manager POST:CheckTheCaptchaUrl parameters:parameters completion:completion];
}

#pragma mark 第三方登录绑定和解绑
// 绑定
+ (NSURLSessionDataTask *)postBindUserId:(NSString *)userId thirdAccUid:(NSString *)thirdAccUid thirdAccToken:(NSString *)thirdAccToken thirdAccType:(NSString *)thirdAccType completion:(HSSYApiCompletionBlock)completion
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (thirdAccUid) {
        [parameters setObject:thirdAccUid forKey:@"thirdAccUid"];
    }
    if (thirdAccToken) {
        [parameters setObject:thirdAccToken forKey:@"thirdAccToken"];
    }
    if (thirdAccType) {
        [parameters setObject:thirdAccType forKey:@"thirdAccType"];
    }
    return [manager POST:BindThirdIdUrl parameters:parameters completion:completion];
}
// 解绑
+(NSURLSessionDataTask *)postUnbindUserId:(NSString *)userId thirdAccType:(NSString *)thirdAccType completion:(HSSYApiCompletionBlock)completion
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (thirdAccType) {
        [parameters setObject:thirdAccType forKey:@"thirdAccType"];
    }
    return [manager POST:UnbindThirdIdUrl parameters:parameters completion:completion];
}

#pragma mark 用户注册
+(NSURLSessionDataTask *)postUserRegister:(NSString *)phone password:(NSString *)password accType:(NSInteger)accType nickName:(NSString *)nickName gender:(NSInteger)gender captcha:(NSString *)captcha thirdAccUid:(NSString *)thirdAccUid thirdAccToken:(NSString *)thirdAccToken pushId:(NSString *)pushId completion:(HSSYApiCompletionBlock)completion
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManagerWithVerification:captcha];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (phone) {
        [parameters setObject:phone forKey:@"phone"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    if (captcha) {
        [parameters setObject:captcha forKey:@"captcha"];
    }
    if (accType) {
        [parameters setObject:@(accType) forKey:@"accType"];
    }
    if (nickName) {
        [parameters setObject:nickName forKey:@"nickName"];
    }
    if (gender) {
        [parameters setObject:@(gender) forKey:@"gender"];
    }
    if (thirdAccUid) {
        [parameters setObject:thirdAccUid forKey:@"thirdAccUid"];
    }
    if (thirdAccToken) {
        [parameters setObject:thirdAccToken forKey:@"thirdAccToken"];
    }
    if (pushId) {
        [parameters setObject:pushId forKey:@"pushId"];
    }
    return [manager POST:RegisterUrl parameters:parameters completion:completion];
}

#pragma mark 重置密码
+(NSURLSessionDataTask *)postReSetPassword:(NSString *)phone password:(NSString *)password captcha:(NSString *)captcha completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManagerWithVerification:captcha];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (phone) {
        [parameters setObject:phone forKey:@"phone"];
    }
    if (password) {
        [parameters setObject:password forKey:@"newPwd"];
    }
    if (captcha) {
        [parameters setObject:captcha forKey:@"captcha"];
    }
    return [manager POST:ReSetPasswordUrl parameters:parameters completion:completion];
}
#pragma mark 修改密码
/*
 "userid": "",
 "currentPwd": "",
 "newPwd": "",
 "comfirmPwd": ""
 */
+ (NSURLSessionDataTask *)postChangePasswordUserId:(NSString *)userId currentPassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completion:(HSSYApiCompletionBlock)completion{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (currentPassword) {
        [parameters setObject:currentPassword forKey:@"currentPwd"];
    }
    if (newPassword) {
        [parameters setObject:newPassword forKey:@"newPwd"];
    }
    return [manager POST:ChangePasswordUrl parameters:parameters completion:completion];
}

#pragma mark 登出
+(NSURLSessionDataTask *)postLogOut:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:LogOutUrl parameters:parameters completion:completion];
}

#pragma mark  修改个人信息
+(NSURLSessionDataTask *)postUpdateUserInfo:(DCUser *)user completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (user.userId) {
        [parameters setObject:user.userId forKey:@"userId"];
    }
    if (user.nickName) {
        [parameters setObject:user.nickName forKey:@"nickName"];
    }
    if (user.gender) {
        [parameters setObject:((user.gender == DCUserGenderMale) ? @"1" : @"2") forKey:@"gender"];
    }
    if (user.alipayAcc) {
        [parameters setObject:user.alipayAcc forKey:@"alipayAcc"];
    }
    if (user.alipayName) {
        [parameters setObject:user.alipayName forKey:@"alipayName"];
    }
    return [manager POST:UserInfoUrl parameters:parameters completion:completion];
}
#pragma mark - user : UserController 相关操作
//POST /user/upload modifyAvatar 修改个人头像
+ (NSURLSessionDataTask *)postAvatar:(NSData *)avatar userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager uploadImageManager];
    NSURLSessionDataTask *task = [manager POST:UserAvatarUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        DDLogVerbose(@"[request] %@ (POST)", UserAvatarUrl);
        if (userId) {
            [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userId"];
        }
        if (avatar) {
            [formData appendPartWithFileData:avatar name:@"avatar" fileName:@"avatar.jpg" mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
            DDLogVerbose(@"头像上传成功");
            completion(task, YES, webResponse, nil);
            DDLogVerbose(@"[response] %@ success %@", UserAvatarUrl, prettyPrintedstringForJSONObject(responseObject));
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            DDLogVerbose(@"头像上传成失败");
            completion(task, NO, nil, error);
            DDLogVerbose(@"[response] %@ error %@", UserAvatarUrl, error);
        }
    }];
    return task;
}

// GET  /UserInfoUrl 获取用户信息
+ (NSURLSessionDataTask *)getUserInfo:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    NSString *url = [UserInfoUrl stringByAppendingString:userId];
    return [[DCHTTPSessionManager shareManager] GET:url parameters:nil completion:completion];
}

#pragma mark  station&pile
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
                                                completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (longitude) {
        [parameters setObject:longitude forKey:@"longitude"];
    }
    if (latitude) {
        [parameters setObject:latitude forKeyedSubscript:@"latitude"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (cityId) {
        [parameters setObject:cityId forKey:@"cityId"];
    }
    if (distance) {
        [parameters setObject:distance forKey:@"distance"];
    }
    if (sort) {
        [parameters setObject:sort forKey:@"sort"];
    }
    if (types) {
        [parameters setObject:types forKey:@"stationTypes"];
    }
    if (chargeTypes) {
        [parameters setObject:chargeTypes forKey:@"chargeTypes"];
    }
    if (isIdle) {
        [parameters setObject:[NSNumber numberWithBool:isIdle] forKey:@"isIdle"];
    }
    if (isFreeOrder) {
        [parameters setObject:[NSNumber numberWithBool:isFreeOrder] forKey:@"isFreeOrder"];
    }
    if (search) {
        [parameters setObject:search forKey:@"search"];
    }
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:ListStationsUrl parameters:parameters completion:completion];
}

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
+ (NSURLSessionDataTask *)requestMapStationsWithUserId:(NSString *)userId coordinate:(CLLocationCoordinate2D)coordinate
                                        coordinate2:(CLLocationCoordinate2D)coordinate2
                                               zoom:(NSNumber *)zoom
                                           maxLevel:(NSNumber *)maxLevel
                                               stationType:(NSString *)stationType
                                               chargeTypes:(NSString *)chargeTypes
                                             isIdle:(BOOL)isIdle
                                        isFreeOrder:(BOOL)isFreeOrder
                                            keyWord:(NSString *)keyWord
                                         completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
        [parameters setObject:@(coordinate.longitude) forKey:@"leftBottomLng"];
        [parameters setObject:@(coordinate.latitude) forKey:@"leftBottomLat"];
    [parameters setObject:@(coordinate2.longitude) forKey:@"rightTopLng"];
    [parameters setObject:@(coordinate2.latitude) forKey:@"rightTopLat"];
    if (zoom) {
        [parameters setObject:zoom forKey:@"zoom"];
    }
    if (maxLevel) {
        [parameters setObject:maxLevel forKey:@"maxZoom"];
    }
    if (stationType) {
        [parameters setObject:stationType forKey:@"stationTypes"];
    }
    if (chargeTypes) {
        [parameters setObject:chargeTypes forKey:@"chargeTypes"];
    }
    [parameters setObject:[NSNumber numberWithBool:isIdle] forKey:@"isIdle"];
    [parameters setObject:[NSNumber numberWithBool:isFreeOrder] forKey:@"isFreeOrder"];
    if (keyWord) {
        [parameters setObject:keyWord forKey:@"search"];
    }
    return [manager GET:MapStationsUrl parameters:parameters completion:completion];
}

// GET /station 获取电站详情
+ (NSURLSessionDataTask *)getStationId:(NSString *)stationId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (stationId) {
        [parameters setObject:stationId forKey:@"stationId"];
    }
    return [manager GET:StationInfoUrl parameters:parameters completion:completion];
}

// GET station/pile_list 获取站内电桩列表信息
+ (NSURLSessionDataTask *)getPileList:(NSString *)stationId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (stationId) {
        [parameters setObject:stationId forKey:@"stationId"];
    }
    return [manager GET:PileListUrl parameters:parameters completion:completion];
}

// POST station/favor 添加/取消收藏电站
+ (NSURLSessionDataTask *)postFavoritesStations:(NSArray *)stationIds userId:(NSString *)userId favorites:(NSInteger)favorites completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    NSString *stationIdsString = [stationIds componentsJoinedByString:@","];
    if (stationIds) {
        [parameters setObject:stationIds forKey:@"stationIds"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (favorites) {
        [parameters setObject:@(favorites) forKey:@"favor"];//1：收藏 ；2：取消收藏
    }
    return [manager POST:AddOrCancelFavorStationUrl parameters:parameters completion:completion];
}

// GET /favorites/list 获取电站收藏列表
+ (NSURLSessionDataTask *)getFavoritesStationList:(NSString *)userId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:GetFavorStationsUrl parameters:parameters completion:completion];
}

// POST station/report
+ (NSURLSessionDataTask *)postAddStation:(NSString *)userId address:(NSString *)address longitude:(double)longitude latitude:(double)latitude stationStatus:(NSInteger)stationStatus stationType:(NSInteger)stationType images:(NSArray *)images stationName:(NSString *)stationName desp:(NSString *)desp completion:(HSSYApiCompletionBlock)completion{
    
    DCHTTPSessionManager *manager = [DCHTTPSessionManager uploadImageManager];
    NSURLSessionDataTask *task = [manager POST:ReportStationUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (userId) {
            [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userId"];
        }
        if (address) {
            [formData appendPartWithFormData:[address dataUsingEncoding:NSUTF8StringEncoding] name:@"address"];
        }
        if (longitude) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%f",longitude] dataUsingEncoding:NSUTF8StringEncoding] name:@"longitude"];
        }
        if (latitude) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%f",latitude] dataUsingEncoding:NSUTF8StringEncoding] name:@"latitude"];
        }
        
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", (int)stationStatus] dataUsingEncoding:NSUTF8StringEncoding] name:@"status"];
        
        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d", (int)stationType] dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
        
        for (NSInteger i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSString *fileName = [NSString stringWithFormat:@"image%d.jpg", (int)i];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"images" fileName:fileName mimeType:@"image/jpeg"];
        }
        
        if (stationName) {
            [formData appendPartWithFormData:[stationName dataUsingEncoding:NSUTF8StringEncoding] name:@"stationName"];
        }
        
        if (desp) {
            [formData appendPartWithFormData:[desp dataUsingEncoding:NSUTF8StringEncoding] name:@"desp"];
        }
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
            completion(task, YES, webResponse, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    return task;
}

// 获取地图上方4个桩群数的数据
+ (NSURLSessionDataTask *)getMapTopData:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    return [manager GET:MapDataUrl parameters:nil completion:completion];
}

//// pile/newlist 搜索电桩
//+ (NSURLSessionDataTask *)postPileSearch:(NSString *)search
//                                   page:(NSNumber *)page
//                                   pageSize:(NSNumber *)pageSize
//                              completion:(HSSYApiCompletionBlock)completion {
//    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
//    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    if (search) {
//        [parameters setObject:search forKey:@"search"];
//    }
//    if (page) {
//        [parameters setObject:page forKey:@"page"];
//    }
//    if (pageSize) {
//        [parameters setObject:pageSize forKey:@"pageSize"];
//    }
//    return [manager POST:ListStationsUrl parameters:parameters completion:completion];
//}

//POST /favorites/batch 批量收藏电桩或者批量取消收藏电桩
//+ (NSURLSessionDataTask *)postFavoritesBatch:(NSDictionary *)batch completion:(HSSYApiCompletionBlock)completion {
//    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
//    return [manager POST:FavoritesBatchUrl parameters:batch completion:completion];
//}

#pragma mark - charge ChargingViewController相关API
//GET 自检用户是否正在充电
+ (NSURLSessionDataTask *)getUserChargingStatus:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:CheckCharingStatusUrl parameters:parameters completion:completion];
}

//GET /pile/scan_info 获取扫码后电桩详细信息
+ (NSURLSessionDataTask *)getPileInfoAfterScan:(NSString *)pileId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (pileId) {
        [parameters setObject:pileId forKey:@"pileId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:PileScanInfoUrl parameters:parameters completion:completion];
}

// POST /pile/floor_lock 地锁控制
+ (NSURLSessionDataTask *)postCommandToDownFloorLockWithPileId:(NSString *)pileId userId:(NSString *)userId chargePortIndex:(NSInteger)chargePortIndex control:(NSInteger)control completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (pileId) {
        [parameters setObject:pileId forKey:@"pileId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    [parameters setObject:@(chargePortIndex) forKey:@"chargePortIndex"];
    [parameters setObject:@(control) forKey:@"control"];
    return [manager POST:FloorLockUrl parameters:parameters completion:completion];
}

//POST api/pile/charge/start 开始充电
+ (NSURLSessionDataTask *)postStartCharging:(NSString *)userId
                                   pileId:(NSString *)pileId
                          chargePortIndex:(NSInteger)chargePortIndex
                               chargeMode:(NSInteger)chargeMode
                              chargeLimit:(double)chargeLimit
                               completion:(HSSYApiCompletionBlock)completion;
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKeyedSubscript:@"userId"];
    }
    if (pileId) {
        [parameters setObject:pileId forKeyedSubscript:@"pileId"];
    }
    if (chargePortIndex) {
        [parameters setObject:@(chargePortIndex) forKey:@"chargePortIndex"];
    }
    [parameters setObject:@(chargeMode) forKey:@"chargeMode"];
//    if (chargeMode != 0) {
//        if (chargeLimit) {
            [parameters setObject:@(chargeLimit) forKey:@"chargeLimit"];
//        }
//    }
    return [manager POST:StartChargingUrl parameters:parameters completion:completion];
}

//POST api/pile/charge/stop 停止充电
+ (NSURLSessionDataTask *)postStopCharging:(NSString *)userId
                                   pileId:(NSString *)pileId
                          chargePortIndex:(NSInteger)chargePortIndex
                               completion:(HSSYApiCompletionBlock)completion;
{
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKeyedSubscript:@"userId"];
    }
    if (pileId) {
        [parameters setObject:pileId forKeyedSubscript:@"pileId"];
    }
    if (chargePortIndex) {
        [parameters setObject:@(chargePortIndex) forKey:@"chargePortIndex"];
    }
    return [manager POST:StopChargingUrl parameters:parameters completion:completion];
}

#pragma mark - order OrderViewController相关操作
// POST api/order/sub 预约订单
+ (NSURLSessionDataTask *)postBookingOrderWithUserId:(NSString *)userId stationId:(NSString *)stationId chargeType:(NSInteger)chargeType orderDuration:(NSInteger)orderDuration completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (stationId) {
        [parameters setObject:stationId forKey:@"stationId"];
    }
    
    [parameters setObject:@(chargeType) forKey:@"chargeType"];

    if (orderDuration) {
        [parameters setObject:@(orderDuration) forKey:@"orderDuration"];
    }
    return [manager POST:BookingUrl parameters:parameters completion:completion];
}

// GET api/order/list 获取订单列表
+ (NSURLSessionDataTask *)getOrderList:(NSString *)userId status:(NSString *)status startTime:(NSString *)startTime endTime:(NSString *)endTime page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (status) {
        [parameters setObject:status forKey:@"status"];
    }
    if (startTime) {
        [parameters setObject:startTime forKey:@"startTime"];
    }
    if (endTime) {
        [parameters setObject:endTime forKey:@"endTime"];
    }
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:OrderListUrl parameters:parameters completion:completion];
}

//GET api/order/info 根据订单id来获取订单详情
+ (NSURLSessionDataTask *)getOrderInfo:(NSString *)orderId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (orderId) {
        [parameters setObject:orderId forKey:@"orderId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:OrderInfoUrl parameters:parameters completion:completion];
}

#pragma mark - ChargeCoins
//GET api/coin/info
+ (NSURLSessionDataTask *)getChargeCoinInfoWithUserId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:ChargeCoinInfoUrl parameters:parameters completion:completion];
}

//GET api/coin/record/list
+ (NSURLSessionDataTask *)getChargeCoinRecordListWithUserId:(NSString *)userId type:(NSInteger)type page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    [parameters setInteger:type forKey:@"type"];
    if (page) {
        [parameters setInteger:page forKey:@"page"];
    }
    if (pageSize) {
        [parameters setInteger:pageSize forKey:@"pageSize"];
    }
    return [manager GET:ChargeCoinRecordListUrl parameters:parameters completion:completion];
}

//GET api/coin/record/info
+ (NSURLSessionDataTask *)getChargeCoinRecordInfoWithId:(NSString *)coinRecordId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (coinRecordId) {
        [parameters setObject:coinRecordId forKey:@"coinRecordId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:ChargeCoinRecordInfoUrl parameters:parameters completion:completion];
}

//POST api/order/delete 删除订单
+ (NSURLSessionDataTask *)postOrderIdsToDeleteOrder:(NSString *)userId orderIds:(NSArray *)orderIds completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (orderIds) {
        [parameters setObject:orderIds forKey:@"orderIds"];
    }
    return [manager POST:DeleteOrdersUrl parameters:parameters completion:completion];
}

//POST api/order/cancel 取消订单
+ (NSURLSessionDataTask *)postOrderIdToCancelOrder:(NSString *)userId orderId:(NSString *)orderId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (orderId) {
        [parameters setObject:orderId forKey:@"orderId"];
    }
    return [manager POST:CancelOrderUrl parameters:parameters completion:completion];
}

#pragma mark - BeeCloudPay
//POST api/transaction/recharge 在线充值
+ (NSURLSessionDataTask *)postRechargeWithUserId:(NSString *)userId rechargeCoins:(CGFloat)rechargeCoins completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (rechargeCoins) {
        [parameters setObject:@(rechargeCoins) forKey:@"money"];
    }
    return [manager POST:RechargeUrl parameters:parameters completion:completion];
}

//POST api/transaction/pay 在线支付
+ (NSURLSessionDataTask *)postPayWithUserId:(NSString *)userId orderId:(NSString *)orderId costCoin:(NSNumber *)costCoin completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (orderId) {
        [parameters setObject:orderId forKey:@"orderId"];
    }
    [parameters setObject:costCoin forKey:@"costCoin"];
    return [manager POST:PayUrl parameters:parameters completion:completion];
}

//POST api/transaction/cash 在线提现
+ (NSURLSessionDataTask *)postDrawTheCashWithUserId:(NSString *)userId costCoin:(CGFloat)costCoin password:(NSString *)password completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (costCoin) {
        [parameters setObject:@(costCoin) forKey:@"costCoin"];
    }
    if (password) {
        [parameters setObject:password forKey:@"password"];
    }
    return [manager POST:CaseUrl parameters:parameters completion:completion];
}

//POST api/transaction/unlock 解锁支付
+ (NSURLSessionDataTask *)postOrderIdForUnlockOrder:(NSString *)orderId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (orderId) {
        [parameters setObject:orderId forKey:@"orderId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:UnlockOrderUrl parameters:parameters completion:completion];
}

#pragma mark - ChargeCard
//GET api/card/info 充电卡基本信息
+ (NSURLSessionDataTask *)getChargeCardInfoWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (cardId) {
        [parameters setObject:cardId forKey:@"cardId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:ChargeCardInfoUrl parameters:parameters completion:completion];
}

//GET api/card/list 获取充电卡列表
+ (NSURLSessionDataTask *)getChargeCardListWithUserId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:ChargeCardListUrl parameters:parameters completion:completion];
}

//POST api/card/bind 绑定电卡
+ (NSURLSessionDataTask *)postBindChargeCardWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (cardId) {
        [parameters setObject:cardId forKey:@"cardId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:ChargeCardBindUrl parameters:parameters completion:completion];
}

//POST api/card/unbind 解绑电卡
+ (NSURLSessionDataTask *)postUnbindChargeCardWithCardId:(NSString *)cardId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (cardId) {
        [parameters setObject:cardId forKey:@"cardId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:ChargeCatdUnbindUrl parameters:parameters completion:completion];
}


#pragma mark - Message消息中心
//POST api/message/pushId 绑定推送ID
+ (NSURLSessionDataTask *)postBindPushId:(NSString *)pushId userId:(NSString *)userId pushEnable:(BOOL)pushEnable completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (pushId) {
        [parameters setObject:pushId forKey:@"pushId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    [parameters setObject:(pushEnable ? @"1" : @"0") forKey:@"pushEnable"];
    return [manager POST:PushBindingUrl parameters:parameters completion:completion];
}

//GET api/message/list 获取消息列表
+ (NSURLSessionDataTask *)getMessageListWithStatus:(DCMessageStatus)status userId:(NSString *)userId page:(NSNumber *)page pageSize:(NSNumber *)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(status) forKey:@"status"];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (page) {
        [parameters setObject:page forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:pageSize forKey:@"pageSize"];
    }
    return [manager GET:PushListUrl parameters:parameters completion:completion];
}

//GET api/message/unread_num 获取未读消息数量
+ (NSURLSessionDataTask *)getUnreadMessageCount:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }    
    return [manager GET:PushUnreadUrl parameters:parameters completion:completion];
}

//POST api/message/status 设置消息状态
+ (NSURLSessionDataTask *)postMessageIds:(NSArray *)messageIds status:(DCMessageStatus)status type:(DCMessageSetType)type userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (messageIds) {
        [parameters setObject:messageIds forKey:@"messageIds"];
    }
    [parameters setObject:@(status) forKey:@"status"];
    [parameters setObject:@(type) forKey:@"type"];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:PushStatusUrl parameters:parameters completion:completion];
}

//POST api/message/delete 删除消息
+ (NSURLSessionDataTask *)postClearMessageListWithMessageIds:(NSArray *)messageIds type:(DCMessageDeleteType)type userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
//    NSString *messageIdsString = [messageIds componentsJoinedByString:@","];
    if (messageIds) {
        [parameters setObject:messageIds forKey:@"messageIds"];
    }
    [parameters setObject:@(type) forKey:@"type"];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:PushDeleteUrl parameters:parameters completion:completion];
}


#pragma mark - Social社交
//GET api/social/news/list 获取资讯列表
+ (NSURLSessionDataTask *)getNewsListWithNewType:(DCNewType)type page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(type) forKey:@"type"];
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:SocialNewsListUrl parameters:parameters completion:completion];
}

//GET api/social/article/list 获取文章列表
+ (NSURLSessionDataTask *)getArticleListWithArticleType:(DCArticleListType)type page:(NSInteger)page pageSize:(NSInteger)pageSize userId:(NSString *)userId stationId:(NSString *)stationId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:@(type) forKey:@"type"];
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (stationId) {
        [parameters setObject:stationId forKey:@"stationId"];
    }
    return [manager GET:SocialArticleListUrl parameters:parameters completion:completion];
}

//GET api/social/article/info 获取文章详情
+ (NSURLSessionDataTask *)getArticleInfo:(NSString *)articleId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (articleId) {
        [parameters setObject:articleId forKey:@"articleId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager GET:SocialArticleInfoUrl parameters:parameters completion:completion];
}

//GET api/social/comment/list 获取评论列表
+ (NSURLSessionDataTask *)getCommentListWithArticleId:(NSString *)articleId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (articleId) {
        [parameters setObject:articleId forKey:@"articleId"];
    }
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:SocialCommentListUrl parameters:parameters completion:completion];
}

//GET api/social/like/list 获取点赞列表
+ (NSURLSessionDataTask *)getCommnetLikeListWithArticleId:(NSString *)articleId page:(NSInteger)page pageSize:(NSInteger)pageSize completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (articleId) {
        [parameters setObject:articleId forKey:@"articleId"];
    }
    if (page) {
        [parameters setObject:@(page) forKey:@"page"];
    }
    if (pageSize) {
        [parameters setObject:@(pageSize) forKey:@"pageSize"];
    }
    return [manager GET:SocialLikeListUrl parameters:parameters completion:completion];
}

//POST api/social/evaluate 发表评价
+ (NSURLSessionDataTask *)postEvaluate:(NSString *)userId orderId:(NSString *)orderId starScore:(NSInteger)starScore envirScore:(NSInteger)envirScore facadeScore:(NSInteger)facadeScore speedScore:(NSInteger)speedScore content:(NSString *)content images:(NSArray *)images cityId:(NSString *)cityId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager uploadImageManager];
    NSURLSessionDataTask *task = [manager POST:SocialEvaluateUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (userId) {
            [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userId"];
        }
        if (orderId) {
            [formData appendPartWithFormData:[orderId dataUsingEncoding:NSUTF8StringEncoding] name:@"orderId"];
        }
        if (starScore) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d",(int)starScore] dataUsingEncoding:NSUTF8StringEncoding] name:@"starScore"];
        }
        if (envirScore) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d",(int)envirScore] dataUsingEncoding:NSUTF8StringEncoding] name:@"envirScore"];
        }
        if (facadeScore) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d",(int)facadeScore] dataUsingEncoding:NSUTF8StringEncoding] name:@"facadeScore"];
        }
        if (speedScore) {
            [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d",(int)speedScore] dataUsingEncoding:NSUTF8StringEncoding] name:@"speedScore"];
        }
        if (content) {
            [formData appendPartWithFormData:[content dataUsingEncoding:NSUTF8StringEncoding] name:@"content"];
        }

        for (NSInteger i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSString *fileName = [NSString stringWithFormat:@"img%d.jpg", (int)i];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"images" fileName:fileName mimeType:@"image/jpeg"];
        }
        
        if (cityId) {
            [formData appendPartWithFormData:[cityId dataUsingEncoding:NSUTF8StringEncoding] name:@"cityId"];
        }

    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
            completion(task, YES, webResponse, nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    return task;
}

//POST api/social/topic 发表话题
+ (NSURLSessionDataTask *)postTopic:(NSString *)userId content:(NSString *)content images:(NSArray *)images cityId:(NSString *)cityId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager uploadImageManager];
    NSURLSessionDataTask *task = [manager POST:SocialTopicUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (userId) {
            [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userId"];
        }
        if (content) {
            [formData appendPartWithFormData:[content dataUsingEncoding:NSUTF8StringEncoding] name:@"content"];
        }
        
        for (NSInteger i = 0; i < images.count; i++) {
            UIImage *image = images[i];
            NSString *fileName = [NSString stringWithFormat:@"img%d.jpg", (int)i];
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"images" fileName:fileName mimeType:@"image/jpeg"];
        }
        
        if (cityId) {
            [formData appendPartWithFormData:[cityId dataUsingEncoding:NSUTF8StringEncoding] name:@"cityId"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
        completion(task, YES, webResponse, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(task, NO, nil, error);
        }
    }];
    return task;
}

//POST api/social/like 点赞
+ (NSURLSessionDataTask *)postCommentLikeWithArticleId:(NSString *)articleId userId:(NSString *)userId like:(BOOL)like completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (articleId) {
        [parameters setObject:articleId forKey:@"articleId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    [parameters setObject:(like ? @"1" : @"0") forKey:@"like"];
    return [manager POST:SocialLikeUrl parameters:parameters completion:completion];
}

//POST api/social/comment 评论/回复评论
+ (NSURLSessionDataTask *)postComment:(NSString *)userId content:(NSString *)content replyArticleId:(NSString *)replyArticleId replyCommentId:(NSString *)replyCommentId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    if (content) {
        [parameters setObject:content forKey:@"content"];
    }
    if (replyArticleId) {
        [parameters setObject:replyArticleId forKey:@"replyArticleId"];
    }
    if (replyCommentId) {
        [parameters setObject:replyCommentId forKey:@"replyCommentId"];
    }
    return [manager POST:SocialCommentUrl parameters:parameters completion:completion];
}

//POST api/social/article/delete 删除文章
+ (NSURLSessionDataTask *)postDeleteArticleWithArticleId:(NSString *)articleId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (articleId) {
        [parameters setObject:articleId forKey:@"articleId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:SocialDeleteArticleUrl parameters:parameters completion:completion];
}

//POST api/social/comment/delete 删除评论
+ (NSURLSessionDataTask *)postDeleteCommentWithCommentId:(NSString *)commentId userId:(NSString *)userId completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (commentId) {
        [parameters setObject:commentId forKey:@"commentId"];
    }
    if (userId) {
        [parameters setObject:userId forKey:@"userId"];
    }
    return [manager POST:SocialDeleteCommentUrl parameters:parameters completion:completion];
}

#pragma mark - System 系统
//POST api/system/feedback
+ (NSURLSessionDataTask *)postFeedback:(NSString *)feedback userid:(NSString *)userid images:(NSArray *)images completion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager uploadImageManager];
    NSURLSessionDataTask *task = [manager POST:SystemFeedbackUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (userid) {
            [formData appendPartWithFormData:[userid dataUsingEncoding:NSUTF8StringEncoding] name:@"userId"];
        }
        if (feedback) {
            [formData appendPartWithFormData:[feedback dataUsingEncoding:NSUTF8StringEncoding] name:@"content"];
        }
        [formData appendPartWithFormData:[@"1" dataUsingEncoding:NSUTF8StringEncoding] name:@"type"];
        
        for (NSInteger i = 0; i < images.count; i++) {
            NSData *image = images[i];
            NSString *fileName = [NSString stringWithFormat:@"img%d.jpg", (int)i];
            [formData appendPartWithFileData:image name:@"images" fileName:fileName mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        if (completion) {
            DCWebResponse *webResponse = [[DCWebResponse alloc] initWithData:responseObject];
            completion(task, YES, webResponse, nil);
            DDLogVerbose(@"[response] %@ success %@", SystemFeedbackUrl, prettyPrintedstringForJSONObject(responseObject));
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (completion) {
            completion(task, NO, nil, error);
            DDLogVerbose(@"[response] %@ failure)", SystemFeedbackUrl);
        }
    }];
    return task;
}

//GET api/system/check_res_update
+ (NSURLSessionDataTask *)getUpdateMessageWithCompletion:(HSSYApiCompletionBlock)completion {
    DCHTTPSessionManager *manager = [DCHTTPSessionManager shareManager];
    return [manager GET:SystemUpdateUrl parameters:nil completion:completion];
}


//



@end

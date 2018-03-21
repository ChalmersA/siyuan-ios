//
//  HSSYHTTPSessionManager.h
//  Charging
//
//  Created by Ben on 15/1/7.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "AFNetworking.h"
#import "DCWebResponse.h"

#define RESPONSE_CODE_ILLEGAL_DATA (-3)     //输入数据有误
#define RESPONSE_CODE_OPTION (-2)   //非法操作
#define RESPONSE_CODE_BUSY (-1)     //处理失败

#define RESPONSE_CODE_SUCCESS 0     //成功code

#define RESPONSE_CODE_ACCOUNT_EXISTED 10002                 //账户已存在
#define RESPONSE_CODE_ACCOUNT_NOTEXISTED 10003              //账户不存在
#define RESPONSE_CODE_ACCOUNT_LOCKD 10004                   //账户已被锁定, 请联系管理员
#define RESPONSE_CODE_ACCOUNT_LOGIN_LIMIT 10005             //登录尝试失败次数过多, 一小时后再试
#define RESPONSE_CODE_INVALID_USERID 10006                  //无效UserId
#define RESPONSE_CODE_ACCOUNT_PASSWORD_ILLEGAL 10007        //用户名或密码错误
#define RESPONSE_CODE_ACCOUNT_PASSWORD_WRONG 10008          //当前密码不正确
#define RESPONSE_CODE_ACCOUNT_NOT_EQUAL_PASSWORD 10009      //新旧密码重复，请重新设置
#define RESPONSE_CODE_ACCOUNT_CONFIRMPWD_ERR 10010          //新密码与确认密码密码不一致
#define RESPONSE_CODE_ACCOUNT_ACC_IS_BIND 10011             //第三方账号已经绑定其他APP账号
#define RESPONSE_CODE_ACCOUNT_USER_IS_BIND 10012            //此APP账号已经绑定了第三方账户
#define RESPONSE_CODE_ACCOUNT_PASSWORD_LENGTH_LIMIT 10013   //密码应为6-16位的数字或字母
#define RESPONSE_CODE_ACCOUNT_ERR_OLD_PASSWORD 10014        //旧密码错误
#define RESPONSE_CODE_ACCOUNT_ROLENAME_EXISTED 10015        //角色名已经存在
#define RESPONSE_CODE_ACCOUNT_PWORPHONE_WRONG 10017         //手机号或密码不正确

#define RESPONSE_CODE_INVALID_TOKEN 11000           //无效token
#define RESPONSE_CODE_ERROR_CLIENTID 11001          //Token不是由本终端生成
#define RESPONSE_CODE_INVALID_RETOKEN 11002         //无效RefreshToken
#define RESPONSE_CODE_INVALID_CLIENTID 11003        //无效clientId
#define RESPONSE_CODE_TOKEN_EXPIRED 11004           //Token过期
#define RESPONSE_CODE_VALICODE_EXPIRED 11005        //验证码已过期
#define RESPONSE_CODE_VALICODE_ERROR 11006          //请输入正确验证码
#define RESPONSE_CODE_CODE_FREQUENT 11007           //验证码获取时间间隔为6请等待
#define RESPONSE_CODE_PHONE_NOT_EXISTS 11008        //手机号未注册，请先注册
#define RESPONSE_CODE_PHONE_EXISTS 11009            //该手机号已注册，请点击返回，直接登录
#define RESPONSE_CODE_REFRESH_TOKEN_EXPIRED 11010   //授权过期，请重新登陆
#define RESPONSE_CODE_OUTTIMES_PHONE_SMS 11011      //发短信次数超过上限

#define RESPONSE_CODE_CHARGE_NOTPAY 30002           //订单尚未支付
#define RESPONSE_CODE_CHARGE_BOOKED_NOTPAY 303008   //已预约桩但没付款
#define RESPONSE_CODE_CHARGE_ISCHARGING 30700       //已经存在桩充电
#define RESPONSE_CODE_CHARGE_NON_IDLE 307003        //充电口非空闲
#define RESPONSE_CODE_CHARGE_NON_OPEN_TIME 307004   //非充电时段

#define RESPONSE_CODE_VERSION_TOO_LOW 40002         //版本过低

#define RESPONSE_CODE_ARTICLE_UNEXIST 500001         //话题不存在或已删除，请刷新

@interface DCHTTPSessionManager : AFHTTPSessionManager
+ (instancetype)shareManagerWithVerification:(NSString *)verification;
+ (instancetype)shareManager;
+ (instancetype)uploadImageManager;

- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error))completion;
- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error))completion;
- (NSURLSessionDataTask *)DELETE:(NSString *)URLString parameters:(id)parameters completion:(void (^)(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error))completion;
@end

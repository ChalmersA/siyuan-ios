//
//  PaymentObject.h
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCModel.h"

@interface PaymentObject : DCModel
@property(nonatomic, copy) NSString * partner;                  //合作者身份ID
@property(nonatomic, copy) NSString * sellerId;                 //收款方：卖家支付宝账号(邮箱或手机 号码格式)，或其对应的支付宝唯一用户号(以'2088'开头的纯16位数字)
@property(nonatomic, copy) NSString * outTradeNo;               //唯一订单号
@property(nonatomic, copy) NSString * subject;                  //商品的标题/交易标题/订单标 题/订单关键字等。该参数最长为 128 个汉字。
@property(nonatomic, copy) NSString * body;                     //商品详情
@property(nonatomic, copy) NSString * totalFee;                 //总费用
@property(nonatomic, copy) NSString * notifyURL;                //服务器异步通知页面路径，支付宝服务器主动通知商户网站里指定的页面 http 路径。

@property(nonatomic, copy) NSString * service;                  //接口名称
@property(nonatomic, copy) NSString * paymentType;              //支付类型。默认值为:1(商品购买)
@property(nonatomic, copy) NSString * inputCharset;             //参数编码字符集：商户网站使用的编码格式,固定为 utf-8。
@property(nonatomic, copy) NSString * itBPay;                   //未付款交易的超时时间
@property(nonatomic, copy) NSString * showUrl;                  //MARK: 'showUrl' NO DESCRIPTION IN DOC ??

@property(nonatomic, copy) NSString * orderParamsStr;           //被签名的原订单字符串
@property(nonatomic, copy) NSString * signType;                 //签名方式：签名类型,目前仅支持 RSA
@property(nonatomic, copy) NSString * sign;                     //签名
@property(nonatomic, copy) NSString * signedOrderStr;           //签名签名合并后的字符串


@property(nonatomic, copy) NSString * rsaDate;                  //MARK: 'rsaDate' NO DESCRIPTION IN DOC ??
@property(nonatomic, copy) NSString * appID;                    //客户端号
@property(nonatomic, copy) NSString * appEnv;                   //客户端来源
@property(nonatomic, readonly) NSMutableDictionary * extraParams;


- (NSString *)joinOrderParams;
- (BOOL)isAvailable;
- (void)resign;
@end

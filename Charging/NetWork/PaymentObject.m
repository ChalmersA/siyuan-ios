//
//  PaymentObject.m
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "PaymentObject.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDictionary+Model.h"
#import "DataSigner.h"

static NSString * const PaymentSignKey = @"MVSE1uZLs22mFVm87ffFXTXEsuy2Xbc7jcQaiz77";

@implementation PaymentObject


- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"payment_type"]) {
        key = @"paymentType";
    }
    else if ([key isEqualToString:@"total_fee"]) {
        key = @"totalFee";
    }
    else if ([key isEqualToString:@"it_b_pay"]) {
        key = @"itBPay";
    }
    else if ([key isEqualToString:@"_input_charset"]) {
        key = @"inputCharset";
    }
    else if ([key isEqualToString:@"return_url"]) {
//        key = @"paymentType";self.showUrl??
    }
    
    else if ([key isEqualToString:@"out_trade_no"]) {
        key = @"outTradeNo";
    }
    
//    else if ([key isEqualToString:@"service"]) {
//        key = @"service";
//    }
    
    else if ([key isEqualToString:@"sign_type"]) {
        key = @"signType";
    }
    else if ([key isEqualToString:@"notifyUrl"]) {
        key = @"notifyURL";
    }
    else if ([key isEqualToString:@"seller_id"]) {
        key = @"sellerId";
//        value = @"156256090@qq.com";
    }
    else if ([key isEqualToString:@"encryption"]) {
        key = @"signedOrderStr";
    }
    
    
    if ([key isEqualToString:@"extraParams"]) {
        // TODO: parse this dic 'extraParams'
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            value = @([value doubleValue]);
//        }
    }
    [super setValue:value forKey:key];
}

- (NSString *)joinOrderParams {
    NSMutableString * orderSpec = [NSMutableString string];
    if (self.partner) {
        [orderSpec appendFormat:@"partner=\"%@\"", self.partner];
    }
    
    if (self.sellerId) {
        [orderSpec appendFormat:@"&seller_id=\"%@\"", self.sellerId];
    }
    if (self.outTradeNo) {
        [orderSpec appendFormat:@"&out_trade_no=\"%@\"", self.outTradeNo];
    }
    if (self.subject) {
        [orderSpec appendFormat:@"&subject=\"%@\"", self.subject];
    }
    
    if (self.body) {
        [orderSpec appendFormat:@"&body=\"%@\"", self.body];
    }
    if (self.totalFee) {
        [orderSpec appendFormat:@"&total_fee=\"%@\"", self.totalFee];
    }
    if (self.notifyURL) {
        [orderSpec appendFormat:@"&notify_url=\"%@\"", self.notifyURL];
    }
    
    if (self.service) {
        [orderSpec appendFormat:@"&service=\"%@\"",self.service];//mobile.securitypay.pay
    }
    if (self.paymentType) {
        [orderSpec appendFormat:@"&payment_type=\"%@\"",self.paymentType];//1
    }
    
    if (self.inputCharset) {
        [orderSpec appendFormat:@"&_input_charset=\"%@\"",self.inputCharset];//utf-8
    }
    if (self.itBPay) {
        [orderSpec appendFormat:@"&it_b_pay=\"%@\"",self.itBPay];//30m
    }
    if (self.showUrl) {
        [orderSpec appendFormat:@"&show_url=\"%@\"",self.showUrl];//m.alipay.com
    }
    if (self.rsaDate) {
        [orderSpec appendFormat:@"&sign_date=\"%@\"",self.rsaDate];
    }
    if (self.appID) {
        [orderSpec appendFormat:@"&app_id=\"%@\"",self.appID];
    }
    for (NSString * key in [self.extraParams allKeys]) {
        [orderSpec appendFormat:@"&%@=\"%@\"", key, [self.extraParams objectForKey:key]];
    }
    return orderSpec;
}

- (BOOL)isAvailable {
    // TODO: make some judgement here
    return YES;
//    return (self.sellerEmail.length > 0) && (self.subject.length > 0) && (self.outTradeNo.length > 0) && (self.sign.length > 0);
}

- (void)resign {
//    NSArray *elements = @[self.outTradeNo, [NSString stringWithFormat:@"%.2f" ,self.totalFee]];
//    NSString *sign = [@[[elements componentsJoinedByString:@""], PaymentSignKey] componentsJoinedByString:@"@"];
//    self.sign = [self md5:sign];
//    DDLogDebug(@"%@  md5->  %@", sign, self.sign);
    
    
    
    
    
    NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBALlqekFAqYfm9vSNHxfN6CdkMv1yyVz2g+BjcnaaFi3NktorefUG1VGHPLgtHEd1DjCQGaxOu09iyj6n+CunIRn6uFvG8SxvcYLntETaiagjPQ9SfC4JGs8IuB1QG30pz43jUlVrDlviKxBiLQy/XE5ckJqX/lwdGeTV9e/6YqHLAgMBAAECgYA8zI9+KiftKm08T7IsahaAJDkcJrGkzCj+QV3dSjWPm2NWKv94u17jtwbQFeq5+8ZFYlsox0BgjbJnzUhxeAJAJMYcXbKzAFQhl1XtalG/GG8OnzyD0r6mm2pF2FaBt1mAGSRHH3X3xjG6R0ihrcmdR6cQn6XhbE/dh9QoLMhJ4QJBAPRTqXC9nhzY7/ZxAeR4A1Qw512rxaWRMqOkhPr6EtCxa3nS0uGiv/ctAcr0ha1oxSuL+P7Cxt/6awxylDiCgrkCQQDCRkhFGyyzAJ5utRCXlrzGTUf5QX4aLLN06OK0/481CDjS5UNzgxwSJJOR67piXoV7xuW0sm7tAgGLvRAHuZajAkEAwXu7U/+lRZz6MsP9RqtPn412u3Q6+cmJO5Qehw4gdkn6Hag5vdt/f8ORhuKrNc8hTUH0dfNTQK3zthDKlhGsaQJBAITiA+7Y7pMlujipOsclQMw28iMI7BNFPh6aaO862p6AmDWQwblSFbJHOHUYEy3Tz2PhoR8e6YbN13bYhA10oRcCQQCN4XWtMntVxYKqPEeK6Yg03mcjJW5OUD+7jdyCuvPBPaX+eIT/81i+W5TDl1gjNtb/0mxxoohqF8PkVwAHrV8U";
    

    
    NSString *orderSpec = @"partner=\"2088911205944812\"&seller_id=\"156256090@qq.com\"&out_trade_no=\"W113RHWJI6VS3ON\"&subject=\"1\"&body=\"我是测试数据\"&total_fee=\"0.02\"&notify_url=\"http://www.xxx.com\"&service=\"mobile.securitypay.pay\"&payment_type=\"1\"&_input_charset=\"utf-8\"&it_b_pay=\"30m\"&show_url=\"m.alipay.com\"";
    
    self.orderParamsStr = [self joinOrderParams];
    
    //MARK: testcode
    self.orderParamsStr =orderSpec;
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    self.sign = [signer signString:self.orderParamsStr];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (self.sign != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"", self.orderParamsStr, self.sign, self.signType];
        self.signedOrderStr = orderString;
    }
}

- (NSString *)md5:(NSString *)input {
    const char *ptr = [input UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02X",md5Buffer[i]];
    }
    return output;
}
@end

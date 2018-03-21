//
//  BCQueryReq.h
//  BCPaySDK
//
//  Created by Ewenlong03 on 15/7/27.
//  Copyright (c) 2015年 BeeCloud. All rights reserved.
//

#import "BCBaseReq.h"
#import "BCPayConstant.h"

#pragma mark BCQueryReq
/**
 *  根据条件查询请求支付订单记录
 */
@interface BCQueryReq : BCBaseReq 

@property (nonatomic, assign) PayChannel channel;
@property (nonatomic, retain) NSString *billNo;
@property (nonatomic, assign) NSString *startTime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSString *endTime;//@"yyyyMMddHHmm"格式
@property (nonatomic, assign) NSInteger skip;
@property (nonatomic, assign) NSInteger limit;

@end

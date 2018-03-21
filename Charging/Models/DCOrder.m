//
//  DCOrder.m
//  Charging
//
//  Created by xpg on 15/1/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCOrder.h"
#import "NSDateFormatter+HSSYCategory.h"
#import "DCDatabaseOrder.h"
#import "NSDate+HSSYDate.h"
#import "Charging-Swift.h"
#import "DCOrderDetailInfoItem.h"

@implementation DCOrder

- (instancetype)initOrderWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if ([dict objectForKey:@"id"]) {
                self.orderId = [dict objectForKey:@"id"];
            }
            if ([dict objectForKey:@"cancelfee"]) {
                self.cancelFee = [[dict objectForKey:@"cancelfee"] doubleValue];
            }
        }
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"orderState"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    else if ([key isEqualToString:@"chargePortIndex"]) {
        if ([value isKindOfClass:[NSString class]]) {
            value = @([value integerValue]);
        }
    }
    else if ([key isEqualToString:@"createTime"] ||
             [key isEqualToString:@"cancelTime"] ||
             [key isEqualToString:@"payTime"] ||
             [key isEqualToString:@"reserveStartTime"] ||
             [key isEqualToString:@"reserveEndTime"] ||
             [key isEqualToString:@"chargeStartTime"] ||
             [key isEqualToString:@"chargeEndTime"]) {
        if ([value respondsToSelector:@selector(doubleValue)]) {
            value = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]/1000];
        }
    }
    [super setValue:value forKey:key];
}

#pragma mark - Equal
- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[DCOrder class]]) {
        DCOrder *order = object;
        return [self.orderId isEqualToString:order.orderId];
    }
    return NO;
}

- (NSUInteger)hash {
    return [self.orderId hash];
}

#pragma mark - For OrderCell
- (NSArray *)orderForState:(DCOrderState)state {
    
    NSMutableArray *array = [NSMutableArray array];
    [self stateForStateLabel:state];
    
    //订单详情
    NSMutableArray *orderInfoArray = [NSMutableArray array];
    [orderInfoArray addObject:@""];
    
    DCOrderDetailInfoItem *item1_1 = [[DCOrderDetailInfoItem alloc] init];
    item1_1.title = @"交易单号";
    item1_1.content = self.orderId;
    [orderInfoArray addObject:item1_1];
    
    DCOrderDetailInfoItem *item1_2 = [[DCOrderDetailInfoItem alloc] init];
    item1_2.title = @"订单状态";
    item1_2.content = self.state;
    [orderInfoArray addObject:item1_2];
    
    DCOrderDetailInfoItem *item1_3 = [[DCOrderDetailInfoItem alloc] init];
    item1_3.title = @"订单生成";
    item1_3.content = [self orderTimeDescription];
    [orderInfoArray addObject:item1_3];
    
    //电桩信息
    NSMutableArray *stationInfoArray = [NSMutableArray array];
    [stationInfoArray addObject:@"电桩信息"];
    
    DCOrderDetailInfoItem *item2_1 = [[DCOrderDetailInfoItem alloc] init];
    item2_1.title = @"桩群名称";
    item2_1.content = self.stationName;
    [stationInfoArray addObject:item2_1];
    
    DCOrderDetailInfoItem *item2_2 = [[DCOrderDetailInfoItem alloc] init];
    item2_2.title = @"桩群位置";
    item2_2.content = self.stationLocation;
    [stationInfoArray addObject:item2_2];
    
    DCOrderDetailInfoItem *item2_3 = [[DCOrderDetailInfoItem alloc] init];
    item2_3.title = @"充电电桩";
    item2_3.content = [self pileNameDescription:self];
    [stationInfoArray addObject:item2_3];
    
    DCOrderDetailInfoItem *item2_4 = [[DCOrderDetailInfoItem alloc] init];
    item2_4.title = @"电桩类型";
    item2_4.content = (self.pileType == DCPileTypeAC) ? @"交流桩" : @"直流桩";
    [stationInfoArray addObject:item2_4];
    
    [array addObject:orderInfoArray];
    [array addObject:stationInfoArray];
    
    //预约信息
    NSMutableArray *bookInfoArray = [NSMutableArray array];
    [bookInfoArray addObject:@"预约信息"];
    
    DCOrderDetailInfoItem *item3_1 = [[DCOrderDetailInfoItem alloc] init];
    item3_1.title = @"预约时段";
    item3_1.content = [self bookingTimeDescription];
    [bookInfoArray addObject:item3_1];
    
    DCOrderDetailInfoItem *item3_2 = [[DCOrderDetailInfoItem alloc] init];
    item3_2.title = @"预约费用";
    item3_2.content = [NSString stringByDoubleValue:self.reserveFee];
    [bookInfoArray addObject:item3_2];
    
    DCOrderDetailInfoItem *item3_3 = [[DCOrderDetailInfoItem alloc] init];
    item3_3.title = @"预约条件";
    item3_3.content = [self onTimeChargeRetDescription];
    [bookInfoArray addObject:item3_3];
    
    if (self.cancelTime && state != DCOrderStateOvertimeToCharge &&
        state != DCOrderStateOvevtimeToPayBookfee) {
        DCOrderDetailInfoItem *item3_4 = [[DCOrderDetailInfoItem alloc] init];
        item3_4.title = @"退约时间";
        item3_4.content = [self cancelTimeDescription];
        [bookInfoArray addObject:item3_4];
        
        DCOrderDetailInfoItem *item3_5 = [[DCOrderDetailInfoItem alloc] init];
        item3_5.title = @"退约费用";
        item3_5.content = [[NSString stringByDoubleValue:self.cancelFee] stringByAppendingString:@" 元"];
        [bookInfoArray addObject:item3_5];
    }
    
    //充电信息
    NSMutableArray *chargeInfoArray = [NSMutableArray array];
    [chargeInfoArray addObject:@"充电信息"];
    
    DCOrderDetailInfoItem *item4_1 = [[DCOrderDetailInfoItem alloc] init];
    item4_1.title = @"启动方式";
    item4_1.content = [self startTypeDescription];
    [chargeInfoArray addObject:item4_1];
    
    DCOrderDetailInfoItem *item4_2 = [[DCOrderDetailInfoItem alloc] init];
    item4_2.title = @"充电单价";
    item4_2.content = [NSString stringByDoubleValue:self.serviceFee];
    [chargeInfoArray addObject:item4_2];
    
    DCOrderDetailInfoItem *item4_3 = [[DCOrderDetailInfoItem alloc] init];
    item4_3.title = @"充电模式";
    item4_3.content = [self chargeModeDescription];
    [chargeInfoArray addObject:item4_3];
    
    DCOrderDetailInfoItem *item4_4 = [[DCOrderDetailInfoItem alloc] init];
    item4_4.title = @"启动时间";
    item4_4.content = [self chargeStartTimeDescription];
    [chargeInfoArray addObject:item4_4];
    
    if (self.chargeEndTime) {
        DCOrderDetailInfoItem *item4_5 = [[DCOrderDetailInfoItem alloc] init];
        item4_5.title = @"结束时间";
        item4_5.content = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.chargeEndTime];;
        [chargeInfoArray addObject:item4_5];
        
        DCOrderDetailInfoItem *item4_6 = [[DCOrderDetailInfoItem alloc] init];
        item4_6.title = @"充电时长";
        item4_6.content = [NSDate timeLengthFromStartTime:self.chargeStartTime toEndTime:self.chargeEndTime];
        [chargeInfoArray addObject:item4_6];
        
        DCOrderDetailInfoItem *item4_7 = [[DCOrderDetailInfoItem alloc] init];
        item4_7.title = @"充电电量";
        item4_7.content = [NSString stringByDoubleValue:_chargeEnergy];
        [chargeInfoArray addObject:item4_7];
        
        DCOrderDetailInfoItem *item4_8 = [[DCOrderDetailInfoItem alloc] init];
        item4_8.title = @"充电金额";
        item4_8.content = [NSString stringByDoubleValue:self.chargeTotalFee];
        [chargeInfoArray addObject:item4_8];
    }
    if (self.orderState == DCOrderStateExceptionWithNotChargeRecord ||
        self.orderState == DCOrderStateExceptionWithChargeData ||
        self.orderState == DCOrderStateExceptionWithStartChargeFail) {
        DCOrderDetailInfoItem *item4_9 = [[DCOrderDetailInfoItem alloc] init];
        item4_9.title = @"异常状态";
        item4_9.content = [self exceptionTypeDescription];
        [chargeInfoArray addObject:item4_9];
    }
    
    //付款信息
    NSMutableArray *payInfoArray = [NSMutableArray array];
    [payInfoArray addObject:@"付款信息"];
    
    DCOrderDetailInfoItem *item5_1 = [[DCOrderDetailInfoItem alloc] init];
    item5_1.title = @"支付金额";
    item5_1.content = [NSString stringWithFormat:@"%.2f 元", self.payChargeFee];
    [payInfoArray addObject:item5_1];
    
    DCOrderDetailInfoItem *item5_2 = [[DCOrderDetailInfoItem alloc] init];
    item5_2.title = @"消费充电币";
    item5_2.content = [NSString stringWithFormat:@"%.2f 个", self.coinsChargeFee];
    [payInfoArray addObject:item5_2];
    
    DCOrderDetailInfoItem *item5_3 = [[DCOrderDetailInfoItem alloc] init];
    item5_3.title = @"付款时间";
    item5_3.content = [self payTimeDescription];
    [payInfoArray addObject:item5_3];
    
    DCOrderDetailInfoItem *item5_4 = [[DCOrderDetailInfoItem alloc] init];
    item5_4.title = @"支付方式";
    item5_4.content = [self payTypeDescription];
    [payInfoArray addObject:item5_4];
    
    //订单评价
    NSMutableArray *evaluationArray = [NSMutableArray array];
    [evaluationArray addObject:@"订单评价"];
    
    DCOrderDetailInfoItem *item6_1 = [[DCOrderDetailInfoItem alloc] init];
    item6_1.title = @"评价时间";
    item6_1.content = nil;
    [evaluationArray addObject:item6_1];
    
    DCOrderDetailInfoItem *item6_2 = [[DCOrderDetailInfoItem alloc] init];
    item6_2.title = @"评价星数";
    item6_2.content = nil;
    [evaluationArray addObject:item6_2];
    
    DCOrderDetailInfoItem *item6_3 = [[DCOrderDetailInfoItem alloc] init];
    item6_3.title = @"评价内容";
    item6_3.content = nil;
    [evaluationArray addObject:item6_3];
    
    
    switch (state) {
        case DCOrderStateNotPayBookfee:
        case DCOrderStatePaidBookfee:
        case DCOrderStateOvertimeToCharge:
        case DCOrderStateOvevtimeToPayBookfee:
        case DCOrderStateCancelBooking:
        case DCOrderStateCancelBookingAfterPay:
            [array addObject:bookInfoArray];
            break;
            
        case DCOrderStateCharging: {
            if (self.reserveStartTime) {
                [array addObject:bookInfoArray];
            }
        }
        case DCOrderStateExceptionWithStartChargeFail:
        case DCOrderStateExceptionWithStartChargeFailAfterBook:
        case DCOrderStateExceptionWithNotChargeRecord:
        case DCOrderStateNotPayChargefee:
        case DCOrderStateExceptionWithChargeData:
            [array addObject:chargeInfoArray];
            break;
            
        case DCOrderStateNotEvaluate:
            if (self.reserveStartTime) {
                [array addObject:bookInfoArray];
            }
            [array addObject:chargeInfoArray];
            [array addObject:payInfoArray];
            break;
            
        case DCOrderStateEvaluated:
            if (self.reserveStartTime) {
                [array addObject:bookInfoArray];
            }
            [array addObject:chargeInfoArray];
            [array addObject:payInfoArray];
            if (self.hasArticle) {
                [array addObject:evaluationArray];
            }
            break;
            
        default:
            break;
    }
    return array;
}

#pragma mark - Extension

- (NSString *)startTypeDescription {
    return self.chargeType == DCChargeStartTypeScanQrcode ? @"扫码充电" : @"刷卡充电";
}

- (NSString *)onTimeChargeRetDescription {
    if (self.onTimeChargeRet ==  DCChargeRefundTypeNotNeed) {
        return @"不返还预约费用";
    } else if (self.onTimeChargeRet == DCChargeRefundTypeNeed) {
        return @"预约时段内启动返还预约费用";
    } else if (self.onTimeChargeRet == DCChargeRefundTypeHasRefund) {
        return @"已退还预约费用";
    } else {
        return @"未知";
    }
}

- (NSString *)exceptionTypeDescription {
    if (self.orderState == DCOrderStateExceptionWithNotChargeRecord) {
        return @"未收到充电数据";
    } else if (self.orderState == DCOrderStateExceptionWithChargeData) {
        return @"收到异常充电数据";
    } else if (self.orderState == DCOrderStateExceptionWithStartChargeFail) {
        return @"启动充电失败";
    } else {
        return @"未知异常";
    }
}

- (NSString *)payTypeDescription {
    NSString *string = nil;
    switch (self.payType) {
        case DCPayTypeCard:
            string = @"刷卡付费";
            break;
            
        case DCPayTypeChargeCoins:
            string = @"充电币";
            break;
            
        case DCPayTypeAlipay: {
            if (self.coinsChargeFee) {
                string = @"支付宝+充电币";
            } else {
                string = @"支付宝";
            }
        }
            break;
            
        case DCPayTypeWechat: {
            if (self.coinsChargeFee) {
                string = @"微信支付+充电币";
            } else {
                string = @"微信支付";
            }
        }
            break;
            
        default:
            break;
    }
    return string;
}

- (NSString *)pileNameDescription:(DCOrder *)order {
    NSString *chargePort = nil;
    switch (order.chargePortIndex) {
        case 1:
            chargePort = @" 枪1";
            break;
        case 2:
            chargePort = @" 枪2";
            break;
        case 3:
            chargePort = @" 枪3";
            break;
        case 4:
            chargePort = @" 枪4";
            break;
        default:
            break;
    }
    NSString *string = [order.pileName stringByAppendingString:chargePort];
    return string;
}

- (void)stateForStateLabel:(DCOrderState)state {
    switch (state) {
        case DCOrderStateOvertimeToCharge:
        case DCOrderStateOvevtimeToPayBookfee:
            self.state = @"已过期";
            break;
            
        case DCOrderStateNotPayBookfee:
            self.state = @"待支付预约费用";
            break;
            
        case DCOrderStatePaidBookfee:
            self.state = @"已预约";
            break;
            
        case DCOrderStateCancelBooking:
        case DCOrderStateCancelBookingAfterPay:
            self.state = @"已取消";
            break;
            
        case DCOrderStateCharging:
            self.state = @"充电中";
            break;
            
        case DCOrderStateNotPayChargefee:
            self.state = @"待支付";
            break;
            
        case DCOrderStateNotEvaluate:
            self.state = @"已支付";
            break;
            
        case DCOrderStateEvaluated:
            self.state = @"已评价";
            break;
            
        case DCOrderStateExceptionWithChargeData:
        case DCOrderStateExceptionWithNotChargeRecord:
        case DCOrderStateExceptionWithStartChargeFail:
        case DCOrderStateExceptionWithStartChargeFailAfterBook:
            self.state = @"异常订单";
            break;
            
        default:
            self.state = @"未知";
            break;
    }
}

- (NSString *)chargeModeDescription {
    if (self.chargeMode == DCChargeModeTypeByFull) {
        return @"自然充满";
    } else if (self.chargeMode == DCChargeModeTypeByTime) {
        return @"按时间充电";
    } else if (self.chargeMode == DCChargeModeTypeByMoney) {
        return @"按金额充电";
    } else if (self.chargeMode == DCChargeModeTypeByPower) {
        return @"按电量充电";
    } else {
        return @"未知";
    }
}

- (NSString *)serviceFeeDescription {
    if (self.serviceFee) {
        return [NSString stringWithFormat:@"¥ %.2f/kWh", self.serviceFee];
    } else {
        return nil;
    }
}

//- (NSString *)scoreDescription {
//    return [NSString stringWithFormat:@"%.1f 分", self.pileLevel.doubleValue];
//}

- (NSString *)orderTimeDescription {
    NSString *orderTimeDescription = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.createTime];
    if (orderTimeDescription) {
        self.orderTimeDescription = orderTimeDescription;
        return orderTimeDescription;
    }
    return nil;
}

- (NSString *)cancelTimeDescription {
    NSString *cancelTimeDescription = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.cancelTime];
    if (cancelTimeDescription) {
        self.cancelTimeDescription = cancelTimeDescription;
        return cancelTimeDescription;
    }
    return nil;
}

- (NSString *)payTimeDescription {
    NSString *payTimeDescription = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.payTime];
    if (payTimeDescription) {
        return payTimeDescription;
    }
    return nil;
}

- (NSString *)bookingTimeDescription {
    NSString *reserveStartTime = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.reserveStartTime];
    NSString *reserveEndTime = [self.reserveEndTime parseToTimeString:YES];
    if (reserveStartTime && reserveEndTime) {
        self.bookingTimeDescription = [NSString stringWithFormat:@"%@ - %@", reserveStartTime, reserveEndTime];
        return [NSString stringWithFormat:@"%@ - %@", reserveStartTime, reserveEndTime];
    }
    return nil;
}

- (NSString *)chargeStartTimeDescription {
    NSString *chargeStartTime = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.chargeStartTime];
    self.chargeStartTimeDescription = chargeStartTime;
    if (chargeStartTime) {
        return chargeStartTime;
    }
    return nil;
}

- (NSString *)chargeTimeDescription {
    NSString *chargeStartTime = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:self.chargeStartTime];
    NSString *chargeEndTime = [self.chargeEndTime parseToTimeString:YES];
    if (chargeStartTime && chargeEndTime) {
        self.chargeTimeDescription = [NSString stringWithFormat:@"%@ - %@", chargeStartTime, chargeEndTime];
        return [NSString stringWithFormat:@"%@ - %@", chargeStartTime, chargeEndTime];
    }
    return nil;
}

- (BOOL)hasPayReserveFee{
    if (self.reserveFee > 0.00001) {
        return YES;
    }
    return NO;
}

//- (CLLocationCoordinate2D)stationCoordinate {
//    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
//}



#pragma mark - Database
+ (instancetype)orderWithDatabaseOrder:(DCDatabaseOrder *)dbOrder {
    DCOrder *order = [self new];
    order.orderId = dbOrder.orderId;
    order.tenantId = dbOrder.tenantId;
    order.pileId = dbOrder.pileId;
    order.stationId = dbOrder.stationId;
    order.reserveStartTime = [NSDate dateWithTimeIntervalSince1970:dbOrder.schedule_start_t/1000];
    order.reserveEndTime = [NSDate dateWithTimeIntervalSince1970:dbOrder.schedule_end_t/1000];
    order.orderState = dbOrder.orderState;
    order.createTime = [NSDate dateWithTimeIntervalSince1970:dbOrder.create_time/1000];
    order.serviceFee = dbOrder.serviceFee;
    return order;
}

- (DCDatabaseOrder *)databaseObject {
    DCDatabaseOrder *order = [DCDatabaseOrder new];
    order.orderId = self.orderId;
    order.tenantId = self.tenantId;
    order.pileId = self.pileId;
    order.stationId = self.stationId;
    order.schedule_start_t = [self.reserveStartTime timeIntervalSince1970]*1000;
    order.schedule_end_t = [self.reserveEndTime timeIntervalSince1970]*1000;
    order.orderState = self.orderState;
    order.create_time = [self.createTime timeIntervalSince1970]*1000;
    order.serviceFee = self.serviceFee;
    return order;
}

@end

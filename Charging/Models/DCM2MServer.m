//
//  DCM2MStart.m
//  Charging
//
//  Created by kufufu on 16/3/10.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCM2MServer.h"
#import "DCChargingCurrentData.h"

NSString * const SPARE = @"00";                         //空闲
NSString * const BOOKED = @"01";                        //预约
NSString * const CHARGE = @"02";                        //开始放电
NSString * const CHARGING = @"03";                      //充电进行中
NSString * const OVER_VOLTAGE = @"04";                  //过压
NSString * const UNDER_VOLTAGE = @"05";                 //欠压
NSString * const OVER_CURRENT = @"06";                  //过流
NSString * const SCRAM = @"07";                         //急停
NSString * const FINISH_CHARGE = @"08";                 //充电完成
NSString * const CHARGE_CONNECT_ABNORMAL = @"09";       //充电连接异常
NSString * const CHARGE_UNIT_ERROR = @"0A";             //充电机故障
NSString * const BMS_ERROR = @"0B";                     //BMS通信故障
NSString * const DEVICE_STATUS_BMS_CONNECTED = @"0C";   //BMS已连接
NSString * const GUN_LOCK_OPEN = @"0D";                 //枪锁已打开
NSString * const DOOR_LOCK_OPEN = @"0E";                //门锁已打开

NSString * const POWER_OFF = @"power_off";              //断电


NSString * const ack = @"{""\"cmd\":\"client_ack\"}";

@implementation DCM2MServer
{
    int connectCount;   //m2m连接次数
    BOOL isConnect;    //是否正在连接中
    NSMutableArray *errorArray;
    BOOL isNormalStatus;    //是否是正常的充电充电状态
    BOOL isAllIdleStatus;   //当第二收到的心跳包仍为空闲(即为device_status = 00)
    NSTimer *connectSocketTimer;     //app端重新连接socket的Timer
}

- (instancetype)initWithDict:(NSDictionary *)dict isCharing:(BOOL)isCharging {
    self = [super initWithDict:dict];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        if ([dict objectForKey:@"m2mIP"]) {
            self.ip = [dict objectForKey:@"m2mIP"];
        }
        if ([dict objectForKey:@"m2mPort"]) {
            self.port = [dict objectForKey:@"m2mPort"];
        }
        if ([dict objectForKey:@"m2mSign"]) {
            self.sign = [dict objectForKey:@"m2mSign"];
        }
        if ([dict objectForKey:@"chargePort"]) {
            self.chargePort = [[DCChargePort alloc] initChargePortWithDictionary:[dict objectForKey:@"chargePort"]];
        }
    }
    [self newInit:(BOOL)isCharging];
    return self;
}

- (void)newInit:(BOOL)isCharging {
    connectCount = 0;
    if (isCharging == YES) {
        isNormalStatus = YES;
        isAllIdleStatus = YES;
    } else {
        isNormalStatus = NO;
        isAllIdleStatus = NO;
    }
    errorArray = [[NSMutableArray alloc] initWithObjects:SPARE, BOOKED, CHARGE, CHARGING, OVER_VOLTAGE, UNDER_VOLTAGE, OVER_CURRENT, SCRAM, FINISH_CHARGE, CHARGE_CONNECT_ABNORMAL, CHARGE_UNIT_ERROR, BMS_ERROR, DEVICE_STATUS_BMS_CONNECTED, GUN_LOCK_OPEN, DOOR_LOCK_OPEN, nil];
    [self socketConnectHost];
}

//socket连接
- (void)socketConnectHost {
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    NSError *error = nil;
    [self.socket connectToHost:self.ip onPort:[self.port integerValue] error:&error];
}

//socket断开
- (void)cutOffSocket {
    self.socket.userData = SocketOfflineByUser;
    [self.socket disconnect];
}

#pragma mark - AsyncSocket回调
//连接成功回调
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    [connectSocketTimer invalidate];
    connectSocketTimer = nil;
    
    sock.userData = SocketOfflineByAfterConnect;
    
    [self.delegate connectSuccess:YES message:@"socket连接成功"];
    //授权身份验证
    if (self.sign) {
        NSData *data = [[self DataTOjsonString:self.sign] dataUsingEncoding:NSUTF8StringEncoding];
        [self writeDataWithData:data Tag:1];
    }
}

//连接失败回调
- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    if (sock.userData == SocketOfflineByServer) {
        connectSocketTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(connectSocket) userInfo:nil repeats:YES];
        NSLog(@"m2m服务器重新连接");
        if (connectCount > 3) {
            [connectSocketTimer invalidate];
            connectSocketTimer = nil;
            if ([self.delegate respondsToSelector:@selector(connectError:socketOfflineType:)]) {
                [self.delegate connectError:@"m2m服务器连接失败 -1" socketOfflineType:SocketOfflineByServer];
            }
        }
    }
    else if (sock.userData == SocketOfflineByUser) {
        //用户断开, 不进行重连
        if ([self.delegate respondsToSelector:@selector(connectError:socketOfflineType:)]) {
            [self.delegate connectError:@"用户断开m2m服务器" socketOfflineType:SocketOfflineByUser];
        }
    }
    else if (sock.userData == SocketOfflineByAfterConnect) {
        if ([self.delegate respondsToSelector:@selector(connectError:socketOfflineType:)]) {
            [self.delegate connectError:@"m2m服务器连接失败 -2" socketOfflineType:SocketOfflineByAfterConnect];
        }
    }
}

//读取data
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //对得到的data值进行解析与转换即可
    NSArray *datas = nil;
    if (data) {
        datas = [self m2mDataWithDict:data];
    }
    
    if (datas && datas.count) {
        for (NSDictionary *result in datas) {
            if (result) {
                if (tag == 1) {
                    if ([[result objectForKey:@"result"] boolValue]) {
                        [self.delegate authoriseSuccess:YES message:@"验证身份成功"];
                        //发送心跳包
                        NSData *client_ack = [ack dataUsingEncoding:NSUTF8StringEncoding];
                        [self postSocketHeartbeatData:client_ack];
                    } else {
                        [self.delegate authoriseSuccess:NO message:@"验证身份失败"];
                    }
                }
                
                if (tag == 2) {
                    if ([result objectForKey:@"result"] && [[result objectForKey:@"result"] boolValue] == NO) {
                        [self.delegate chargeingError:POWER_OFF errorType:ErrorTypeForEnd];
                        [self cutOffSocket];
                        return;
                    }
                    
                    DCChargingCurrentData *currenData = [[DCChargingCurrentData alloc] initChargingCurrentDataWithDict:result];
                    
                    if ([currenData.device_status isEqualToString:CHARGE] ||
                        [currenData.device_status isEqualToString:CHARGING]) {
                        isNormalStatus = YES;
                        [self postSocketHeartbeatData:[ack dataUsingEncoding:NSUTF8StringEncoding]];
                        [self.delegate receiveChargeCurrentDataWithDict:result];
                    }
                    else if ([currenData.device_status isEqualToString:CHARGE_CONNECT_ABNORMAL]) {
                        
                        if (isNormalStatus == YES) {
                            [self.delegate chargeingError:CHARGE_CONNECT_ABNORMAL errorType:ErrorTypeForEnd];
                            [self cutOffSocket];
                        }
                        else {
                            [self.delegate chargeingError:CHARGE_CONNECT_ABNORMAL errorType:ErrorTypeForStart];
                            [self cutOffSocket];
                        }
                    }
                    else if ([currenData.device_status isEqualToString:SPARE]){
                        //第一次心跳包为00时先忽略, 不做任何操作.
                        if (isNormalStatus == NO) {
                            
                            //第二次心跳包为00时, 访问后台是否充电中.
                            if (isAllIdleStatus == YES) {
                                if ([self.delegate respondsToSelector:@selector(chargeingError:errorType:)]) {
                                    [self.delegate chargeingError:SPARE errorType:ErrorTypeForStart];
                                    [self cutOffSocket];
                                    NSLog(@"第二次心跳包为00");
                                    return;
                                }
                            }
                            [self postSocketHeartbeatData:[ack dataUsingEncoding:NSUTF8StringEncoding]];
                            isAllIdleStatus = YES;
                        } else {
                            if ([self.delegate respondsToSelector:@selector(chargeingError:errorType:)]) {
                                [self.delegate chargeingError:CHARGE_CONNECT_ABNORMAL errorType:ErrorTypeForEnd];
                                [self cutOffSocket];
                            }
                        }
                        
                        //第二次心跳包为00时, 访问后台是否充电中.
                        //            if (isAllIdleStatus == YES && isNormalStatus == NO) {
                        //                if ([self.delegate respondsToSelector:@selector(chargeingError:errorType:)]) {
                        //                    [self.delegate chargeingError:SPARE errorType:ErrorTypeForStart];
                        //                    [self cutOffSocket];
                        //                    NSLog(@"第二次心跳包为00");
                        //                }
                        //            }
                    }
                    else if ([currenData.device_status isEqualToString:GUN_LOCK_OPEN]) {
                        
                        if (isNormalStatus == YES) {
                            [self.delegate chargeingError:GUN_LOCK_OPEN errorType:ErrorTypeForStart];
                        } else {
                            [self.delegate chargeingError:GUN_LOCK_OPEN errorType:ErrorTypeForEnd];
                        }
                        [self cutOffSocket];
                    }
                    else if ([currenData.device_status isEqualToString:DOOR_LOCK_OPEN]) {
                        
                        if (isNormalStatus == YES) {
                            [self.delegate chargeingError:DOOR_LOCK_OPEN errorType:ErrorTypeForStart];
                        } else {
                            [self.delegate chargeingError:GUN_LOCK_OPEN errorType:ErrorTypeForEnd];
                        }
                        [self cutOffSocket];
                    }
                    else {
                        for (NSString *str in errorArray) {
                            if ([currenData.device_status isEqualToString:str]) {
                                if (isNormalStatus == NO) {
                                    [self.delegate chargeingError:str errorType:ErrorTypeForStart];
                                } else {
                                    [self.delegate chargeingError:str errorType:ErrorTypeForEnd];
                                }
                                [self cutOffSocket];
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)ackAgain{
    [self postSocketHeartbeatData:[ack dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == 1) {
        NSLog(@"发送验证身份数据");
        //读取验证
        [self readDataWithTag:1];
    }
    if (tag == 2) {
        NSLog(@"发送ack包");
        //读取心跳包
        [self readDataWithTag:2];
    }
}

#pragma mark - Socket-write&read
- (void)writeDataWithData:(NSData *)data Tag:(long)tag {
    [self.socket writeData:data withTimeout:-1 tag:tag];
}

- (void)readDataWithTag:(long)tag {
    [self.socket readDataWithTimeout:120 tag:tag];
}

- (void)postSocketHeartbeatData:(NSData *)heartbeatData {
    [self.socket writeData:heartbeatData withTimeout:-1 tag:2];
}

#pragma mark - timer
- (void)connectSocket {
    connectCount++;
    [self socketConnectHost];
}

#pragma mark - Public
- (NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0 // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (NSArray *)m2mDataWithDict:(NSData *)data {
    NSMutableArray *results = [NSMutableArray array];

    for (NSData *oneData in [self getDatasWithMutableData:data]) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:oneData options:NSJSONReadingAllowFragments error:nil];
        
        if ([[dict objectForKey:@"cmd"] isEqualToString:@"server_res"]) {
            NSLog(@"socket身份验证包:%@", dict);
            for (NSDictionary *dict1 in results) {
                if ([[dict1 objectForKey:@"cmd"] isEqualToString:@"server_res"]) {
                    [results removeObject:dict1];
                    break;
                }
            }
            [results addObject:dict];
        }
        else if ([[dict objectForKey:@"cmd"] integerValue] == 2) {
            NSLog(@"socket心跳包:%@", dict);
            for (NSDictionary *dict1 in results) {
                if ([[dict1 objectForKey:@"cmd"] isEqualToString:@"02"]) {
                    [results removeObject:dict1];
                    break;
                }
            }
            [results addObject:dict];
        }
        else if ([[dict objectForKey:@"cmd"] isEqualToString:@"no_data"]){
            NSLog(@"socket心跳包 no_data");
        }
        else {
            NSLog(@"socket其他包:%@", dict);
        }
    }
    
    if (!results || results.count == 0) { // 没有可用的包
        NSLog(@"---没有可用的包");
        [self performSelector:@selector(ackAgain) withObject:nil afterDelay:10];
        return nil;
    } else{
        
        NSMutableArray *datas = [NSMutableArray array];
        for (NSDictionary *dict in results) {
            if ([dict objectForKey:@"data"]) {
                [datas addObject:[dict objectForKey:@"data"]];
            }
        }
        
        return datas;
    }
}

- (NSArray *)getDatasWithMutableData:(NSData *)data{
    NSMutableArray *array = [NSMutableArray array];
    
    const char *bytes = [data bytes];
    
    int index = 0;
    for (int i = 0; i < [data length]; i++) {
        if (bytes[i] == 0x0a) {// '\n'
            [array addObject: [data subdataWithRange:NSMakeRange(index, i - index + 1)]];
            index = i + 1;
        }
    }
    
    
    return array;
}

- (NSData *)convertHexStrToData:(NSString *)str{
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}
@end

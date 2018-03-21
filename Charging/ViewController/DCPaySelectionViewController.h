//
//  DCPaySelectionViewController.h
//  Charging
//
//  Created by xpg on 15/2/4.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "PaymentObject.h"

@interface DCPaySelectionViewController : DCViewController

@property (assign, nonatomic) double chargePrice; //充电费用
@property (copy, nonatomic) NSString *orderId;//订单id
@property (strong, nonatomic) PayFinishBlock payFinishBlock;

@property (assign, nonatomic) BOOL isReserverFee;

+ (instancetype)storyboardInstantiate;
@end

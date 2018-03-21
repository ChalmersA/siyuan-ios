//
//  DCPayWebViewController.h
//  Charging
//
//  Created by xpg on 15/2/3.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "PaymentObject.h"

@interface DCPayWebViewController : DCViewController
@property (strong, nonatomic) PaymentObject *payment;
@property (copy, nonatomic) NSString *alipayUrl;
@end

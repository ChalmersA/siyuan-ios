//
//  HSSYDatabaseFault.h
//  Charging
//
//  Created by xpg on 15/1/28.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCDatabaseFault : NSObject

@property (assign, nonatomic) int64_t fault_no;
@property (copy, nonatomic) NSString *pole_no;
@property (assign, nonatomic) NSTimeInterval record_time;
@property (assign, nonatomic) int8_t fault_type;
@property (copy, nonatomic) NSString *data;
@property (copy, nonatomic) NSString *response_data;

@end

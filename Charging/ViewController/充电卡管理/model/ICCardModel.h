//
//  ICCardModel.h
//  Charging
//
//  Created by 陈志强 on 2018/3/10.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICCardModel : NSObject

@property (nonatomic, strong) NSString *valid_time;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, assign) double ic_money;

@property (nonatomic, strong) NSString *card_no;

@property (nonatomic, assign) int papers_type;

@property (nonatomic, strong) NSString *open_operator_id;

@property (nonatomic, strong) NSString *open_card_time;

@property (nonatomic, strong) NSString *open_operator_name;

@property (nonatomic, assign) int card_type;

@property (nonatomic, strong) NSString *papers_num;

@property (nonatomic, strong) NSString *open_branch_id;

@property (nonatomic, strong) NSString *open_branch_name;


@end

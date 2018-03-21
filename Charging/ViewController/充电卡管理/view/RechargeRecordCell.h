//
//  RechargeRecordCell.h
//  Charging
//
//  Created by 陈志强 on 2018/3/6.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RechargeRecordCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *cardNumLb;
@property (weak, nonatomic) IBOutlet UILabel *moneyLb;
@property (weak, nonatomic) IBOutlet UILabel *rechargeWayLb;
@property (weak, nonatomic) IBOutlet UILabel *rechargeDateLb;



@end

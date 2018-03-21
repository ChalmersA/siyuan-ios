//
//  SlotCardRecordCell.h
//  Charging
//
//  Created by 陈志强 on 2018/3/6.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlotCardRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *cardNumLb;//卡号
@property (weak, nonatomic) IBOutlet UILabel *createTimeLb;//订单生成时间
@property (weak, nonatomic) IBOutlet UILabel *comefromLb;//充电记录类型,0来自充电卡, 1来自充电币

@property (weak, nonatomic) IBOutlet UILabel *startChargeTimeLb;//充电开始时间
@property (weak, nonatomic) IBOutlet UILabel *stopChargeTimeLb;//充电结束时间
@property (weak, nonatomic) IBOutlet UILabel *chargeCountLb;//充电电量
@property (weak, nonatomic) IBOutlet UILabel *moneyLb;//充电费用
@property (weak, nonatomic) IBOutlet UILabel *flagLb;//结算信息 0:已结算 99:未结算 1:未找到充电记录


@end

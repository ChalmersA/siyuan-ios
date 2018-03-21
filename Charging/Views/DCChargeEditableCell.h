//
//  DCOrderCell.h
//  Charging
//
//  Created by xpg on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCOrder.h"

@class FiveStarsView;

static float cellHeight;
static NSString * const DCCellIdReserveOrderNormal = @"DCChargeEditableCell";
typedef NS_ENUM(NSInteger, DCOrderButtonTag) {
    DCOrderButtonTagNavi,                   //导航
    DCOrderButtonTagPayForBook,             //支付预约费
    DCOrderButtonTagReschedule,             //重新预约
    DCOrderButtonTagJumpToCharingView,      //查看充电界面
    DCOrderButtonTagPayForCharge,           //支付充电费
    DCOrderButtonTagEvaluate,               //去评价
    DCOrderButtonTagContactOwner,           //联系客服
    
    DCOrderButtonTagUnbindChargeCard,       //解绑电卡
};

@protocol DCChargeEditableCellDelegate <NSObject>
- (void)cellButtonClicked:(DCOrder *)order tag:(DCOrderButtonTag)tag;
@end

@interface DCChargeEditableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;
@property (weak, nonatomic) IBOutlet FiveStarsView *starView;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *startModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *payCoinsLabel;


@property (weak, nonatomic) id <DCChargeEditableCellDelegate> delegate;
@property (strong, nonatomic) DCOrder *order;

- (void)updateEditingState:(BOOL)editing;
- (void)configForOrder:(DCOrder *)order;

+ (CGFloat)cellHeight;
@end

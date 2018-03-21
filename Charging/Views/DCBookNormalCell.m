//
//  DCBookNormalCell.m
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCBookNormalCell.h"
#import "DCChargeNormalCell.h"

@interface DCBookNormalCell ()

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSInteger remainTime;

@end

@implementation DCBookNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bottomButton.layer.cornerRadius = 6;
    self.bottomButton.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.lastView.hidden = YES;
    self.bottomButtonView.hidden = YES;
    self.bottomViewCons.constant = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(UIButton *)sender {
    if (self.order) {
        [self.delegate cellButtonClicked:self.order tag:sender.tag];
    } else {
        [self.myDelegate cellButtonClickedByChargeCard:self.chargeCard tag:DCChargeCardButtonTagUnbind];
    }
}

- (void)configForOrder:(DCOrder *)order {
    self.order = order;
    
    [order stateForStateLabel:self.order.orderState];
    self.statusLabel.text = order.state;
    self.orderTimeLabel.text = order.orderTimeDescription;
    
    self.orderIdLabel.text = order.orderId;
    self.stationNameLabel.text = order.stationName;
    self.pileNameLabel.text = [order pileNameDescription:order];
    self.reserveTimeLabel.text = order.bookingTimeDescription;
    self.reserveFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:order.reserveFee type:ParamTypePrice];
    
    if (order.orderState == DCOrderStatePaidBookfee) {
        [self.timer invalidate];
        self.timer = nil;
        
        self.statusImageView.image = [UIImage imageNamed:@"order_list_booked"];
        self.bottomButton.tag = DCOrderButtonTagNavi;
        [self setBottomButtonWithTitle:@"导航" color:[UIColor paletteDCMainColor]];
        self.bottomTipLabel.hidden = YES;
        self.bottomButtonCons.constant = 10;
    }
    else if (order.orderState == DCOrderStateNotPayBookfee) {
        self.statusLabel.attributedText = [NSAttributedString setDifferentColorWithString:order.state color:[UIColor palettePriceRedColor]];
        self.statusImageView.image = [UIImage imageNamed:@"order_list_pay_book"];
        self.bottomButton.tag = DCOrderButtonTagPayForBook;
        [self setBottomButtonWithTitle:@"支付预约费" color:[UIColor paletteButtonRedColor]];
        self.bottomTipLabel.hidden = NO;
        self.bottomButtonCons.constant = 29;
//        self.order.remainTime4ReserveFee = 5000;
        self.remainTime = self.order.remainTime4ReserveFee / 1000;
        if (self.remainTime > 0) {
            [self timerStart];
        }
    }
    cellHeight = 285;
}

- (void)configForChargeCard:(DCChargeCard *)chargeCard {
    
    self.statusLabel.textColor = [UIColor paletteDCMainColor];
    self.statusLabel.text = [chargeCard useStatusForStatusLabel];
    self.orderTimeLabel.hidden = YES;
    
    self.firstLabel.text = @"电 卡 号";
    self.orderIdLabel.text = chargeCard.cardId;
    
    self.secondLabel.text = @"开卡日期";
    self.stationNameLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:chargeCard.createTime];
    
    self.thirdLabel.text = @"绑定日期";
    self.pileNameLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:chargeCard.bindTime];
    
    
    if (chargeCard.useStatus == DCChargeCardUseStatusInit || chargeCard.useStatus == DCChargeCardUseStatusUsing) {
        self.statusImageView.image = [UIImage imageNamed:@"chargeCard_icon_normal"];
        [self setBottomButtonWithTitle:@"解绑电卡" color:[UIColor palettePriceRedColor]];
        self.bottomButton.tag = DCOrderButtonTagUnbindChargeCard;
        
        self.forthLabel.text = @"卡内余额";
        self.reserveTimeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:chargeCard.remain type:ParamTypePrice];
        
        self.fifthLabel.text = @"充电记录";
        self.reserveFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:chargeCard.chargeCount type:ParamTypeCount];
        
    }
    else if (chargeCard.useStatus == DCChargeCardUseStatusFreeze){
        self.statusLabel.textColor = [UIColor palettePriceRedColor];

        self.lastView.hidden = NO;
        self.bottomButton.hidden = YES;
        self.bottomButtonView.hidden = NO;
        self.bottomViewCons.constant = 32;
        
        self.statusImageView.image = [UIImage imageNamed:@"chargeCard_icon_freeze"];
        
        self.forthLabel.text = @"冻结日期";
        self.reserveTimeLabel.textColor = [UIColor palettePriceRedColor];
        self.reserveTimeLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:chargeCard.freezeTime];
        
        self.fifthLabel.text = @"卡内余额";
        self.reserveFeeLabel.attributedText = [NSAttributedString setDifferentColorWithParam:chargeCard.remain type:ParamTypePrice];
        
        self.chargeCountLabel.text = [NSString stringWithFormat:@"%ld 条", (long)chargeCard.chargeCount];
        self.bottomButton.enabled = NO;
    }
}

- (IBAction)contactCustomerButton:(id)sender {
    if ([self.myDelegate respondsToSelector:@selector(clickTheContactButton)]) {
        [self.myDelegate clickTheContactButton];
    }
}

//暂时屏蔽该按钮的点击事件
- (IBAction)unbindChargeCardButton:(id)sender {
    if ([self.myDelegate respondsToSelector:@selector(clickTheUnbindButton)]) {
        [self.myDelegate clickTheUnbindButton];
    }
}

#pragma mark Extension
- (void)setBottomButtonWithTitle:(NSString *)title color:(UIColor *)color {
    [self.bottomButton setTitle:title forState:UIControlStateNormal];
    self.bottomButton.backgroundColor = color;
}

+ (CGFloat)cellHeight {
    return cellHeight;
}

- (void)timerStart {
    if (self.timer == nil) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(overTime) userInfo:nil repeats:YES];
        [self.timer fire];
    }
}

- (void)overTime {
    if (self.remainTime <= 0) {
        [self.timer invalidate];
        self.timer = nil;
        
        if ([self.myDelegate respondsToSelector:@selector(timeOut)]) {
            [self.myDelegate timeOut];
        }
        return;
    }
    if (self.remainTime > 0) {
        NSString *str1 = @"支付预约费用";
        
        NSString *min = self.remainTime / 60 >= 10 ? [NSString stringWithFormat:@" (%ld:", self.remainTime / 60] : [NSString stringWithFormat:@" (0%ld:", self.remainTime / 60];
        NSString *second = self.remainTime % 60 >= 10 ? [NSString stringWithFormat:@"%lds) ", self.remainTime % 60] : [NSString stringWithFormat:@"0%lds) ", self.remainTime % 60];
        NSString *str2 = [min stringByAppendingString:second];
        
        NSString *string = [str1 stringByAppendingString:str2];
        [self.bottomButton setTitle:string forState:UIControlStateNormal];
        self.remainTime--;
    }
}

@end

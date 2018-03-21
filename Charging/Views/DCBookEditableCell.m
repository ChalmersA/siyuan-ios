//
//  DCBookEditableCell.m
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCBookEditableCell.h"

@interface DCBookEditableCell ()
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reserverFeeConstraints;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonConstraints;

@end

@implementation DCBookEditableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor paletteSeparateLineLightGrayColor];
    self.bottomButton.layer.cornerRadius = 6;
    self.bottomButton.layer.masksToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self updateEditingState:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectImageView.highlighted = selected;
    // Configure the view for the selected state
}

- (IBAction)buttonClicked:(UIButton *)sender {
    [self.delegate cellButtonClicked:self.order tag:sender.tag];
}

#pragma mark - Extension
- (void)updateEditingState:(BOOL)editing {
    self.topViewConstraints.constant = editing ? 39 : 10;
    self.selectImageView.hidden = editing ? NO : YES;
}

- (void)configForOrder:(DCOrder *)order {
    self.order = order;
    
    [order stateForStateLabel:self.order.orderState];
    self.statusLabel.text = order.state;
    self.orderTimeLabel.text = order.orderTimeDescription;
    
    self.orderIdLabel.text = order.orderId;
    self.stationNameLabel.text = order.stationName;
    self.pileNameLabel.text = [order pileNameDescription:order];
    self.bookingTime.text = order.bookingTimeDescription;
    self.reserveFeeLabel.text = [NSString stringWithFormat:@"%0.2f", order.reserveFee];
    self.statusImageView.image = [UIImage imageNamed:@"order_list_outTime"];
    self.bottomButton.tag = DCOrderButtonTagReschedule;
    
    if (order.orderState == DCOrderStateCancelBooking ||
        order.orderState == DCOrderStateCancelBookingAfterPay) {
        self.returnTimeView.hidden = NO;
        self.returnFeeView.hidden = NO;
        self.returnTimeLabel.text = order.cancelTimeDescription;
        self.returnFeeLabel.text = [NSString stringWithFormat:@"%0.2f", order.cancelFee];
        self.bottomTipLabel.text = @"(您的预约订单已取消，请您重新预约)";
        self.reserverFeeConstraints.constant = 64;
        cellHeight = [self setCellHeight];
    }
    else if (order.orderState == DCOrderStateOvevtimeToPayBookfee ||
             order.orderState == DCOrderStateOvertimeToCharge) {
        self.returnTimeView.hidden = YES;
        self.returnFeeView.hidden = YES;
        self.reserverFeeConstraints.constant = 0;
        self.bottomTipLabel.text = @"(您的预约订单已过期，请您重新预约)";
        cellHeight = [self setCellHeight];
    }
}

- (CGFloat)setCellHeight {
    CGRect bgViewRect = self.bgView.bounds;
    bgViewRect.size.width = [UIScreen mainScreen].bounds.size.width - 40;
    CGSize s = [self.bgView systemLayoutSizeFittingSize:bgViewRect.size];
    [self layoutIfNeeded];
    return s.height + 20;
}

+ (CGFloat)cellHeight {
    NSLog(@"%@ %f", [self class], cellHeight);
    return cellHeight;
}

@end

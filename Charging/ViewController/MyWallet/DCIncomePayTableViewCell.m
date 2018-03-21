//
//  DCIncomePayTableViewCell.m
//  Charging
//
//  Created by kufufu on 15/12/11.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCIncomePayTableViewCell.h"

@implementation DCIncomePayTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configViewWithCoinRecord:(DCCoinRecord *)coinRecord {
    self.timeLabel.text = [[NSDateFormatter reserveStartTimeFormatter] stringFromDate:coinRecord.createTime];
    
    switch (coinRecord.type) {
        case DCTradeTypeRecharge: {
            self.timeTitleLabel.text = @"充值时间:";
            
            self.secondTitleLabel.text = @"充值金额:";
            self.secondContentLabel.attributedText = [NSAttributedString setDifferentColorWithParam:coinRecord.money type:ParamTypePrice];
            
            self.thirdTitleLabel.text = @"到账充电币:";
            self.thirdContentLabel.attributedText = [NSAttributedString setDifferentColorWithParam:coinRecord.coin type:ParamTypeCoins];
            
            switch (coinRecord.channel) {
                case DCChannelTypeAlipay:
                    self.forthContentLabel.text = @"支付宝";
                    break;
                    
                case DCChannelTypeWechat:
                    self.forthContentLabel.text = @"微信";
                    break;
                    
                default:
                    self.forthContentLabel.text = @"未知";
                    break;
            }
        }
            break;
            
        case DCTradeTypePay: {
            self.timeTitleLabel.text = @"付款时间:";
            
            self.secondTitleLabel.text = @"订单号:";
            self.secondContentLabel.text = coinRecord.orderId;
            
            self.thirdTitleLabel.text = @"消费充电币:";
            self.thirdContentLabel.attributedText = [NSAttributedString setDifferentColorWithParam:coinRecord.coin type:ParamTypeCoins];
            
            self.forthView.hidden = YES;
            self.bottomLayoutConstraint.constant = 10;
        }
            break;
            
        case DCTradeTypeWithdraw: {
            self.secondTitleLabel.text = @"提现充电币:";
            self.secondContentLabel.attributedText = [NSAttributedString setDifferentColorWithParam:coinRecord.money type:ParamTypeCoins];
            
            self.thirdTitleLabel.text = @"提现方式:";
            
            switch (coinRecord.channel) {
                case DCChannelTypeAlipay:
                    self.forthContentLabel.text = @"支付宝";
                    break;
                    
                case DCChannelTypeWechat:
                    self.forthContentLabel.text = @"微信";
                    break;
                    
                default:
                    self.forthContentLabel.text = @"未知";
                    break;
            }
        }
        default:
            break;
    }
}

@end

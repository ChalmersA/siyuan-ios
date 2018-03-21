//
//  DCBookNormalCell.h
//  Charging
//
//  Created by kufufu on 16/4/20.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCChargeEditableCell.h"
#import "DCChargeCard.h"

static float cellHeight;

typedef NS_ENUM(NSInteger, DCChargeCardButtonTag) {
    DCChargeCardButtonTagUnbind,
};

@protocol DCBookNormalCellDelegate <NSObject>

@optional
- (void)cellButtonClickedByChargeCard:(DCChargeCard *)chargeCard tag:(DCChargeCardButtonTag)tag;

- (void)clickTheContactButton;
- (void)clickTheUnbindButton;

- (void)timeOut;
@end

@interface DCBookNormalCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reserveFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomTipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonCons;


//For ChargeCard
@property (weak, nonatomic) IBOutlet UILabel *firstLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthLabel;
@property (weak, nonatomic) IBOutlet UILabel *fifthLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *lastView;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *unbindButton; //暂时屏蔽该按钮
@property (weak, nonatomic) IBOutlet UIView *bottomButtonView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewCons;
@property (strong, nonatomic) DCOrder *order;
@property (strong, nonatomic) DCChargeCard *chargeCard;

@property (weak, nonatomic) id <DCChargeEditableCellDelegate> delegate;
@property (weak, nonatomic) id <DCBookNormalCellDelegate> myDelegate;

- (void)configForOrder:(DCOrder *)order;

- (void)configForChargeCard:(DCChargeCard *)chargeCard;

+ (CGFloat)cellHeight;

@end

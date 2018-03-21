//
//  HSSYManagePoleCell.h
//  Charging
//
//  Created by xpg on 15/5/19.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPole.h"

typedef NS_ENUM(NSInteger, HSSYManagePoleCellButton) {
    HSSYManagePoleCellButtonOrder,
    HSSYManagePoleCellButtonSetting,
    HSSYManagePoleCellButtonRecord,
};

@protocol HSSYManagePoleCellDelegate <NSObject>
- (void)cellDidClickedButton:(HSSYManagePoleCellButton)button withPole:(DCPole *)pole;
@end

@interface DCManagePoleCell : UITableViewCell
@property (weak, nonatomic) id <HSSYManagePoleCellDelegate> delegate;
@property (strong, nonatomic) DCPole *pole;
@property (weak, nonatomic) IBOutlet UIImageView *poleImage;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *shareLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *orderButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
- (void)configForPole:(DCPole *)pole user:(NSString *)userId;
@end

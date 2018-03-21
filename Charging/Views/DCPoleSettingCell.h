//
//  HSSYPoleSettingCell.h
//  Charging
//
//  Created by xpg on 14/12/22.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HSSYPoleSettingCellButtonTag) {
    HSSYPoleSettingCellLightButtonTag=1,
    HSSYPoleSettingCellDoorcontrolButtonTag,
    HSSYPoleSettingCellLoadButtonTag,
};

@protocol HSSYPoleSettingCellDelegate <NSObject>
- (void)settingSwitchButtonClick:(id)order buttonTag:(HSSYPoleSettingCellButtonTag)buttonTag;
@end

@interface DCPoleSettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImage;
@property (weak, nonatomic) IBOutlet UISwitch *settingSwitch;
@property (weak, nonatomic) id <HSSYPoleSettingCellDelegate> delegate;
@property (strong, nonatomic) id item;
- (IBAction)settingSwitchChanged:(UISwitch *)sender;
@end

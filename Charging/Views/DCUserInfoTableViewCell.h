//
//  DCUserInfoTableViewCell.h
//  Charging
//
//  Created by Ben on 14/12/24.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCUser.h"

@class UserInfo;

@interface DCUserInfoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *keyLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthCons;
@property (weak, nonatomic) IBOutlet UIImageView *headPortraitImage;
- (void)configureForUseInfo:(UserInfo *)userInfo;
@end

//
//  DCUserInfoTableViewCell.m
//  Charging
//
//  Created by Ben on 14/12/24.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCUserInfoTableViewCell.h"
#import "DCUserInfoViewController.h"
#import "UIImageView+HSSYCatagory.h"

@implementation DCUserInfoTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.keyLabel.textColor = [UIColor blackColor];
    self.valueLabel.textColor = [UIColor darkGrayColor];
    self.headPortraitImage.layer.cornerRadius = (self.headPortraitImage.frame.size.width/2);
    self.headPortraitImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForUseInfo:(UserInfo *)userInfo {
    BOOL isPhoneNumber = [userInfo.userInfoKey isEqualToString:@"登录手机号"];
    BOOL isSexInfo = [userInfo.userInfoKey isEqualToString:@"性别"];
    self.accessoryType = isPhoneNumber ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    self.iconWidthCons.constant = 25;
    if ([userInfo.imgName isEqualToString:@"user_alipay_icon"]) {
        self.iconWidthCons.constant = 50;
    }
    [self.iconView setImage:[UIImage imageNamed:userInfo.imgName]];
    [self.keyLabel setText:userInfo.userInfoKey];
    [self.valueLabel setText:userInfo.userInfoValue];
    
    if (isSexInfo) {
        self.valueLabel.text = userInfo.userInfoValue;
    }
    
    self.headPortraitImage.hidden = ![userInfo.userInfoKey isEqualToString:@"头像"];
    if (userInfo.userAvatarURL) {
        [self.headPortraitImage sd_setImageWithURL:userInfo.userAvatarURL placeholderImage:[UIImage imageNamed:@"default_user_avatar_gray"]];
    } else if (userInfo.userPortimage) {
        self.headPortraitImage.image = userInfo.userPortimage;
    } else {
        self.headPortraitImage.image = [UIImage imageNamed:@"default_user_avatar_gray"];
    }
}

@end

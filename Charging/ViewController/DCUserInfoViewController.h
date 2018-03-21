//
//  DCUserInfoViewController.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"

@interface DCUserInfoViewController : DCViewController

@end

@interface UserInfo : NSObject
@property(copy, nonatomic) NSString *imgName;
@property(copy, nonatomic) NSString *userInfoKey;
@property(copy, nonatomic) NSString *userInfoValue;

@property(copy, nonatomic) NSURL *userAvatarURL;
@property(nonatomic) UIImage *userPortimage;
@end

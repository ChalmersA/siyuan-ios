//
//  HSSYRegistInfoViewController.h
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"

@interface DCRegistInfoViewController : DCViewController
@property (copy,nonatomic) NSString *verificationString;
@property (copy,nonatomic) NSString *phoneNumString;
//第三方登录3个参数
@property (copy, nonatomic) NSString *thirdUid;
@property (copy, nonatomic) NSString *thirdAccToken;
@property (nonatomic) NSInteger thirdAccType;
@property (copy, nonatomic) NSString *thirdNickName;
@property (nonatomic) DCUserGender thirdGender;
@property (copy, nonatomic) NSString *thirdAvatarUrl;

@end

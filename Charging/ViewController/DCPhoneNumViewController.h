//
//  HSSYPhoneNumViewController.h
//  Charging
//
//  Created by Ben on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"

@interface DCPhoneNumViewController : DCViewController
// 立即注册手机号
@property (copy, nonatomic) NSString *phoneNumber;

//第三方登录
@property (copy, nonatomic) NSString *thirdUid;
@property (copy, nonatomic) NSString *thirdAccToken;
@property (nonatomic) NSInteger thirdAccType;
@property (copy, nonatomic) NSString *thirdNickName;
@property (nonatomic) DCUserGender thirdGender;
@property (copy, nonatomic) NSString *thirdAvatarUrl;

@end

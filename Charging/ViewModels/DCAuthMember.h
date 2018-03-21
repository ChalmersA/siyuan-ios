//
//  HSSYAuthMember.h
//  Charging
//
//  Created by xpg on 15/1/12.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCAuthorizedUserTableViewCell.h"

@interface DCAuthMember : DCModel

@property (copy, nonatomic) NSString *userid;
@property (copy, nonatomic) NSString *phone;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *realName;
@property (strong, nonatomic) NSDate *authTime;

@end

@interface DCAuthorizedUserTableViewCell (HSSYAuthMember)
- (void)configureForItem:(DCAuthMember *)item;
@end

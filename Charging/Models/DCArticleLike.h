//
//  HSSYArticleLike.h
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCArticleLike : DCModel
@property (copy, nonatomic, nonnull) NSString *userId;
@property (copy, nonatomic, nonnull) NSString *userName;
@property (copy, nonatomic, nullable) NSString *avatar;

// Computed Properties
@property (readonly, nullable) NSURL *avatarURL;

+ (nullable instancetype)currentUserLike;
@end

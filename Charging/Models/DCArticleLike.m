//
//  HSSYArticleLike.m
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCArticleLike.h"
#import "DCApp.h"

@implementation DCArticleLike

#pragma mark - Model
- (instancetype)initWithDict:(NSDictionary *)dict {
    _userId = @"";
    _userName = @"匿名";
    self = [super initWithDict:dict];
    return self;
}

- (NSURL *)avatarURL {
    return [NSURL URLWithImagePath:self.avatar];
}

+ (instancetype)currentUserLike {
    DCUser *user = [DCApp sharedApp].user;
    if (user) {
        DCArticleLike *like = [DCArticleLike new];
        like.userId = user.userId;
        like.userName = user.nickName;
        like.avatar = user.avatarUrl;
        return like;
    }
    return nil;
}

@end

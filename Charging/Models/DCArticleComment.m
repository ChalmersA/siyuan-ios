//
//  HSSYArticleComment.m
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCArticleComment.h"
#import "DCApp.h"

@implementation DCArticleComment

#pragma mark - Model
- (instancetype)initWithDict:(NSDictionary *)dict {
    _commentId = @"";
    _userId = @"";
    _userName = @"匿名";
    _time = [NSDate new];
    _content = @"";
    self = [super initWithDict:dict];
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"userId"]) {
        key = @"userId";
    }
    else if ([key isEqualToString:@"replyUserid"]) {
        key = @"replyUserId";
    }
    else if ([key isEqualToString:@"id"]) {
        key = @"commentId";
    }
    else if ([key isEqualToString:@"createTime"]) {
        key = @"time";
        NSNumber *number = [value numberObject];
        value = [NSDate dateWithTimestamp:[number longLongValue]];
    }
    else if ([key isEqualToString:@"replyArticleId"]) {
        key = @"replyItemId";
    }
    [super setValue:value forKey:key];
}

- (NSURL *)avatarURL {
    return [NSURL URLWithImagePath:self.avatar];
}

- (instancetype)initWithContent:(NSString *)content {
    DCUser *user = [DCApp sharedApp].user;
    if (!user) {
        return nil;
    }
    
    _userId = user.userId;
    _userName = user.nickName;
    _avatar = user.avatarUrl;

    _commentId = @"";
    _time = [NSDate new];
    _content = content;
    return self;
}

- (void)setReplyComment:(DCArticleComment *)comment {
    if (comment) {
        self.replyItemId = comment.commentId;
        self.replyUserId = comment.userId;
        self.replyUserName = comment.userName;
    } else {
        self.replyItemId = nil;
        self.replyUserId = nil;
        self.replyUserName = nil;
    }
}

@end

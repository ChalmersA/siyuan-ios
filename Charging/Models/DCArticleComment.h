//
//  HSSYArticleComment.h
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"

@interface DCArticleComment : DCModel
@property (copy, nonatomic, nonnull) NSString *commentId;
@property (copy, nonatomic, nonnull) NSString *userId;
@property (copy, nonatomic, nonnull) NSString *userName;
@property (copy, nonatomic, nullable) NSString *avatar;
@property (copy, nonatomic, nonnull) NSString *content;
@property (copy, nonatomic, nullable) NSString *replyItemId;
@property (copy, nonatomic, nullable) NSString *replyCommentId; //APP端用不着
@property (copy, nonatomic, nullable) NSString *replyUserId;
@property (copy, nonatomic, nullable) NSString *replyUserName;
@property (strong, nonatomic, nonnull) NSDate *time;



// Computed Properties
@property (readonly, nullable) NSURL *avatarURL;

- (nullable instancetype)initWithContent:(nonnull NSString *)content;
- (void)setReplyComment:(nullable DCArticleComment *)comment;

@end

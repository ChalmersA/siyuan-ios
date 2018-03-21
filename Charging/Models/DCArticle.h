//
//  DCArticle.h
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"
#import <CoreLocation/CoreLocation.h>
#import "DCArticleLike.h"
#import "DCArticleComment.h"

typedef NS_ENUM(NSInteger, DCArticleType) { // 类型：1:话题，2:评价
    DCArticleTypeTopic = 1,
    DCArticleTypeEvaluate
};

@interface DCArticle : DCModel
@property (copy, nonatomic, nonnull) NSString *articleId;   //文章Id
@property (nonatomic) DCArticleType type; // 类型：1:话题 2:评价
@property (copy, nonatomic, nonnull) NSString *userId;      //用户Id
@property (copy, nonatomic, nonnull) NSString *userName;    //用户名(昵称)
@property (copy, nonatomic, nullable) NSString *avatar;     //用户头像
@property (copy, nonatomic, nullable) NSString *content;    //文章内容
@property (strong, nonatomic, nonnull) NSArray *images;     //文章图片

@property (copy, nonatomic, nullable) NSString *stationId;      //评价的桩群id
@property (copy, nonatomic, nullable) NSString *stationName;    //评价的桩群名字

@property (copy, nonatomic, nullable) NSString *orderId;        //评价对应的订单号

@property (assign, nonatomic, nullable) NSNumber *starScore;    //桩群总评分
@property (assign, nonatomic) double envirScore;                //桩群周边环境评分
@property (assign, nonatomic) double facadeScore;               //桩群设备情况评分
@property (assign, nonatomic) double speedScore;                //桩群充电速度评分

@property (copy, nonatomic, nullable) NSString *cityId;         //城市Id

@property (assign, nonatomic) NSInteger commentCount;           //文章评论数量
@property (strong, nonatomic, nonnull) NSArray *comments;       //此文章的评论列表

@property (strong, nonatomic, nonnull) NSDate *createTime;        //文章发表时间

@property (nonatomic) NSInteger likeCount;                      //点赞数量
@property (strong, nonatomic, nonnull) NSArray *likes;          //点赞用户列表(前10)
@property (readonly) BOOL like;                                 //当前用户是否已经点赞此文章


// Computed Properties
@property (readonly, nullable) NSURL *avatarURL;
@property (readonly, nonnull) NSArray *likeAvatarURLs;
@property (readonly) BOOL userArticle;

- (NSString *)cityNameFormId:(NSString *)cityId;

- (void)addCurrentUserLike;
- (void)deleteCurrentUserLike;
- (void)addUserCommentWithContent:(nonnull NSString *)content replyComment:(nullable DCArticleComment *)replyComment;

- (void)replaceArticle:(nonnull DCArticle*)newArticle;

@end

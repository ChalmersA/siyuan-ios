//
//  HSSYArticle.m
//  Charging
//
//  Created by chenzhibin on 15/9/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCArticle.h"
#import "DCApp.h"
#import "DCCitySelection.h"

@implementation DCArticle

#pragma mark - Model
- (instancetype)initWithDict:(NSDictionary *)dict {
    _articleId = @"";
    _userId = @"";
    _userName = @"匿名";
    _createTime = [NSDate new];
    _images = @[];
    _likes = @[];
    _comments = @[];
    self = [super initWithDict:dict];
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString:@"createTime"]) {
        NSNumber *number = [value numberObject];
        value = [NSDate dateWithTimestamp:[number longLongValue]];
    } else if ([key isEqualToString:@"images"]) {
        NSMutableArray *images = [NSMutableArray array];
        for (id object in [value arrayObject]) {
            NSString *path = [object stringObject];
            if (path) {
                [images addObject:path];
            }
        }
        value = images;
    } else if ([key isEqualToString:@"likes"]) {
        NSMutableArray *likes = [NSMutableArray array];
        for (id object in [value arrayObject]) {
            NSDictionary *dict = [object dictionaryObject];
            if (dict) {
                DCArticleLike *like = [[DCArticleLike alloc] initWithDict:dict];
                [likes addObject:like];
            }
        }
        value = likes;
    } else if ([key isEqualToString:@"comments"]) {
        NSMutableArray *comments = [NSMutableArray array];
        for (id object in [value arrayObject]) {
            NSDictionary *dict = [object dictionaryObject];
            if (dict) {
                DCArticleComment *comment = [[DCArticleComment alloc] initWithDict:dict];
                [comments addObject:comment];
            }
        }
        value = comments;
    }
    [super setValue:value forKey:key];
}

#pragma mark - Computed Properties
- (NSURL *)avatarURL {
    return [NSURL URLWithImagePath:self.avatar];
}

- (NSArray *)likeAvatarURLs {
    NSMutableArray *array = [NSMutableArray array];
    for (DCArticleLike *like in self.likes) {
        NSURL *url = like.avatarURL;
        if (url) {
            [array addObject:url];
        } else {
            NSURL *url = [NSURL URLWithString:@""];
            [array addObject:url];
        }
    }
    return array;
}

- (BOOL)userArticle {
    DCUser *user = [DCApp sharedApp].user;
    if (user) {
        if ([self.userId isEqualToString:user.userId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)like {
    DCUser *user = [DCApp sharedApp].user;
    if (user) {
        for (DCArticleLike *like in self.likes) {
            if ([like.userId isEqualToString:user.userId]) {
                return YES;
            }
        }
    }
    return NO;
}

- (NSString *)cityNameFormId:(NSString *)cityId {
    if (cityId) {
        DCCitySelection *citySelection = [[DCCitySelection alloc] init];
        for (City *city in citySelection.cities) {
            if ([city.cityId isEqualToString:[DCApp sharedApp].searchParam.placeCode]) {
                return city.name;
            }
        }
    }
    return nil;
}

#pragma mark - Business
- (void)addCurrentUserLike {
    DCArticleLike *currentUserLike = [DCArticleLike currentUserLike];
    if (currentUserLike) {
        NSMutableArray *likes = [self.likes mutableCopy];
        [likes addObject:currentUserLike];
        self.likes = likes;
        self.likeCount++;
    }
}

- (void)deleteCurrentUserLike {
    DCUser *user = [DCApp sharedApp].user;
    if (user) {
        NSMutableArray *likes = [self.likes mutableCopy];
        for (NSInteger index = 0; index < self.likes.count; index++) {
            DCArticleLike *like = self.likes[index];
            if ([like.userId isEqualToString:user.userId]) {
                [likes removeObject:like];
                self.likeCount--;
                break;
            }
        }
        self.likes = likes;
    }
}

- (void)addUserCommentWithContent:(NSString *)content replyComment:(DCArticleComment *)replyComment {
    DCArticleComment *comment = [[DCArticleComment alloc] initWithContent:content];
    if (comment) {
        [comment setReplyComment:replyComment];
        self.comments = [self.comments arrayByAddingObject:comment];
        self.commentCount++;
    }
}

- (void)replaceArticle:(DCArticle*)newArticle {
    // TODO: Add more replacement
    self.articleId = newArticle.articleId;
    self.type = newArticle.type;
    self.userId = newArticle.userId;
    self.userName = newArticle.userName;
    self.avatar = newArticle.avatar;
    self.content = newArticle.content;
    self.images = newArticle.images;
    self.stationId = newArticle.stationId;
    self.stationName = newArticle.stationName;
    self.orderId = newArticle.orderId;
    self.starScore = newArticle.starScore;
    self.envirScore = newArticle.envirScore;
    self.facadeScore = newArticle.facadeScore;
    self.speedScore = newArticle.speedScore;
    self.cityId = newArticle.cityId;
    self.commentCount = newArticle.commentCount;
    self.comments = newArticle.comments;
    self.createTime = newArticle.createTime;
    self.likeCount = newArticle.likeCount;
    self.likes = newArticle.likes;
}

@end

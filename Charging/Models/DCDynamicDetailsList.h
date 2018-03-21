//
//  HSSYDynamicDetailsList.h
//  Charging
//
//  Created by xpg on 15/9/17.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCModel.h"

typedef NS_ENUM(NSInteger, DynamicSourceType) {
    DynamicSourceTypeIN = 1,
    DynamicSourceTypeOUT
};

@interface DCDynamicDetailsList : DCModel


/**
 "content" : "文章摘要信息。。。测试版",
 "id" : "da46bf6333a44c1ca100686dee123d38",
 "coverImg" : "",
 "title" : "12312",
 "isTop" : false,
 "issueTime" : 1443410181000,
 "viewCount" : 1
 */
@property (copy, nonatomic) NSString *dynamicId; //id
@property (copy, nonatomic) NSString *title; //标题
@property (copy, nonatomic) NSString *summary; //资讯简介
@property (copy, nonatomic) NSString *coverImg;//资讯封面图
@property (assign, nonatomic) BOOL isTop; //是否置顶
@property (assign, nonatomic) NSInteger viewCount; //阅读量
@property (copy, nonatomic) NSString *sourceUrl; //url链接
@property (copy, nonatomic) NSDate *createTime; //发表时间
@property (copy, nonatomic) NSDate *updateTime; //发表时间
@property (assign, nonatomic) DynamicSourceType sourceType; //站内:1 外链:2

@end

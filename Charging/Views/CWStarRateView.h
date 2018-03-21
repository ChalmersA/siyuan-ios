//
//  CWStarRateView.h
//  StarRateDemo
//
//  Created by WANGCHAO on 14/11/4.
//  Copyright (c) 2014年 wangchao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CWStarRateView;
@protocol CWStarRateViewDelegate <NSObject>
@optional
- (void)starRateView:(CWStarRateView *)starRateView scroePercentDidChange:(CGFloat)newScorePercent;
@end

@interface CWStarRateView : UIView

@property (nonatomic, assign) CGFloat scorePercent;//得分值，范围为0--1，默认为1
@property (nonatomic, assign) BOOL hasAnimation;//是否允许动画，默认为NO
@property (nonatomic, assign) BOOL allowIncompleteStar;//评分时是否允许不是整星，默认为NO
@property (nonatomic, assign) BOOL needAppositeColor; // 是否需要把选中的颜色与非选中的颜色互换
@property (nonatomic, weak) id<CWStarRateViewDelegate>delegate;

@property (nonatomic, strong) NSString * backgroundImageName; // 设置背景效果视图图片（未选）
@property (nonatomic, strong) NSString * foregroundImageName; // 设置效果图片（已选）

- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars referView:(UIView *)referView;
- (instancetype)initWithFrame:(CGRect)frame numberOfStars:(NSInteger)numberOfStars referView:(UIView *)referView backgroundImageName:(NSString *)backgroundImageName foregroundImageName:(NSString *)foregroundImageName;

@end
//
//  DCStationDetailViewController.h
//  CollectionViewTest
//
//  Created by  Blade on 4/22/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCShareDateChooseView.h"
#import "DCPeriodSpliterView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCViewController.h"
#import "PagedImageScrollView.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import "DCStation.h"
@class CWStarRateView;

@interface DCStationDetailViewController : DCViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *testLastView;


@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
//标题
@property (weak, nonatomic) IBOutlet MarqueeLabel *labelTitle;
//评价 rightBarButton
@property (weak, nonatomic) IBOutlet UIButton *evaluationButton;


//电桩图片
@property (weak, nonatomic) IBOutlet PagedImageScrollView *imagePageView;

// 电桩详情
@property (weak, nonatomic) IBOutlet UIView *viewPoleDetail;
@property (weak, nonatomic) IBOutlet UILabel *labelPolePosition;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelPoleLoactionInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelTagPileType;
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;   //状态(GPRS:空闲、占用、维护;蓝牙:已分享、未分享;站:有空闲、满载)

// 评分模块
@property (weak, nonatomic) IBOutlet UIView *viewScoreContainer;                    //
@property (weak, nonatomic) IBOutlet UIView *viewTotalScore;                        // 总评分项
@property (weak, nonatomic) IBOutlet UIView *viewScoreStarBg;                       // 总评分星星bg
@property (weak, nonatomic) IBOutlet CWStarRateView *viewScoreStar;                 // 总评分星星bg
@property (weak, nonatomic) IBOutlet UILabel *labelScoreTitle;                      // 总评分Title
@property (weak, nonatomic) IBOutlet UIView *viewLastScorePreview;                  // 最后评分项
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLastScoreUserPortrain;   // 最后评分用户的头像
@property (weak, nonatomic) IBOutlet UILabel *labelLastScoreUserName;               // 最后评分用户的名字
@property (weak, nonatomic) IBOutlet UIView *viewLastScoreStarsBg;                  // 最后评分星星背景
@property (weak, nonatomic) IBOutlet CWStarRateView *viewLastScoreStars;            // 最后评分星星
@property (weak, nonatomic) IBOutlet UILabel *labelLastScoreTime;                    // 最后评分时间
@property (weak, nonatomic) IBOutlet UILabel *labelLastScoreContent;                // 最后评分内容

@property (weak, nonatomic) IBOutlet UIView *viewScoresCountContainer;              // 总评分数
@property (weak, nonatomic) IBOutlet UILabel *labelScoresCount;                     // 总评分数Label

@property (weak, nonatomic) IBOutlet UIView *viewScoreViewBottomLine;                       // 总评分数
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintScoreViewBottomLine;     //

// 属性模块
@property (weak, nonatomic) IBOutlet UILabel *bookFeeLabel;
@property (weak, nonatomic) IBOutlet UILabel *functionLabel;
@property (weak, nonatomic) IBOutlet UILabel *facilityLabel;

// 业主项
@property (weak, nonatomic) IBOutlet UIView *viewOwner;
@property (weak, nonatomic) IBOutlet UILabel *labelOwnerNameContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintPhoneBtnWidth;

// 桩群描述
@property (weak, nonatomic) IBOutlet UILabel *stationDesctiptionLabel;

// 底栏和预约按钮
@property (weak, nonatomic) IBOutlet UIView *blockLeft;
@property (weak, nonatomic) IBOutlet UIView *blockMid;
@property (weak, nonatomic) IBOutlet UIView *blockRight;
@property (weak, nonatomic) IBOutlet UIButton *bookButton;
@property (weak, nonatomic) IBOutlet UIButton *navibutton;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomBarViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBottomBarViewBottom;

@property (strong, nonatomic) DCStation *selectStationInfo;
@property (assign, nonatomic) BOOL segueFromMyFavor;
@property (retain, nonatomic) NSNumber *distance;
@property (retain, nonatomic) NSNumber *tripTimeMinute;

//@property (assign, nonatomic) BOOL isPole; //是否是桩
//@property (assign, nonatomic) BOOL isSharing; //是否在分享

- (void)prelaodDataFromServer;
@end

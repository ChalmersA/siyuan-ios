//
//  HSSYPeriodSpliterViewController.h
//  CollectionViewTest
//
//  Created by  Blade on 4/24/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCShareDate.h"
typedef enum {
    HSSYSplitePeriodDisplayModeAll,             //所有时段，包括Booked、Overdue
    HSSYSplitePeriodDisplayModeValidPartial,    //所有有效时段的部分
    HSSYSplitePeriodDisplayModeValidAll         //所有有效的时段
} HSSYSplitePeriodDisplayMode;
@protocol HSSYPeriodSpliterViewDelegate <NSObject>
- (void)didSelectDates:(NSArray*)dates;
@end

@interface DCPeriodSpliterView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic,retain) IBOutlet UICollectionView* collectionView;
@property (nonatomic,retain) IBOutlet NSLayoutConstraint* collectionViewHeightConstraint;
@property (nonatomic,retain) IBOutlet UIButton* btnMore;
@property (nonatomic,retain) IBOutlet UILabel* labelMore;
@property (nonatomic,retain) IBOutlet UIImageView* imageViewMore;
@property (nonatomic,retain) IBOutlet UILabel* labelHint;

@property (nonatomic, weak) id <HSSYPeriodSpliterViewDelegate> delegate;
@property (nonatomic,assign) HSSYSplitePeriodDisplayMode displayMode;
@property (nonatomic,retain) NSNumber* duration;
- (void)initView;
- (void)setupPeriodSpliterViewWithData:(DCShareDate*) shareDate;
- (void)updateCollectionView;
@end

//
//  HSSYShareDateChooseView.h
//  CollectionViewTest
//
//  Created by  Blade on 4/23/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCShareDate.h"
#import "DCShareDatePickView.h"
@protocol HSSYShareDateChooseViewDelegate <NSObject>
- (void)didSelectShareDateWithTag:(NSInteger)tag;
@end

@interface DCShareDateChooseView : UIView <HSSYShareDatePickViewDelegate>
@property (nonatomic, weak) id <HSSYShareDateChooseViewDelegate> delegate;
@property (nonatomic, retain) NSMutableArray *dateBtnArr;
@property (nonatomic, retain) DCShareDatePickView *shareDatePickView;
- (void)initView;
- (NSInteger)setUpDateChooseViewWithShareDates:(NSArray*)shareDates andBeginDate:(NSDate*) beginDate;
@end

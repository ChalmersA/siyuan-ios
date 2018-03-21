//
//  HSSYSharePeriod.h
//  CollectionViewTest
//
//  Created by  Blade on 4/29/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCModel.h"

@interface DCSharePeriod : DCModel
@property (nonatomic, retain) NSDate* dateOfShare;
@property (nonatomic, retain) NSDate* timeShareStart;
@property (nonatomic, retain) NSDate* timeShareEnd;
@property (nonatomic, retain) NSNumber* duration;
@property (nonatomic, retain) NSMutableArray* arrFreeSplitedPeriod;
@property (nonatomic, retain) NSMutableArray* arrBookedSplitedPeriod;
@property (nonatomic, retain) NSMutableArray* arrOverdueSplitedPeriod;
@property (nonatomic, retain) NSMutableArray* arrAllSplitedPeriod;

#pragma mark - initialization
- (instancetype)initWithDict:(NSDictionary *)dict dateOfShareDay:(NSDate*)shareDate;

- (NSString*)sharePeriodStr;
- (NSString*)splitePeriodStringAtIndex:(NSInteger)index;
- (BOOL)canSelectThisPeriod;
- (BOOL)canSelected:(NSInteger) index;
// 将Index中的时段变成开始时间和结束时间
- (NSArray*)datesOfPeriodWithIndex:(NSInteger)index;

@end

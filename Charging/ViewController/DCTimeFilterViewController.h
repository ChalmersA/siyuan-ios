//
//  HSSYTimeFilterViewController.h
//  Charging
//
//  Created by xpg on 15/5/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCClockView.h"

@protocol HSSYTimeFilterViewControllerDelegate <NSObject>
- (void)applyFilterStartTime:(ClockTime)startTime startTimeActivated:(BOOL)startTimeActivated endTime:(ClockTime)endTime endTimeActivated:(BOOL)endTimeActivated duration:(double)duration;
@end

@interface DCTimeFilterViewController : DCViewController
@property (weak, nonatomic) id <HSSYTimeFilterViewControllerDelegate> delegate;

@property (strong, nonatomic) NSDateComponents *defaultDay;
@property (strong, nonatomic) NSDateComponents *defaultStartTime;
@property (strong, nonatomic) NSDateComponents *defaultEndTime;
@property (strong, nonatomic) NSNumber *defaultDuration;

@end

//
//  HSSYClockView.h
//  Charging
//
//  Created by xpg on 15/5/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct {
    NSInteger hour;
    NSInteger minute;
} ClockTime;

@protocol HSSYClockViewDelegate <NSObject>
@optional
- (void)clockChangedStartTime:(ClockTime)startTime endTime:(ClockTime)endTime;
@end

@interface DCClockView : UIView
@property (weak, nonatomic) id <HSSYClockViewDelegate> delegate;
@property (assign, nonatomic) BOOL isStartTimeActive;
@property (assign, nonatomic) BOOL isEndTimeActive;
@property (assign, nonatomic, readonly) ClockTime startTime;
@property (assign, nonatomic, readonly) ClockTime endTime;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
- (float)hoursBetweenStartTimeAndEndTime;
- (void)updateStartTime:(ClockTime)startTime endTime:(ClockTime)endTime;
@end

ClockTime clockTimeMake(NSInteger hour, NSInteger minute);
ClockTime clockTimeOffset(ClockTime time, NSInteger minutes);
ClockTime clockTimeApplyMinuteInterval(ClockTime time, NSInteger minuteInterval);
NSString *NSStringFromClockTime(ClockTime time);

static inline NSInteger minutesFromClockTime(ClockTime time) {
    return time.hour * 60 + time.minute;
}

static inline ClockTime clockTimeFromMinutes(NSInteger minutes) {
    NSInteger hour = minutes / 60;
    NSInteger minute = minutes - hour * 60;
    return clockTimeMake(hour, minute);
}

static inline NSComparisonResult clockTimeCompare(ClockTime time0, ClockTime time1) {
    NSInteger minutes0 = minutesFromClockTime(time0);
    NSInteger minutes1 = minutesFromClockTime(time1);
    if (minutes0 < minutes1) {
        return NSOrderedAscending;
    } else if (minutes0 > minutes1) {
        return NSOrderedDescending;
    }
    return NSOrderedSame;
}

static inline BOOL isClockTimeEqual(ClockTime time0, ClockTime time1) {
    return clockTimeCompare(time0, time1) == NSOrderedSame;
}

static ClockTime ClockTimeZero = {0, 0};
static ClockTime ClockTimeEnd = {24, 0};

//
//  HSSYClockView.m
//  Charging
//
//  Created by xpg on 15/5/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCClockView.h"
#import "ArcLayer.h"

#define ToRad(deg)      ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )

#define MIN_ANGLE   (-M_PI_2)
#define MAX_ANGLE   (MIN_ANGLE + 4 * M_PI)

#define DRAG_MIN_ANGLE  (MIN_ANGLE - M_PI)
#define DRAG_MAX_ANGLE  (MAX_ANGLE + M_PI)

static inline CGPoint CGRectGetCenterPoint(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

CGFloat angleForTime(ClockTime time);
ClockTime clockTimeForAngle(CGFloat angle);
ClockTime clockTimeApplyMinuteInterval(ClockTime time, NSInteger minuteInterval);
NSInteger minutesDiff(ClockTime time, ClockTime time2);

@interface DCClockView ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *midTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) UIButton *startThumb;
@property (weak, nonatomic) UIButton *endThumb;
@property (weak, nonatomic) CAShapeLayer *progressLayer;
@property (strong, nonatomic) UIColor *gradientStartColor;
@property (strong, nonatomic) UIColor *gradientEndColor;
@property (strong, nonatomic) UIColor *strokeColor;

@property (assign, nonatomic) ClockTime startTime;
@property (assign, nonatomic) ClockTime endTime;
@end

@implementation DCClockView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _strokeColor = [UIColor colorWithWhite:232/255.0 alpha:1];
        _gradientStartColor = [UIColor digitalColorWithRed:56 green:241 blue:231];
        _gradientEndColor = [UIColor digitalColorWithRed:40 green:244 blue:126];
        
        CAShapeLayer *progressLayer = [CAShapeLayer layer];
        [self.layer addSublayer:progressLayer];
        _progressLayer = progressLayer;
        
        UIButton *startButton = [self thumbWithImage:[UIImage imageNamed:@"time_clock_start_button"]];
        [self addSubview:startButton];
        _startThumb = startButton;
        
        UIButton *endButton = [self thumbWithImage:[UIImage imageNamed:@"time_clock_end_button"]];
        [self addSubview:endButton];
        _endThumb = endButton;
    }
    return self;
}

- (void)setup {
    ClockTime minTime = clockTimeForAngle(MIN_ANGLE);
    assert(minutesDiff(minTime, clockTimeMake(0, 0)) == 0);
    ClockTime maxTime = clockTimeForAngle(MAX_ANGLE);
    assert(minutesDiff(maxTime, clockTimeMake(24, 0)) == 0);
    CGFloat angle = angleForTime(clockTimeMake(0, 0));
    assert(angle >= MIN_ANGLE && angle <= MAX_ANGLE);
    angle = angleForTime(clockTimeMake(24, 0));
    assert(angle >= MIN_ANGLE && angle <= MAX_ANGLE);
}

- (void)awakeFromNib {
    self.startTimeLabel.textColor = self.gradientStartColor;
    self.midTimeLabel.textColor = self.gradientStartColor;
    self.endTimeLabel.textColor = self.gradientStartColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - Public
- (void)setIsStartTimeActive:(BOOL)isStartTimeActive {
    _isStartTimeActive = isStartTimeActive;
    [self updateStartTime:self.startTime endTime:self.endTime];
}

- (void)setIsEndTimeActive:(BOOL)isEndTimeActive {
    _isEndTimeActive = isEndTimeActive;
    if (isEndTimeActive) {
        self.isStartTimeActive = YES;
    } else {
        [self updateStartTime:self.startTime endTime:self.endTime];
    }
}

- (float)hoursBetweenStartTimeAndEndTime {
    return minutesDiff(self.endTime, self.startTime)/60.0;
}

#pragma mark - UI
- (void)updateStartAngle:(CGFloat)angle {
    CGFloat possibleAngle = [self mostPossibleAngle:angle forLastAngle:angleForTime(self.startTime)];
    CGFloat adjustedAngle = MIN(MAX(MIN_ANGLE, possibleAngle), MAX_ANGLE);
    
    ClockTime startTime = clockTimeForAngle(adjustedAngle);
    startTime = clockTimeApplyMinuteInterval(startTime, 30);
    DDLogVerbose(@"update start time %@", NSStringFromClockTime(startTime));
    
    ClockTime endTime = self.endTime;
    if (!_isEndTimeActive) {
        endTime = clockTimeOffset(startTime, 30);
        if (minutesDiff(endTime, clockTimeMake(24, 0)) > 0) {//大于24:00
            startTime = clockTimeMake(23, 30);
            endTime = clockTimeMake(24, 00);
            DDLogVerbose(@"adjust start time %@", NSStringFromClockTime(startTime));
        }
    }
    else if (minutesDiff(endTime, startTime) > minutesFromClockTime(clockTimeMake(10, 0))) {//大于10h
        endTime = clockTimeOffset(startTime, minutesFromClockTime(clockTimeMake(10, 0)));
        DDLogVerbose(@"pull end time %@", NSStringFromClockTime(endTime));
    } else if (minutesDiff(endTime, startTime) < 30) {//小于30min
        endTime = clockTimeOffset(startTime, 30);
        if (minutesDiff(endTime, clockTimeMake(24, 0)) > 0) {//大于24:00
            startTime = clockTimeMake(23, 30);
            endTime = clockTimeMake(24, 00);
            DDLogVerbose(@"adjust start time %@", NSStringFromClockTime(startTime));
        }
        DDLogVerbose(@"push end time %@", NSStringFromClockTime(endTime));
    }
    
    [self updateStartTime:startTime endTime:endTime];
}

- (void)updateEndAngle:(CGFloat)angle {
    CGFloat possibleAngle = [self mostPossibleAngle:angle forLastAngle:angleForTime(self.endTime)];
    CGFloat adjustedAngle = MIN(MAX(MIN_ANGLE, possibleAngle), MAX_ANGLE);
    
    ClockTime endTime = clockTimeForAngle(adjustedAngle);
    endTime = clockTimeApplyMinuteInterval(endTime, 30);
    DDLogVerbose(@"update end time %@", NSStringFromClockTime(endTime));
    
    ClockTime startTime = self.startTime;
    if (minutesDiff(endTime, startTime) > minutesFromClockTime(clockTimeMake(10, 0))) {//大于10h
        startTime = clockTimeOffset(endTime, -minutesFromClockTime(clockTimeMake(10, 0)));
        DDLogVerbose(@"pull start time %@", NSStringFromClockTime(startTime));
    } else if (minutesDiff(endTime, startTime) < 30) {//小于30min
        startTime = clockTimeOffset(endTime, -30);
        if (minutesDiff(startTime, clockTimeMake(0, 0)) < 0) {//小于00:00
            startTime = clockTimeMake(0, 0);
            endTime = clockTimeMake(0, 30);
            DDLogVerbose(@"adjust end time %@", NSStringFromClockTime(endTime));
        }
        DDLogVerbose(@"push start time %@", NSStringFromClockTime(startTime));
    }
    
    [self updateStartTime:startTime endTime:endTime];
}

- (void)updateStartTime:(ClockTime)startTime endTime:(ClockTime)endTime {
    self.startTime = startTime;
    self.endTime = endTime;
    
    if (_isStartTimeActive) {
        [self.startThumb setImage:[UIImage imageNamed:@"time_clock_start_button"] forState:UIControlStateNormal];
    } else {
        [self.startThumb setImage:[UIImage imageNamed:@"time_clock_disable_button"] forState:UIControlStateNormal];
    }
    
    if (_isEndTimeActive) {
        [self.endThumb setImage:[UIImage imageNamed:@"time_clock_end_button"] forState:UIControlStateNormal];
    } else {
        [self.endThumb setImage:[UIImage imageNamed:@"time_clock_disable_button"] forState:UIControlStateNormal];
        self.endTime = clockTimeOffset(self.startTime, 30);
    }
    
    if ([self.delegate respondsToSelector:@selector(clockChangedStartTime:endTime:)]) {
        [self.delegate clockChangedStartTime:self.startTime endTime:self.endTime];
    }
    DDLogVerbose(@"time %@ ~ %@", NSStringFromClockTime(self.startTime), NSStringFromClockTime(self.endTime));
    [self updateViews];
}

- (void)updateViews {
    CGFloat startAngle = angleForTime(self.startTime);
    self.startThumb.center = [self pointFromCenter:[self centerPoint] radius:[self radius] angle:startAngle];
    self.startThumb.transform = CGAffineTransformMakeRotation(startAngle + M_PI);
    
    CGFloat endAngle = angleForTime(self.endTime);
    self.endThumb.center = [self pointFromCenter:[self centerPoint] radius:[self radius] angle:endAngle];
    self.endThumb.transform = CGAffineTransformMakeRotation(endAngle);
    
    [self setProgressStartAngle:startAngle endAngle:endAngle];
    
    if (_isStartTimeActive) {
        self.startTimeLabel.text = NSStringFromClockTime(self.startTime);
    } else {
        self.startTimeLabel.text = @"- -";
    }
    
    if (!_isEndTimeActive) {
        self.endTimeLabel.text = @"- -";
    } else {
        self.endTimeLabel.text = NSStringFromClockTime(self.endTime);
    }
}

- (CGFloat)mostPossibleAngle:(CGFloat)angle forLastAngle:(CGFloat)lastAngle {
    CGFloat angleA = angle;
    if (angle > M_PI_2) {
        angleA = angle - 2 * M_PI;
    }
    CGFloat angleB = angleA + 2 * M_PI;
    CGFloat angleC = angleA + 4 * M_PI;
//    DDLogVerbose(@"possible angle %.1f %.1f %.1f", ToDeg(angleA), ToDeg(angleB), ToDeg(angleC));
    
    CGFloat deltaA = fabs(angleA - lastAngle);
    CGFloat deltaB = fabs(angleB - lastAngle);
    CGFloat deltaC = fabs(angleC - lastAngle);
    CGFloat possibleAngle = angleB;
    if ((deltaA < deltaB) && (deltaA < deltaC)) {
        possibleAngle = angleA;
    } else if ((deltaC < deltaB) && (deltaC < deltaA)) {
        possibleAngle = angleC;
    }
    return possibleAngle;
}

- (void)setProgressStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    for (CALayer *layer in self.progressLayer.sublayers) {
        [layer removeFromSuperlayer];
    }
    if (_isEndTimeActive) {
        GradientArcLayer *layer = [GradientArcLayer layerWithCenter:[self centerPoint]
                                                             radius:[self radius]
                                                         startAngle:startAngle
                                                           endAngle:endAngle
                                                         startColor:self.gradientStartColor
                                                           endColor:self.gradientEndColor];
        [self.progressLayer addSublayer:layer];
    }
    else {
        ArcLayer *layer = [ArcLayer layerWithCenter:[self centerPoint]
                                             radius:[self radius]
                                         startAngle:startAngle
                                           endAngle:endAngle
                                        strokeColor:self.strokeColor];
        [self.progressLayer addSublayer:layer];
    }
}

- (UIButton *)thumbWithImage:(UIImage *)image {
    UIButton *thumb = [UIButton buttonWithType:UIButtonTypeCustom];
    thumb.frame = CGRectMake(0, 0, 44, 44);
    [thumb setImage:image forState:UIControlStateNormal];
    
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [thumb addGestureRecognizer:gesture];
    return thumb;
}

#pragma mark - Gesture
- (void)handleGesture:(UIGestureRecognizer *)gesture {
    if (gesture.view != self.startThumb && gesture.view != self.endThumb) {
        return;
    }
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat angle = [self angleFromPoint:touchPoint withCenter:[self centerPoint]];
    if (gesture.view == self.startThumb) {
        self.isStartTimeActive = YES;
        [self updateStartAngle:angle];
    } else {
        self.isEndTimeActive = YES;
        [self updateEndAngle:angle];
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            if ([self distanceFromPoint:touchPoint toPoint:[self centerPoint]] < ([self radius] - CGRectGetWidth(gesture.view.bounds)*2)) {
                gesture.enabled = NO;
                gesture.enabled = YES;
            }
            
            if ([self distanceFromPoint:touchPoint toPoint:gesture.view.center] > CGRectGetWidth(gesture.view.bounds)*2) {
                gesture.enabled = NO;
                gesture.enabled = YES;
            }
            break;
        }
            
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded: {
            
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Extension
- (CGPoint)centerPoint {
    return CGRectGetCenterPoint(self.bounds);
}

- (CGFloat)radius {
    return CGRectGetWidth(self.bounds)/2.0 - 22;
}

- (CGPoint)pointFromCenter:(CGPoint)center radius:(CGFloat)radius angle:(CGFloat)angle {
    CGPoint point;
    point.y = round(center.y + radius * sin(angle));
    point.x = round(center.x + radius * cos(angle));
    return point;
}

- (CGFloat)distanceFromPoint:(CGPoint)point toPoint:(CGPoint)point2 {
    CGPoint v = CGPointMake(point.x - point2.x, point.y - point2.y);
    return sqrt(v.x * v.x + v.y * v.y);
}

- (CGFloat)angleFromPoint:(CGPoint)point withCenter:(CGPoint)center {
    CGPoint v = CGPointMake(point.x - center.x, point.y - center.y);
    double result = atan2(v.y, v.x);
    return result;
}

@end

ClockTime clockTimeMake(NSInteger hour, NSInteger minute) {
    return (ClockTime){hour, minute};
}

CGFloat angleForTime(ClockTime time) {
    NSInteger minutes = minutesFromClockTime(time);
    CGFloat angle = MIN_ANGLE + 2 * M_PI * minutes / (12 * 60);
    angle = MIN(MAX(MIN_ANGLE, angle), MAX_ANGLE);
//    assert((angle >= MIN_ANGLE) && (angle <= MAX_ANGLE));
    return angle;
}

ClockTime clockTimeForAngle(CGFloat angle) {
    angle = MIN(MAX(MIN_ANGLE, angle), MAX_ANGLE);
//    assert((angle >= MIN_ANGLE) && (angle <= MAX_ANGLE));
    NSInteger minutes = 12 * 60  * (angle - MIN_ANGLE) / (M_PI * 2);
    return clockTimeFromMinutes(minutes);
}

ClockTime clockTimeApplyMinuteInterval(ClockTime time, NSInteger minuteInterval) {
    NSInteger minutes = minutesFromClockTime(time);
    NSInteger times = (NSInteger)(minutes/(CGFloat)minuteInterval + 0.5);
    minutes = minuteInterval * times;
    return clockTimeFromMinutes(minutes);
}

NSInteger minutesDiff(ClockTime time, ClockTime time2) {
    return minutesFromClockTime(time) - minutesFromClockTime(time2);
}

ClockTime clockTimeOffset(ClockTime time, NSInteger minutes) {
    return clockTimeFromMinutes(minutesFromClockTime(time) + minutes);
}

NSString *NSStringFromClockTime(ClockTime time) {
    return [NSString stringWithFormat:@"%02d:%02d", (int)time.hour, (int)time.minute];
}

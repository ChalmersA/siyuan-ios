//
//  HSSYTimeFilterViewController.m
//  Charging
//
//  Created by xpg on 15/5/5.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCTimeFilterViewController.h"

@interface DCTimeFilterViewController () <HSSYClockViewDelegate>
@property (assign, nonatomic) float minTimeLength;
@property (assign, nonatomic) float maxTimeLength;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet DCClockView *clockView;
@property (weak, nonatomic) IBOutlet UILabel *timeLengthLabel;
@property (weak, nonatomic) IBOutlet UISlider *timeLengthSlider;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@end

@implementation DCTimeFilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.clockView.delegate = self;
    
    self.timeLengthLabel.textColor = [UIColor timeFilterTintColor];
    self.timeLengthSlider.minimumTrackTintColor = [UIColor timeFilterTintColor];
//    [self.timeLengthSlider setMaximumTrackImage:[UIImage imageNamed:@"time_slider_track"] forState:UIControlStateNormal];//time_slider_progress
    [self.timeLengthSlider setThumbImage:[UIImage imageNamed:@"time_slider_button"] forState:UIControlStateNormal];
    self.timeLengthSlider.value = 0;
    
    [self configButton:self.resetButton];
    [self configButton:self.applyButton];
    
    [self updateWithStartTime:self.defaultStartTime endTime:self.defaultEndTime duration:self.defaultDuration day:self.defaultDay];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Action
- (IBAction)timeLengthChanged:(UISlider *)sender {
    [self updateTimeLengthSliderValue:round(sender.value * 2) * 0.5];
}

- (IBAction)reset:(id)sender {
    self.timeLengthSlider.value = 0;
    
    self.clockView.isEndTimeActive = NO;//deactive end time before deactive start time
    self.clockView.isStartTimeActive = NO;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]];
    ClockTime startTime = clockTimeMake(components.hour, components.minute/30*30);
    [self.clockView updateStartTime:startTime endTime:startTime];
}

- (IBAction)apply:(id)sender {
    if ([self.delegate respondsToSelector:@selector(applyFilterStartTime:startTimeActivated:endTime:endTimeActivated:duration:)]) {
        [self.delegate applyFilterStartTime:self.clockView.startTime startTimeActivated:self.clockView.isStartTimeActive endTime:self.clockView.endTime endTimeActivated:self.clockView.isEndTimeActive duration:self.timeLengthSlider.value];
    }
    [self navigateBack:nil];
}

#pragma mark - HSSYClockViewDelegate
- (void)clockChangedStartTime:(ClockTime)startTime endTime:(ClockTime)endTime {
    [self updateTimeLengthSliderValue:self.timeLengthSlider.value];
}

#pragma mark - Extension
- (void)configButton:(UIButton *)button {
    [button setTitleColor:[UIColor timeFilterTintColor] forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor timeFilterTintColor].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 2;
}

- (void)updateTimeLengthSliderValue:(float)value {
    if (self.clockView.isEndTimeActive) {
        self.minTimeLength = 0.5;
        self.maxTimeLength = [self.clockView hoursBetweenStartTimeAndEndTime];
    } else {
        self.minTimeLength = 0;
        self.maxTimeLength = 10;
    }
    
    self.timeLengthSlider.value = MIN(MAX(self.minTimeLength, value), self.maxTimeLength);
    
    if (self.timeLengthSlider.value > 0) {
        if (!self.clockView.isStartTimeActive) {
            self.clockView.isStartTimeActive = YES;
        }
    }
    
    NSInteger minutes = self.timeLengthSlider.value * 60;
    ClockTime timeLength = clockTimeFromMinutes(minutes);
    if (timeLength.minute == 0) {
        self.timeLengthLabel.text = [NSString stringWithFormat:@"%d h", (int)timeLength.hour];
    } else {
        self.timeLengthLabel.text = [NSString stringWithFormat:@"%d h %d m", (int)timeLength.hour, (int)timeLength.minute];
    }
}

- (void)updateWithStartTime:(NSDateComponents *)startTimeComponent endTime:(NSDateComponents *)endTimeComponent duration:(NSNumber *)duration day:(NSDateComponents *)dayComponent {
    if (startTimeComponent) {
        self.clockView.isStartTimeActive = YES;
        ClockTime startTime = clockTimeMake(startTimeComponent.hour, startTimeComponent.minute);
        [self.clockView updateStartTime:startTime endTime:startTime];
        
        if (endTimeComponent) {
            self.clockView.isEndTimeActive = YES;
            ClockTime endTime = clockTimeMake(endTimeComponent.hour, endTimeComponent.minute);
            [self.clockView updateStartTime:startTime endTime:endTime];
        }
    } else {
        [self reset:nil];
    }
    
    if (dayComponent) {
        self.clockView.dateLabel.text = [NSString stringWithFormat:@"%02d月%02d日", (int)dayComponent.month, (int)dayComponent.day];
    } else {
        self.clockView.dateLabel.text = nil;
    }
    self.clockView.dateLabel.hidden = YES; // blade: hide it
    
    if (duration) {
        [self updateTimeLengthSliderValue:[duration floatValue]];
    } else {
        [self updateTimeLengthSliderValue:0];
    }
}

@end

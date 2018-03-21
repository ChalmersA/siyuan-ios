//
//  HSSYSetTimeView.m
//  Charging
//
//  Created by Ben on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCSetTimeView.h"
#import "NSDateFormatter+HSSYCategory.h"

@implementation DCSetTimeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 4;
}

- (void)awakeFromNib {
    self.titleView.backgroundColor = [UIColor paletteDCMainColor];
    [self.confirmButton setTitleColor:[UIColor paletteDCMainColor] forState:UIControlStateNormal];
    
    [self setDatePickDate:[NSDate date]];
}

#pragma mark - Action
-(void)cancelSetting:(id)sender{
    [self.delegate finishSettingTime:NO time:nil];
}

-(void)confirmSetting:(id)sender{
    NSDate *date = [self.datePicker date];

    //以下处理当datepicker获取的minute不是30的倍数就处理一下14舍15入
    if (self.datePicker.minuteInterval == 30) {
        long remainder = [[[[NSDateFormatter authDateTimeFormatter] stringFromDate:date] substringWithRange:NSMakeRange(14, 2)] integerValue] % 30;
        NSString *subString = [[[NSDateFormatter authDateTimeFormatter] stringFromDate:date] substringToIndex:14];
        
        if (remainder >= 15) {
            date = [[NSDateFormatter authDateTimeFormatter] dateFromString:[NSString stringWithFormat:@"%@30:00",subString]];
        }else if (remainder > 0 && remainder <15){
            date = [[NSDateFormatter authDateTimeFormatter] dateFromString:[NSString stringWithFormat:@"%@00:00",subString]];
        }
    }
    [self.delegate finishSettingTime:YES time:date];
}

- (IBAction)close:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeButtonClicked:)]) {
        [self.delegate closeButtonClicked:self];
    }
}

-(void)setDateOfPickerWithTimeStamp:(unsigned long) timeStamp {
    self.confirmButton.titleLabel.textColor = [UIColor paletteDCMainColor];
    NSDate* nowDate;
    if (timeStamp > 0) {
        [self.cancelButton setTitle:@"取消定时" forState:UIControlStateNormal];
        nowDate = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    }
    else {
        nowDate = [NSDate date];
    }
    [self setDatePickDate:nowDate];
}

#pragma mark - Utilies
- (void)setDatePickDate:(NSDate*)date {
    if (!date) {
        return;
    }
    // remove seconds
    NSTimeInterval time = floor([date timeIntervalSince1970] / 60.0) * 60.0;
    date = [NSDate dateWithTimeIntervalSince1970:time];
    
    // set pick's Date
    self.datePicker.date = date;
}
@end

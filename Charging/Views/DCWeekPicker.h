//
//  HSSYWeekPicker.h
//  Charging
//
//  Created by Ben on 15/1/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DCWeekButton.h"

@interface DCWeekPicker : UIView<WeekButtonDelegate>
@property (weak,nonatomic) IBOutlet DCWeekButton *mondayBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *tuesdayBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *wednesBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *thursdayBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *fridaydayBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *saturdayBtn;
@property (weak,nonatomic) IBOutlet DCWeekButton *sundayBtn;

@property (weak,nonatomic) IBOutlet UIView *line1;
@property (weak,nonatomic) IBOutlet UIView *line2;
@property (weak,nonatomic) IBOutlet UIView *line3;
@property (weak,nonatomic) IBOutlet UIView *line4;
@property (weak,nonatomic) IBOutlet UIView *line5;
@property (weak,nonatomic) IBOutlet UIView *line6;

-(NSString *)getWeekResult;
-(void)setButtonSelectedWithWeek:(NSString *)weekString;
@end

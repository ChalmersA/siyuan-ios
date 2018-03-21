//
//  HSSYWeekPicker.m
//  Charging
//
//  Created by Ben on 15/1/14.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCWeekPicker.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HSSYColor.h"

@implementation DCWeekPicker

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBorder];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setBorder];
    }
    return self;
}

- (void)awakeFromNib {
    [self commonInit:self];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[DCWeekButton class]]) {
            DCWeekButton *button = (DCWeekButton *)view;
            button.delegate = self;
            button.selected = NO;
            [button setTitleColor:[UIColor paletteDCMainColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(setButtonSelected:) forControlEvents:UIControlEventTouchDown];
        }
    }
}

#pragma mark 设置边框
- (void)setBorder {
    self.layer.borderWidth = 1;
    self.layer.borderColor = [[UIColor paletteDCMainColor] CGColor];
}

#pragma mark 获取最后的结果
- (NSString *)getWeekResult {
    NSMutableArray *weekArray = [NSMutableArray array];
    if (self.sundayBtn.isSelected) {
        [weekArray addObject:@"1"];
    }
    if (self.mondayBtn.isSelected) {
        [weekArray addObject:@"2"];
    }
    if (self.tuesdayBtn.isSelected) {
        [weekArray addObject:@"3"];
    }
    if (self.wednesBtn.isSelected) {
        [weekArray addObject:@"4"];
    }
    if (self.thursdayBtn.isSelected) {
        [weekArray addObject:@"5"];
    }
    if (self.fridaydayBtn.isSelected) {
        [weekArray addObject:@"6"];
    }
    if (self.saturdayBtn.isSelected) {
        [weekArray addObject:@"7"];
    }
    return [weekArray componentsJoinedByString:@","];
}

- (void)setButtonSelectedWithWeek:(NSString *)weekString {
    if ([weekString rangeOfString:@"1"].location != NSNotFound) {
        [self.sundayBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"2"].location != NSNotFound) {
        [self.mondayBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"3"].location != NSNotFound) {
        [self.tuesdayBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"4"].location != NSNotFound) {
        [self.wednesBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"5"].location != NSNotFound) {
        [self.thursdayBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"6"].location != NSNotFound) {
        [self.fridaydayBtn setSelected:YES];
    }
    if ([weekString rangeOfString:@"7"].location != NSNotFound) {
        [self.saturdayBtn setSelected:YES];
    }
}

#pragma mark 点击按钮
- (void)setButtonSelected:(DCWeekButton *)sender {
    NSArray *buttons = @[self.sundayBtn, self.mondayBtn, self.tuesdayBtn, self.wednesBtn, self.thursdayBtn, self.fridaydayBtn, self.saturdayBtn];
    sender.selected = !sender.selected;
    for (DCWeekButton *button in buttons) {
        if (button.selected) {
            return;
        }
    }
    sender.selected = !sender.selected;
}

#pragma mark 设置圆角
- (void)commonInit:(UIView *)view{
    view.layer.masksToBounds = YES;
    view.layer.cornerRadius = 4;
}

#pragma mark 回调设置边线颜色
- (void)weekButtonSelectedChange {
    NSArray *buttons = @[self.sundayBtn, self.mondayBtn, self.tuesdayBtn, self.wednesBtn, self.thursdayBtn, self.fridaydayBtn, self.saturdayBtn];
    NSArray *lines = @[self.line1, self.line2, self.line3, self.line4, self.line5, self.line6];
    
    for (UIView *line in lines) {
        NSInteger index = [lines indexOfObject:line];
        UIButton *leftButton = buttons[index];
        UIButton *rightButton = buttons[index+1];
        BOOL between = leftButton.isSelected && rightButton.isSelected;
        line.backgroundColor = between?[UIColor whiteColor]:[UIColor paletteDCMainColor];
    }
}
@end

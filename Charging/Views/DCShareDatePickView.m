//
//  HSSYShareDatePickViewController.m
//  CollectionViewTest
//
//  Created by  Blade on 5/4/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCShareDatePickView.h"
#import "UIImage+HSSYCategory.h"
#import "UIColor+HSSYColor.h"
#import "NSDate+HSSYDate.h"
#import "DCShareDate.h"


@interface DCShareDatePickView ()
@property (retain, nonatomic) NSDate *dateOfBegin;
@property (retain, nonatomic) NSArray *arrShareDates;
@end

@implementation DCShareDatePickView
- (void)awakeFromNib {
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* btn = (UIButton*)view;
            [btn setSelected:NO];
            [btn addTarget:self action:@selector(setButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
            [btn.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            // normal
            [btn setTitleColor:[UIColor paletteDCMainColor] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            
            // selected
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setBackgroundImage:[UIImage imageWithColor:[UIColor paletteDCMainColor]] forState:UIControlStateSelected];
            
            // disable
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
            [btn setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0xd7d7d7)] forState:UIControlStateDisabled];
            
            
            //MARK: TEST CODE
//            [btn setTitle:@"今天\n4/12" forState:UIControlStateNormal];
            [btn.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
//            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
//            btn.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//            btn.titleLabel.minimumScaleFactor=0.1;
        }
    }
    
    
    
    // lines
    self.arrLines = @[self.line_1, self.line_2, self.line_3, self.line_4, self.line_5, self.line_6];
    self.arrBtns = @[self.btn_0, self.btn_1, self.btn_2, self.btn_3, self.btn_4, self.btn_5, self.btn_6];
    for (UIView * aline in self.arrLines) {
        aline.backgroundColor = [UIColor mainthemeColor];
    }
}

- (NSInteger) setUpPickWithShareDates:(NSArray*)shareDates andBeginDate:(NSDate*)beginDate {
    self.dateOfBegin = beginDate;
    self.arrShareDates = shareDates;
    
    NSInteger selecedTag = -1;
    
    
    NSDateFormatter *ft = [[NSDateFormatter alloc] init];
    ft.timeZone = [NSTimeZone localTimeZone];
    ft.shortStandaloneWeekdaySymbols = @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"];

    // TODO: reset date buttons
    for (int i=0; i<[self.arrBtns count]; i++) {
        UIButton * button = [self.arrBtns objectAtIndex:i];
        [button setEnabled:NO];
        [button setSelected:NO];
        button.tag = -1;
//        if (0 == i) {
//            ft.dateFormat = @"今天\nMM/dd";
//        }
//        else {
//            ft.dateFormat = @"ccc\nMM/dd";
//        }
//        [button setTitle:[ft stringFromDate:[self.dateOfBegin dateByAddingCompoent:kCFCalendarUnitDay withCount:i]] forState:UIControlStateNormal];
        
//        if (0 == i) {
//            ft.dateFormat = @"今天";
//        }
//        else {
//            ft.dateFormat = @"c";
//        }
        
        ft.dateFormat = @"ccc";
        NSString* weekString = [ft stringFromDate:[self.dateOfBegin dateByAddingCompoent:kCFCalendarUnitDay withCount:i]];
        ft.dateFormat = @"M/d";
        NSString* dateString = [ft stringFromDate:[self.dateOfBegin dateByAddingCompoent:kCFCalendarUnitDay withCount:i]];

        [self setDateButton:button weekString:weekString dateString:dateString];
    }
    
    
    for (DCShareDate *aShareDate in self.arrShareDates) {
        NSInteger dayGap = [NSDate daysBetweenDate:self.dateOfBegin andDate:aShareDate.dateOfShare];
        if (dayGap >= 0 && [self.arrBtns count] > dayGap) {
            UIButton* btn = self.arrBtns[dayGap];
            if ([aShareDate canSelectThisDay]) {
                [btn setEnabled:YES];
                if (selecedTag > aShareDate.tag || selecedTag < 0) {
                    [btn setSelected:YES];
                    selecedTag = aShareDate.tag;
                }
            }
            btn.tag = aShareDate.tag;
        }
    }
    return selecedTag;
}

-(void)setDateButton:(UIButton*)button weekString:(NSString *)weekString dateString:(NSString*)dateString{
    
    static NSDictionary* btnStateColorDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // define colors
        UIColor *normalColor = [UIColor paletteFontDarkGrayColor];
        UIColor *hightLightColor = [UIColor whiteColor];
        UIColor *disableColor = [UIColor whiteColor];
        btnStateColorDic = @{@(UIControlStateNormal):normalColor
                             ,@(UIControlStateSelected):hightLightColor
                             , @(UIControlStateDisabled):disableColor};
    });

    // define font
    UIFont *weekFont = [UIFont fontWithName:@"HelveticaNeue" size:19];
    UIFont *dateFont = [UIFont fontWithName:@"HelveticaNeue" size:14];
    // define attribute
    
    
    NSMutableArray *strArr = [NSMutableArray array];
    NSMutableArray *attriArr = [NSMutableArray array];
    NSNumber *key;
    UIColor *color;
    NSEnumerator *enumerator = [btnStateColorDic keyEnumerator];
    while ((key = [enumerator nextObject])) {
        [strArr removeAllObjects];
        [attriArr removeAllObjects];
        color = btnStateColorDic[key];
        
        [strArr addObject:weekString];
        [attriArr addObject:@{NSForegroundColorAttributeName:color, NSFontAttributeName:weekFont}];
        
        [strArr addObject:@"\n"];
        [attriArr addObject:@{NSForegroundColorAttributeName:color, NSFontAttributeName:dateFont}];
        
        [strArr addObject:dateString];
        [attriArr addObject:@{NSForegroundColorAttributeName:color, NSFontAttributeName:dateFont}];
        
        [self joidStrings:strArr withAttributes:attriArr toButton:button forState:[key intValue]];
    }
}

- (void)joidStrings:(NSArray*)strArr withAttributes:(NSArray*)attrArr toButton:(UIButton*)targetButton forState:(UIControlState)state{
    if ([strArr count] != [attrArr count]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i< strArr.count; i++) {
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strArr[i] attributes:attrArr[i]];
        [attributedText appendAttributedString:attrStr];
    }
    
    if ([targetButton respondsToSelector:@selector(setAttributedTitle:forState:)]) {
        [targetButton setAttributedTitle:attributedText forState:state];
    }
    else {
        [targetButton setTitle:attributedText.string forState:state];
    }
}




#pragma mark 点击按钮
- (void)setButtonSelected:(id)sender{
    UIButton *selectedBtn = (UIButton*)sender;
    if (selectedBtn.tag < 0 || selectedBtn.isSelected) { // 不可选的
        return;
    }
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]] ) {
            UIButton* btn = (UIButton*)view;
            BOOL isSelected = NO;
            if ([btn isEqual:sender]) {
                isSelected = YES;
            }
            [btn setSelected:isSelected];
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedItemWithTag:)]) {
        [self.delegate didSelectedItemWithTag:selectedBtn.tag];
    }
}

@end

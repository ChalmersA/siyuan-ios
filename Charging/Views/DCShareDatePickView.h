//
//  HSSYShareDatePickViewController.h
//  CollectionViewTest
//
//  Created by  Blade on 5/4/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HSSYShareDatePickViewDelegate <NSObject>

- (void) didSelectedItemWithTag:(NSInteger) index;

@end

@interface DCShareDatePickView : UIView
@property (weak, nonatomic) id <HSSYShareDatePickViewDelegate> delegate;
@property (retain, nonatomic) NSArray* arrBtns;
@property (retain, nonatomic) NSArray* arrLines;

@property (weak, nonatomic) IBOutlet UIView *line_1;
@property (weak, nonatomic) IBOutlet UIView *line_2;
@property (weak, nonatomic) IBOutlet UIView *line_3;
@property (weak, nonatomic) IBOutlet UIView *line_4;
@property (weak, nonatomic) IBOutlet UIView *line_5;
@property (weak, nonatomic) IBOutlet UIView *line_6;

@property (weak, nonatomic) IBOutlet UIButton *btn_0;
@property (weak, nonatomic) IBOutlet UIButton *btn_1;
@property (weak, nonatomic) IBOutlet UIButton *btn_2;
@property (weak, nonatomic) IBOutlet UIButton *btn_3;
@property (weak, nonatomic) IBOutlet UIButton *btn_4;
@property (weak, nonatomic) IBOutlet UIButton *btn_5;
@property (weak, nonatomic) IBOutlet UIButton *btn_6;

- (NSInteger) setUpPickWithShareDates:(NSArray*)shareDates andBeginDate:(NSDate*)beginDate;

@end

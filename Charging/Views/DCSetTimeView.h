//
//  HSSYSetTimeView.h
//  Charging
//
//  Created by Ben on 14/12/20.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

@protocol HSSYSetTimeDelegate;

@interface DCSetTimeView : UIView
@property (weak, nonatomic) id <HSSYSetTimeDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, assign) unsigned long secondsFrom1970;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

-(IBAction)cancelSetting:(id)sender;
-(IBAction)confirmSetting:(id)sender;
-(void)setDateOfPickerWithTimeStamp:(unsigned long) timeStamp;
@end

@protocol HSSYSetTimeDelegate <NSObject>
-(void)finishSettingTime:(BOOL)hasSetTime time:(NSDate *)time;
@optional
- (void)closeButtonClicked:(DCSetTimeView *)view;
@end
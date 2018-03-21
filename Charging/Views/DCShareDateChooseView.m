//
//  HSSYShareDateChooseView.m
//  CollectionViewTest
//
//  Created by  Blade on 4/23/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCShareDateChooseView.h"
#import "UIColor+HSSYColor.h"
#import "UIImage+HSSYCategory.h"
#import "NSDate+HSSYDate.h"

@implementation DCShareDateChooseView
- (void)initView {
    
    DCShareDatePickView *shareDatePicker  =  [[NSBundle mainBundle] loadNibNamed:@"HSSYShareDatePickViewController" owner:nil options:nil][0];
    shareDatePicker.delegate = self;
    shareDatePicker.translatesAutoresizingMaskIntoConstraints = NO;
    shareDatePicker.layer.masksToBounds = YES;
    shareDatePicker.layer.cornerRadius = 4;
    shareDatePicker.layer.borderColor = [UIColor paletteDCMainColor].CGColor;
    shareDatePicker.layer.borderWidth = 1;
    [self addSubview:shareDatePicker];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:shareDatePicker
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0f
                                                                          constant:10.f];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:shareDatePicker
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:-10.f];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:shareDatePicker
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0f
                                                                           constant:-10.f];
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:shareDatePicker
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:self
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:10.f];
    [self addConstraints:@[leadingConstraint, bottomConstraint, trailingConstraint, topConstraint]];
    self.shareDatePickView = shareDatePicker;
    [self setUpDateChooseViewWithShareDates:@[] andBeginDate:[NSDate date]];
}


-(NSInteger)setUpDateChooseViewWithShareDates:(NSArray*)shareDates andBeginDate:(NSDate*) beginDate{
    return [self.shareDatePickView setUpPickWithShareDates:shareDates andBeginDate:beginDate];
}

- (void) didSelectedItemWithTag:(NSInteger) index {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectShareDateWithTag:)]) {
        [self.delegate didSelectShareDateWithTag:index];
    }
}

@end

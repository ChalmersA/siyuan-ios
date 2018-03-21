//
//  HSSYPeriodSpliteCollectionViewCell.h
//  CollectionViewTest
//
//  Created by  Blade on 4/24/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCSharePeriod.h"

@interface DCPeriodSpliteCollectionViewCell : UICollectionViewCell
@property (nonatomic, retain) IBOutlet UILabel *labelSplitedPeriod;
@property (nonatomic, retain) IBOutlet UIImageView *imageIcon;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *leftBlockView;
@property (weak, nonatomic) IBOutlet UIView *rightBlockView;

@property (nonatomic, retain) UIColor* theme_color_selectedBackground;
@property (nonatomic, retain) UIColor* theme_color_unSelected_label;
@property (nonatomic, retain) UIColor* theme_color_selected_label;
@property (nonatomic, retain) UIColor* theme_color_diable_label;

@property (nonatomic, retain) DCSharePeriod* sharePeriod;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL enabled;


- (void)setupPeriodStr:(NSString*) periodStr;
- (void)setupPeriod:(DCSharePeriod*) sharePeriod withIndex:(NSInteger) index;
- (NSArray*)datesForBooking ;
@end

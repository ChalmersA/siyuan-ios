//
//  HSSYSelectCityViewController.h
//  Charging
//
//  Created by xpg on 14/12/23.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "DCCitySelection.h"

@class City;

@protocol SelectCityDelegate <NSObject>
- (void)selectedCity:(City *)city;
@end

@interface DCSelectCityViewController : DCViewController <SelectCityDelegate>
@property (weak, nonatomic) id <SelectCityDelegate> delegate;
@property (nonatomic) DCCitySelection *citySelection;
- (void)selectedCity:(City *)city;
@end

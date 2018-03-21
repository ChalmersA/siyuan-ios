//
//  HSSYCitySelection.h
//  Charging
//
//  Created by xpg on 14/12/29.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface DCCitySelection : NSObject <NSCoding>
@property (nonatomic) NSArray *cities; // [City]
@property (nonatomic) NSDictionary *cityDict; // [String : City]
@property (nonatomic) NSArray *cityDictKeys; // [String]
@property (nonatomic) NSArray *popularCities; // [City]
@property (nonatomic) City *locationCity;

@property (nonatomic, readonly) BOOL isCityDictLoaded;

+ (instancetype)defaultSelection;
- (void)initCitySelectionCompletion:(dispatch_block_t)completion;
@end

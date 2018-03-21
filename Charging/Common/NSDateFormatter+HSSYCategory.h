//
//  NSDateFormatter+HSSYCategory.h
//  Charging
//
//  Created by xpg on 15/1/12.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (HSSYCategory)
+ (instancetype)authDateFormatter;
+ (instancetype)authDateTimeFormatter;
+ (instancetype)reserveStartTimeFormatter;
+ (instancetype)reserveEndTimeFormatter;
+ (instancetype)mapFilterDateFormatter;
+ (instancetype)pileEvaluateDateFormatter;
+ (instancetype)circleArticleDateFormatter;
+ (instancetype)minuteDateFormatter;
@end

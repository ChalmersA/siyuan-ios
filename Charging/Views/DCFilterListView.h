//
//  HSSYFilterListView.h
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DCFilterType) {
    DCFilterTypeDistance,
    DCFilterTypeSort,
    DCFilterTypeOther,
};

@interface DCFilterListView : UIView
@property (assign, nonatomic) DCFilterType filterType;
@property (copy, nonatomic) void (^didSelectFilter)(DCFilterType type, NSIndexPath *index, NSString *text);
- (NSInteger)selectedIndex;
- (void)setSelectedIndex:(NSInteger)index;
@end

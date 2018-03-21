//
//  HSSYMenuItem.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCMenuCell.h"

@interface DCMenuItem : NSObject
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *text;
@property (nonatomic) NSInteger badgeNumber;
+ (NSArray *)loadMenuItems;
@end

@interface DCMenuCell (HSSYMenuItem)
- (void)configureForItem:(DCMenuItem *)item;
@end

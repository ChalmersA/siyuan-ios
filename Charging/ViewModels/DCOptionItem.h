//
//  HSSYOptionItem.h
//  Charging
//
//  Created by xpg on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCModel.h"
#import "DCOptionCell.h"

@interface DCOptionItem : DCModel
@property (copy, nonatomic) NSString *text;
@property (copy, nonatomic) NSString *describe_text;
@property (copy, nonatomic) NSString *imageName;
@property (assign, nonatomic) BOOL chosen;
@end

@interface DCOptionList : DCModel
@property (strong, nonatomic) NSArray *items;//HSSYOptionItem
+ (instancetype)listWithItems:(NSArray *)items;
+ (instancetype)loadPaySelection;
- (void)singleChooseIndex:(NSInteger)index;
- (void)singleChooseNo;
- (DCOptionItem*)chosenItem;
- (NSInteger)chosenIndex;
@end

@interface DCOptionCell (DCOptionItem)
- (void)configureForItem:(DCOptionItem *)item;
- (void)configureForPayItem:(DCOptionItem *)item;
@end

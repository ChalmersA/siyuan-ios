//
//  ArrayDataSource.h
//  Charging
//
//  Created by xpg on 14/12/16.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CellConfigureBlock)(id cell, id item);
typedef NSString *(^CellIdentifierBlock)(id item);

//__attribute__((deprecated("")))
@interface ArrayDataSource : NSObject <UITableViewDataSource>
@property (copy, nonatomic) NSArray *items;
+ (instancetype)dataSourceWithItems:(NSArray *)items
                     cellIdentifier:(NSString *)cellIdentifier
                 configureCellBlock:(CellConfigureBlock)configureCellBlock;
+ (instancetype)dataSourceWithItems:(NSArray *)items
                cellIdentifierBlock:(CellIdentifierBlock)cellIdentifierBlock
                 configureCellBlock:(CellConfigureBlock)configureCellBlock;
@end

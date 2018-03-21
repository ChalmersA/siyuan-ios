//
//  ArrayDataSource.m
//  Charging
//
//  Created by xpg on 14/12/16.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()
@property (copy, nonatomic) NSString *cellIdentifier;
@property (copy, nonatomic) CellIdentifierBlock cellIdentifierBlock;
@property (copy, nonatomic) CellConfigureBlock configureCellBlock;
@end

@implementation ArrayDataSource 

- (instancetype)initWithItems:(NSArray *)items
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(CellConfigureBlock)configureCellBlock {
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}

+ (instancetype)dataSourceWithItems:(NSArray *)items
                     cellIdentifier:(NSString *)cellIdentifier
                 configureCellBlock:(CellConfigureBlock)configureCellBlock {
    return [[self alloc] initWithItems:items cellIdentifier:cellIdentifier configureCellBlock:configureCellBlock];
}

- (instancetype)initWithItems:(NSArray *)items
          cellIdentifierBlock:(CellIdentifierBlock)cellIdentifierBlock
           configureCellBlock:(CellConfigureBlock)configureCellBlock {
    self = [super init];
    if (self) {
        self.items = items;
        self.cellIdentifierBlock = cellIdentifierBlock;
        self.configureCellBlock = configureCellBlock;
    }
    return self;
}

+ (instancetype)dataSourceWithItems:(NSArray *)items
                cellIdentifierBlock:(CellIdentifierBlock)cellIdentifierBlock
                 configureCellBlock:(CellConfigureBlock)configureCellBlock {
    return [[self alloc] initWithItems:items cellIdentifierBlock:cellIdentifierBlock configureCellBlock:configureCellBlock];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.items[indexPath.row];
    UITableViewCell *cell = nil;
    if (self.cellIdentifierBlock) {
        NSString *cellIdentifier = self.cellIdentifierBlock(item);
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    }
    if (self.configureCellBlock) {
        self.configureCellBlock(cell, item);
    }
    return cell;
}

@end

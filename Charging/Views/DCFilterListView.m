//
//  DCFilterListView.m
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCFilterListView.h"
#import "DCOptionItem.h"
#import "DropListView.h"

static NSString * const DCFilterListCellIdentifier = @"DCOptionCell";

@interface DCFilterListView () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DCOptionList *optionList;
@end

@implementation DCFilterListView

- (void)awakeFromNib {
    [self.tableView registerNib:[UINib nibWithNibName:@"DCOptionCell" bundle:nil] forCellReuseIdentifier:DCFilterListCellIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 44;
}

- (CGSize)intrinsicContentSize {
    NSInteger i = 5;
    if (_filterType == DCFilterTypeSort) {
        i = 4;
    }
    return CGSizeMake(UIViewNoIntrinsicMetric, self.tableView.rowHeight * i);
}

- (void)setFilterType:(DCFilterType)filterType {
    _filterType = filterType;
    NSMutableArray *items = [NSMutableArray array];
    switch (filterType) {
        case DCFilterTypeDistance:
            for (NSString *title in @[@"不限", @"500m", @"1km", @"2km", @"5km"]) {
                DCOptionItem *item = [[DCOptionItem alloc] init];
                item.text = title;
                [items addObject:item];
            }
            break;
        case DCFilterTypeSort:
            for (NSString *title in @[@"不限", @"智能排序", @"距离优先", @"好评优先"]) {
                DCOptionItem *item = [[DCOptionItem alloc] init];
                item.text = title;
                [items addObject:item];
            }
            break;
        case DCFilterTypeOther:
//            for (NSString *title in @[@"全部", @"直流", @"交流", @"站点"]) {
//                DCOptionItem *item = [[DCOptionItem alloc] init];
//                item.text = title;
//                [items addObject:item];
//            }
            break;
            
        default:
            break;
    }
    self.optionList = [DCOptionList listWithItems:items];
    [self.tableView reloadData];
}

- (NSInteger)selectedIndex {
    return [self.optionList chosenIndex];
}

- (void)setSelectedIndex:(NSInteger)index {
    [self.optionList singleChooseIndex:index];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.optionList.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:DCFilterListCellIdentifier];
    
    DCOptionItem *item = self.optionList.items[indexPath.row];
    [cell configureForItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.optionList singleChooseIndex:indexPath.row];
    [tableView reloadData];
    if (self.didSelectFilter) {
        DCOptionItem *item = self.optionList.items[indexPath.row];
        self.didSelectFilter(self.filterType, indexPath, item.text);
        dispatch_async(dispatch_get_main_queue(), ^{
            //
            if ([self.superview isKindOfClass:[DropListView class]] && [(DropListView*)self.superview respondsToSelector:@selector(dismiss)]) {
                [(DropListView*)self.superview dismiss];
            }
        });
    }
}

@end

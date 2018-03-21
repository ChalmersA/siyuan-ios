//
//  HSSYListView.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCListView.h"

@interface DCListView ()

@end

@implementation DCListView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 8;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.topView.backgroundColor = [UIColor paletteDCMainColor];
}

#pragma mark - UIRefreshControl
- (void)addRefreshControl {
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    [control addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
}

- (void)refreshTable:(UIRefreshControl *)control {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [control endRefreshing];
    });
}

#pragma mark - Action
- (IBAction)dismissClick:(id)sender {
    [self.delegate listViewDismissClick];
}
@end

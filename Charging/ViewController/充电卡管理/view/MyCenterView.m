//
//  MyCenterView.m
//  SPAlertController
//
//  Created by Libo on 2017/11/5.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyCenterView.h"
#import "MyCenterCell.h"
#import "SearchRecordTool.h"

@interface MyCenterView() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MyCenterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
        [SearchRecordTool getAllRecords];

    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [SearchRecordTool getAllRecords].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCenterCell"];
    if (cell == nil) {
        cell = [[MyCenterCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MyCenterCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.cardLabel.text  = [SearchRecordTool getAllRecords][indexPath.row];
    cell.clickDeletedBtnBlock = ^{
        // 点击删除当前这条记录
        NSLog(@"=========删除第%ld行",(long)indexPath.row);
        [SearchRecordTool deleteRecord:[SearchRecordTool getAllRecords][indexPath.row]];
        [tableView reloadData];
        
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if (self.seletedRowBlock) {
        self.seletedRowBlock([SearchRecordTool getAllRecords][indexPath.row]);
    }
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}


@end

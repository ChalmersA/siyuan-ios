//
//  DevicesWindow.m
//  GuoBangCleaner
//
//  Created by Ben on 15/8/27.
//  Copyright (c) 2015年 com.xpg. All rights reserved.
//

#import "DevicesWindow.h"
#import "DevicesWindowTableViewCell.h"
#import "Charging-Swift.h"

@implementation DevicesWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame stations:(NSArray *)stations itemSelectBlock:(DevicesWindowSelctedBlcok)block {
    NSArray *views = [[NSBundle mainBundle]loadNibNamed:@"DevicesWindow" owner:self options:nil];
    self = [views firstObject];
    if (self) {
        self.stations = stations;
        self.frame = frame;
        self.backgroundImageView.userInteractionEnabled = YES;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self.tableView registerNib:[UINib nibWithNibName:@"DevicesWindowTableViewCell" bundle:nil] forCellReuseIdentifier:@"DevicesWindowTableViewCell"];
        [self setCornerRadius];
        self.backgroundColor = [UIColor clearColor];
        
        self.itemSelectedBlock = block;
    }
    return self;
}

- (DCStation *)selectStation:(DCStation *)station {
    if (self.stations && [self.stations containsObject:station]) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.stations indexOfObject:station] inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        return station;
    }
    return nil;
}

#pragma mark - tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DevicesWindowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DevicesWindowTableViewCell" forIndexPath:indexPath];
    [cell updateViewWithStation:[self.stations objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    id item = self.stations[indexPath.row];
    if (item && self.itemSelectedBlock) {
        self.itemSelectedBlock(item);
    }
    if ([self.delegate respondsToSelector:@selector(devicesWindow:selectedStation:)]) {
        [self.delegate devicesWindow:self selectedStation:[self.stations objectAtIndex:indexPath.row]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.stations.count;
}
@end

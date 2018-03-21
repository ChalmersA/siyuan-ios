//
//  DCDetailTableView.m
//  Charging
//
//  Created by Pp on 15/10/12.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import "DCDetailTableView.h"
#import "DCDetailTableViewHeader.h"
#import "DCPileDetailTableViewCell.h"
#import "DCSiteApi.h"
//#import "DCStationPile.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCPile.h"
#import "DCChargePort.h"

@interface DCDetailTableView()<UITableViewDelegate, UITableViewDataSource, DCDetailTableViewHeaderDelegate>
{
    CGFloat addHeigt;        // 被占用的桩的tableViewCell多出来的高度
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSLayoutConstraint *tableHeight;       // tableview 的高度
@property (nonatomic, assign) CGFloat headerHeight;                  // tableView header 的高度
@property (nonatomic, strong) UITableView *detailTableView;
@property (nonatomic, assign) BOOL tableViewOpen;

@property (assign, nonatomic) NSInteger dcGunIdleNum;     //直流桩空闲数量
@property (assign, nonatomic) NSInteger dcGunBookableNum; //直流桩可预约数量
@property (assign, nonatomic) NSInteger acGunIdleNum;     //交流桩空闲数量
@property (assign, nonatomic) NSInteger acGunBookableNum; //交流桩可预约数量

@property (strong, nonatomic) DCPile *pile;

@property (strong, nonatomic) NSMutableArray *pileArray;
@property (strong, nonatomic) NSMutableArray *chargePortArray;
@property (strong, nonatomic) NSArray *chargePortViewArray;

@property (nonatomic) DCDetailTableViewHeader *myHeader;

@end

@implementation DCDetailTableView

- (void)createTableView:(UITableView *)table andHeight:(NSLayoutConstraint *)height dcGunIdleNum:(NSInteger)dcGunIdleNum dcGunBookableNum:(NSInteger)dcGunBookableNum acGunIdleNum:(NSInteger)acGunIdleNum acGunBookableNum:(NSInteger)acGunBookableNum stationId:(NSString *)stationId {    
    self.tableHeight = height;
    self.detailTableView = table;
    self.headerHeight = height.constant;
    
    self.detailTableView.dataSource = self;
    self.detailTableView.delegate = self;
    
    self.detailTableView.sectionHeaderHeight = self.headerHeight;
    self.tableViewOpen = NO;
    
    addHeigt = 20;
    
    self.dcGunIdleNum = dcGunIdleNum;
    self.dcGunBookableNum = dcGunBookableNum;
    self.acGunIdleNum = acGunIdleNum;
    self.acGunBookableNum = acGunBookableNum;
    
    self.stationId = stationId;
}

#pragma tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pileArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier1 = @"DCPileDetailTableViewCell";
    
    DCPile *pile = self.pileArray[indexPath.row];
    
    DCPileDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier1];
    if (cell == nil) {
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:identifier1 owner:nil options:nil];
        cell = [nibContents lastObject];
    }
    cell.name.text = pile.pileName;
    cell.type.text = (pile.pileType == DCPileTypeAC) ? @"(交流桩)" : @"(直流桩)";
    cell.offLineView.hidden = NO;
    
    self.chargePortArray = [NSMutableArray array];
    for (NSDictionary *dict in pile.chargePort) {
        DCChargePort *chargePort = [[DCChargePort alloc] initChargePortWithDictionary:dict];
        [self.chargePortArray addObject:chargePort];
    }
    
    //根据self.chargePortArray根据index排序后得到sortedArray
    NSSortDescriptor *indexDescriptou = [[NSSortDescriptor alloc] initWithKey:@"index" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:indexDescriptou];
    NSArray *sortedArray = [self.chargePortArray sortedArrayUsingDescriptors:sortDescriptors];
    
    self.chargePortViewArray = @[cell.cpView4, cell.cpView3, cell.cpView2, cell.cpView1];
    for (int i = 0; i < self.chargePortArray.count; i++) {
        UIView *view = [self.chargePortViewArray objectAtIndex:i];
        view.hidden = NO;
        [cell cellWithChargePort:sortedArray];
        cell.offLineView.hidden = YES;
    }
    return cell;
}

#pragma tableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:@"DCDetailTableViewHeader" owner:nil options:nil];
    self.myHeader = [nibContents lastObject];
    self.myHeader.myDelegate = self;
    
    if (self.tableViewOpen) {
        self.myHeader.arrow.transform = CGAffineTransformMakeRotation(M_PI);
    }
    else {
        self.myHeader.arrow.transform = CGAffineTransformMakeRotation(0);
    }
    
    self.myHeader.dcNumLabel.text = [self numWithSpare:_dcGunIdleNum andBook:_dcGunBookableNum];
    self.myHeader.acNumLabel.text = [self numWithSpare:_acGunIdleNum andBook:_acGunBookableNum];
    self.myHeader.arrow.hidden = self.headerArrowHidden;
    return self.myHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.headerHeight;
}

#pragma touchTableViewHeader
- (void)touchedHeader
{
    if (self.tableViewOpen) {
        [self reloadMyTableView];
    }
    else{
        UIView *view = self.detailTableView.superview;
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    // 点一下详情按钮 重新加载接口
        [DCSiteApi getPileList:self.stationId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            [hud hide:YES];
            if (![webResponse isSuccess]) {
            }
            else{
                self.pileArray = [NSMutableArray array];
                NSDictionary *resultDict = webResponse.result;
                
                self.dcGunIdleNum = [[resultDict objectForKey:@"dcGunIdleNum"] integerValue];
                self.dcGunBookableNum = [[resultDict objectForKey:@"dcGunBookableNum"] integerValue];
                self.acGunIdleNum = [[resultDict objectForKey:@"acGunIdleNum"] integerValue];
                self.acGunBookableNum = [[resultDict objectForKey:@"acGunBookableNum"] integerValue];
                
                self.myHeader.dcNumLabel.text = [self numWithSpare:_dcGunIdleNum andBook:_dcGunBookableNum];
                self.myHeader.acNumLabel.text = [self numWithSpare:_acGunIdleNum andBook:_acGunBookableNum];
                
                NSArray *array = [resultDict objectForKey:@"piles"];
                for (NSDictionary *dict in array) {
                    DCPile *pile = [[DCPile alloc] initPileWithDict:dict];
                    [self.pileArray addObject:pile];
                }
                
                [self reloadMyTableView];
            }
        }];
    }
}

- (void)reloadMyTableView
{
    // cell的总高度cellHeight
    CGFloat cellHeight = 0;
    
    for (int i = 0; i < self.pileArray.count; i++) {
        cellHeight += self.headerHeight;
    }
    
    self.tableViewOpen = !self.tableViewOpen;
    if (self.tableViewOpen) {
        self.tableHeight.constant = self.headerHeight + cellHeight;
        [self.detailTableView.superview layoutIfNeeded];
    }
    else{
        self.tableHeight.constant = self.headerHeight;
        [self.detailTableView.superview layoutIfNeeded];
    }
    [self.detailTableView reloadData];
}

#pragma mark - headerArrowHidden
- (void)setHeaderArrowHidden:(BOOL)headerArrowHidden {
    _headerArrowHidden = headerArrowHidden;
    self.myHeader.arrow.hidden = headerArrowHidden;
    if (headerArrowHidden) { // close table view body
        self.tableViewOpen = YES;
        [self reloadMyTableView];
    }
}

#pragma mark - extend
- (NSString *)numWithSpare:(NSInteger)spare andBook:(NSInteger)book {
    return [NSString stringWithFormat:@"空闲%ld/可预约%ld", spare, book];
}

@end

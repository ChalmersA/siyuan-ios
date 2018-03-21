//
// DCDynamicListViewController.m
//  Charging
//
//  Created by xpg on 15/9/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCDynamicListViewController.h"
#import "DCDynamicListTableViewCell.h"
#import "DCDynamicDetailsViewController.h"
#import "DCDynamicAtlasTableViewCell.h"
#import "UIViewController+HSSYExtensions.h"
#import "DCDynamicDetailsList.h"


static NSString * const ListCell = @"DCDynamicListTableViewCell";
static NSString * const AtlasCell = @"DCDynamicAtlasTableViewCell";
NSString * const DCSegueIdPushToDynamicDetails = @"DynamicDetails";

@interface DCDynamicListViewController ()<UITableViewDataSource, UITableViewDelegate, HSSYDynamicAtlasTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) NSURLSessionDataTask *requestTask; //列表请求

@property (copy, nonatomic) NSArray *dynamicTop;
@property (strong, nonatomic) NSArray *dynamicList;

@property (copy, nonatomic) DCDynamicDetailsList *dynamicDetailsList;
@property (assign, nonatomic) NSInteger dynamicListLoadCount;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (assign, nonatomic) DynamicSourceType dynamicType;

@end

@implementation DCDynamicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    typeof(self) __weak weakSelf = self;
    // refresh header
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf fetchDynamicListWithStartCount:1];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.header = header;
    
    // refresh footer
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        [weakSelf fetchDynamicListWithStartCount:weakSelf.dynamicListLoadCount];
    }];
    [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
    [self.tableView.footer noticeNoMoreData];
    [header beginRefreshing]; //进来就下啦刷新动作
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone]; //隐藏分割线

}

- (void)fetchDynamicListWithStartCount:(NSUInteger)count{
    [self.requestTask cancel];

    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.requestTask = [DCSiteApi getNewsListWithNewType:DCNewTypeAll page:count pageSize:10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        //    获取动态列表
        if ([self.tableView.header isRefreshing]) {
            [self.tableView.header endRefreshing];
        }
        if ([self.tableView.footer isRefreshing]) {
            [self.tableView.footer endRefreshing];
        }
        if (![webResponse isSuccess]) {
            [self hideHUD:self.hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        NSArray *dynamicListArray = [webResponse.result arrayObject];
        NSMutableArray *tempArray = [NSMutableArray array];
        NSMutableArray *isTopTempArray = [NSMutableArray array];
        for (id object in dynamicListArray) {
            if (![object isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
                continue;
            }
            
            NSDictionary *dict = [object dictionaryObject];
            DCDynamicDetailsList *dynamicDetails = [[DCDynamicDetailsList alloc] initWithDict:dict];
            
            if (dynamicDetails.isTop == YES) { //区分是否需要置顶的文章
                [isTopTempArray addObject:dynamicDetails];
                
                if (isTopTempArray.count > 5) { //做了限定五篇
                    [isTopTempArray removeLastObject];
                }
            }
            else {
                [tempArray addObject:dynamicDetails];
            }
        }
        
        if (!self.dynamicList) { //防止初始为空
            self.dynamicList = [NSArray array];
        }
        if (!self.dynamicTop) { //防止初始为空
            self.dynamicTop = [NSArray array];
        }
        
        if (count > 1 ) {
            self.dynamicList = [self.dynamicList arrayByAddingObjectsFromArray:tempArray]; // 多次加载的时候要添加
            
            if (tempArray.count < 10) {
                [self.tableView.footer noticeNoMoreData];
            } else {
                [self.tableView.footer resetNoMoreData];
                self.dynamicListLoadCount++;
            }
        }
        else if (count == 1) { // 第一次进来加载
            self.dynamicTop = isTopTempArray;
            self.dynamicList = tempArray;
            
            self.dynamicListLoadCount = 1;// 重新设置为第一页请求参数（初始请求状态）
            
            if (tempArray.count < 10) {
                [self.tableView.footer noticeNoMoreData];
            } else {
                [self.tableView.footer resetNoMoreData];
                self.dynamicListLoadCount++;
            }
        }
        
        
        [self.tableView reloadData];
        [self.hud hide:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

#pragma mark - UIStoryboardSegue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:DCSegueIdPushToDynamicDetails]) {
        DCDynamicDetailsViewController * vc = segue.destinationViewController;
        vc.url = sender;
        vc.soucrceType = self.dynamicType;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DCDynamicDetailsList * dynamicDetailsListData = self.dynamicList[indexPath.row];
    if ([dynamicDetailsListData.dynamicId isEqualToString:@""]) {
        [self showAlertView];
    }else{
        //站内
        self.dynamicType = dynamicDetailsListData.sourceType;
        
        if (dynamicDetailsListData.sourceType == DynamicSourceTypeIN) {
            [self performSegueWithIdentifier:DCSegueIdPushToDynamicDetails sender:dynamicDetailsListData.dynamicId];
        } else if (dynamicDetailsListData.sourceType == DynamicSourceTypeOUT) {
            [self performSegueWithIdentifier:DCSegueIdPushToDynamicDetails sender:dynamicDetailsListData.sourceUrl];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        return 200;
    }
    else{
        return 107;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return self.dynamicTop.count?1:0;
            break;
        case 1:
            return self.dynamicList.count;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        DCDynamicAtlasTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:AtlasCell forIndexPath:indexPath];
        cell.delegate = self;//设置代理
        [cell configureFordynamicTop:self.dynamicTop];
        cell.imageArray = self.dynamicTop;
        return cell;
    }
    else {
        DCDynamicListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ListCell forIndexPath:indexPath];
        DCDynamicDetailsList * dynamicDetailsListData = self.dynamicList[indexPath.row];

        [cell configureForDynamicDetailsList:dynamicDetailsListData];
        return cell;
    }
}

#pragma mark - HSSYDynamicAtlasTableViewCellDelegate
- (void)didClickImageView:(NSString *)string sourceType:(NSInteger)sourceType {
    if (!string) {
        [self showAlertView];
    }else{
        self.dynamicType = sourceType;
        [self performSegueWithIdentifier:DCSegueIdPushToDynamicDetails sender:string];
    }
}

-(void)showAlertView {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self hideHUD:self.hud withText:@"此篇文章连接已不存在"];
}
@end

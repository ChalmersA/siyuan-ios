//
//  DCFavoritesViewController.m
//  Charging
//
//  Created by xpg on 14/12/18.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCFavoritesViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCSiteApi.h"
#import "DCStation.h"
#import "DCSearchViewController.h"
#import "DCStationDetailViewController.h"
#import "DCPoleInMapViewController.h"
#import "DCFavoritesRequestObject.h"
#import "DCSearchPoleCell.h"

static int const LoadDataCount = 10; //每次加载的条目数
NSString * const DCSegueIdPushToStationDetail = @"PushToStationDetail";
NSString * const DCSegueIdPushToMapNavi = @"PushToMapNavi";

@interface DCFavoritesViewController () <UITableViewDataSource, UITableViewDelegate, HSSYSearchPoleCellDelegate>
@property (nonatomic) NSInteger startIndex;
@property (strong, nonatomic) NSMutableArray *stationArray;
@property (weak, nonatomic) NSURLSessionTask *requestFavoritesTask;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableEmptyView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomCons;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) NSMutableArray *deleteArray; //删除数据的数组

@property (nonatomic) BOOL editingMode;
@end

@implementation DCFavoritesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableViewBottomCons.constant = 0;
    
    self.stationArray = [NSMutableArray array];
    self.deleteArray = [NSMutableArray array];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DCSearchPoleCell" bundle:nil] forCellReuseIdentifier:@"DCSearchPoleCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    typeof(self) __weak weakSelf = self;
    
    // refresh header
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestFavoritesWithStartIndex:1];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    self.tableView.header = header;
    
    // refresh footer
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf requestFavoritesWithStartIndex:weakSelf.startIndex];
    }];
    [footer setTitle:@"没有更多" forState:MJRefreshStateNoMoreData];
    self.tableView.footer = footer;
    [self.tableView.footer noticeNoMoreData];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self requestFavoritesWithStartIndex:1];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.requestFavoritesTask cancel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Request
- (void)requestFavoritesWithStartIndex:(NSInteger)start {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    typeof(self) __weak weakSelf = self;
    self.requestFavoritesTask = [DCSiteApi getFavoritesStationList:[DCApp sharedApp].user.userId page:start pageSize:LoadDataCount completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        typeof(self) __strong strongSelf = weakSelf;
        
        if ([strongSelf.tableView.header isRefreshing]) {
            [strongSelf.tableView.header endRefreshing];
        }
        if ([strongSelf.tableView.footer isRefreshing]) {
            [strongSelf.tableView.footer endRefreshing];
        }
        
        if (![webResponse isSuccess]) {
            [strongSelf hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        if (start == 1) {
            [strongSelf.stationArray removeAllObjects];
            strongSelf.startIndex = start;
        }
        
        NSArray *stations = [webResponse.result arrayObject];;
        strongSelf.startIndex += 1;
        for (NSDictionary *dict in stations) {
            if (![dict isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
                continue;
            }
        DCStation *stationInfo = [[DCStation alloc] initStationWithDict:dict];
        [strongSelf.stationArray addObject:stationInfo];
        }
        [strongSelf.tableView reloadData];
        if (stations.count < LoadDataCount) {
            [strongSelf.tableView.footer noticeNoMoreData];
        } else {
            [strongSelf.tableView.footer resetNoMoreData];
        }
        [hud hide:YES];
        
        if (strongSelf.stationArray.count <= 0) {
            strongSelf.editButton.hidden = YES;
        }
    }];
    
    /**
     * TEST CODE
     */
//    for (int i = 0; i < 6; i++) {
//        DCStation *station = [[DCStation alloc] init];
//        [self.stationArray addObject:station];
//    }
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:DCSegueIdPushToStationDetail]) {
        DCStationDetailViewController *VC = segue.destinationViewController;
        VC.segueFromMyFavor = YES;
        VC.selectStationInfo = sender;
    } else if ([segue.identifier isEqualToString:DCSegueIdPushToMapNavi]) {
        DCPoleInMapViewController *vc = segue.destinationViewController;
        DCStation *station = sender;
        vc.coordinate = station.coordinate;
        vc.address = station.addr;
        vc.stationName = station.stationName;
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCSearchPoleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCSearchPoleCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCSearchPoleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCSearchPoleCell"];
    }
    cell.delegate = self;
    DCStation *station = self.stationArray[indexPath.row];
    [cell configureForStation:station withLocation:[DCApp sharedApp].centerLocation.coordinate];
    [cell updateEditingState:self.editingMode];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editingMode) {
        DCSearchPoleCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectImageView.image = [UIImage imageNamed:@"book_icon_select"];
        DCStation *staiton = [self.stationArray objectAtIndex:indexPath.row];
        if (![self.deleteArray containsObject:staiton.stationId]) {
            [self.deleteArray addObject:staiton.stationId];
        }
        NSLog(@"%ld", (long)indexPath.row);
    } else {
        DCStation *station = self.stationArray[indexPath.row];
        [self performSegueWithIdentifier:DCSegueIdPushToStationDetail sender:station];
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DCSearchPoleCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.selectImageView.image = [UIImage imageNamed:@"book_icon_unselect"];
    DCStation *staiton = [self.stationArray objectAtIndex:indexPath.row];
    if ([self.deleteArray containsObject:staiton.stationId]) {
        [self.deleteArray removeObject:staiton.stationId];
    }
    NSLog(@"%ld", (long)indexPath.row);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [DCSearchPoleCell cellHeightWithTableViewWidth:CGRectGetWidth(tableView.bounds)];
}

#pragma mark - HSSYSearchPoleCellDelegate
- (void)searchStationCellOrderAction:(DCStation *)station {
    [self performSegueWithIdentifier:DCSegueIdPushToStationDetail sender:station];
}

- (void)searchStationCellNavigationAction:(DCStation *)station {
    [self performSegueWithIdentifier:DCSegueIdPushToMapNavi sender:station];
}

- (IBAction)editButton:(id)sender {
    
    self.editingMode = !self.editingMode;
    
    for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
        [self tableView:self.tableView didDeselectRowAtIndexPath:indexPath];
    }

    [self.tableView reloadData];
}

- (void)setEditingMode:(BOOL)editingMode {
    _editingMode = editingMode;
    
    if (editingMode) {
        [self.editButton setTitle:@"取消" forState:UIControlStateNormal];
        self.deleteButton.hidden = NO;
        self.tableView.allowsMultipleSelection = YES;
        self.tableViewBottomCons.constant = 74;
    } else {
        [self.editButton setTitle:@"编辑" forState:UIControlStateNormal];
        self.deleteButton.hidden = YES;
        self.tableViewBottomCons.constant = 0;
        [self.deleteArray removeAllObjects];
    }
}

#pragma mark - Delete
- (IBAction)deleteCollectStation:(id)sender {
    if (!self.deleteArray || self.deleteArray.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        [self hideHUD:hud withText:@"没有选择任何桩群"];
        return;
    }
    NSString *userId = [DCApp sharedApp].user.userId;
    if (userId) {
        MBProgressHUD *hud = [self showHUDIndicator];
        
        [DCSiteApi postFavoritesStations:self.deleteArray userId:userId favorites:2 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                return;
            }
            [self hideHUD:hud withText:@"已取消收藏"];
            self.editingMode = NO;
            self.deleteButton.hidden = YES;
            self.tableViewBottomCons.constant = 0;
            [self requestFavoritesWithStartIndex:1];
        }];
    }
}

@end

//
//  DCUserViewController.m
//  Charging
//
//  Created by xpg on 14/12/16.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCUserViewController.h"
#import "DCUserInfoViewController.h"
#import "DCMenuItem.h"
#import "DCCommon.h"
#import "DCSiteApi.h"
#import "DCOrder.h"
#import "DCDatabaseOrder.h"
#import "UIButton+HSSYCategory.h"
#import "DCCommon.h"
#import "DCHTTPSessionManager.h"
#import "DCMessageListViewController.h"
#import "Charging-Swift.h"
#import "DCChargeCardViewController.h"
#import "DCPileSetLocationViewController.h"
#import "DCSettingViewController.h"
#import "DCWalletViewController.h"
#import "WCCardViewController.h"

typedef NS_ENUM(NSInteger, AlertViewType) {
    ServiceAlertView_Type,
    FeedBackAlertView_Type,
    VersionAlertView_Type,
};

const NSInteger DCMenuRowOrder        = 0;//我的订单
const NSInteger DCMenuRowWallet       = 1;//我的钱包
const NSInteger DCMenuRowChargeCard   = 2;//充点卡管理
const NSInteger DCMenuRowFavorites    = 3;//我的收藏
const NSInteger DCMenuRowEvaluations  = 4;//我的评价

const NSInteger DCMenuRowAddPile      = 0;//发现充电站

const NSInteger DCMenuRowHelp         = 0;//帮助与反馈
const NSInteger DCMenuRowSetting      = 1;//我的设置
const NSInteger DCMenuRowAbout        = 2;//关于易卫充

@interface DCUserViewController () <UITableViewDataSource, UITableViewDelegate, PopUpViewDelegate, MyOrderRefreshDelegate> {
    PopUpView *popUpView;
}
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UIButton *userNameButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@property (weak, nonatomic) JSBadgeView *messageBadgeView;

@property (strong, nonatomic) NSURLSessionDataTask *reserveOrderTask;
@property (strong, nonatomic) NSMutableArray *reservePoleOrderTasks;

@property NSURLSessionDataTask *fetchUnreadMessageTask;
@property NSDate *lastFetchUnreadMessageDate;
@end

@implementation DCUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor paletteDCMainColor];
    
    self.poleMessageDict = [NSMutableDictionary dictionary];
    self.reservePoleOrderTasks = [NSMutableArray array];
    
    self.menuItems = [DCMenuItem loadMenuItems];
    self.tableView.separatorColor = [UIColor colorWithWhite:239/255.0 alpha:1];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo) name:NOTIFICATION_USER_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMessageItem) name:NOTIFICATION_MESSAGE_UPDATE object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self updateUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)pushToViewController:(UIViewController *)vc {
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Action
- (IBAction)gotoUserInfo:(id)sender {
    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
    DCUserInfoViewController *userInfoVC = [DCUserInfoViewController storyboardInstantiate];
    [self pushToViewController:userInfoVC];
}

- (IBAction)gotoMessageList:(id)sender {
    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
    DCMessageListViewController *messageVC = [DCMessageListViewController storyboardInstantiate];
    [self.fetchUnreadMessageTask cancel];
    self.fetchUnreadMessageTask = nil;
    [self pushToViewController:messageVC];
}

- (IBAction)logoutCurrentUser:(id)sender {
    UIAlertView *logoutAlert = [UIAlertView showAlertMessage:@"您确定要注销当前账号吗？" buttonTitles:@[@"取消", @"确定"]];
    [logoutAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"正在注销...";
            
            [DCSiteApi postLogOut:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                [hud hide:YES];
                [DCApp sharedApp].user = nil;
                [DCDefault saveLoginedUser:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_DID_CHANGE object:nil];
                [self presentLoginViewIfNeededCompletion:^{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }];
            }];
        }
    }];
}

#pragma mark 刷新数据-（我的订单、电桩订单）
- (void)refreshData:(id)sender {
    [self stopRefreshOrders];
    if (![DCApp sharedApp].user) {
        return;
    }
    
    //我的订单
    self.reserveOrderTask = [DCSiteApi getOrderList:[DCApp sharedApp].user.userId status:nil startTime:nil endTime:nil page:1 pageSize:10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        NSDictionary *resultDic = webResponse.result;
        
        NSMutableArray *newOrders = [NSMutableArray array];
        NSArray *orders = [resultDic objectForKey:@"orders"];
        for (NSDictionary *orderDic in orders) {
            if (![orderDic isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
                continue;
            }
            DCOrder *order = [[DCOrder alloc] initWithDict:orderDic];
            [newOrders addObject:order];
            
        }
        
        for (DCOrder *order in newOrders) {
            DCDatabaseOrder *datebaseOrder = [DCDatabaseOrder ordersWithOrderId:order.orderId];
            if (!datebaseOrder || (datebaseOrder.orderState != order.orderState)) { //数据库没有, 或者其中有一个状态改变了
                //加红点
                //DCMenuItem *reservation = self.menuItems[HSSYMenuIndexReservation];
                //reservation.hasMessage = YES;
                [self.tableView reloadData];
                break;
            }
        }
    }];
    
//    self.reserveOrderTask = [DCSiteApi postOrderList:nil userid:[DCApp sharedApp].user.userId search:nil start:@(0) count:@(10) action:nil startOffset:nil endOffset:nil completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        NSDictionary *resultDic = webResponse.result;
//        
//        NSMutableArray *newOrders = [NSMutableArray array];
//        NSArray *orders = [resultDic objectForKey:@"orders"];
//        for (NSDictionary *orderDic in orders) {
//            if (![orderDic isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
//                continue;
//            }
//            DCOrder *order = [[DCOrder alloc] initWithDict:orderDic];
//            [newOrders addObject:order];
//            
//        }
//        
//        for (DCOrder *order in newOrders) {
//            DCDatabaseOrder *datebaseOrder = [DCDatabaseOrder ordersWithOrderId:order.orderId];
//            if (!datebaseOrder || (datebaseOrder.orderState != order.orderState)) { //数据库没有, 或者其中有一个状态改变了
//                //加红点
//                //DCMenuItem *reservation = self.menuItems[HSSYMenuIndexReservation];
//                //reservation.hasMessage = YES;
//                [self.tableView reloadData];
//                break;
//            }
//        }
//    }];
    
    //电桩管理
//    NSArray *accessPoles = [DCApp sharedApp].ownedPoles;
//    for (DCPole *pole in accessPoles) {
//        NSURLSessionDataTask *reservePoleOrderTask = [DCSiteApi postOrderList:pole.pileId userid:nil search:nil start:@(0) count:@(10) action:nil startOffset:nil endOffset:nil completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            NSDictionary *resultDic = webResponse.result;
//            NSMutableArray *newOrders = [NSMutableArray array];
//            NSArray *orders = [resultDic objectForKey:@"orders"];
//            for (NSDictionary *orderDic in orders) {
//                if (![orderDic isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
//                    continue;
//                }
//                DCOrder *order = [[DCOrder alloc] initWithDict:orderDic];
//                [newOrders addObject:order];
//            }
//            
//            for (DCOrder *order in newOrders) {
//                DCDatabaseOrder *datebaseOrder = [DCDatabaseOrder ordersWithOrderId:order.orderId];
//                if (!datebaseOrder || (datebaseOrder.orderState != order.orderState)) { //数据库没有, 或者其中有一个状态改变了
//                    [self.poleMessageDict setObject:@1 forKey:pole.pileId];
//                    //加红点
//                    //DCMenuItem *poleManage = self.menuItems[HSSYMenuIndexPolesManage];
//                    //poleManage.hasMessage = YES;
//                    break;
//                }
//            }
//            
//            [self.tableView reloadData];
//        }];
//        [self.reservePoleOrderTasks addObject:reservePoleOrderTask];
//    }
}

- (void)stopRefreshOrders {
    [self.reserveOrderTask cancel];
    for (NSURLSessionDataTask *task in self.reservePoleOrderTasks) {
        [task cancel];
    }
    [self.reservePoleOrderTasks removeAllObjects];
}

- (void)fetchUnreadMessageCount:(NSString *)userId {
    [self.fetchUnreadMessageTask cancel];
    
    self.lastFetchUnreadMessageDate = [NSDate date];
    self.fetchUnreadMessageTask = [DCSiteApi getUnreadMessageCount:userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if ([webResponse isSuccess]) {
            NSNumber *unreadMessageCount = [webResponse.result numberObject];
            if (unreadMessageCount) {
                [DCDefault saveNewMessageCount:[unreadMessageCount integerValue]];
            }
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.menuItems[section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCMenuCell" forIndexPath:indexPath];
    NSArray *menuSection = self.menuItems[indexPath.section];
    DCMenuItem *item = menuSection[indexPath.row];
    [cell configureForItem:item];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *vc = nil;
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case DCMenuRowOrder: {
                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
                    DCOrderViewController *orderVC = [DCOrderViewController storyboardInstantiate];
                    orderVC.initialTab = DCReserveOrderTabCharge;
                    orderVC.delegate = self;
                    vc = orderVC;
                    break;
                }
                case DCMenuRowWallet:{
                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
                    vc = [DCWalletViewController storyboardInstantiate];
                    break;
                }
                case DCMenuRowChargeCard: {
//                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
//                    vc = [DCChargeCardViewController storyboardInstantiate];
                    
                    if ([DCApp sharedApp].user.userId.length) {
                        WCCardViewController *vc = [[WCCardViewController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        //弹出登录界面
                        [self presentLoginViewIfNeededCompletion:nil];
                    }
                    break;
                }

                case DCMenuRowFavorites: {
                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
                    vc = [DCFavoritesViewController storyboardInstantiate];
                    break;
                }

                case DCMenuRowEvaluations: {
                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
                    vc = [MyEvaluationsViewController storyboardInstantiate];
                    break;
                }
                    
                default: break;
            }
            break;

        case 1:
            switch (indexPath.row) {
                case DCMenuRowAddPile: {
                    if ([self presentLoginViewIfNeededCompletion:nil]) { return; }
                    DCPileSetLocationViewController *pileSetLocationController = [DCPileSetLocationViewController storyboardInstantiate];
                    vc = pileSetLocationController;
                    break;
                }
                    
                default: break;
            }
            break;

        case 2:
            switch (indexPath.row) {
                case DCMenuRowHelp: {
                    vc = [[UIStoryboard storyboardWithName:@"Help" bundle:nil] instantiateViewControllerWithIdentifier:@"HelpViewController"];
                    break;
                }
                case DCMenuRowSetting: {
                    DCSettingViewController *settingVC = [[UIStoryboard storyboardWithName:@"Setting" bundle:nil] instantiateViewControllerWithIdentifier:@"DCSettingViewController"];
                    vc = settingVC;
                    break;
                }
                case DCMenuRowAbout: {
                    vc = [[UIStoryboard storyboardWithName:@"Help" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
                    break;
                }
                default: break;
            }
            break;
//
        default: break;
    }
    if (vc) {
        [self pushToViewController:vc];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section < self.menuItems.count-1) {
        return 8;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [UIView new];
    footer.backgroundColor = tableView.separatorColor;
    return footer;
}

#pragma mark - Extension
- (void)updateUserAvatarAndName {
    DCUser *user = [DCApp sharedApp].user;
    [self.userNameButton setTitle:(user.nickName ?: @"点击登录") forState:UIControlStateNormal];
    if ([DCApp sharedApp].user.userId) {
        [self.userNameButton addTarget:self action:@selector(gotoUserInfo:) forControlEvents:UIControlEventTouchUpInside];
    }
//    UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[user avatarImageURL]]];
    [self.avatarButton setCircleAvatarURL:[user avatarImageURL] andImage:nil];
}

#pragma mark - MyOrderRefreshDelegate
- (void)myOrderRefresh:(id)sender {
//    DCMenuItem *reservation = self.menuItems[HSSYMenuIndexReservation];
//    reservation.hasMessage = NO;
    [self.tableView reloadData];
}

#pragma mark - Notification
- (void)poleOrderRefresh:(NSNotification *)note {
    NSString *poleId = note.object;
    if (poleId) {
        self.poleMessageDict[poleId] = @0;
        
        BOOL hasMessage = NO;
        for (NSNumber *num in self.poleMessageDict) {
            if ([num intValue] > 0) {
                hasMessage = YES;
            }
        }
        DDLogDebug(@"has new order %d", hasMessage);
        
//        DCMenuItem *poleManage = self.menuItems[HSSYMenuIndexPolesManage];
//        poleManage.hasMessage = hasMessage;
        [self.tableView reloadData];
    }
}

- (void)updateMessageItem {
    NSInteger number = [DCDefault loadNewMessageCount];
    if (number == 0) {
        [self.messageBadgeView removeFromSuperview];
    } else {
        if (!self.messageBadgeView) {
            JSBadgeView *messageBadgeView = [[JSBadgeView alloc] initWithParentView:self.messageButton alignment:JSBadgeViewAlignmentTopRight];
            messageBadgeView.userInteractionEnabled = NO;
            [self.messageButton addSubview:messageBadgeView];
            self.messageBadgeView = messageBadgeView;
        }
        self.messageBadgeView.badgeText = @(number).stringValue;
    }
}

- (void)updateUserInfo {
    [self updateUserAvatarAndName];
    
    NSString *userId = [DCApp sharedApp].user.userId;
    if (userId) { // login
        if ((self.lastFetchUnreadMessageDate == nil) || ([[NSDate date] timeIntervalSinceDate:self.lastFetchUnreadMessageDate] > 60)) { // never fetch or last fetch past 60s
            [self fetchUnreadMessageCount:userId];
        }
    } else { // logout
        [self.fetchUnreadMessageTask cancel];
        self.lastFetchUnreadMessageDate = nil;
        [DCDefault saveNewMessageCount:0];
        
        /*
         DCMenuItem *reservation = self.menuItems[HSSYMenuIndexReservation];
         reservation.hasMessage = NO;
         DCMenuItem *poleManage = self.menuItems[HSSYMenuIndexPolesManage];
         poleManage.hasMessage = NO;
         */
    }
    [self updateMessageItem];
}

@end

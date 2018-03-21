//
//  DCChargeCardViewController.m
//  Charging
//
//  Created by kufufu on 16/5/9.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCChargeCardViewController.h"
#import "DCSiteApi.h"
#import "DCBookNormalCell.h"
#import "DCBindChargeCardViewController.h"
#import "DCOneButtonAlertView.h"
#import "DCPopupView.h"

@interface DCChargeCardViewController ()<UITableViewDelegate, UITableViewDataSource, DCBookNormalCellDelegate, DCPopupViewDelegate, DCOneButtonAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *placeholderVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *topBindChargeCardButton;

@property (strong, nonatomic) DCChargeCard *chargeCard;
@property (strong, nonatomic) DCPopupView *warmPopupView;

@property (strong, nonatomic) NSMutableArray *array;

@end

@implementation DCChargeCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DCBookNormalCell" bundle:nil] forCellReuseIdentifier:@"DCBookNormalCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self requestChargeCardList];
    
    if (self.chargeCard.cardId) {
        self.topBindChargeCardButton.hidden = YES;
        self.placeholderVIew.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestChargeCardList {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DCSiteApi getChargeCardListWithUserId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [hud hide:YES];
        self.array = webResponse.result;
        if (self.array.count > 0) {
            self.chargeCard = [[DCChargeCard alloc] initWithChargeCardWithDict:[self.array firstObject]];
            self.topBindChargeCardButton.hidden = YES;
            self.placeholderVIew.hidden = YES;
            [self.tableView reloadData];
        }
        
        /**
         * TEST CODE
         */
        //        self.chargeCard = [[DCChargeCard alloc] init];
        //        self.chargeCard.useStatus = DCChargeCardUseStatusUsing;
        //        [self.tableView reloadData];
    }];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DCBookNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DCBookNormalCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[DCBookNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DCBookNormalCell"];
    }
    cell.myDelegate = self;
    [cell configForChargeCard:self.chargeCard];
    return cell;
}

#pragma mark - Action
- (IBAction)bindNewChargeCard:(id)sender {
    DCBindChargeCardViewController *vc = [DCBindChargeCardViewController storyboardInstantiate];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - DCBookNormalCellDelegate
- (void)cellButtonClickedByChargeCard:(DCChargeCard *)chargeCard tag:(DCChargeCardButtonTag)tag {
    if (tag == DCChargeCardButtonTagUnbind) {
        [self popUpWarmView];
    }
}

- (void)clickTheContactButton {
    [[DCApp sharedApp] callPhone:@"021-616-10101" viewController:self];
}

- (void)clickTheUnbindButton {
    [self popUpWarmView];
}

#pragma mark - public
- (void)popUpWarmView {
    DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeUnbindChargeCard];
    view.delegate = self;
    self.warmPopupView = [DCPopupView popUpWithTitle:@"是否解除电卡绑定" contentView:view withController:self];
}

- (void)popUpViewDismiss:(DCPopupView *)view {
    [self.warmPopupView dismiss];
}

- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [DCSiteApi postUnbindChargeCardWithCardId:self.chargeCard.cardId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self.warmPopupView dismiss];
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        [self.warmPopupView dismiss];
        [self hideHUD:hud withDetailsText:@"解绑成功" completion:^{
            self.topBindChargeCardButton.hidden = NO;
            self.placeholderVIew.hidden = NO;
            [self requestChargeCardList];
        }];
        
    }];
}

@end

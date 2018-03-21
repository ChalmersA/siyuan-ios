//
//  HSSYMessageDetailViewController.m
//  Charging
//
//  Created by xpg on 15/4/8.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCMessageDetailViewController.h"
#import "DCMessage.h"
#import "DCOrder.h"
#import "DCFieldItem.h"
#import "UIColor+HSSYColor.h"
#import "DCChargeEditableCell.h"
#import "DCPayWebViewController.h"
#import "DCPileEvaluationViewController.h"
#import "DCPoleInMapViewController.h"
#import "DCMapManager.h"
#import "DCPaySelectionViewController.h"
#import "DCChargeEditableCell.h"
#import "Charging-Swift.h"

@interface DCMessageDetailViewController () <UITableViewDataSource, UITableViewDelegate, DCChargeEditableCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) DCOrder *order;
@end

@implementation DCMessageDetailViewController

+ (instancetype)storyboardInstantiate {
    UIStoryboard *messageStoryboard = [UIStoryboard storyboardWithName:@"Message" bundle:nil];
    return [messageStoryboard instantiateViewControllerWithIdentifier:@"HSSYMessageDetailViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"DCChargeEditable" bundle:nil] forCellReuseIdentifier:DCCellIdReserveOrderNormal];
//    [self.tableView registerNib:[UINib nibWithNibName:@"DCOrderDoneCell" bundle:nil] forCellReuseIdentifier:HSSYCellIdReserveOrderDone];
//    [self.tableView registerNib:[UINib nibWithNibName:@"DCPoleOrderCell" bundle:nil] forCellReuseIdentifier:HSSYCellIdPoleOrder];
//    [self.tableView registerNib:[UINib nibWithNibName:@"DCPoleOrderFinishCell" bundle:nil] forCellReuseIdentifier:DCCellIdPoleOrderFinish];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshOrder:self.message.typeId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)navigateBack:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [super navigateBack:sender];
    }
}

#pragma mark - Request
- (void)refreshOrder:(NSString *)orderId {
    MBProgressHUD *hud = [self showHUDIndicator];
    
    [DCSiteApi getOrderInfo:orderId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        self.order = [[DCOrder alloc] initWithDict:[webResponse.result objectForKey:@"order"]];
        [self.tableView reloadData];
        [hud hide:YES];
    }];
}

//- (void)modifyOrderState:(DCOrderState)state {
//    NSString *action = nil;
//    NSString *result = nil;
//    if (state == DCOrderStateConfirmed) {
//        action = @"1";
//        result = @"已同意";
//    } else if (state == DCOrderStateRefused) {
//        action = @"2";
//        result = @"已拒绝";
//    } else if (state == DCOrderStateCanceled) {
//        action = @"3";
//        result = @"已取消";
//    }
    
//    MBProgressHUD *hud = [self showHUDIndicator];
//    [DCSiteApi postOrderModify:self.order.orderId action:action completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        if (![webResponse isSuccess]) {
//            [hud hide:YES];
//            UIAlertView *alert = [UIAlertView showAlertMessage:[DCWebResponse errorMessage:error withResponse:webResponse] buttonTitles:@[@"确定"]];
//            [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
//                [self refreshOrder:self.order.orderId];
//            }];
//            return;
//        }
//        [self hideHUD:hud withText:result];
//        [self navigateBack:nil];
//    }];
//}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.order?1:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userId = [DCApp sharedApp].user.userId;
    DCOrder *order = self.order;
    
//    if ([order.ownerId isEqualToString:userId]) { // 桩主
//        if (order.orderState == DCOrderStateCharged || order.orderState == DCOrderStatePaid || order.orderState == DCOrderStateEvaluated) {
//            DCPoleOrderFinishCell *cell = [tableView dequeueReusableCellWithIdentifier:DCCellIdPoleOrderFinish forIndexPath:indexPath];
//            cell.delegate = self;
//            [cell configForOrder:order];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        } else {
//            DCPoleOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:HSSYCellIdPoleOrder forIndexPath:indexPath];
//            cell.delegate = self;
//            [cell configForOrder:order];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
//    } else {
//        if (order.orderState == DCOrderStateNotPayChargefee || order.orderState == DCOrderStateNotEvaluate || order.orderState == DCOrderStateEvaluated) {
//            DCOrderDoneCell *cell = [tableView dequeueReusableCellWithIdentifier:HSSYCellIdReserveOrderDone forIndexPath:indexPath];
//            cell.delegate = self;
//            [cell configForOrder:order];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        } else {
//            DCOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:DCCellIdReserveOrderNormal forIndexPath:indexPath];
//            cell.delegate = self;
//            [cell configForOrder:order];
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            return cell;
//        }
//    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *userId = [DCApp sharedApp].user.userId;
    DCOrder *order = self.order;
//    if ([order.ownerId isEqualToString:userId]) {//桩主 {
//        if (order.orderState == DCOrderStateCharged || order.orderState == DCOrderStatePaid || order.orderState == DCOrderStateEvaluated) {
//            return [DCPoleOrderFinishCell cellHeightForOrder:order];
//        }
//        return [DCPoleOrderCell cellHeight];
//    } else {
//        if (order.orderState == DCOrderStateCharged || order.orderState == DCOrderStatePaid || order.orderState == DCOrderStateEvaluated) {
//            return [DCOrderDoneCell cellHeightForOrder:order];
//        }
//        return [DCOrderCell cellHeight];
//    }
    return 100;
}

#pragma mark - DCChargeEditableCellDelegate
- (void)cellButtonClicked:(DCOrder *)order tag:(DCOrderButtonTag)tag {
    if (!order) {
        return;
    }
    
    switch (tag) {
//        case DCOrderButtonTagCancel: {
//            [self modifyOrderState:DCOrderStateCancelBooking];
//            break;
//        }
            
//        case DCOrderButtonTagBooking: {
//            DCStationDetailViewController *vc = [DCStationDetailViewController storyboardInstantiate];
//            DCPole *pole = [DCPole new];
//            pole.pileId = order.pileId;
//            vc.selectedPoleInfo = pole;
//            [self.navigationController pushViewController:vc animated:YES];
//            break;
//        }
            
//        case DCOrderButtonTagEvaluate: {
//            HSSYEvaluateViewController *vc = [HSSYEvaluateViewController storyboardInstantiate];
            
//            DCPileEvaluationViewController * vc = [DCPileEvaluationViewController storyboardInstantiate];
//            vc.order = self.order;
//            [self.navigationController pushViewController:vc animated:YES];
//            break;
//        }
            
//        case DCOrderButtonTagPay: {
//            [self payWithOrder:order withFinishBlock:^(NSDictionary *resultDic) {
                // TODO: deal with  payment finish
//            }];
//            break;
//        }
            
        case DCOrderButtonTagNavi: {
            if ([DCMapManager isCoordinateValid:order.stationCoordinate]) {
                DCPoleInMapViewController *vc = [DCPoleInMapViewController storyboardInstantiate];
                vc.coordinate = order.stationCoordinate;
                vc.address = order.stationLocation;
                vc.stationName = order.stationName;
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                [self hideHUD:hud withText:@"抱歉，该电桩经纬度位置未知"];
            }
            break;
        }
            
        case DCOrderButtonTagContactOwner: {
            [self callPhone:@"4000220288"];
            break;
        }
            
//        case DCOrderButtonTagRefuse: {
//            [self modifyOrderState:DCOrderStateRefused];
//            break;
//        }
//            
//        case DCOrderButtonTagConfirm: {
//            [self modifyOrderState:DCOrderStateConfirmed];
//            break;
//        }
            
//        case DCOrderButtonTagContactTenant: {
//            [self callPhone:order.tenantPhone];
//            break;
//        }
            
        default:
            NSAssert(NO, @"unhandled case");
            break;
    }
}

#pragma mark - Extension
- (void)callPhone:(NSString *)phone {
    if (!phone.length) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"联系电话不存在";
        [hud hide:YES afterDelay:2];
        return;
    }
    
    [[DCApp sharedApp] callPhone:phone viewController:self];
}

@end

//
//  UIViewController+HSSYExtensions.m
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "UIViewController+HSSYExtensions.h"
#import "DCTabBarController.h"
#import "DCApp.h"
#import "UIColor+HSSYColor.h"
#import "UIActionSheet+HSSYCategory.h"
#import "DCOrder.h"
#import "DCSiteApi.h"
#import "DCPaySelectionViewController.h"
#import "DCLoginViewController.h"

static NSString * const HSSYActionSheetTakePhoto = @"拍照";
static NSString * const HSSYActionSheetPickPhoto = @"从手机相册选择";

@implementation UIViewController (HSSYExtensions)

+ (instancetype)storyboardInstantiate {
    NSString *identifier = NSStringFromClass([self class]);
    return [self storyboardInstantiateWithIdentifier:identifier];
}

+ (instancetype)storyboardInstantiateWithIdentifier:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

+ (instancetype)storyboardInstantiateWithIdentifierInAttention:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:@"Attention" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

+ (instancetype)storyboardInstantiateWithIdentifierInLogin:(NSString *)identifier {
    return [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:identifier];
}

- (DCTabBarController *)hssy_tabBarController {
    UITabBarController *tabBarController = self.tabBarController;
    if ([tabBarController isKindOfClass:[DCTabBarController class]]) {
        return (DCTabBarController *)tabBarController;
    }
    return nil;
}

#pragma mark - Login
- (BOOL)presentLoginViewIfNeededCompletion:(void (^)(void))completion {//return NO;
    if ([DCApp sharedApp].user) {
        return NO;
    }
    
    UIViewController *viewPresenter = [DCApp sharedApp].rootViewController;
    while (viewPresenter.presentedViewController) {
        viewPresenter = viewPresenter.presentedViewController;
    }
    
    if ([viewPresenter isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController *)viewPresenter;
        if ([navController.viewControllers.firstObject isKindOfClass:[DCLoginViewController class]]) {
            return NO;
        }
    }
    
    UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    UINavigationController *loginNavVC = [loginStoryboard instantiateInitialViewController];
    [loginNavVC hssy_customNavigationBar];
    
    [viewPresenter presentViewController:loginNavVC animated:YES completion:completion];
    return YES;
}

#pragma mark - Search
- (void)jumpToSearchPole {
    [DCApp sharedApp].rootTabBarController.selectedIndex = DCTabIndexSearch;
    [[DCApp sharedApp].rootNavigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Pay
- (void)payWithOrder:(DCOrder *)order withFinishBlock:(PayFinishBlock)block {
    [self payWithOrder:order showFinishBlock:nil PayFinishBlock:block];
}
- (void)payWithOrder:(DCOrder *)order showFinishBlock:(PayViewShowFinish)showFinish PayFinishBlock:(PayFinishBlock)block {
//    NSArray *chargeRecordIds = order.unpaidChargeRecordIds;
//    if (chargeRecordIds.count == 0) {
//        // TODO: show error about no record to be pay
//        return;
//    }
    
    DCPaySelectionViewController *payChooseVC = [DCPaySelectionViewController storyboardInstantiate];
    payChooseVC.chargePrice = order.chargeTotalFee;
    if (order.orderState == DCOrderStateNotPayBookfee) {
        payChooseVC.chargePrice = order.reserveFee;
        payChooseVC.isReserverFee = YES;
    }
    payChooseVC.orderId = order.orderId;
    payChooseVC.payFinishBlock = block;
    UINavigationController *payNavVC = [UINavigationController navControllerWithRootVC:payChooseVC];
    
    [self presentViewController:payNavVC animated:YES completion:^{
        if (showFinish) {
            showFinish();
        }
    }];
}

#pragma mark - HUD
- (MBProgressHUD *)showHUDIndicator {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

- (void)hideHUD:(MBProgressHUD *)hud withText:(NSString *)text {
    if (text.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = text;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    } else {
        [hud hide:YES];
    }
}

- (void)hideHUD:(MBProgressHUD *)hud withDetailsText:(NSString *)text {
    if (text.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = text;
        hud.detailsLabelFont = hud.labelFont;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:2];
    } else {
        [hud hide:YES];
    }
}

- (void)hideHUD:(MBProgressHUD *)hud withDetailsText:(NSString *)text completion:(MBProgressHUDCompletionBlock)completion {
    if (text.length > 0) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = text;
        hud.detailsLabelFont = hud.labelFont;
        hud.removeFromSuperViewOnHide = YES;
        hud.completionBlock = completion;
        [hud hide:YES afterDelay:2];
    } else {
        [hud hide:YES];
    }
}

- (MBProgressHUD *)showHUDText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self hideHUD:hud withText:text];
    return hud;
}

- (MBProgressHUD *)showHUDText:(NSString *)text completion:(MBProgressHUDCompletionBlock)completion {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.completionBlock = completion;
    [self hideHUD:hud withText:text];
    return hud;
}

#pragma mark - Debug
- (void)logChildrenWithPrefix:(NSString *)prefix {
    DDLogVerbose(@"%@%@", prefix, [self class]);
    prefix = [@"    " stringByAppendingString:prefix];
    for (UIViewController *child in self.childViewControllers) {
        [child logChildrenWithPrefix:prefix];
    }
}

#pragma mark - Image
- (void)selectImagePickerSource:(void (^)(UIImagePickerControllerSourceType source))handler {
    UIActionSheet *actionSheet;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:HSSYActionSheetTakePhoto, HSSYActionSheetPickPhoto, nil];
    } else {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:HSSYActionSheetPickPhoto, nil];
    }
    [actionSheet showInView:self.view];
    [actionSheet setClickedButtonHandler:^(NSString *buttonTitle) {
        if ([buttonTitle isEqualToString:HSSYActionSheetPickPhoto]) {
            handler(UIImagePickerControllerSourceTypePhotoLibrary);
        } else if ([buttonTitle isEqualToString:HSSYActionSheetTakePhoto]) {
            handler(UIImagePickerControllerSourceTypeCamera);
        }
    }];
}

@end

@implementation UINavigationController (HSSYExtensions)

- (UIViewController *)hssy_firstViewController {
    return [self.viewControllers firstObject];
}

- (void)hssy_customNavigationBar {
    self.navigationBar.translucent = NO;
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor paletteDCMainColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
}

- (void)hssy_customBackIndicatorImage {
    UIImage *backIndicatorImage = [UIImage imageNamed:@"bar_back_button"];
    self.navigationBar.backIndicatorImage = backIndicatorImage;
    self.navigationBar.backIndicatorTransitionMaskImage = backIndicatorImage;
}

+ (instancetype)navControllerWithRootVC:(UIViewController *)vc {
    UINavigationController *nav = [[self alloc] initWithRootViewController:vc];
    [nav hssy_customNavigationBar];
    return nav;
}

@end

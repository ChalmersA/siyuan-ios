//
//  UIViewController+HSSYExtensions.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DCTabBarController.h"

@class DCOrder;

@interface UIViewController (HSSYExtensions)

+ (instancetype)storyboardInstantiate;
+ (instancetype)storyboardInstantiateWithIdentifier:(NSString *)identifier;
+ (instancetype)storyboardInstantiateWithIdentifierInAttention:(NSString *)identifier;
+ (instancetype)storyboardInstantiateWithIdentifierInLogin:(NSString *)identifier;

@property (nonatomic, readonly) DCTabBarController *hssy_tabBarController;

- (void)logChildrenWithPrefix:(NSString *)prefix;
- (BOOL)presentLoginViewIfNeededCompletion:(void (^)(void))completion;
- (void)jumpToSearchPole;
- (void)payWithOrder:(DCOrder *)order withFinishBlock:(PayFinishBlock)block;
- (void)payWithOrder:(DCOrder *)order showFinishBlock:(PayViewShowFinish)showFinish PayFinishBlock:(PayFinishBlock)block;

- (MBProgressHUD *)showHUDIndicator;
- (void)hideHUD:(MBProgressHUD *)hud withText:(NSString *)text;
- (void)hideHUD:(MBProgressHUD *)hud withDetailsText:(NSString *)text;
- (void)hideHUD:(MBProgressHUD *)hud withDetailsText:(NSString *)text completion:(MBProgressHUDCompletionBlock)completion;
- (MBProgressHUD *)showHUDText:(NSString *)text;
- (MBProgressHUD *)showHUDText:(NSString *)text completion:(MBProgressHUDCompletionBlock)completion;

- (void)selectImagePickerSource:(void (^)(UIImagePickerControllerSourceType source))handler;

@end

@interface UINavigationController (HSSYExtensions)
@property (nonatomic, readonly) UIViewController *hssy_firstViewController;
- (void)hssy_customNavigationBar;
+ (instancetype)navControllerWithRootVC:(UIViewController *)vc;
@end

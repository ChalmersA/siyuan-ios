//
//  HSSYTabBarController.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCTabBarController.h"
#import "UIColor+HSSYColor.h"
#import "DCApp.h"
#import "UIViewController+HSSYExtensions.h"
#import "UIBarButtonItem+HSSYExtensions.h"
#import "DCSearchViewController.h"
#import "BaiduMapKits.h"
#import "DCSelectDetailAreaViewController.h"
#import "ABCIntroView.h"

@interface DCTabBarController () <UITabBarControllerDelegate, UINavigationControllerDelegate, ABCIntroViewDelegate>
{
    NSUInteger lastSelectedTabIndex;
}
@property (nonatomic) ABCIntroView *introView;
@end

@implementation DCTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
    //TODO:暂时把引导页屏蔽 ABCIntroView
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HasShowIntroView"];//以前使用的key
    if (![[DCDefault loadInstalledVersion] isEqualToString:appVersion()]) {
        self.introView = [[ABCIntroView alloc] initWithFrame:self.navigationController.view.bounds];
        self.introView.delegate = self;
        self.introView.backgroundColor = [UIColor lightGrayColor];
        [self.navigationController.view addSubview:self.introView];
        [self initStationAndPoleType];
    }
    //   设置 UITabBarController 的 UITabBarItem图片
    UITabBarController *tabBarController = (DCTabBarController *)self;
    UITabBarItem *tabBarItem1 = [tabBarController.tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBarController.tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBarController.tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBarController.tabBar.items objectAtIndex:3];
    
    //在iOS7以上的手机中，Tab的选中图一直显示的是系统默认的蓝色图.如果不希望使用系统颜色，需要对图片加上属性UIImageRenderingModeAlwaysOriginal
    tabBarItem1.image = [[UIImage imageNamed:@"tab_icon_charge_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.image = [[UIImage imageNamed:@"tab_icon_search_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.image = [[UIImage imageNamed:@"tab_icon_attention_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4.image = [[UIImage imageNamed:@"tab_icon_me_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"tab_icon_charge"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"tab_icon_search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"tab_icon_attention"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4.selectedImage = [[UIImage imageNamed:@"tab_icon_me"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    [self getStationAndPoleType];
}

#pragma mark - 获取站桩类型
//- (void)getStationAndPoleType{
//    [DCSiteApi getStationTypeCompletion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        NSLog(@"Test: getStationTypeCompletion");
//        if (success) {
//            NSMutableDictionary *stationTypeDic = [NSMutableDictionary dictionary];
//            if (webResponse.result) {
//                NSMutableArray *array = webResponse.result;
//                for (NSDictionary *dic in array) {
//                    NSString *key = [NSString stringWithFormat:@"%@", [dic objectForKey:@"dkey"]];
//                    NSString *value = [NSString stringWithFormat:@"%@", [dic objectForKey:@"value"]];
//                    [stationTypeDic setObject:key forKey:value];
//                }
//                if (stationTypeDic.count) {
//                    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:stationTypeDic] forKey:@"HSSYStationType"];
//                }
//            }
//        }
//        
//    }];
//
//    [DCSiteApi getPoleTypeCompletion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        NSLog(@"Test: getPoleTypeCompletion");
//        if (success) {
//            NSMutableDictionary *poleTypeDic = [NSMutableDictionary dictionary];
//            if (webResponse.result) {
//                NSMutableArray *array = webResponse.result;
//                for (NSDictionary *dic in array) {
//                    NSString *key = [NSString stringWithFormat:@"%@", [dic objectForKey:@"dkey"]];
//                    NSString *value = [NSString stringWithFormat:@"%@", [dic objectForKey:@"value"]];
//                    [poleTypeDic setObject:key forKey:value];
//                }
//                if (poleTypeDic.count) {
//                    [[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithDictionary:poleTypeDic] forKey:@"HSSYPoleType"];
//                }
//            }
//        }
//    }];
//    
//}

- (void)initStationAndPoleType{
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"HSSYStationType"]) {
        NSDictionary *stationType = @{@"1":@"公共站" , @"2":@"专用站", @"4":@"优易充小站", @"9":@"其他"};
        [[NSUserDefaults standardUserDefaults] setObject:stationType forKey:@"HSSYStationType"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"HSSYPoleType"]) {
        NSDictionary *poleType = @{@"1":@"直流充电桩", @"2":@"交流充电桩", @"3":@"无线充电桩", @"4":@"换电工位"};
        [[NSUserDefaults standardUserDefaults] setObject:poleType forKey:@"HSSYPoleType"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segue
- (IBAction)unWindToSelectAreaView:(UIStoryboardSegue *)segue {
    DCSelectDetailAreaViewController *detailSelectView = segue.sourceViewController;
    BMKPoiInfo *poiInfo = detailSelectView.choosenPoiInfo;
    DCSearchViewController *mapVC = self.viewControllers[DCTabIndexSearch];
    [mapVC selectPoiInfo:poiInfo];
}

#pragma mark - View
- (void)updateNavigationBar {
    self.navigationItem.title = self.selectedViewController.navigationItem.title;
    self.navigationItem.titleView = self.selectedViewController.navigationItem.titleView;
    self.navigationItem.leftBarButtonItem = self.selectedViewController.navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = self.selectedViewController.navigationItem.rightBarButtonItem;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    [self updateNavigationBar];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

#pragma mark - Theme
- (void)themeDidChange:(HSSYTheme)theme {
//    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor tabBarColorForTheme:theme]};
//    for (UITabBarItem *item in self.tabBar.items) {
////        [item setTitleTextAttributes:attributes forState:UIControlStateNormal];
//        [item setTitleTextAttributes:attributes forState:UIControlStateSelected];
//    }
//    self.tabBar.tintColor = [UIColor tabBarColorForTheme:theme];
}

#pragma mark - ABCIntroViewDelegate
- (void)onDoneButtonPressed {
    [DCDefault saveInstalledVersion:appVersion()];
    [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.introView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
    }];
}

@end

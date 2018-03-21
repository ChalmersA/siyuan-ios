//
//  DCApp.h
//  Charging
//
//  Created by xpg on 14/12/9.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "DCDefault.h"
#import "DCUser.h"
#import "DCPole.h"
#import "Reachability.h"
#import "DCSearchParameters.h"
#import "DCTabBarController.h"
#import "DCOrder.h"
#import "DCDatabaseOrder.h"

@protocol HSSYThemeProtocol <NSObject>
@optional
- (void)themeDidChange:(HSSYTheme)theme;
@end

extern NSString * const DCThemeDidChangeNotification;


@interface DCApp : NSObject

+ (instancetype)sharedApp;
+ (AppDelegate *)appDelegate;

@property (nonatomic, readonly) UIViewController *rootViewController;
- (UINavigationController *)rootNavigationController;
- (DCTabBarController *)rootTabBarController;
@property (nonatomic) HSSYTheme theme;

@property (strong, nonatomic) DCUser *user;//当前登录用户
@property (strong, nonatomic) NSData *currentPoleID;
@property (copy, nonatomic) NSArray *chargeablePoles;//HSSYPole 拥有Key的桩(租户|家人|业主)
@property (copy, nonatomic) NSArray *accessiblePoles;//HSSYPole 用户是业主或家人的桩
@property (copy, nonatomic) NSArray *ownedPoles;//HSSYPole 用户是业主的桩
@property (copy, nonatomic) NSArray *poleKeys;  //HSSYKeyObject
@property (retain, nonatomic) NSMutableArray *orders;     //HSSYOrder 用户KEY对应的Order

@property (strong, nonatomic) CLLocation *userLocation;//定位位置
@property (strong, nonatomic) CLLocation *centerLocation;//地图中心位置

@property (strong, nonatomic) DCSearchParameters *searchParam;

@property (nonatomic, readonly) NetworkStatusx networkStatus;

//- (void)fetchUserPolesCompletion:(void(^)(BOOL success))completion;
//- (void)fetchUserKeysCompletion:(void(^)(BOOL success))completion;
/**
 *  从数据库中读取KEY值，并替换当前所有KEY；
 */
//-(void)loadKeysFromDatabaseWithCurUser;
/**
 *  根据当前的KEYs 获取相应的桩的信息
 */
//-(void)loadPolesWithCurKEYs;
//- (void)startFetchUserKeysTimer;
- (void)handleRemoteNotificationInfo:(NSDictionary *)userInfo forLaunching:(BOOL)launching;
//- (void)startPostRecordTimer;
//- (NSURLSessionDataTask *)postNeedChargesToServer:(NSArray*)records withCompletion:(void (^)(NSArray* records, BOOL isSuccess))completion;
- (void)showUpdateAppAlert;
- (void)startReachabilityNotifier;

- (void)callPhone:(NSString *)phone viewController:(UIViewController *)vc;
//- (BOOL)chargePossible;
@end

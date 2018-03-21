//
//  DCApp.m
//  Charging
//
//  Created by xpg on 14/12/9.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCApp.h"
#import "DCSiteApi.h"
#import "DCSiteApi.h"
#import "AppDelegate.h"
#import "DCCommon.h"
#import "UIAlertView+HSSYCategory.h"
#import "DCMessage.h"
#import "DCMessageDetailViewController.h"
#import "NSMutableArray+HSSY.h"
#import "DCSearchViewController.h"
#import "JPUSHService.h"
#import "Charging-Swift.h"

NSString * const DCThemeDidChangeNotification = @"DCThemeDidChangeNotification";

@interface DCApp ()

@property (weak, nonatomic) NSTimer *postRecordTimer;
@property (weak, nonatomic) NSURLSessionDataTask *postRecordTask;

@property (weak, nonatomic) NSTimer *fetchKeysTimer;
@property (weak, nonatomic) NSURLSessionDataTask *fetchKeysTask;

@property (strong, nonatomic) NSURLSessionDataTask *refreshTokenTask;
@property (strong, nonatomic) NSMutableArray *handledMessages;

@property (weak, nonatomic) UIAlertView *updateAlert;

@property (nonatomic) Reachabilityx *hostReachability;
@property (nonatomic) NetworkStatusx networkStatus;
@property (weak, nonatomic) UIAlertView *notReachableAlert;

@property (nonatomic) UIWebView *callWebView;

@property (weak, nonatomic)id lastViewController;

@end

@implementation DCApp

+ (instancetype)sharedApp {
    static DCApp *app = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        app = [[self alloc] init];
    });
    return app;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _handledMessages = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTokenExpired:) name:NOTIFICATION_TOKEN_EXPIRED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefreshTokenExpired:) name:NOTIFICATION_REFRESH_TOKEN_EXPIRED object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTokenInvalid:) name:NOTIFICATION_TOKEN_INVALID object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidChange:) name:NOTIFICATION_USER_DID_CHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateApplicationBadge:) name:NOTIFICATION_MESSAGE_UPDATE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCurrentVIewController:) name:@"CurrentViewController" object:nil];
    }
    return self;
}

- (void)memoryWarning {
    self.callWebView = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (AppDelegate *)appDelegate {
    return ((AppDelegate *)[UIApplication sharedApplication].delegate);
}

#pragma mark - Business
//- (void)fetchUserPolesCompletion:(void (^)(BOOL success))completion {
//    [DCSiteApi postGetAccessPiles:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        if (![webResponse isSuccess]) {
//            if (completion) { completion(NO); }
//            return;
//        }
//        
//        // [DCDatabasePole cleanAllPolesInDataBase]; // 数据库除了需要保存作为业主或家人的桩，还要保存作为租户的桩，充电时需要显示桩的信息（名字）
//        
//        NSString *userId = [DCApp sharedApp].user.userId;
//        NSMutableArray *accessiblePoles = [NSMutableArray array]; // 用户是业主或家人的桩
//        NSMutableArray *ownedPoles = [NSMutableArray array]; // 用户是业主的桩
//        NSMutableArray *familyPoles = [NSMutableArray array]; // 用户是家人的桩
//        for (id obj in [webResponse.result arrayObject]) {
//            NSDictionary *dict = [obj dictionaryObject];
//            if (dict) {
//                DCPole *pole = [[DCPole alloc] initWithDict:dict];
//                
//                if ([pole.userId isEqualToString:userId]) {
//                    [ownedPoles addObject:pole];
//                } else {
//                    [familyPoles addObject:pole];
//                }
//                
//                [pole savePoleToDatabase];
//            }
//        }
//        
//        [accessiblePoles addObjectsFromArray:ownedPoles];
//        [accessiblePoles addObjectsFromArray:familyPoles];
//        
//        self.ownedPoles = ownedPoles;
//        self.accessiblePoles = accessiblePoles;
//        
//        if (completion) { completion(YES); }
//    }];
//}

//- (void)fetchUserKeysCompletion:(void(^)(BOOL success))completion {
//    [self.fetchKeysTask cancel];
//    self.fetchKeysTask = [DCSiteApi postRequestKey:self.user.phone idType:@"1" completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//        if (![webResponse isSuccess]) {
//            DDLogDebug(@"~~~~~~~ Keys fetched (fail)");
//            if (completion) { completion(NO); }
//            return;
//        }
//        
//        [DCDatabaseKey cleanAllKeysInDataBase];
//        NSMutableArray *poleIds = [NSMutableArray array];
//        NSMutableArray *orderIds = [NSMutableArray array];
//        NSMutableArray *keys = [NSMutableArray array];
//        for (id obj in [webResponse.result arrayObject]) {
//            NSDictionary *dict = [obj dictionaryObject];
//            if (dict) {
//                DCKeyObject *keyObject = [[DCKeyObject alloc] initWithDict:dict];
//                if ([keys containsObject:keyObject] || !keyObject.pileId || [keyObject.pileId length] < 8) {
//                    continue;
//                }
//                [keys addObject:keyObject];
//                [keyObject saveKeyToDatabase];
//                
//                if (![poleIds containsObject:keyObject.pileId]) {
//                    [poleIds addObject:keyObject.pileId];
//                }
//                
//                if (keyObject.orderId && ![orderIds containsObject:keyObject.orderId]) {
//                    [orderIds addObject:keyObject.orderId];
//                }
//            }
//        }
//        
//        // 租户KEY最少保留3*24小时。
//        if(self.poleKeys) {
//            for (DCKeyObject *anOldKey in self.poleKeys) {
//                if (anOldKey.keyType == HSSYKeyTypeTenant && anOldKey.endTime && [anOldKey.endTime timeIntervalSinceDate:[NSDate date]] >= -KeyHoldingTime && ![keys containsObject:anOldKey]) {
//                    [keys addObject:anOldKey];
//                    [anOldKey saveKeyToDatabase];
//                }
//            }
//        }
//        
//        self.poleKeys = keys;
//        DDLogDebug(@"~~~~~~~ Keys fetched (%d)", (int)keys.count);
//        
//        [self fetchChargeablePolesInfo:poleIds];
//        [self fetchChargeableOrderInfo:orderIds];
//        
//        if (completion) { completion(YES); }
//    }];
//}

//- (void)startFetchUserKeysTimer {
//    [self.fetchKeysTimer invalidate];
//    self.fetchKeysTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeToFetchPoleKeys:) userInfo:nil repeats:YES];
//    [self.fetchKeysTimer fire];
//}
//
//- (void)timeToFetchPoleKeys:(NSTimer *)timer {
//    if (self.user) {
//        if (self.poleKeys == nil) {
//            [self loadKeysFromDatabaseWithCurUser];
//        }
//        
//        [self fetchUserKeysCompletion:^(BOOL success) {
//        }];
//    }
//}

//-(void)loadKeysFromDatabaseWithCurUser {
//    NSArray *databaseKeys = [DCDatabaseKey keysWithUserId:[[DCApp sharedApp].user.userId longLongValue]];
//    NSMutableArray *keys = [NSMutableArray array];
//    for (DCDatabaseKey *key in databaseKeys) {
//        [keys addObject:[[DCKeyObject alloc] initWithHSSYDatabaseKey:key]];
//    }
//    DDLogDebug(@"~~~~~~~ Keys loaded (%d)", (int)keys.count);
//    for (int i=0; i<[keys count]; ) {
//        DCKeyObject *key = [keys objectAtIndex:i];
//        if (!key.pileId) {
//            [keys removeObject:key];
//            continue;
//        }
//        i++;
//    }
//    self.poleKeys = keys;
//}

//- (void)loadPolesWithCurKEYs {
//    if (!self.user) {
//        return;
//    }
//    
//    NSString *userId = self.user.userId;
//    NSMutableArray *ownedPoles = [NSMutableArray array];
//    NSMutableArray *accessiblePoles = [NSMutableArray array];
//    NSMutableArray *chargeablePoles = [NSMutableArray array];
//    NSArray *dbPoles = [DCDatabasePole polesOfUserAsOwner:[userId longLongValue]];
//    for (DCDatabasePole *dbPole in dbPoles) {
//        DCPole *pole = [DCPole poleFromDatabase:dbPole];
//        pole.userId = userId;
//        [ownedPoles addObject:pole];
//        [accessiblePoles addObject:pole];
//        [chargeablePoles addObject:pole];
//    }
//    
//    dbPoles = [DCDatabasePole polesOfUserAsFamily:[userId longLongValue]];
//    for (DCDatabasePole *dbPole in dbPoles) {
//        DCPole *pole = [DCPole poleFromDatabase:dbPole];
//        if (![accessiblePoles containsObject:pole]) {
//            [accessiblePoles addObject:pole];
//        }
//        if (![chargeablePoles containsObject:pole]) {
//            [chargeablePoles addObject:pole];
//        }
//    }
//    
//    dbPoles = [DCDatabasePole polesOfUserAsTenant:[userId longLongValue]];
//    for (DCDatabasePole *dbPole in dbPoles) {
//        DCPole *pole = [DCPole poleFromDatabase:dbPole];
//        if (![chargeablePoles containsObject:pole]) {
//            [chargeablePoles addObject:pole];
//        }
//    }
//
//    self.ownedPoles = ownedPoles;
//    self.accessiblePoles = accessiblePoles;
//    self.chargeablePoles = chargeablePoles;
//}
//
//- (void)fetchChargeablePolesInfo:(NSArray *)poleIds {
//    DDLogDebug(@"~~~~~~~ fetch poles(%@)", poleIds);
//    dispatch_group_t group = dispatch_group_create();
//    for (NSString *poleId in poleIds) {
//        dispatch_group_enter(group);
//        [DCSiteApi postPoleInfo:poleId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            DDLogDebug(@"~~~~~~~ fetch pole(%@) finish", poleId);
//            if ([webResponse isSuccess]) {
//                DCPole *pole = [[DCPole alloc] initWithDict:webResponse.result];
//                [pole savePoleToDatabase];
//            }
//            dispatch_group_leave(group);
//        }];
//    }
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        DDLogDebug(@"~~~~~~~ fetch all poles finish");
//        [self loadPolesWithCurKEYs];
//    });
//}

//- (void)fetchChargeableOrderInfo:(NSArray *)orderIds {
//    if (!self.orders) {
//        self.orders = [NSMutableArray array];
//    }
//    
//    //
//    NSMutableArray *ordersToload = [NSMutableArray arrayWithArray:orderIds];
//    NSMutableArray *ordersToDiscard = [NSMutableArray array];
//    for (DCOrder *order in self.orders) {
//        if ([ordersToload containsObject:order.orderId]) {
//            [ordersToDiscard addObject:[order.orderId copy]];
//        }
//    }
//    [ordersToload removeObjectsInArray:ordersToDiscard];
//    [ordersToDiscard removeAllObjects];
//    
//    // load from database
//    for (NSString *orderId in ordersToload) {
//        DCDatabaseOrder *dbOrder = [DCDatabaseOrder ordersWithOrderId:orderId];
//        if(dbOrder) {
//            [ordersToDiscard addObject:orderId];
//            [self.orders addObject:[DCOrder orderWithDatabaseOrder:dbOrder]];
//        }
//    }
//    [ordersToload removeObjectsInArray:ordersToDiscard];
//    [ordersToDiscard removeAllObjects];
//    
//    
//    DDLogDebug(@"~~~~~~~ fetch orders(%@)", ordersToload);
//    dispatch_group_t group = dispatch_group_create();
//    for (NSString *orderId in ordersToload) {
//        dispatch_group_enter(group);
//        [DCSiteApi getOrderInfo:orderId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            DDLogDebug(@"~~~~~~~ fetch order(%@) finish", orderId);
//            if ([webResponse isSuccess]) {
//                DCOrder *order = [[DCOrder alloc] initWithDict:webResponse.result];
//                [[order databaseObject] saveToDatabase];
//                if (![self.orders containsObject:order]) {
//                    [self.orders addObject:order];
//                }
//            }
//            dispatch_group_leave(group);
//        }];
//    }
//    NSLog(@"fetchChargeableOrderInfo finish");
//}

//- (BOOL)chargePossible {
//    for (DCKeyObject *key in self.poleKeys) {
//        if ((key.keyType == HSSYKeyTypeOwner) || (key.keyType == HSSYKeyTypeFamilyWhiteList) || (key.keyType == HSSYKeyTypeFamilyPeriod)) {
//            return YES;
//        } else if (key.keyType == HSSYKeyTypeTenant) {
//            return YES;
//        }
//    }
//    return NO;
//}

//- (void)startPostRecordTimer {
//    [self.postRecordTimer invalidate];
//    self.postRecordTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeToPostRecord:) userInfo:nil repeats:YES];
//    [self.postRecordTimer fire];
//}
//
//- (void)timeToPostRecord:(NSTimer *)timer {
//    [self.postRecordTask cancel];
//    self.postRecordTask = [self postNeedChargesToServer:nil withCompletion:nil];
//}
//
//// 把未上传的记录上传服务器
//- (NSURLSessionDataTask *)postNeedChargesToServer:(NSArray*)records withCompletion:(void (^)(NSArray* records, BOOL isSuccess))completion {
//    __block NSArray *recordsToPost = nil;
//    if (records) {
//        recordsToPost = records;
//    }
//    else {
//        recordsToPost = [DCDatabaseCharge chargesNeedPost];
//    }
//    if (!recordsToPost || recordsToPost.count == 0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECORD_POSTED object:records];
//        if (completion) {
//            completion(nil, NO);
//        }
//        return nil;
//    }
//    return [DCSiteApi postChargeRecordToServer:recordsToPost completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
//            if (![webResponse isSuccess]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECORD_POSTED object:records];
//                if (completion) {
//                    completion(nil, NO);
//                }
//                DDLogDebug(@"~~~~~~~ ChargeRecord posted (fail)");
//                return;
//            }
//        
//        
//        for (DCChargeRecord *aPostedRecord in recordsToPost) {
//            // MARK Posted once
//            [DCDatabaseCharge markRecordPosted:aPostedRecord.poleNum
//                                              sn:(uint64_t)[aPostedRecord.serialNum longLongValue]
//                                       startTime:[aPostedRecord.startTime timeIntervalSince1970]
//                                         endTime:[aPostedRecord.endTime timeIntervalSince1970]];
//        }
//        
//            DDLogDebug(@"~~~~~~~ ChargeRecord posted (%d)", (int)webResponse.result);
//            NSMutableArray *records = [NSMutableArray array];
//            for (NSDictionary *resultDict in webResponse.result) {
//                // TODO: HSSYChargeRecord? HSSYChargeRecord ？ HSSYChargeRecordPost ？
//                DCChargeRecord *record = [[DCChargeRecord alloc] initWithDict:resultDict];
//                [records addObject:record];
//                NSString *pileId = [resultDict objectForKey:@"pileId"];
//                int64_t sn = [[resultDict objectForKey:@"sequence"] longLongValue];
//                NSTimeInterval startTime = [[resultDict objectForKey:@"startTime"] doubleValue]/1000;
//                NSTimeInterval endTime = [[resultDict objectForKey:@"endTime"] doubleValue]/1000;
//                NSString *receipt = [resultDict objectForKey:@"receipt"];
//                
//                [DCDatabaseCharge markRecordGotResponseData:pileId sn:sn startTime:startTime endTime:endTime responseData:receipt];
//            }
//        
//            if (completion) {
//                completion(records, YES);
//            }
//        
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_RECORD_POSTED object:records];
//        }];
//}

- (void)showUpdateAppAlert {
    if (!self.updateAlert.isVisible) {
        self.updateAlert = [UIAlertView showAlertMessage:@"当前应用版本过低，请更新最新版本" buttonTitles:nil];
        [self.updateAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/"]];
        }];
    }
}

#pragma mark - ViewController
- (UIViewController *)rootViewController {
    return [DCApp appDelegate].window.rootViewController;
}

- (UINavigationController *)rootNavigationController {
    if ([self.rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)self.rootViewController;
    }
    return nil;
}

- (DCTabBarController *)rootTabBarController {
    if ([self.rootNavigationController.hssy_firstViewController isKindOfClass:[DCTabBarController class]]) {
        DCTabBarController *tabBarController = (DCTabBarController *)self.rootNavigationController.hssy_firstViewController;
        return tabBarController;
    }
    return nil;
}

- (void)traverseChildViewControllers:(UIViewController *)vc withBlock:(void (^)(UIViewController *viewController))block {
    block(vc);
    for (UIViewController *child in vc.childViewControllers) {
        [self traverseChildViewControllers:child withBlock:block];
    }
}

#pragma mark - Theme
- (void)setTheme:(HSSYTheme)theme {
    _theme = theme;
    
    [self traverseChildViewControllers:self.rootViewController withBlock:^(UIViewController *viewController) {
        if ([viewController respondsToSelector:@selector(themeDidChange:)]) {
            id<HSSYThemeProtocol> vc = (id<HSSYThemeProtocol>)viewController;
            [vc themeDidChange:theme];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:DCThemeDidChangeNotification object:nil];
}

#pragma mark - Push Notification
- (void)handleRemoteNotificationInfo:(NSDictionary *)userInfo forLaunching:(BOOL)launching {
    DDLogDebug(@"handleRemoteNotification %@ launching %@ state %@", userInfo, launching?@"YES":@"NO", appState());
    
    if (self.user == nil) {
        return;
    }
//    [[DCApp sharedApp] startFetchUserKeysTimer];
    
    DCMessage *message = [[DCMessage alloc] initWithNotificationInfo:userInfo];
    if ([self.handledMessages containsObject:message]) {
        DDLogDebug(@"handled messageId %@", message.messageId);
        return;
    }
    [self.handledMessages addObject:message limitCount:1];
    if (message.type == 1) {
        [DCDefault saveNewMessageCount:[DCDefault loadNewMessageCount] + 1];
    }
    switch ([UIApplication sharedApplication].applicationState) {
        case UIApplicationStateActive: {
            if (message.type == 1) { // 订单
                UIAlertView *alert = [UIAlertView showAlertMessage:message.content buttonTitles:@[@"取消", @"查看"]];
                [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [self presentMessageView:message];
                    }
                }];
                break;
            }
            else if (message.type == 4) { // 评论
                UIAlertView *alert = [UIAlertView showAlertMessage:message.content buttonTitles:@[@"取消", @"确定"]];
                [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        [self presentCircleArticleView:message];
                    }
                }];
                break;
            }
            else{
                UIAlertView *alert = [UIAlertView showAlertMessage:message.content buttonTitles:@[@"确定"]];
                [alert setClickedButtonHandler:^(NSInteger buttonIndex) {
                    
                }];
                break;
            }
        }
        case UIApplicationStateInactive:{
            if (message.type != 1) {
                break;
            }
            else{
                [self presentMessageView:message];
                break;
            }
            
        }
        case UIApplicationStateBackground:{
            DDLogDebug(@"background notify ???");
            break;
        }
        default:
            break;
    }
}

- (void)presentMessageView:(DCMessage *)message {
    if (message.status != DCMessageStatusRead) {
        NSMutableArray *messageIdArray = [NSMutableArray array];
        [messageIdArray addObject:message.messageId];
        [DCSiteApi postMessageIds:messageIdArray status:DCMessageStatusRead type:DCMessageSetTypeSpecial userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (webResponse.isSuccess) {
                message.status = DCMessageStatusRead;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_DID_READ object:message];
                [DCDefault saveNewMessageCount:[DCDefault loadNewMessageCount] - 1];
            }
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"present view messageId %@", message.messageId);
        
        DCOrderDetailViewController *vc = [DCOrderDetailViewController storyboardInstantiateWithIdentifier:@"DCOrderDetailViewController"];
        vc.orderId = message.typeId;
        
        UIViewController *viewPresenter = self.rootViewController;
        while (viewPresenter.presentedViewController) {
            viewPresenter = viewPresenter.presentedViewController;
        }
        [viewPresenter presentViewController:[UINavigationController navControllerWithRootVC:vc] animated:YES completion:nil];
    });
}

- (void)presentCircleArticleView:(DCMessage *)message {
    // 点击查看后把推送的取消
    if (message.status != DCMessageStatusRead) {
        
        NSMutableArray *messageIdArray = [NSMutableArray array];
        [messageIdArray addObject:message.messageId];
        [DCSiteApi postMessageIds:messageIdArray status:DCMessageStatusRead type:DCMessageSetTypeSpecial userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (webResponse.isSuccess) {
                message.status = DCMessageStatusRead;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_DID_READ object:message];
                [DCDefault saveNewMessageCount:[DCDefault loadNewMessageCount] - 1];
            }
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"present view messageId %@", message.messageId);
        
        typeof(self) __weak weakSelf = self;
        
        CircleArticleViewController *vc = [CircleArticleViewController storyboardInstantiateWithIdentifierInAttention:@"CircleArticleViewController"];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.rootViewController.view animated:YES];
        
        [DCSiteApi getArticleInfo:message.typeId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            typeof(weakSelf) __strong strongSelf = weakSelf;
            
            if (![webResponse isSuccess] || strongSelf == nil) {
                [hud hide:YES];
                return;
            }
            [hud hide:YES];
            DCArticle *article = [[DCArticle alloc] initWithDict:webResponse.result];
            vc.article = article;
            
            UIViewController *viewPresenter = strongSelf.rootViewController;
            
            if (strongSelf.lastViewController != nil && [strongSelf.lastViewController isKindOfClass:[CircleArticleViewController class]]) {
                CircleArticleViewController *vc = (CircleArticleViewController *)strongSelf.lastViewController;
                if ([vc.article.articleId isEqualToString:article.articleId]) {
                    vc.article = article;
                    [vc reloadTableView];
                    return;
                } else {
                    if (viewPresenter.presentedViewController != nil) {
                        CircleArticleViewController *vc1 = (CircleArticleViewController *)strongSelf.lastViewController;
                        vc1.article = article;
                        [vc1 reloadTableView];
                        return;
                    }
                    CircleArticleViewController *vc2 = [CircleArticleViewController storyboardInstantiateWithIdentifierInAttention:@"CircleArticleViewController"];
                    vc2.article = article;
                    [viewPresenter presentViewController:[UINavigationController navControllerWithRootVC:vc2] animated:YES completion:nil];
                }
            } else {
                [viewPresenter presentViewController:[UINavigationController navControllerWithRootVC:vc] animated:YES completion:nil];
            }
        }];
    });
}

#pragma mark - Notification
- (void)handleTokenExpired:(NSNotification *)notif {
    NSURLSessionTask *task = notif.object;
    NSString *token = task.currentRequest.allHTTPHeaderFields[@"token"];
    DDLogDebug(@"~~~~~~~ token expired %@", token);
    if ([token isEqualToString:self.user.token] && (!self.refreshTokenTask)) {
        DDLogDebug(@"~~~~~~~ refresh token ...");
        self.refreshTokenTask = [DCSiteApi refreshToken:self.user.refreshToken userId:self.user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            self.refreshTokenTask = nil;
            if ([webResponse isSuccess]) { // refresh token success
                NSString *accessToken = [[webResponse.result dictionaryObject] stringForKey:@"accessToken"];
                NSString *refreshToken = [[webResponse.result dictionaryObject] stringForKey:@"refreshToken"];
                DDLogDebug(@"~~~~~~~ refresh token result \naccessToken:%@ \nrefreshToken:%@", accessToken, refreshToken);
                if (accessToken && refreshToken) {
                    self.user.token = accessToken;
                    self.user.refreshToken = refreshToken;
                    [DCDefault saveLoginedUser:self.user];
                    return;
                }
            }
            
            // TODO: if refresh failed: 1.disconnect ble; 2.clean all the keys in database;
            self.user = nil;
            [DCDefault saveLoginedUser:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_DID_CHANGE object:nil];
            
            [self popToRootViewController];
            UIAlertView *loginAlert = [UIAlertView showAlertMessage:@"您的账号授权已过期，请重新登录" title:@"温馨提示" buttonTitles:@[@"重新登录", @"忽略"]];
            [loginAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.rootViewController presentLoginViewIfNeededCompletion:nil];
                }
            }];
        }];
    }
}

- (void)handleTokenInvalid:(NSNotification *)note {
    if (self.user) {
        self.user = nil;
        [DCDefault saveLoginedUser:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_DID_CHANGE object:nil];
        
        [self popToRootViewController];
        UIAlertView *loginAlert = [UIAlertView showAlertMessage:@"您的账号已在其他设备登录,已从本设备下线,请检查." title:@"温馨提示" buttonTitles:@[@"重新登录", @"忽略"]];
        [loginAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self.rootViewController presentLoginViewIfNeededCompletion:nil];
            }
        }];
    } else {
        [self popToRootViewController];
        [self.rootViewController presentLoginViewIfNeededCompletion:nil];
    }
}

- (void)handleRefreshTokenExpired:(NSNotification *)note {
    if (self.user) {
        self.user = nil;
        [DCDefault saveLoginedUser:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_DID_CHANGE object:nil];
        
        [self popToRootViewController];
        UIAlertView *loginAlert = [UIAlertView showAlertMessage:@"您的账号登录信息已过期，请重新登录." title:@"温馨提示" buttonTitles:@[@"重新登录", @"忽略"]];
        [loginAlert setClickedButtonHandler:^(NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                [self.rootViewController presentLoginViewIfNeededCompletion:nil];
            }
        }];
    } else {
        [self popToRootViewController];
        [self.rootViewController presentLoginViewIfNeededCompletion:nil];
    }
}

- (void)popToRootViewController {
    // remove pop up view
    for (UIView *view in [DCApp appDelegate].window.subviews) {
        if ([view isKindOfClass:[PopUpView class]]) {
            PopUpView *popUpView = (PopUpView *)view;
            [popUpView dismiss];
        }
    }
    
    [self.rootViewController dismissViewControllerAnimated:NO completion:nil];
    [self.rootNavigationController popToRootViewControllerAnimated:NO];
    
//    HSSYSearchViewController *mapVC = self.rootTabBarController.viewControllers[DCTabIndexSearch];
//    [mapVC deselectPoleAnnotation:nil];
//    self.rootTabBarController.selectedIndex = DCTabIndexUser;
    
//    [HSSYApp appDelegate].window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
}

// 用户登出、token无效、
- (void)userDidChange:(NSNotification *)note {
    if (!self.user) {
        // 1.清空必要的数据库数据
        // KEY 部分
        self.poleKeys = [NSArray array];
        [DCDatabasePole cleanAllPolesInDataBase];
        [DCDatabaseUser cleanAllUsersInDataBase];
        [DCDatabaseKey cleanAllKeysInDataBase];
    }
}

- (void)updateApplicationBadge:(NSNotification *)note {
    NSInteger newMessageCount = [DCDefault loadNewMessageCount];
    [UIApplication sharedApplication].applicationIconBadgeNumber = newMessageCount;
    [JPUSHService setBadge:newMessageCount];
}

- (void)handleCurrentVIewController:(NSNotification *)notification {
    if ([[notification userInfo] objectForKey:@"lastViewController"]) {
        self.lastViewController = [[notification userInfo] objectForKey:@"lastViewController"];
    }
}

#pragma mark - Reachability
- (void)startReachabilityNotifier {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotificationx object:nil];
        
        //Change the host name here to change the server you want to monitor.
        NSString *remoteHostName = @"www.baidu.com";
        
        self.hostReachability = [Reachabilityx reachabilityWithHostName:remoteHostName];
        [self.hostReachability startNotifier];
    });
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachabilityx *reachability = [note object];
    if (reachability == self.hostReachability) {
        NetworkStatusx netStatus = [reachability currentReachabilityStatus];
        if (netStatus == NotReachable) {
            if (!self.notReachableAlert.isVisible) {
                self.networkStatus = netStatus;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_CHANGE_FAUTL object:nil];
                self.notReachableAlert = [UIAlertView showAlertMessage:@"当前网络不可用，请检查你的网络设置" buttonTitles:@[@"确定"]];
            }
        }
        
        if (self.networkStatus != netStatus && (netStatus == ReachableViaWiFi || netStatus == ReachableViaWWAN) && self.networkStatus == NotReachable) {
            self.networkStatus = netStatus;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NETWORK_CHANGE_SUCCESS object:nil];
        }
    }
}

#pragma mark - Function
- (void)callPhone:(NSString *)phone viewController:(UIViewController *)vc{
//    if (!self.callWebView) {
//        self.callWebView = [UIWebView new];
//    }
//    [self.callWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]]]];
    
    NSMutableString* str1=[[NSMutableString alloc]initWithString:phone];//存在堆区，可变字符串
    [str1 insertString:@"-"atIndex:3];//把一个字符串插入另一个字符串中的某一个位置
    [str1 insertString:@"-"atIndex:8];//把一个字符串插入另一个字符串中的某一个位置
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str1 message:nil preferredStyle:UIAlertControllerStyleAlert];
    // 设置popover指向的item
    alert.popoverPresentationController.barButtonItem = vc.navigationItem.leftBarButtonItem;
    // 添加按钮
    [alert addAction:[UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSLog(@"点击了呼叫按钮");
        NSString* phoneStr = [NSString stringWithFormat:@"tel://%@",phone];
        if ([phoneStr hasPrefix:@"sms:"] || [phoneStr hasPrefix:@"tel:"]) {
            UIApplication * app = [UIApplication sharedApplication];
            if ([app canOpenURL:[NSURL URLWithString:phoneStr]]) {
                [app openURL:[NSURL URLWithString:phoneStr]];
            }
        }
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        NSLog(@"点击了取消按钮");
    }]];
    
    [vc presentViewController:alert animated:YES completion:nil];
}

@end

//
//  AppDelegate.m
//  Charging
//
//  Created by xpg on 14/12/8.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "AppDelegate.h"
#import "DCCommon.h"
#import "DCMapManager.h"
#import "UIViewController+HSSYExtensions.h"
#import "DCDatabase.h"
#import "DCApp.h"
#import "DCSiteApi.h"
#import "Reachability.h"
#import "JPUSHService.h"
#import "UIDeviceHardware.h"
#import "MobClick.h"
#import <AudioToolbox/AudioToolbox.h>
#import "IQKeyboardManager.h"
#import "Charging-Swift.h"
#import "BeeCloud.h"
#import "DCUVPrice.h"

#if DEBUG
const NSUInteger ddLogLevel = DDLogLevelAll;
#else
const NSUInteger ddLogLevel = DDLogLevelError;
#endif

@interface AppDelegate (){
    UIAlertView *alert;
}
@property (nonatomic) Reachabilityx *hostReachability;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //手机别名： 用户定义的名称
    NSString* userPhoneName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", userPhoneName);
    //设备名称
    NSString *platform = [[[UIDeviceHardware alloc] init] platformString];
    NSLog(@"设备类型: %@",platform );
    //手机系统版本
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", phoneVersion);
    //手机型号
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",phoneModel );
    //地方型号  （国际化区域名称）
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    NSLog(@"国际化区域名称: %@",localPhoneModel );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用名称
    NSString *appCurName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"当前应用名称：%@",appCurName);
    // 当前应用软件版本  比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"当前应用软件版本:%@",appCurVersion);
    // 当前应用版本号码   int类型
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSLog(@"当前应用版本号码：%@",appCurVersionNum);
    
    //     Override point for customization after application launch.
    
    //    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    // Unit Test
    if (isRunningTests()) {
        self.window.rootViewController = nil;
        return YES;
    }
    
    [self setupAppearance];
    if (isTestMode()) {
        NSString *identifier = @"DCRegistSuccessViewController";
        self.window.rootViewController = [UINavigationController navControllerWithRootVC:[UIViewController storyboardInstantiateWithIdentifier:identifier]];
        return YES;
    }
    
    // launch log
    [self configureLumberjack];
//    DDLogDebug(@"\n=======\n didFinishLaunchingWithOptions %@\n=======", appState());
    
    // infrastructure
    [self configureDatabase];
    [self configureUmeng];
    [[DCMapManager shareMapManager] configureBaiduMap];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [self configureJPushWithOptions:launchOptions];
    [self configureShareSDK];
    [self configureBeeCloud];
    
    // business
    [DCApp sharedApp].user = [DCDefault loadLoginedUser];
//    if([DCApp sharedApp].user) { // data initialize, specially for Offline charging
        // load keys
//        [[DCApp sharedApp] loadKeysFromDatabaseWithCurUser];
        // load Poles
//        [[DCApp sharedApp] loadPolesWithCurKEYs];
//    }
    
//    [[DCApp sharedApp] startFetchUserKeysTimer];
//    [[DCApp sharedApp] startPostRecordTimer];
    
    // 首先进入找桩
    [DCApp sharedApp].rootTabBarController.selectedIndex = 1;
    if ([DCApp sharedApp].user) {
        [DCSiteApi getUserChargingStatus:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                return;
            }
            if ([[webResponse.result objectForKey:@"charging"] boolValue] == YES) {
                [DCApp sharedApp].rootTabBarController.selectedIndex = 0;
                [[DCApp sharedApp].rootTabBarController updateNavigationBar];
                [[DCApp sharedApp].rootTabBarController.view setNeedsLayout];
                [[DCApp sharedApp].rootTabBarController.view layoutIfNeeded];
            }
        }];
    }
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        DDLogDebug(@"UIApplicationLaunchOptionsRemoteNotificationKey %@", appState());
        [[DCApp sharedApp] handleRemoteNotificationInfo:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey] forLaunching:YES];
    }
    
    [[DCApp sharedApp] startReachabilityNotifier];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    [BMKMapView willBackGround];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    DDLogDebug(@"applicationWillEnterForeground");
    
//    [[DCApp sharedApp] startFetchUserKeysTimer];
//    [[DCApp sharedApp] startPostRecordTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [BMKMapView didForeGround];
    
    DDLogDebug(@"applicationDidBecomeActive");
    application.applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    DDLogDebug(@"openURL:%@", url);
    if (![BeeCloud handleOpenUrl:url]) {
//        return NO;
    }
    return YES;
}

#pragma mark - Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    DDLogDebug(@"didRegisterForRemoteNotificationsWithDeviceToken %@", deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
    
    NSString *pushId = [JPUSHService registrationID];
    DDLogDebug(@"JPush registrationID %@", pushId);
    
    if ([DCApp sharedApp].user) {
        [DCSiteApi postBindPushId:pushId userId:[DCApp sharedApp].user.userId pushEnable:YES completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if ([webResponse isSuccess]) {
                DDLogDebug(@"Bind UserId %@ PushId %@", [DCApp sharedApp].user.userId, pushId);
            }
        }];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    DDLogDebug(@"didFailToRegisterForRemoteNotificationsWithError %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    DDLogDebug(@"didReceiveRemoteNotification %@", appState());
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[DCApp sharedApp] handleRemoteNotificationInfo:userInfo forLaunching:NO];
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    DDLogDebug(@"didReceiveRemoteNotificationWithHandler %@", appState());
    //    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[DCApp sharedApp] handleRemoteNotificationInfo:userInfo forLaunching:NO];
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

//Available in iOS 8.0 and later
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    DDLogDebug(@"didRegisterUserNotificationSettings %@", notificationSettings);
}

#pragma mark - Configure
- (void)configureUmeng {
    //deviceID
    //    Class cls = NSClassFromString(@"UMANUtil");
    //    SEL deviceIDSelector = @selector(openUDIDString);
    //    NSString *deviceID = nil;
    //    if(cls && [cls respondsToSelector:deviceIDSelector]){
    //        deviceID = [cls performSelector:deviceIDSelector];
    //    }
    //    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:@{@"oid" : deviceID}
    //                                                       options:NSJSONWritingPrettyPrinted
    //                                                         error:nil];
    //
    //    NSLog(@"Umeng %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    [MobClick startWithAppkey:@"5731a840e0f55a27e80010a9" reportPolicy:BATCH channelId:UmengChannelId];
}

- (void)configureLumberjack {
#if defined(DEBUG) && DEBUG
    setenv("XcodeColors", "YES", 0);
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    // Load setting colors
    NSString * colorListPath = [[NSBundle mainBundle] pathForResource:@"SelfDefine/LogColor/ColorListForCocoaLumberjack" ofType:@"plist"];
    if (colorListPath) {
        NSDictionary *colorListDict = [NSDictionary dictionaryWithContentsOfFile:colorListPath];
        if (colorListDict) {
            NSString *keyError = @"Error";
            NSString *keyWarning = @"Warning";
            NSString *keyInfo = @"Info";
            NSString *keyDebug = @"Debug";
            NSString *keyVerbose = @"Verbose";
            
            NSArray *colorKeyArr = @[keyError, keyWarning, keyInfo, keyDebug, keyVerbose];
            
            NSDictionary *colorDict = nil;
            for (NSString *key in colorKeyArr) {
                colorDict = [colorListDict objectForKey:key];
                if (colorDict) {
                    NSNumber *RColorValue = [colorDict objectForKey:@"Red"];
                    NSNumber *GColorValue = [colorDict objectForKey:@"Green"];
                    NSNumber *BColorValue = [colorDict objectForKey:@"Blue"];
                    NSNumber *AColorValue = [colorDict objectForKey:@"Alpha"];
                    if (RColorValue && GColorValue && BColorValue && AColorValue) {
                        UIColor *color = [UIColor colorWithRed:[RColorValue floatValue] green:[GColorValue floatValue] blue:[BColorValue floatValue] alpha:[AColorValue floatValue]];
                        if ([key isEqualToString:keyError]) {
                            [[DDTTYLogger sharedInstance] setForegroundColor:color backgroundColor:nil forFlag:DDLogFlagError];
                        }
                        else if ([key isEqualToString:keyWarning]) {
                            [[DDTTYLogger sharedInstance] setForegroundColor:color backgroundColor:nil forFlag:DDLogFlagWarning];
                        }
                        else if ([key isEqualToString:keyInfo]) {
                            [[DDTTYLogger sharedInstance] setForegroundColor:color backgroundColor:nil forFlag:DDLogFlagInfo];
                        }
                        else if ([key isEqualToString:keyDebug]) {
                            [[DDTTYLogger sharedInstance] setForegroundColor:color backgroundColor:nil forFlag:DDLogFlagDebug];
                        }
                        else if ([key isEqualToString:keyVerbose]) {
                            [[DDTTYLogger sharedInstance] setForegroundColor:color backgroundColor:nil forFlag:DDLogFlagVerbose];
                        }
                        
                    }
                }
            }
        }
    }
    
    
    
    
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:1.000 green:0.000 blue:0.028 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagError];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:1.000 green:0.921 blue:0.000 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagWarning];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.000 green:0.888 blue:0.041 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagInfo];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.000 green:0.969 blue:0.960 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagDebug];
//    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.848 green:0.866 blue:1.000 alpha:1.000] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
#endif
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    
#if defined(DEBUG) && DEBUG
    DDLogVerbose(@"Verbose");
    DDLogDebug(@"Debug");
    DDLogInfo(@"Info");
    DDLogWarn(@"Warn");
    DDLogError(@"Error");
#endif

}

- (void)configureDatabase {
    [[DCDatabase db] setupDatabase:nil completion:nil];
}

- (void)configureJPushWithOptions:(NSDictionary *)launchOptions {
        //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    // Required
    [JPUSHService setupWithOption:launchOptions appKey:@"abe98bc6c73a5e37a6434443" channel:@"App Store" apsForProduction:YES advertisingIdentifier:nil];
    
    /*
     if ([HSSYApp sharedApp].user) {
     [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeSound |
     UIRemoteNotificationTypeAlert)
     categories:nil];
     } else {
     [application unregisterForRemoteNotifications];
     }
     */
}

- (void)configureShareSDK {
    //初始化sdk
    [ShareSDK registerApp:@"1a259a6f7058c" activePlatforms:@[
                                                            @(SSDKPlatformTypeWechat),
                                                            @(SSDKPlatformTypeQQ),
                                                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class]
                                        tencentOAuthClass:[TencentOAuth class]];
                             break;
                         default:
                             break;
                     }
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              switch (platformType)
              {
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wxabe3f9deff1ef510"
                                            appSecret:@"97b3a42e2c3bcb9ba8e51d17d0821ff1"];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"1105637323"
                                           appKey:@"aRom83KBbnNkRba5"
                                         authType:SSDKAuthTypeBoth];
                      break;
                  default:
                      break;
              }
          }];
}

- (void)configureBeeCloud {
    //初始化BeeCloud
    //TODO: 支付宝只可以使用开发环境
    if ([SERVER_URL isEqualToString:SERVER_URL_RELEASE]) {  //生产环境
        [BeeCloud initWithAppID:@"b1c6e4ce-e1db-4190-840d-34e29a211c0b" andAppSecret:@"1793db21-090b-427f-a53a-02133f22030f"];
    }
    else if ([SERVER_URL isEqualToString:SERVER_URL_DEV]){  //开发环境
        [BeeCloud initWithAppID:@"b1c6e4ce-e1db-4190-840d-34e29a211c0b" andAppSecret:@"1793db21-090b-427f-a53a-02133f22030f"];
    }
    else {
        DDLogError(@"Unknow server url for BeeCloud");
    }
    //初始化微信
    [BeeCloud initWeChatPay:@"wxabe3f9deff1ef510"];
}

- (void)setupAppearance {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    if ([UIDevice systemVersionLessThan8]) {
        
    } else {
        [UINavigationBar appearance].translucent = NO;
    }
    [UINavigationBar appearance].barStyle = UIBarStyleBlack;
    [UINavigationBar appearance].barTintColor = [UIColor paletteDCMainColor];
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].shadowImage = [UIImage new];
    [UITabBar appearance].barTintColor = [UIColor whiteColor];
    [[IQKeyboardManager sharedManager] disableInViewControllerClass:[SLKTextViewController class]];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.xpg.Charging" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Charging" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Charging.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end

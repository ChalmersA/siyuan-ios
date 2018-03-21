//
//  DCChargingViewController.m
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//
#import "DCChargingViewController.h"
#import "DCChargeDoneViewController.h"
#import "DCSiteApi.h"
#import "DCPile.h"
#import "DCScanQrcodeParams.h"
#import "ScanQrcodeView.h"
#import "DCChargingAnimationView.h"
#import "Charging-Swift.h"
#import "DCChargePort.h"
#import "DCSelectChargeModeView.h"
#import "DCChargeConfirmView.h"
#import "ChargePortView.h"
#import "DCM2MServer.h"
#import "DCChargingCurrentData.h"
#import "DCStartChargeParams.h"
#import "DCOneButtonAlertView.h"
#import "DCNotPayAlertView.h"
#import "DCOrderDetailViewController.h"
#import "CarouselView.h"
#import "DCDynamicDetailsList.h"
#import "DCDynamicDetailsViewController.h"

#import "DCHTTPSessionManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSObject+AutoDescription.h"
#import "UIImage+GIF.h"
#import "NSString+HSSY.h"

#import "ManualInputAlertView.h"

NSString * const DEVICE_TYPE_AC = @"0";
NSString * const DEVICE_TYPE_DC = @"1";

@interface DCChargingViewController () <ScanQrcodeViewDelegate, DCPopupViewDelegate, DCM2MServerDelegate, ChargePortViewDelegate, ChargeConfirmViewDelegate, SelectChargeModeViewDelegate, DCOneButtonAlertViewDelegate, DCNotPayAlertViewDelegate, CarouselViewDelegate, ChargeDoneViewDelegate> {
    
    BOOL isCharging;
    BOOL flashLightState;
    int requestOrderCount;
    DCAlertType popUpType;
}

@property (weak, nonatomic) DCPopupView *changeChargePortPopUpView;
@property (weak, nonatomic) DCPopupView *selectPopUpView;
@property (weak, nonatomic) DCPopupView *confirmPopUpView;
@property (weak, nonatomic) DCPopupView *warmPopUpView;
@property (weak, nonatomic) DCSelectChargeModeView *selectView;
@property (weak, nonatomic) DCChargeConfirmView *confirmView;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *homePageView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIImageView *scanImageView;

@property (weak, nonatomic) IBOutlet ScanQrcodeView *scanQrcodeView; //扫码充电view
@property (weak, nonatomic) IBOutlet UIButton *flashLightButton; //闪光灯-关/开
@property (weak, nonatomic) IBOutlet UIButton *inputCodeButton;  //手动输入编码

@property (nonatomic, strong) ManualInputAlertView *alertView;   //alertView

@property (weak, nonatomic) IBOutlet UIView *charingView;
@property (weak, nonatomic) IBOutlet DCChargingAnimationView *chargingAnimationView;
@property (weak, nonatomic) IBOutlet UILabel *chargingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeModeLabel;
@property (weak, nonatomic) IBOutlet UILabel *electricLabel;
@property (weak, nonatomic) IBOutlet UIImageView *highLigthView;
//@property (weak, nonatomic) IBOutlet UILabel *electricIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *pileTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;

@property (weak, nonatomic) IBOutlet UIButton *endButton; //暂停按钮

@property (strong, nonatomic) AVCaptureDevice *flashLightDevice;
@property (strong, nonatomic) AVCaptureSession *flashLightSession;

@property (strong, nonatomic) DCScanQrcodeParams *scanQrcodeParams;         //扫码后的参数
//@property (strong, nonatomic) DCPile *pileDetailCharge;                     //桩的详细
@property (strong, nonatomic) DCChargePort *detailChargePort;               //充电口信息

@property (strong, nonatomic) DCStartChargeParams *startChargeParams;              //启动充电参数

@property (strong, nonatomic) DCM2MServer *m2mServer;                       //连接M2M服务器
@property (strong, nonatomic) DCChargingCurrentData *charingCurrentParam;   //实时充电数据
@property (strong, nonatomic) DCOrder *chargedOrder;

//@property (strong, nonatomic) NSTimer *requestOrderStateTimer;              //获取order

@property (strong, nonatomic) NSURLSessionDataTask *requestScanTask; //获取扫码信息Task
//@property (strong, nonatomic) NSURLSessionDataTask *requestGprsOrderTask; //获取GPRS桩的充电记录Task

@property (copy, nonatomic) NSString *gprsOrderId;
@property (nonatomic, retain) DCOrder *gprsOrder;

@property (assign, nonatomic) DCChargingState initChargingState;
@property (strong, nonatomic) CarouselView *loopView;

@end

@implementation DCChargingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"扫码充电";
    
    self.topView.layer.cornerRadius = 6;
    self.topView.layer.masksToBounds = YES;
    
    [self.hssy_tabBarController updateNavigationBar];
    
//    self.initChargingState = DCChargingStateHomePage;
        self.initChargingState = DCChargingStateScaning;

    
    isCharging = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidChange:) name:NOTIFICATION_USER_DID_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusFault) name:NOTIFICATION_NETWORK_CHANGE_FAUTL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusSuccess) name:NOTIFICATION_NETWORK_CHANGE_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    if (!isCharging) {
//        if (self.chargingState != self.initChargingState) {
//            self.chargingState = DCChargingStateHomePage;
//        } else {
//            self.chargingState = DCChargingStateHomePage;
//        }
        self.chargingState = DCChargingStateScaning;

//        [self requestForTopView];
        [self checkUserGprsChargingWithBlock:nil];
    } else {
        self.chargingState = DCChargingStateCharging;
        self.endButton.enabled = YES;
    }
    
    [self judgeCamera];// 判断相机权限

}

#pragma mark --- 判断相机权限
- (void)judgeCamera
{
    //======判断 访问相机 权限是否开启=======
    AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //===无权限====
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied){
        //====没有权限====
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"您尚未开启允许访问相机权限，请前往设置开启" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            //===无权限 引导去开启===
            [self openJurisdiction];
        }];
        // 将UIAlertAction添加到UIAlertController中
        [alertController addAction:cancel];
        [alertController addAction:ok];
        // present显示
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else{  //===有权限======
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {   //相机可用
            
        }else{  // 相机不可用
//            [SVProgressHUD showErrorWithStatus:@"相机不可用"];
            return;
        }
    }
}

#pragma mark-------去设置界面开启权限----------
-(void)openJurisdiction{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [self.requestScanTask cancel];
    self.requestScanTask = nil;
    
    [self.selectPopUpView dismiss];
    [self.scanQrcodeView stopScan];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DCChargeDoneViewController"]) {
        DCChargeDoneViewController *vc = segue.destinationViewController;
        vc.orderId = sender;
    } else if ([segue.identifier isEqualToString:@"DCOrderDetailViewController"]) {
        DCOrderDetailViewController *vc = segue.destinationViewController;
        vc.orderId = sender;
    }
}

#pragma mark - Storyboard
+ (instancetype)storyboardInstantiate {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"DCChargingViewController"];
}

#pragma mark - Notification
- (void)userDidChange:(NSNotification *)note {
    if (![DCApp sharedApp].user) { // logout
        
        // when user logout change to unknown state
        isCharging = NO;
        [self.m2mServer cutOffSocket];
        if (self.chargingState == DCChargingStateCharging) {
//            self.chargingState = DCChargingStateHomePage;
            self.chargingState = DCChargingStateScaning;

        }
    }
}

- (void)appDidBecomeActive:(NSNotification *)note { // UIApplicationDidBecomeActiveNotification
    [self.selectPopUpView dismiss];
    self.chargingState = _chargingState;
}

#pragma mark RequestForTopView
- (void)requestForTopView {
    [self.loopView removeFromSuperview];
    CGRect topViewRect = self.topView.frame;
    
    self.loopView = [[CarouselView alloc] initWithFrame:CGRectMake(self.topView.bounds.origin.x, self.topView.bounds.origin.y, topViewRect.size.width, topViewRect.size.height)];
    self.loopView.delegate = self;
    
    NSMutableArray *dataArray = [NSMutableArray array];
    [DCSiteApi getNewsListWithNewType:DCNewTypeTop page:1 pageSize:10 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self showHUDText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        
        NSArray *dynamicListArray = [webResponse.result arrayObject];
        for (NSDictionary *dict in dynamicListArray) {
            DCDynamicDetailsList *dynamicDetail = [[DCDynamicDetailsList alloc] initWithDict:dict];
            [dataArray addObject:dynamicDetail];
        }
        
        if (dataArray.count > 0) {
            self.loopView.array = dataArray;
        }
        
        if (![[self.topView.subviews firstObject] isKindOfClass:[CarouselView class]]) {
            [self.topView addSubview:self.loopView];
            [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[loopView]|" options:0 metrics:nil views:@{@"loopView":self.loopView}]];
            [self.topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[loopView]|" options:0 metrics:nil views:@{@"loopView":self.loopView}]];
        }
    }];
    
}

- (void)clickTheTopOfImageViewWithUrl:(NSString *)url sourceType:(NSInteger)sourceType {
    DCDynamicDetailsViewController *vc = [DCDynamicDetailsViewController storyboardInstantiateWithIdentifierInAttention:@"DCDynamicDetailsViewController"];
    vc.url = url;
    vc.soucrceType = sourceType;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark popUpView dismiss
- (void)popUpViewDismiss:(DCPopupView *)view {
    if (popUpType == DCAlertTypeException) {
//        [self endCharging:self.endButton];
        [self jumpToChargeDoneVCWithOrderId:self.m2mServer.orderId];
        popUpType = DCAlertTypeUnkown;
    } else if (view == self.changeChargePortPopUpView){
        
        [self.changeChargePortPopUpView dismiss];
        [self loadSelectChargeModeViewWithStartChargeParams:self.startChargeParams];
    } else {
        self.chargingState = DCChargingStateScaning;
    }
}

- (void)clickForResignFirstResponse {
    [self.confirmView.moneyTextfield resignFirstResponder];
    [self.confirmView.powerTextfield resignFirstResponder];
}

#pragma mark 充电自检
- (void)checkUserGprsChargingWithBlock:(void (^)(BOOL success))charging{ //判断用户之前是否在充电
    self.chargingState = _chargingState;
    DCUser *user = [DCApp sharedApp].user;
    if (user == nil) {
        return;
    }
    
    typeof(self) __weak weakSelf = self;
    [DCSiteApi getUserChargingStatus:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        
        typeof(weakSelf) __strong strongSelf = weakSelf;
        if ([[webResponse.result objectForKey:@"charging"] boolValue] == NO) {
            if (charging) {
                charging(NO);
            }
            return;
        }
        else {
            if (charging) {
                charging(YES);
            }
            isCharging = YES;
            strongSelf.m2mServer = [[DCM2MServer alloc] initWithDict:webResponse.result isCharing:YES];
            strongSelf.m2mServer.delegate = strongSelf;
            [self chargeModeDescription:strongSelf.m2mServer.chargePort.chargeMode];
            [self titleWithStationName:strongSelf.m2mServer.stationName withPileName:strongSelf.m2mServer.pileName withChargePort:strongSelf.m2mServer.chargePort.index];
            strongSelf.chargingState = DCChargingStateCharging;
        }
    }];
}

#pragma mark - State
- (void)setChargingState:(DCChargingState)chargingState {
    NSLog(@"setChargingState %d", (int)chargingState);
    _chargingState = chargingState;
    self.backgroundImageView.hidden = YES;
    //HomePageView
    self.homePageView.hidden = YES;
//    [self.scanImageView stopAnimating];
    
    //scanQrcodeView
    self.scanQrcodeView.hidden = YES;
    
    //闪光灯
    self.flashLightButton.hidden = YES;
    self.inputCodeButton.hidden = YES;
    
    //chargingView
    self.charingView.hidden = YES;
//    [self.chargingAnimationView stopAnimation];
    
    switch (chargingState) {
//        case DCChargingStateHomePage: {
//            
//            self.homePageView.hidden = NO;
//            
//            self.scanImageView.userInteractionEnabled = YES;
//            UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeTheChargingState)];
//            [self.scanImageView addGestureRecognizer:touch];
//            
//            NSMutableArray *imgArray = [NSMutableArray array];
//            for (int i = 0; i < 26; i++) {
//                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"charge%d.png", i]];
//                [imgArray addObject:image];
//            }
//            self.scanImageView.animationImages = imgArray;
//            self.scanImageView.animationDuration = 1;
//            self.scanImageView.animationRepeatCount = 0;
//            [self.scanImageView startAnimating];
////            NSString  *filePath = [[NSBundle bundleWithPath:[[NSBundle mainBundle] bundlePath]] pathForResource:@"scan.gif" ofType:nil];
////            NSData  *imageData = [NSData dataWithContentsOfFile:filePath];
////            self.scanImageView.image = [UIImage sd_animatedGIFWithData:imageData];
//        }
//            break;
            
        case DCChargingStateScaning: {
            
            UIView *statusBarView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
            statusBarView.backgroundColor=[UIColor paletteDCMainColor];
            [self.view addSubview:statusBarView];
            
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
            
            self.scanQrcodeView.hidden = NO;
            self.flashLightButton.hidden = NO;
            self.inputCodeButton.hidden = NO;

            flashLightState = 0; //flashLight OFF
            [self.flashLightButton addTarget:self action:@selector(flashLightOnOrOff) forControlEvents:UIControlEventTouchUpInside];
            [self.inputCodeButton addTarget:self action:@selector(inputCodeAlertView) forControlEvents:UIControlEventTouchUpInside];
            
            self.scanQrcodeView.delegate = self;
            [self.scanQrcodeView startScan];

        }
            break;

        case DCChargingStateCharging: {
            self.backgroundImageView.hidden = NO;

            [self.scanQrcodeView stopScan];
            
            self.charingView.hidden = NO;
//            [self.chargingAnimationView startAnimation];

        }
            break;
        default:
            break;
    }
}

#pragma mark 扫码后回调
- (void)scanSuccess:(NSString *)qrcode {
    self.startChargeParams = nil;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        [hud hide:YES];
        return;
        
    } else {
        NSLog(@"扫码成功");
        DCUser *user = [DCApp sharedApp].user;
        
        typeof(self) __weak weakSelf = self;
        self.requestScanTask = [DCSiteApi getPileInfoAfterScan:qrcode userId:user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            typeof(weakSelf) __strong strongSelf = weakSelf;
            if (![webResponse isSuccess]) {
                
                if (webResponse.code == RESPONSE_CODE_CHARGE_ISCHARGING) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"发现用户正在充电中,是否跳转到充电信息页面?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alertView setClickedButtonHandler:^(NSInteger buttonIndex) {
                        if (buttonIndex == 1) {
                            [self checkUserGprsChargingWithBlock:nil];
                        }
                    }];
                    return;
                }
                
                if (webResponse.code == RESPONSE_CODE_CHARGE_NON_IDLE) {
                    DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeCharging];
                    view.delegate = self;
                    self.warmPopUpView = [DCPopupView popUpWithTitle:@"温馨提示" contentView:view withController:self];
                }
                
                [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                DDLogDebug(@"scan QRCode success but can not get response");
                hud.completionBlock = ^{
                    self.chargingState = DCChargingStateScaning;
                };
                return;
            }
            
            [hud hide:YES];
            strongSelf.scanQrcodeParams = [[DCScanQrcodeParams alloc] initScanQrcodeParamsWithDict:webResponse.result];
            strongSelf.startChargeParams = [strongSelf getTheStartChargeParams:strongSelf.scanQrcodeParams];
            if (strongSelf.startChargeParams.isHasChargePort) {
                [strongSelf loadSelectChargeModeViewWithStartChargeParams:strongSelf.startChargeParams];
            } else {
                DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeNoChargePort];
                view.delegate = self;
                strongSelf.warmPopUpView = [DCPopupView popUpWithTitle:@"温馨提示" contentView:view withController:self];
            }
        }];
    }
}

-(void)scanError:(NSError *)error {
    DDLogDebug(@"camera not open");
}

#pragma mark 获取GPRS桩的实时参数
//纯GPRS桩的实时参数
- (void)gprsRequestChargeCurrentParam:(DCChargingCurrentData *)currentParams {
    //5秒再次拿实时参数时才能点击停止.
    self.endButton.enabled = YES;
    
    if ([currentParams.device_status isEqualToString:CHARGE]) {
        self.electricLabel.text = @"待充电";
        self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_leisure"];

//        self.electricIconLabel.text = @"...";
    }
    
    self.voltageLabel.text = [NSString stringWithFormat:@"%.1f", currentParams.voltage];
    self.currentLabel.text = [NSString stringWithFormat:@"%.2f", currentParams.current];
    if ([currentParams.device_type isEqualToString:DEVICE_TYPE_AC]) {
        self.pileTypeLabel.text = @"交流桩";
        if ([currentParams.device_status isEqualToString:CHARGING]) {
            self.electricLabel.text = [NSString stringWithFormat:@"%.2fKWh", currentParams.consumtion];
//            self.electricIconLabel.text = @"kWh";
            self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_charging"];

        }
    } else if ([currentParams.device_type isEqualToString:DEVICE_TYPE_DC]) {
        self.pileTypeLabel.text = @"直流桩";
        if ([currentParams.device_status isEqualToString:CHARGING]) {
            self.electricLabel.text = [NSString stringWithFormat:@"%.2fKWh", currentParams.consumtion];
//            self.electricLabel.text = [NSString stringWithFormat:@"%ldKWh", (long)currentParams.soc];
//            self.electricIconLabel.text = @"%";
            self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_charging"];

        }
    }
    
    /**
     *  TODO 不同充电形式显示不同单位
     */
//    switch (self.startChargeParams.chargeModeType) {
//        case DCChargeModeTypeByTime:
//            self.electricLabel.text = [NSString stringWithFormat:@"%.2f", currentParams.consumtion];
//            self.electricIconLabel.text = @"kWh";
//            break;
//            
//        case DCChargeModeTypeByMoney:
//            self.electricLabel.text = [NSString stringWithFormat:@"%0.2f", self.startChargeParams.chargeFee * currentParams.consumtion];
//            self.electricIconLabel.text = @"元";
//            break;
//            
//        case DCChargeModeTypeByFull:
//        case DCChargeModeTypeByPower:
//            self.electricLabel.text = [NSString stringWithFormat:@"%.2f", currentParams.consumtion];
//            self.electricIconLabel.text = @"kWh";
//            break;
//            
//        default:
//            break;
//    }
    //pileType为桩类型 0:交流 1:直流
    self.pileTypeLabel.text = [currentParams.device_type isEqualToString:DEVICE_TYPE_AC] ? @"交流桩" : @"直流桩";
}

#pragma mark 停止按钮
- (IBAction)endCharging:(UIButton *)sender {
    
    UIAlertView *endCharingAlertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否停止充电？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [endCharingAlertView show];
    
    [endCharingAlertView setClickedButtonHandler:^(NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //一按就先把停止按钮屏蔽掉
            self.endButton.enabled = NO;
            
            NSString *pileId = nil;
            if (self.m2mServer.chargePort.pileId) {
                pileId = self.m2mServer.chargePort.pileId;
            } else {
                pileId = self.scanQrcodeParams.pile.deviceId;
            }
            
            NSInteger chargePortIndex = chargePortIndex = [self.charingCurrentParam.gun_number integerValue];
            
            typeof(self) __weak weakSelf = self;
            DCUser *user = [DCApp sharedApp].user;
            [DCSiteApi postStopCharging:user.userId
                                 pileId:pileId
                        chargePortIndex:chargePortIndex
                             completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                 typeof(weakSelf) __strong strongSelf = weakSelf;
                                 if (![webResponse isSuccess]) {
                                     MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:strongSelf.view animated:YES];
                                     [strongSelf hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                                     
                                     //停止失败后, 访问后台是否还在正在充电, 如果是则不做任何操作, 如果不在充电了则获取订单.
                                     [self checkUserGprsChargingWithBlock:^(BOOL success) {
                                         if (success) {
                                             self.endButton.enabled = YES;
                                             return;
                                         }
                                         
                                         isCharging = NO;
                                         [self.m2mServer cutOffSocket];
                                         strongSelf.endButton.enabled = NO;
                                         strongSelf.electricLabel.text = @"停止中";
//                                         strongSelf.electricIconLabel.text = @"...";
                                         
                                         [self cleanChargingDataShow];
//                                         self.chargingState = DCChargingStateHomePage;
                                         self.chargingState = DCChargingStateScaning;

                                         
                                         [strongSelf performSegueWithIdentifier:@"DCChargeDoneViewController" sender:self.m2mServer.orderId];
                                         return;
                                     }];
                                 }
                                 
                                 strongSelf.gprsOrderId = [webResponse.result objectForKey:@"orderId"];
                                 [self jumpToChargeDoneVCWithOrderId:strongSelf.gprsOrderId];
                                 
                                 // 停止成功
                                 //                         isCharging = NO;
                                 //                         [self.m2mServer cutOffSocket];
                                 //                         strongSelf.endButton.enabled = NO;
                                 //                         strongSelf.electricLabel.text = @"停止中";
                                 //                         strongSelf.electricIconLabel.text = @"...";
                                 //                         
                                 //                         [strongSelf performSegueWithIdentifier:@"DCChargeDoneViewController" sender:self.gprsOrder];
                                 //                         self.chargingState = DCChargingStateHomePage;
                             }];

        }
    }];
}

- (void)loadSelectChargeModeViewWithStartChargeParams:(DCStartChargeParams *)params {
    [self.scanQrcodeView stopScan];

    self.selectView = [DCSelectChargeModeView selectChargeModeViewWithStartChargeParams:params];
    self.selectView.delegate = self;
    self.selectPopUpView = [DCPopupView popUpWithTitle:@"电桩信息" contentView:self.selectView withController:self];
    self.selectPopUpView.backgroundDismissEnable = YES;
}

#pragma mark - SelectChargeModeViewDelegate
- (void)clickTheChargeByMode:(DCChargeModeType)chargeModeType chargePort:(DCChargePort *)chargePort{

    switch (chargeModeType) {
            
        case DCChargeModeTypeByFull: {
            [self startCharge:self.startChargeParams];
        }
            break;
            
        case DCChargeModeTypeByTime:
        case DCChargeModeTypeByMoney:
        case DCChargeModeTypeByPower: {
            [self.selectPopUpView dismiss];
            NSString *title = nil;
            if (chargeModeType == DCChargeModeTypeByTime) {
                title = @"请选择充电时长";
            } else if (chargeModeType == DCChargeModeTypeByPower) {
                title = @"请输入充电电量";
            } else if (chargeModeType == DCChargeModeTypeByMoney) {
                title = @"请输入充电金额";
            }
            _confirmView = [DCChargeConfirmView chargeConfirmViewWithType:chargeModeType];
            _confirmView.delegate = self;
            self.confirmPopUpView = [DCPopupView popUpWithTitle:title contentView:_confirmView withController:self];
            [self.confirmPopUpView setBackgroundDismissEnable:NO];
        }
            break;
        default:
            break;
    }
}
- (void)changeOtherChargePort {
    [self.selectPopUpView dismiss];
    ChargePortView *view = [ChargePortView chargePortViewWithChargePorts:self.scanQrcodeParams.pile.chargePort chooseIndex:self.startChargeParams.chargePortIndex];
    view.delegate = self;
    self.changeChargePortPopUpView = [DCPopupView popUpWithTitle:@"请选择电枪口" contentView:view withController:self];
    self.changeChargePortPopUpView.backgroundDismissEnable = YES;
}

- (void)clickTheLockButton {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.selectPopUpView animated:YES];
    [DCSiteApi postCommandToDownFloorLockWithPileId:self.self.scanQrcodeParams.pile.deviceId userId:[DCApp sharedApp].user.userId chargePortIndex:0 control:2 completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        [self hideHUD:hud withDetailsText:@"地锁下降成功"];
        self.selectView.lockButton.enabled = NO;
        self.selectView.lockButton.backgroundColor = [UIColor paletteButtonBoradColor];
    }];
}

#pragma mark - ChargeConfirmViewDelegate
-(void)clickConfirmChargeButton:(DCChargeModeType)chargeModeType chargeLimit:(double)chargeLimit{
    self.startChargeParams.chargeModeType = chargeModeType;
    self.startChargeParams.chargeLimit = chargeLimit;
    [self startCharge:self.startChargeParams];
    [self.confirmPopUpView dismiss];
}
- (void)clickOhterChargeModeButton {
    [self.confirmPopUpView dismiss];
    [self loadSelectChargeModeViewWithStartChargeParams:self.startChargeParams];
}

#pragma mark - ChargePortViewDelegate
- (void)clickChargePortButton:(DCChargePortButton)chargePort {
    
    self.detailChargePort = [[DCChargePort alloc] initChargePortWithDictionary:[self.scanQrcodeParams.pile.chargePort objectAtIndex:(chargePort - 1)]];
    
    if (self.detailChargePort.runStatus == DCRunStatusFault) {
        [self showHUDText:@"充电枪尚未连接"];
        return;
    } else {
        self.startChargeParams.chargePortIndex = chargePort;
        
        [self.changeChargePortPopUpView dismiss];
        [self loadSelectChargeModeViewWithStartChargeParams:self.startChargeParams];
    }

}

#pragma mark - Socket的代理
//socket连接成功
- (void)connectSuccess:(BOOL)success message:(NSString *)message{
    if (success) {
        NSLog(@"%@", message);
        self.electricLabel.text = @"获取中";
        self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_charging"];

//        self.electricIconLabel.text = @"...";
    }
}

//socket连接失败
- (void)connectError:(NSString *)message socketOfflineType:(SocketOfflineType)type {
    NSLog(@"%@", message);
    
    //m2m服务器连接失败
    if (type == SocketOfflineByServer) {
        [self showHUDText:@"连接服务器失败, 请重新扫码" completion:^{
//            self.chargingState = DCChargingStateHomePage;
            self.chargingState = DCChargingStateScaning;

        }];
    }
    
    //用户停止充电断开m2m服务器
    else if (type == SocketOfflineByUser) {
    }
    
    //m2m服务器连接后再断开
    else if (type == SocketOfflineByAfterConnect) {
        self.electricLabel.text = @"获取中";
//        self.electricIconLabel.text = @"...";
        self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_charging"];

        [self cleanChargingDataShow];
        
        [self showHUDText:@"获取实时充电参数失败, 重新连接中"];
        
        [self checkUserGprsChargingWithBlock:nil];
    }
}

//身份验证
- (void)authoriseSuccess:(BOOL)succeess message:(NSString *)message {
    if (!succeess) {
        [self checkUserGprsChargingWithBlock:nil];
    }
    NSLog(@"%@", message);
}

//读取充电实时参数
- (void)receiveChargeCurrentDataWithDict:(NSDictionary *)dict {
    self.charingCurrentParam = [[DCChargingCurrentData alloc] initChargingCurrentDataWithDict:dict];
    [self gprsRequestChargeCurrentParam:self.charingCurrentParam];
}

- (void)chargeingError:(NSString *)message errorType:(ErrorType)errorType{

    if ([message isEqualToString:SPARE]) {
        if (errorType == ErrorTypeForStart) {
            [self checkUserGprsChargingWithBlock:^(BOOL success) {
                if (!success) {
                    //电桩离线
                    DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeException];
                    popUpType = DCAlertTypeException;
                    view.delegate = self;
                    self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
                    self.highLigthView.image = [UIImage imageNamed:@"charging_backgroud_charging"];

                }
            }];
        }
    }
    
    else if ([message isEqualToString:CHARGE_CONNECT_ABNORMAL]) {
        if (errorType == ErrorTypeForEnd) {
            //充电时充电枪拔出
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeException];
            popUpType = DCAlertTypeException;
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
        if (errorType == ErrorTypeForStart) {
            //一开始充电枪没插上
            isCharging = NO;
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeExtract];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
    }
    
    else if ([message isEqualToString:FINISH_CHARGE]) {
        [self jumpToChargeDoneVCWithOrderId:self.m2mServer.orderId];
    }
    
    else if ([message isEqualToString:POWER_OFF]) {
        [self checkUserGprsChargingWithBlock:^(BOOL success) {
            if (!success) {
                //电桩离线
                DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeException];
                popUpType = DCAlertTypeException;
                view.delegate = self;
                self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
            }
            else {
                [self showHUDText:@"获取电桩参数失败, 正在尝试重新连接"];
                self.endButton.enabled = YES;
            }
        }];
    }
    
    else if ([message isEqualToString:GUN_LOCK_OPEN]) {
        if (errorType == ErrorTypeForStart) {
            isCharging = NO;
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeGunLockOpen];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        } else {
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeGunLockOpen];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
    }
    
    else if ([message isEqualToString:DOOR_LOCK_OPEN]) {
        if (errorType == ErrorTypeForStart) {
            isCharging = NO;
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeDoorLockOpen];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        } else {
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeDoorLockOpen];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
    }
    
    else {
        if (errorType == ErrorTypeForStart) {
            //充电前, 电桩已经断电
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeError];
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
        if (errorType == ErrorTypeForEnd) {
            DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeException];
            popUpType = DCAlertTypeException;
            view.delegate = self;
            self.warmPopUpView = [DCPopupView popUpWithTitle:@"故障提示" contentView:view withController:self];
        }
    }
}

#pragma mark DCOneButtonAlertViewDelegate 
- (void)oneButtonAlertViewConfrimButton:(DCAlertType)alertType {
    [self.warmPopUpView dismiss];
    switch (alertType) {
        case DCAlertTypeFault:
        case DCAlertTypeBooked:
        case DCAlertTypeCharging:
        case DCAlertTypeError:
        case DCAlertTypeExtract:
        case DCAlertTypeNoChargePort:
        case DCAlertTypeWithoutFreeChargePort:
            self.chargingState = DCChargingStateScaning;
            break;
            
        case DCAlertTypeException:
//            [self endCharging:self.endButton];
            [self jumpToChargeDoneVCWithOrderId:self.m2mServer.orderId];
            break;
            
        case DCAlertTypeNotPay:
//            self.chargingState = DCChargingStateHomePage;
            self.chargingState = DCChargingStateScaning;

            break;
        
        case DCAlertTypeGunLockOpen:
        case DCAlertTypeDoorLockOpen: {
            if (isCharging) {
//                [self endCharging:self.endButton];
                [self jumpToChargeDoneVCWithOrderId:self.m2mServer.orderId];
            } else {
                self.chargingState = DCChargingStateScaning;
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark ChargeDoneView
- (void)chargeDoneViewShow{
    //结算页面返回后显示主页
//    self.chargingState = DCChargingStateHomePage;
    self.chargingState = DCChargingStateScaning;

}

#pragma mark ChargePublic
- (DCStartChargeParams *)getTheStartChargeParams:(DCScanQrcodeParams *)scanQrcodeParams {
    DCStartChargeParams *params = [[DCStartChargeParams alloc] init];
    params.userId = [DCApp sharedApp].user.userId;
    params.deviceId = scanQrcodeParams.pile.deviceId;
    params.chargeModeType = DCChargeModeTypeByFull;
    params.chargeLimit = 0;
    params.pileName = scanQrcodeParams.pile.pileName;
    params.chargeFee = scanQrcodeParams.chargeFee;
    params.pileType = scanQrcodeParams.pile.pileType;
    
    if (scanQrcodeParams.pile.hasFloorLock) {
        params.isHasFloorLock = YES;
    }
    
    // 先判断一下该桩有没有充电口
    if (scanQrcodeParams.pile.chargePort.count) {
        for (int i = 0; i < scanQrcodeParams.pile.chargePort.count; i++) {
            
            // 当前用户是否预约了该桩的充电口
            if (scanQrcodeParams.isOrder && scanQrcodeParams.orderChargePort) {
                params.chargePortIndex = scanQrcodeParams.orderChargePort;
                params.isHasChargePort = YES;
                return params;
            }
            else {
                DCChargePort *chargePort = [[DCChargePort alloc] initChargePortWithDictionary:[scanQrcodeParams.pile.chargePort objectAtIndex:i]];
                params.isHasChargePort = YES;
                if (chargePort.runStatus == DCRunStatusSpare || chargePort.runStatus == DCRunStatusConnectNotCharge) {
                    if (i == 0) {
                        params.chargePortIndex = i + 1;
                        return params;
                    }
                    if (i == 1) {
                        params.chargePortIndex = i + 1;
                        return params;
                    }
                    if (i == 2) {
                        params.chargePortIndex = i + 1;
                        return params;
                    }
                    if (i == 3) {
                        params.chargePortIndex = i + 1;
                        return params;
                    }
                } else {
                    params.isHasChargePort = NO;
                }
            }
        }
    } else {
        params.isHasChargePort = NO;
    }
    return params;
}

- (void)startCharge:(DCStartChargeParams *)params {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    typeof(self) __weak weakSelf = self;
    [DCSiteApi postStartCharging:params.userId
                          pileId:params.deviceId
                 chargePortIndex:params.chargePortIndex
                      chargeMode:params.chargeModeType
                     chargeLimit:params.chargeLimit
                      completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                          typeof(weakSelf) __strong strongSelf = weakSelf;
                          if (![webResponse isSuccess]) {
                              [self.selectPopUpView dismiss];
                              
                              if (webResponse.code == RESPONSE_CODE_CHARGE_NOTPAY) {
                                  NSString *orderId = [webResponse.result objectForKey:@"orderId"];
                                  [DCSiteApi getOrderInfo:orderId userId:params.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
                                      if (![webResponse isSuccess]) {
                                          [strongSelf hideHUD:hud withText:@"获取未支付的订单详情失败"];
                                          return ;
                                      }
                                      
                                      [hud hide:YES];
                                      DCOrder *order = [[DCOrder alloc] initOrderWithDict:[webResponse.result objectForKey:@"order"]];
                                      DCNotPayAlertView *view = [DCNotPayAlertView loadWithNotPayOrder:order];
                                      view.delegate = self;
                                      self.warmPopUpView = [DCPopupView popUpWithTitle:@"您还有没结算订单" contentView:view withController:self];
                                  }];
                              }
                              
                              else if (webResponse.code == RESPONSE_CODE_CHARGE_NON_IDLE) {
                                  [hud hide:YES];
                                  DCOneButtonAlertView *view = [DCOneButtonAlertView viewWithAlertType:DCAlertTypeWithoutFreeChargePort];
                                  view.delegate = self;
                                  self.warmPopUpView = [DCPopupView popUpWithTitle:@"温馨提示" contentView:view withController:self];
                              }
                              
                              else if (webResponse.code == RESPONSE_CODE_CHARGE_BOOKED_NOTPAY) {
                                  [strongSelf hideHUD:hud withDetailsText:@"请您支付预约费用，支付成功后即可扫码启动充电" completion:^{
                                      strongSelf.chargingState = DCChargingStateScaning;
                                  }];
                              }
                              
                              else {
                                  [strongSelf hideHUD:hud withDetailsText:[DCWebResponse errorMessage:error withResponse:webResponse]];
                                  hud.completionBlock = ^{
                                      strongSelf.chargingState = DCChargingStateScaning;
                                  };
                              }
                              return;
                          }
                          
                          [hud hide:YES];
                          isCharging = YES;
                          [self.selectPopUpView dismiss];
                          strongSelf.m2mServer = [[DCM2MServer alloc] initWithDict:webResponse.result isCharing:NO];
                          strongSelf.m2mServer.delegate = strongSelf;
                          [self chargeModeDescription:strongSelf.m2mServer.chargePort.chargeMode];
                          [strongSelf titleWithStationName:strongSelf.m2mServer.stationName withPileName:strongSelf.m2mServer.pileName withChargePort:strongSelf.m2mServer.chargePort.index];
                          strongSelf.chargingState = DCChargingStateCharging;
                      }];

}

- (void)jumpToChargeDoneVCWithOrderId:(NSString *)orderId {
    isCharging = NO;
    
    [self.m2mServer cutOffSocket];
    self.endButton.enabled = NO;
    
    [self cleanChargingDataShow];
//    self.chargingState = DCChargingStateHomePage;
    self.chargingState = DCChargingStateScaning;

    
    [self performSegueWithIdentifier:@"DCChargeDoneViewController" sender:orderId];
}

#pragma mark - DCNotPayViewDelegate
- (void)clickToPayWithOrderId:(NSString *)orderId {
    [self.warmPopUpView dismiss];
    [self performSegueWithIdentifier:@"DCOrderDetailViewController" sender:orderId];
}

#pragma mark Clean
- (void)cleanChargingDataShow {
    self.electricLabel.text = @"0.00KWh";
    self.voltageLabel.text = @"0.0";
    self.currentLabel.text = @"0.00";
    self.pileTypeLabel.text = @"桩类型";
}

#pragma mark 闪关灯
- (void)flashLightOnOrOff{//闪光灯-开/关
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        self.flashLightDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([self.flashLightDevice hasTorch] && [self.flashLightDevice hasFlash]){
            
            [self.flashLightDevice lockForConfiguration:nil];
            if (flashLightState == 0) {
                [self.flashLightButton setImage:[UIImage imageNamed:@"scan_flashlight_on"] forState:UIControlStateNormal];
                [self.flashLightDevice setTorchMode:AVCaptureTorchModeOn];
                [self.flashLightDevice setFlashMode:AVCaptureFlashModeOn];
                flashLightState = 1;
            } else {
                [self.flashLightButton setImage:[UIImage imageNamed:@"scan_flashlight_off"] forState:UIControlStateNormal];
                [self.flashLightDevice setTorchMode:AVCaptureTorchModeOff];
                [self.flashLightDevice setFlashMode:AVCaptureFlashModeOff];
                flashLightState = 0;
            }
            [self.flashLightDevice unlockForConfiguration];
        }
    }
}

#pragma mark ----- 手动输入编码 弹框
- (void)inputCodeAlertView {

    _alertView = [[ManualInputAlertView alloc] initWithFrame:CGRectMake(20, KSH / 2 - 70, KSW - 40, 150)];
    
    //    //设置自定义视图的中点为屏幕的中点
    //    [_alertView setCenter:CGPointMake(KSW / 2, KSH / 2 + 50)];
    
    //    __weak typeof (WCCardViewController *)weakSelf = self;
    //添加视图
    _alertView.transform = CGAffineTransformMakeScale(0.0, 1.0);
    [UIView animateWithDuration:0.5 animations:^{
        _alertView.transform = CGAffineTransformIdentity;
    }];
    
    UIView *bigView = [[UIView alloc] initWithFrame:kKeyWindow.bounds];
    [bigView setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.504]];
    [bigView addSubview:_alertView];
    [kKeyWindow addSubview:bigView];
    
    __weak typeof(_alertView)weakAlertView = _alertView;
    __weak typeof(self)weakSelf = self;

    _alertView.clickSureButtonBlock = ^ {
        
        if (weakAlertView.cardNum.length < 16) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kKeyWindow animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"请输入正确的充电桩编号";
            [hud hide:YES afterDelay:2];
            return;
        }
        
        [weakAlertView removeFromSuperview];
        [bigView removeFromSuperview];
#pragma mark ==== 点击确定  ------调用扫码之后的回调方法
        [weakSelf scanSuccess:weakAlertView.cardNum];
        
    };
    _alertView.clickCancelButtonBlock = ^{
        weakAlertView.transform = CGAffineTransformMakeScale(0.00001, 1.0);
        [UIView animateWithDuration:0.5 animations:^{
            weakAlertView.transform = CGAffineTransformIdentity;
        }];
        [weakAlertView removeFromSuperview];
        [bigView removeFromSuperview];
    };
    
}


#pragma mark Public
- (void)changeTheChargingState {
    self.chargingState = DCChargingStateScaning;
}

- (void)titleWithStationName:(NSString *)stationName withPileName:(NSString *)pileName withChargePort:(NSString *)chargePortIndex {
    NSString *str = [stationName stringByAppendingFormat:@" (%@.枪%@) ", pileName, chargePortIndex];
    self.chargingTitleLabel.text = str;
}

- (void)chargeModeDescription:(DCChargeModeType)mode {
    switch (mode) {
        case DCChargeModeTypeByFull:
            self.chargeModeLabel.text = @"自然充满";
            break;
        case DCChargeModeTypeByTime:
            self.chargeModeLabel.text = @"按时间充电";
            break;
        case DCChargeModeTypeByMoney:
            self.chargeModeLabel.text = @"按金额充电";
            break;
        case DCChargeModeTypeByPower:
            self.chargeModeLabel.text = @"按电量充电";
            break;
        default:
            break;
    }
}

- (NSString *)pileNameDescription:(DCStartChargeParams *)param {
    NSString *chargePort = nil;
    switch (param.chargePortIndex) {
        case 1:
            chargePort = @" 枪1";
            break;
        case 2:
            chargePort = @" 枪2";
            break;
        case 3:
            chargePort = @" 枪3";
            break;
        case 4:
            chargePort = @" 枪4";
            break;
        default:
            break;
    }
    NSString *string = [param.pileName stringByAppendingString:chargePort];
    return string;
}

#pragma mark 网络状态
- (void)networkStatusFault {
    if (self.chargingState == DCChargingStateCharging) {
        isCharging = NO;
//        self.chargingState = DCChargingStateHomePage;
        self.chargingState = DCChargingStateScaning;

    }
}
- (void)networkStatusSuccess {
    [self checkUserGprsChargingWithBlock:nil];
}
@end

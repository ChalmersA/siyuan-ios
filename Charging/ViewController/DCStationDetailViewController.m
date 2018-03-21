//
//  DCStationDetailViewController.m
//  CollectionViewTest
//
//  Created by  Blade on 4/22/15.
//  Copyright (c) 2015  Blade. All rights reserved.
//

#import "DCStationDetailViewController.h"
#import "DCShareDate.h"
#import "DCSharePeriod.h"
#import "DCSiteApi.h"
#import "DCReservationViewController.h"
#import "CWStarRateView.h"
#import "NSString+HSSY.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "DCTimeFilterViewController.h"
#import "DCApp.h"
#import "DCSearchParameters.h"
#import "NSDate+HSSYDate.h"
#import "DCMapManager.h"
#import "DCOrder.h"
#import "DCPileEvaluationViewController.h"
#import "DCArticle.h"
#import "DCListView.h"
#import "PopUpView.h"
#import "DCPeriodTableViewCell.h"
#import "DCPreloadingView.h"
#import "Charging-Swift.h"
#import "DCPileEvaluationViewController.h"
#import "DCDetailTableView.h"
#import "DCSearchViewController.h"
#import "UILabel+HSSYPole.h"
#import "DCShareViewController.h"

static NSString *kCellIdentifier = @"DCPeriodTableViewCell";
static NSArray *periodArr;
@interface DCStationDetailViewController () <UIScrollViewDelegate, HSSYListViewDelegate, PopUpViewDelegate, UITableViewDelegate, DCPileEvaluationViewControllerDelegate> {
    DCListView *listView;
}
@property (weak, nonatomic) PopUpView *popUpView;

@property (nonatomic, retain) UIBarButtonItem* shareItem;                 // 分享按钮
@property (nonatomic, copy) DCSearchParameters* searchParam;
@property (nonatomic, retain) DCOrder* curBookedOrder;
@property (nonatomic, strong) ArrayDataSource *periodSource;
@property (nonatomic, assign) NSInteger periodIndex;
@property (nonatomic, retain) DCPreloadingView* preloadView;
@property (nonatomic, strong) DCArticle *lastArticle;


@property (nonatomic, assign) BOOL isStationLoaded;
@property (nonatomic, assign) BOOL isFavorLoaded;
@property (nonatomic, assign) BOOL isShareTimeLoaded;
@property (nonatomic, assign) BOOL isEvaluationLoaded;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailHeight;
@property (nonatomic, assign) CGFloat detailButtonHeight;
@property (nonatomic, strong) DCDetailTableView *createDetailTabeView;
@property (weak, nonatomic) IBOutlet UIButton *favorButton;                // 收藏按钮
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *refresh;     // 刷新小菊花
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scoreViewHiddenCons;

@property (nonatomic, retain) UIBarButtonItem* favorItem;                 // 收藏按钮

@end

@implementation DCStationDetailViewController

#pragma mark Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", self.selectStationInfo.stationId);
 //   [self.favorItem addTarget:self action:@selector(changeFavor:) forControlEvents:UIControlEventTouchUpInside];
    self.shareItem = [UIBarButtonItem shareBarItemWithTarget:self action:@selector(shareApp:)];
    self.favorItem = [UIBarButtonItem favoBarItemWithTarget:self action:@selector(changeFavor:)];
    
    [self.navigationController setTitle:self.selectStationInfo.stationName];
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:.9 blue:.9 alpha:1];
    
    self.scrollView.delegate = self;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        periodArr = @[@(30),@(60*1),@(60*2),@(60*3),@(60*4),@(60*5),@(60*6)];
    });
    
    self.periodIndex = 0;
    self.periodSource = [ArrayDataSource dataSourceWithItems:periodArr
                                              cellIdentifier:kCellIdentifier
                                          configureCellBlock:^(DCPeriodTableViewCell *cell, NSNumber *aPeriod) {
                                              [cell.periodLabel setText:[self getPeriodLengthString:aPeriod.integerValue]];
                                          }];
    
    if (self.searchParam == nil) {
        self.searchParam = [[DCSearchParameters alloc] init];
        
        [self.searchParam setStartClockTime:ClockTimeZero
                         startTimeActivated:YES
                               endClockTime:ClockTimeEnd
                           endTimeActivated:YES
                                   duration:((NSNumber*)[periodArr objectAtIndex:self.periodIndex]).integerValue / 60.f];
    }
    [self updateParametersCalculated];
//    [self initView];
    
    self.preloadView = [DCPreloadingView loadViewWithNib:@"DCPreloadingView"];
    NSDictionary *paramDic = NSDictionaryOfVariableBindings(_preloadView);
    [self.preloadView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addSubview:self.preloadView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_preloadView]|" options:0 metrics:0 views:paramDic]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_preloadView]|" options:0 metrics:0 views:paramDic]];
    [self.preloadView setMode:PreLoadViewModeLoading];
    
    // 刷新小菊花
    [self.refresh setHidden:YES];
    // 记录高度
    self.detailButtonHeight = self.detailHeight.constant;
    
//    [self prelaodDataFromServer];
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // TODO: add autolayout for next line
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self prelaodDataFromServer];// 回来再刷一遍，这边防止删除评论不刷新
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark
- (void)updateParametersCalculated {
    // 计算定位参数
    CLLocation *centerLocation = [DCApp sharedApp].userLocation;
    if (centerLocation) {
        self.distance = @([DCMapManager distanceFromCoor:[self.selectStationInfo coordinate] toCoor:centerLocation.coordinate]);
    }
}
- (void)prelaodDataFromServer {
    self.isEvaluationLoaded = NO;
    self.isFavorLoaded = NO;
    self.isStationLoaded = NO;
    self.isShareTimeLoaded = NO;
    
    self.evaluationButton.hidden = YES;
    typeof(self) __weak weakSelf = self;
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    dispatch_queue_t aQueue = dispatch_queue_create("com.hssy.detailSerialQueue", DISPATCH_QUEUE_SERIAL);
    //创建1个queue group
    dispatch_group_t queueGroup = dispatch_group_create();
    NSLog(@"task begin.");

    // 请求最新的电站信息
    dispatch_group_async(queueGroup, aQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [DCSiteApi getStationId:self.selectStationInfo.stationId userId:[DCApp sharedApp].user.userId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                //TODO: failed to load newestpole
            }
            else{
                DCStation *station = [[DCStation alloc] initStationWithDict:webResponse.result];
                weakSelf.selectStationInfo = station;
                [weakSelf updateParametersCalculated];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STATION_UPDATE object:nil userInfo:@{@"DCStation" : station}];
            }
            self.isStationLoaded = [webResponse isSuccess];
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(semaphore);
    });
    
    //评价信息
    dispatch_group_async(queueGroup, aQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        [DCSiteApi getArticleListWithArticleType:DCArticleListTypeAllEvaluate page:1 pageSize:1 userId:nil stationId:self.selectStationInfo.stationId completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
            if (![webResponse isSuccess]) {
                weakSelf.lastArticle = nil;
                weakSelf.isEvaluationLoaded = NO;
            }
            else {
                NSArray *evaluates = [webResponse.result arrayObject];
                for (NSDictionary *dict in evaluates) {
                    if (![dict isKindOfClass:[NSDictionary class]]) { //处理服务器返回null的异常
                        continue;
                    }
                    DCArticle *article = [[DCArticle alloc] initWithDict:dict];
                    weakSelf.lastArticle = article;
                    break;// 取出第一个可用的
                }
            }
            
            weakSelf.isEvaluationLoaded = [webResponse isSuccess];
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_signal(semaphore);
    });
    
    //等待组内任务全部完成
    dispatch_group_notify(queueGroup, aQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
//            if (weakSelf.isStationLoaded && weakSelf.isFavorLoaded && weakSelf.isShareTimeLoaded && weakSelf.isEvaluationLoaded) {
            if (weakSelf.isStationLoaded) {
                self.detailHeight.constant = self.detailButtonHeight;
                [weakSelf initView];
                if (weakSelf.preloadView) {
                    [weakSelf.preloadView removeFromSuperview];
                    [weakSelf.preloadView setReloadBlock:nil];
                    weakSelf.preloadView = nil;
                }
            }
            else {
                [weakSelf.preloadView setMode:PreLoadViewModeLoadFailed];
                [weakSelf.preloadView setReloadBlock:^{
                    [weakSelf prelaodDataFromServer];
                } ];
            }// do work here
            if (![self.refresh isHidden]) {
                [self.refresh stopAnimating];
                [self.refresh setHidden:YES];
            }
        });
        
    });
}

#pragma mark - Action
//- (void)evaluatePole:(id)sender { //点评  第二版开放
//    if ([self presentLoginViewIfNeededCompletion:nil]) {
//        return;
//    }
//    DCPileEvaluationViewController *vc = [DCPileEvaluationViewController storyboardInstantiate];
//    vc.stationId = self.selectStationInfo.stationId;
//    vc.delegate = self;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//- (IBAction)rigthNavigateEvaluate:(id)sender {
//    [self evaluatePole:sender];
//}

- (void)navigateBack:(id)sender {
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [super navigateBack:sender];
    }
}

- (IBAction)naviBtnClick:(id)sender {
    if (self.selectStationInfo.longitude && self.selectStationInfo.latitude) {
        [DCMapManager showNaviActionSheetInView:self.view withCoordinate:self.selectStationInfo.coordinate];
    } else {
        [self showHUDText:@"获取桩群地理位置失败"];
    }
}

// 预约按钮事件 暂时跳到扫码充电页面
- (IBAction)bookBtnClick:(id)sender {
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        return;
    }
    [self performSegueWithIdentifier:@"book" sender:self];
    
}

- (IBAction)phoneClick:(id)sender {
    if (self.selectStationInfo.ownerPhone && self.selectStationInfo.ownerPhone.length > 0) {
        [[DCApp sharedApp] callPhone:self.selectStationInfo.ownerPhone viewController:self];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"联系电话不存在";
        [hud hide:YES afterDelay:2];
        return;
    }
}

- (void)changeFavor:(id)sender {
    if ([self presentLoginViewIfNeededCompletion:nil]) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    int collect = 1;
    if ([self.selectStationInfo isCollect]) {
        collect = 2;
    }
    
    NSArray *collectArray = [NSArray arrayWithObject:self.selectStationInfo.stationId];
    
    [DCSiteApi postFavoritesStations:collectArray userId:[DCApp sharedApp].user.userId favorites:collect completion:^(NSURLSessionDataTask *task, BOOL success, DCWebResponse *webResponse, NSError *error) {
        if (![webResponse isSuccess]) {
            [self hideHUD:hud withText:[DCWebResponse errorMessage:error withResponse:webResponse]];
            return;
        }
        NSString *text;
        if (self.selectStationInfo.favor) {
            text = @"取消收藏成功";
            self.selectStationInfo.favor = NO;
        } else {
            text = @"收藏成功";
            self.selectStationInfo.favor = YES;
        }
        [self updatePoleFavorState:self.selectStationInfo.favor];
        [self hideHUD:hud withText:text];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeFavor" object:@"PoleDetail" userInfo:@{@"DCPole" : self.selectStationInfo}];
    }];
}

#pragma mark - share
// 分享按钮
- (void)shareApp:(id)sender
{
    UIStoryboard *shareSB = [UIStoryboard storyboardWithName:@"Share" bundle:nil];
    DCShareViewController *shareVC = [shareSB instantiateViewControllerWithIdentifier:@"shareVC"];
    shareVC.shareStation = self.selectStationInfo;
    [self.navigationController pushViewController:shareVC animated:YES];
}

// 分享时间划分跳转
- (void)handlePeriodClick:(UITapGestureRecognizer *)recognizer {
    listView = nil;
    listView = [DCListView loadViewWithNib:@"BluetoothList"];
    [listView.labelTitl setText:@"充电时长"];
    listView.frame = CGRectInset(self.view.bounds, 20, 60);
    
    [listView.tableView registerNib:[UINib nibWithNibName:@"DCPeriodTableViewCell" bundle:nil] forCellReuseIdentifier:kCellIdentifier];
    listView.tableView.backgroundColor = [UIColor clearColor];
    listView.tableView.alwaysBounceVertical = NO;

    self.popUpView = [PopUpView popUpWithContentView:listView withController:self];
    listView.tableView.delegate = self;
    listView.tableView.dataSource = self.periodSource;
    [listView.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.periodIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    listView.delegate = self;
}


// 评分跳转
- (void)handleScoreClick:(UITapGestureRecognizer *)recognizer {
    PoleEvaluationsViewController *vc = [PoleEvaluationsViewController storyboardInstantiate];
    vc.station = self.selectStationInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)poleEvaluation:(id)sender {
//    [self performSegueWithIdentifier:@"poleEvaluation" sender:nil];
//    
//}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"book"]) {
        DCReservationViewController* vc = segue.destinationViewController;
        vc.staion = self.selectStationInfo;
    }if ([segue.identifier isEqualToString:@"poleEvaluation"]) {
        DCPileEvaluationViewController *vc = segue.destinationViewController;
        vc.stationId = self.selectStationInfo.stationId;
    }
}

#pragma mark - initial
// 根据选中的桩进行界面排布
- (void)initView {
    
    // navigation bar
    [self.labelTitle setText:self.selectStationInfo.stationName];
    self.navigationItem.rightBarButtonItems = @[self.favorItem,self.shareItem];
    //================================ 电桩详细信息下拉 ================================

    self.createDetailTabeView = [[DCDetailTableView alloc] init];

    [self.createDetailTabeView createTableView:self.detailTableView
                                     andHeight:self.detailHeight
                                  dcGunIdleNum:self.selectStationInfo.dcGunIdleNum
                              dcGunBookableNum:self.selectStationInfo.dcGunBookableNum
                                  acGunIdleNum:self.selectStationInfo.acGunIdleNum
                              acGunBookableNum:self.selectStationInfo.acGunBookableNum
                                     stationId:self.selectStationInfo.stationId];
    
        [self.detailTableView reloadData];
        
        self.createDetailTabeView.headerArrowHidden = !(self.selectStationInfo.stationStatus == DCStationStatusOperation); // 如果是没有GPRS的站，隐藏箭头，禁止展开列表
//    if (self.selectStationInfo.dcSpareNum || self.selectStationInfo.dcBookNum || self.selectStationInfo.acSpareNum || self.selectStationInfo.acBookNum) {
//        self.createDetailTabeView.headerArrowHidden = NO;
//    } else {
//        self.createDetailTabeView.headerArrowHidden = YES;
//    }

    //================================ 收藏状态 ================================
    [self updatePoleFavorState:self.selectStationInfo.favor];
    
    
    //================================ 电桩图片 ================================
    NSArray *picUrlArr = [self.selectStationInfo stationImagesUrl];
    [self.imagePageView setScrollViewContents:(picUrlArr ? : @[[UIImage imageNamed:@"default_pile_image_long"]])];
    self.imagePageView.pageControlPos = PageControlPositionCenterBottom;
    
    //================================ 电桩信息部分 ================================
    // 电桩信息部分 -- 开放类型
    if (self.selectStationInfo.stationShareState == DCStationShareStateNotShare) {
        self.labelTagPileType.text = @"不对外开放";
        self.statusLabel.hidden = YES;
    } else {
        switch (self.selectStationInfo.openingAt.openType) {
            case DCOpenTypeAllYear:
                self.labelTagPileType.text = @"全年开放";
                break;
            case DCOpenTypeWorkday:
                self.labelTagPileType.text = @"仅工作日开放";
                break;
            case DCOpenTypeHolidays:
                self.labelTagPileType.text = @"节假日开放";
                break;
            default:
                self.labelTagPileType.text = @"未知";
                break;
        }
        
        // 电桩信息部分 -- 开放时间
        self.statusLabel.text = [[self.selectStationInfo.openingAt.startTime stringByAppendingString:@" - "] stringByAppendingString:self.selectStationInfo.openingAt.endTime];
    }

    
    // 电桩信息部分 -- 价格
//    NSString *price = [self.selectStationInfo.chargeFee objectForKey:@"defaultFee"];
    [self setPrice:self.labelPrice withPrice:[DCUVPrice priceWithDouble:[[self.selectStationInfo chargeFeeDescription] doubleValue]]];

    // 电桩信息部分 -- 距离
    if (self.distance && [self.distance floatValue] > 1000) {
        float distanceInKm = round([self.distance floatValue] / 1000.0f *10.0f) / 10.0f;
        [self.labelPoleLoactionInfo setText:[NSString stringWithFormat:@"%@km", @(distanceInKm)]];
    }
    else {
        float distanceInM = round([self.distance floatValue] * 10.0f) / 10.0f;
        [self.labelPoleLoactionInfo setText:[NSString stringWithFormat:@"%@m", @(distanceInM)]];
    }
    // 电桩信息部分 -- 位置信息
    [self.labelPolePosition setText:self.selectStationInfo.addr];
    
    //================================ 评分模块 ================================
//    if (!self.isPole || !self.isSharing) { // 如果桩未分享 上移评分模块到 电桩信息部分下面
//        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.viewScoreContainer
//                                                                         attribute:NSLayoutAttributeTop
//                                                                         relatedBy:NSLayoutRelationEqual
//                                                                            toItem:self.viewPoleDetail
//                                                                         attribute:NSLayoutAttributeBottom
//                                                                        multiplier:1.0f
//                                                                          constant:12.f];
//        [self.viewScoreContainer.superview removeConstraint:self.constraintScoreViewTop];
//        [self.viewScoreContainer.superview addConstraint:topConstraint];
//        [self.shareDateChooser removeFromSuperview];
//        [self.periodSpliterView removeFromSuperview];
//    }
    
    // 总评分星星的标题
    [self.labelScoreTitle setText:@"桩群评价"];
    [self updatePoleEvaluation];
    
    //TODO: 桩群评价的点击事件
    UITapGestureRecognizer *scoreTap_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScoreClick:)];
    UITapGestureRecognizer *scoreTap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScoreClick:)];
    UITapGestureRecognizer *scoreTap_3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleScoreClick:)];
    [self.viewTotalScore addGestureRecognizer:scoreTap_1];
    [self.viewLastScorePreview addGestureRecognizer:scoreTap_2];
    [self.viewScoresCountContainer addGestureRecognizer:scoreTap_3];
    
    //================================ 预约费用 ================================
    if (self.selectStationInfo.refundState == DCOnTimeChargeRefundStateNotRefund) {
        self.bookFeeLabel.text = [NSString stringWithFormat:@"%0.2f 元/10分钟\n(预约时段内启动不返还预约费用)",self.selectStationInfo.bookFee];
    } else {
        self.bookFeeLabel.text = [NSString stringWithFormat:@"%0.2f 元/10分钟\n(预约时段内启动返还预约费用)",self.selectStationInfo.bookFee];
    }
    
    //================================ 功能区 ================================
    switch (self.selectStationInfo.funcType) {
        case 1:
            self.functionLabel.text = @"地铁沿线 + 交通枢纽";
            break;
        case 2:
            self.functionLabel.text = @"住宅小区";
            break;
        case 3:
            self.functionLabel.text = @"大型商超";
            break;
        case 4:
            self.functionLabel.text = @"4S店";
            break;
        case 5:
            self.functionLabel.text = @"科技园区 + 学校";
            break;
        case 6:
            self.functionLabel.text = @"景区";
            break;
        case 7:
            self.functionLabel.text = @"高速公路服务区";
            break;
        case 8:
            self.functionLabel.text = @"办公场所";
            break;
        default:
            self.functionLabel.text = @"其他";
            break;
    }
    
    //================================ 便利设施 ================================
    self.facilityLabel.text = [self.selectStationInfo facilityLabelDescription];
    
    //================================ 运营商 ================================
    [self.labelOwnerNameContent setText:self.selectStationInfo.ownerName];
    
    //================================ 桩群描述 ================================
    if (self.selectStationInfo.remark.length > 0) {
        self.stationDesctiptionLabel.text = self.selectStationInfo.remark;
    } else {
        self.stationDesctiptionLabel.text = @"欢迎使用充电站，竭诚为您服务!";
    }
    
    //================================ 预约按钮 导航按钮 ================================
    [self.bookButton.layer setCornerRadius:3];
    [self.bookButton.layer setMasksToBounds:YES];
    
    [self.navibutton.layer setCornerRadius:3];
    [self.navibutton.layer setMasksToBounds:YES];
    
    self.evaluationButton.hidden = YES;
}

-(void)setPrice:(UILabel*)label withPrice:(DCUVPrice*)price {
    NSString *prefixStr = @"";
    NSString *unitStr = @"￥";
    NSString *sufixStr = @"/kWh";
    
    // define colors
    UIColor *blueColor = [UIColor palettePriceRedColor];
    UIColor *grayColor = [UIColor paletteFontDarkGrayColor];
    // define font
    UIFont *normalFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
    UIFont *numberFont = [UIFont fontWithName:@"HelveticaNeue" size:19];
    // define attribute
    NSDictionary *prefixAttribs = @{NSForegroundColorAttributeName:grayColor, NSFontAttributeName:normalFont};
    NSDictionary *unitAttribs = @{NSForegroundColorAttributeName:grayColor, NSFontAttributeName:normalFont};
    NSDictionary *numberAttribs = @{NSForegroundColorAttributeName:blueColor, NSFontAttributeName:numberFont};
    NSDictionary *sufixAttribs = @{NSForegroundColorAttributeName:grayColor, NSFontAttributeName:normalFont};
    
    if (price) {
        NSMutableArray *strArr = [NSMutableArray array];
        NSMutableArray *attriArr = [NSMutableArray array];
        
        [strArr addObject:prefixStr];
        [attriArr addObject:prefixAttribs];
        
        [strArr addObject:unitStr];
        [attriArr addObject:unitAttribs];
        
        [strArr addObject:[price stringOfPrice]];
        [attriArr addObject:numberAttribs];
        
        [strArr addObject:sufixStr];
        [attriArr addObject:sufixAttribs];
        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
    }
    else {
        [self joidStrings:@[] withAttributes:@[] tolabel:label];
    }
}

-(void)setScoresCountLabel:(UILabel*)label withScoreCount:(NSNumber*)count {
    NSString *prefixStr = @"查看所有";
    NSString *sufixStr = @"条评论";
    
    // define colors
    UIColor *greenColor = [UIColor paletteDCMainColor];
    UIColor *grayColor = [UIColor paletteFontDarkGrayColor];
    // define font
    UIFont *normalFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
    UIFont *numberFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
    // define attribute
    NSDictionary *prefixAttribs = @{NSForegroundColorAttributeName:grayColor, NSFontAttributeName:normalFont};
    NSDictionary *numberAttribs = @{NSForegroundColorAttributeName:greenColor, NSFontAttributeName:numberFont};
    NSDictionary *sufixAttribs = @{NSForegroundColorAttributeName:grayColor, NSFontAttributeName:normalFont};
    
    
    
    if (count) {
        NSMutableArray *strArr = [NSMutableArray array];
        NSMutableArray *attriArr = [NSMutableArray array];
        
        [strArr addObject:prefixStr];
        [attriArr addObject:prefixAttribs];
        
        [strArr addObject:[NSString stringWithFormat:@"%ld", (long)count.integerValue]];
        [attriArr addObject:numberAttribs];
        
        [strArr addObject:sufixStr];
        [attriArr addObject:sufixAttribs];
        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
    }
    else {
        [self joidStrings:@[] withAttributes:@[] tolabel:label];
    }
}


//-(void)setLocationInfo:(UILabel*)label WithDistace:(NSNumber*)distance andMinute:(NSNumber*)minute {
//    NSString *defaultStr = @"距离未知";
//    NSString *distancePrefix = @"距我";
//    NSString *distanceSurfix = @"公里";
//    NSString *timeHourPrefix = @" 约";
//    NSString *timeHourSurfix = @"小时";
//    NSString *timeMinutePrefix = @"";
//    NSString *timeMinuteSurfix = @"分钟";
//    
//    
//    // define colors
//    UIColor *normalColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
//    UIColor *numberColor = [UIColor colorWithRed:0.99 green:0.55 blue:0.29 alpha:1];
//    // define font
//    UIFont *normalFont = [UIFont fontWithName:@"STHeitiSC-Light" size:16];
//    UIFont *numberFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
//    // define attribute
//    NSDictionary *normalAttribs = @{NSForegroundColorAttributeName:normalColor, NSFontAttributeName:normalFont};
//    NSDictionary *numberAttribs = @{NSForegroundColorAttributeName:numberColor, NSFontAttributeName:numberFont};
//    
//    if (distance) {
//        
//        NSMutableArray *strArr = [NSMutableArray array];
//        NSMutableArray *attriArr = [NSMutableArray array];
//        
//        [strArr addObject:distancePrefix];
//        [attriArr addObject:normalAttribs];
//        
//        [strArr addObject:[NSString stringWithFormat:@"%.1f", distance.doubleValue]];
//        [attriArr addObject:numberAttribs];
//        
//        [strArr addObject:distanceSurfix];
//        [attriArr addObject:normalAttribs];
//        
//        if (minute) {
//            NSInteger minuteCount = [minute integerValue] % 60;
//            NSInteger hourCount = (NSInteger)([minute integerValue] / 60);
//            
//            if (hourCount > 0) {
//                [strArr addObject:timeHourPrefix];
//                [attriArr addObject:normalAttribs];
//                
//                [strArr addObject:[NSString stringWithFormat:@"%ld", (long)hourCount]];
//                [attriArr addObject:numberAttribs];
//                
//                [strArr addObject:timeHourSurfix];
//                [attriArr addObject:normalAttribs];
//            }
//            if (minuteCount > 0) {
//                [strArr addObject:timeMinutePrefix];
//                [attriArr addObject:normalAttribs];
//                
//                [strArr addObject:[NSString stringWithFormat:@"%ld", (long)minuteCount]];
//                [attriArr addObject:numberAttribs];
//                
//                [strArr addObject:timeMinuteSurfix];
//                [attriArr addObject:normalAttribs];
//            }
//        }
//        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
//    }
//    else {
//        [self joidStrings:@[defaultStr] withAttributes:@[normalAttribs] tolabel:label];
//    }
//}

//-(void)setTimeFilterLable:(UILabel*)label withStart:(NSDateComponents *)startTimeComponent end:(NSDateComponents*)endTimeComponent andDuration:(NSNumber*)duration {
//    
//    // define colors
//    UIColor *normalColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
//    UIColor *unitColor = [UIColor colorWithRed:0.29 green:0.29 blue:0.29 alpha:1];
//    // define font
//    UIFont *normalFont = [UIFont fontWithName:@"HelveticaNeue" size:20];
//    UIFont *unitFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
//    // define attribute
//    NSDictionary *normalAttribs = @{NSForegroundColorAttributeName:normalColor, NSFontAttributeName:normalFont};
//    NSDictionary *unitAttribs = @{NSForegroundColorAttributeName:unitColor, NSFontAttributeName:unitFont};
//    
//    if (startTimeComponent) {
//        NSMutableArray *strArr = [NSMutableArray array];
//        NSMutableArray *attriArr = [NSMutableArray array];
//        
//        [strArr addObject:[NSString stringWithFormat:@"%02ld:%02ld",(long)startTimeComponent.hour, (long)startTimeComponent.minute]];
//        [attriArr addObject:normalAttribs];
//        
//        
//        if (endTimeComponent) {
//            [strArr addObject:[NSString stringWithFormat:@" - %02ld:%02ld",(long)endTimeComponent.hour, (long)endTimeComponent.minute]];
//            [attriArr addObject:normalAttribs];
//        }
//        
//        if (duration) {
//            [strArr addObject:@"\n"];
//            [attriArr addObject:normalAttribs];
//            NSInteger minuteCount = [duration floatValue] * 60;
//            NSInteger hours = minuteCount / 60;
//            NSInteger minute = minuteCount % 60;
//            if (hours > 0) {
//                [strArr addObject:[NSString stringWithFormat:@"%ld",(long)hours]];
//                [attriArr addObject:normalAttribs];
//                
//                [strArr addObject:@"h"];
//                [attriArr addObject:unitAttribs];
//            }
//            if (minute > 0) {
//                [strArr addObject:[NSString stringWithFormat:@"%ld",(long)minute]];
//                [attriArr addObject:normalAttribs];
//                
//                [strArr addObject:@"m"];
//                [attriArr addObject:unitAttribs];
//            }
//        }
//        [self joidStrings:strArr withAttributes:attriArr tolabel:label];
//    }
//    else {
//        [self joidStrings:@[@""] withAttributes:@[normalAttribs] tolabel:label];
//    }
//}

- (void)joidStrings:(NSArray*)strArr withAttributes:(NSArray*)attrArr tolabel:(UILabel*)targeLabel {
    if ([strArr count] != [attrArr count]) {
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i< strArr.count; i++) {
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:strArr[i] attributes:attrArr[i]];
        [attributedText appendAttributedString:attrStr];
    }
    
    if ([targeLabel respondsToSelector:@selector(setAttributedText:)]) {
        targeLabel.attributedText = attributedText;
    }
    else {
        [targeLabel setText:attributedText.string];
    }
}

- (void)updatePoleFavorState:(HSSYFavorType)favor {
    [self.favorItem setSelected:(favor == HSSYHasFavor)];
}

// 更新用户评分部分
- (void)updatePoleEvaluation {
    // 总评分星星
    self.viewScoreStar.userInteractionEnabled = NO;
    self.viewScoreStar.scorePercent = self.selectStationInfo.commentAvgScore / 5.0;
    
    //最后评分信息
    [self updateStationLastArticle:self.lastArticle];
    
    // 评分总数Label
    [self setScoresCountLabel:self.labelScoresCount withScoreCount:@(self.selectStationInfo.commentNum)];
    
    
    if (self.selectStationInfo.commentNum <= 0) { // 如果还没有评分，不显示最后评分和评分概况
        self.scoreViewHiddenCons.constant = 18;
        [self.viewScoreContainer removeConstraint:self.constraintScoreViewBottomLine];
        self.constraintScoreViewBottomLine = [NSLayoutConstraint constraintWithItem:self.viewScoreViewBottomLine
                                                                          attribute:NSLayoutAttributeTop
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.viewTotalScore
                                                                          attribute:NSLayoutAttributeBottom
                                                                         multiplier:1
                                                                           constant:0];
        [self.viewScoreContainer addConstraint:self.constraintScoreViewBottomLine];
        //        [self.viewLastScorePreview removeFromSuperview];
        //        [self.viewScoresCountContainer removeFromSuperview];
    }
    else { // 如果有一个或多个评分
        if (self.selectStationInfo.commentNum == 1) { // 如果有一个评分，不显示评分概况
            //            [self.viewScoresCountContainer removeFromSuperview];
            [self.viewScoreContainer removeConstraint:self.constraintScoreViewBottomLine];
            self.constraintScoreViewBottomLine = [NSLayoutConstraint constraintWithItem:self.viewScoreViewBottomLine
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.viewLastScorePreview
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
            [self.viewScoreContainer addConstraint:self.constraintScoreViewBottomLine];
        }
        else {
            [self.viewScoreContainer removeConstraint:self.constraintScoreViewBottomLine];
            self.constraintScoreViewBottomLine = [NSLayoutConstraint constraintWithItem:self.viewScoreViewBottomLine
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.viewScoresCountContainer
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1
                                                                               constant:0];
            [self.viewScoreContainer addConstraint:self.constraintScoreViewBottomLine];
        }
        [self.viewScoreContainer layoutIfNeeded];
        
        self.scoreViewHiddenCons.constant = 18 + 18 + self.viewScoreContainer.bounds.size.height;
    }
}

- (void)updateStationLastArticle:(DCArticle *)article {
    self.imageViewLastScoreUserPortrain.layer.cornerRadius = CGRectGetMidX(self.imageViewLastScoreUserPortrain.bounds);
    self.imageViewLastScoreUserPortrain.layer.masksToBounds = YES;
    self.imageViewLastScoreUserPortrain.isLoad = @(NO);
    [self.imageViewLastScoreUserPortrain hssy_sd_setImageWithURL:article.avatarURL placeholderImage:[UIImage imageNamed:@"default_user_avatar_gray"]];
    [self.labelLastScoreUserName setText:article.userName];
    self.viewLastScoreStars.scorePercent = [article.starScore doubleValue] / 5.0;
    NSString *chargeStartTime = [[NSDateFormatter pileEvaluateDateFormatter] stringFromDate:article.createTime];
    [self.labelLastScoreTime setText:chargeStartTime];
    [self.labelLastScoreContent setText:article.content];
}

- (NSString*)getPeriodLengthString:(NSInteger)periodLength {
    NSString *periodStr;
    if (periodLength < 60) {
        periodStr = [NSString stringWithFormat:@"%d分钟", (int)periodLength];
    }
    else {
        periodStr = [NSString stringWithFormat:@"%d小时", (int)periodLength/60];
    }
    return periodStr;
}


-(void)hideBottomBar:(BOOL)isHide {
    [self.constraintBottomBarViewBottom setConstant:isHide? -self.constraintBottomBarViewHeight.constant : 0];
}

#pragma mark - Scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    imagePageView
    if([scrollView isEqual:self.scrollView]) {
        CGPoint offset = [scrollView contentOffset];
        [self.imagePageView setImageScrollViewHeight:offset.y];
        // 下拉刷新
        if ([scrollView contentOffset].y < -60 && [self.refresh isHidden]) {
            [self.refresh setHidden:NO];
            [self.refresh startAnimating];
        }
        if ([scrollView contentOffset].y == 0 && ![self.refresh isHidden]) {
            [self prelaodDataFromServer];
        }
    }
}


#pragma mark - HSSYEvaluateDelegate
- (void)poleDidEvaluated {
    [self prelaodDataFromServer];
}

//#pragma mark popUpView dismiss
//- (void)popUpViewDidDismiss:(PopUpView *)view {
//    if (!self.autoConnectTimer.isValid) {//不是处于自动连接状态
//        [self stopScanDevice];
//        [self.bleTool.foundPeerIDList removeAllObjects];
//    }
//}

#pragma listview
-(void)listViewDismissClick{
    [self.popUpView dismiss];
}

#pragma mark -OriginImage 改变图片大小
-(UIImage*) OriginImage:(UIImage*)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);//size为CGSize类型，即你所需要的图片尺寸
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
    
}

@end

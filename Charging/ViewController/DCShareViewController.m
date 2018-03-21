//
//  DCShareViewController.m
//  Charging
//
//  Created by kufufu on 16/5/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCShareViewController.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "Charging-Swift.h"
#import "DCShareImageView.h"
#import "ScreenShot.h"

#import <ShareSDKUI/ShareSDK+SSUI.h>

@interface DCShareViewController ()<BMKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *stationImageView;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationTypeLabel;
@property (weak, nonatomic) IBOutlet FiveStarsView *starView;
@property (weak, nonatomic) IBOutlet UILabel *stationAddressLabel;

@property (strong, nonatomic) DCShareImageView *shareView;

@end

@implementation DCShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //地图
    [self initMapView];
    
    //桩群信息
    [self initStationView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMapView {
    self.mapView.centerCoordinate = self.shareStation.coordinate;
    self.mapView.zoomLevel = 17;
    self.mapView.ChangeWithTouchPointCenterEnabled = NO;
    self.mapView.userInteractionEnabled = NO;
    self.mapView.delegate = self;
    
    BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = self.shareStation.coordinate;
    [self.mapView addAnnotation:annotation];
}

- (void)initStationView {
    [self.stationImageView hssy_sd_setImageWithURL:[NSURL URLWithImagePath:self.shareStation.coverImageUrl] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    
    self.stationNameLabel.text = self.shareStation.stationName;
    if (self.shareStation.stationType == DCStationTypePublic) {
        self.stationTypeLabel.text = @"公共桩群";
    } else if (self.shareStation.stationType == DCStationTypeSpecial) {
        self.stationTypeLabel.text = @"专用桩群";
    } else {
        self.stationTypeLabel.text = @"其他";
    }
    
    self.starView.starRateView.scorePercent = self.shareStation.commentAvgScore;
    
    self.stationAddressLabel.text = self.shareStation.addr;
}

#pragma mark - Action
- (IBAction)shareButton:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.shareView = [[DCShareImageView alloc] initShareImageViewWith:[self.mapView takeSnapshot] station:self.shareStation withBlock:^(BOOL success) {
        if (self.shareView == nil) {
            [self hideHUD:hud withText:@"加载二维码失败"];
            return;
        }
        if (success) {
            [hud hide:YES];
            NSArray *imageArray = @[[self imageFromView:self.shareView andHD:true]];
            
            NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
            [shareParams SSDKSetupShareParamsByText:nil images:imageArray url:nil title:@"易卫充" type:SSDKContentTypeImage];
            
            [ShareSDK showShareActionSheet:nil items:[NSArray arrayWithObjects:@(SSDKPlatformSubTypeWechatTimeline), @(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeQZone), @(SSDKPlatformSubTypeQQFriend), nil] shareParams:shareParams onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                NSString *shareString = @"未知分享";
                switch (platformType) {
                    case SSDKPlatformSubTypeQQFriend:
                        shareString = @"QQ";
                        break;
                    case SSDKPlatformSubTypeWechatSession:
                        shareString = @"微信好友";
                        break;
                    case SSDKPlatformSubTypeQZone:
                        shareString = @"QQ空间";
                        break;
                    case SSDKPlatformSubTypeWechatTimeline:
                        shareString = @"微信朋友圈";
                        break;
                        
                    default:
                        break;
                }
                switch (state) {
                    case SSDKResponseStateSuccess: {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                            message:nil
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        break;
                    }
                    case SSDKResponseStateFail: {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                        message:[NSString stringWithFormat:@"%@",error]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        break;
                    }
                    case SSDKResponseStateCancel:{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享已取消"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        break;
                    }
                    default:
                        break;
                }
            }];
        } else {
            [self hideHUD:hud withText:@"加载二维码失败"];
        }
    }];
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    BMKAnnotationView *view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
    view.image = [UIImage imageNamed:@"map_logo"];
    view.centerOffset = CGPointMake(0, -(view.bounds.size.height / 2));
    return view;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIImage *)imageFromView:(UIView *)theView andHD:(BOOL)hd{
    if (hd) {
        UIGraphicsBeginImageContextWithOptions(theView.bounds.size, NO, 0.0);//原图
    } else{
        UIGraphicsBeginImageContext(theView.bounds.size);//模糊
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext: context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end

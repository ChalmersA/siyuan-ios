//
//  DCSelectAreaViewController.m
//  Charging
//
//  Created by  Blade on 4/2/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

#import "DCSelectAreaViewController.h"
#import "DCSelectDetailAreaViewController.h"
#import "DCMapManager.h"
#import "DCArea.h"

#define DEFAULT_CITY_HINT @"请选择城市"
#define DEFAULT_DETAIL_ADDRESS_HINT @"请选择具体位置"

@interface DCSelectAreaViewController () {
}
@property (nonatomic, retain) BMKLocationService *locService;
@end

@implementation DCSelectAreaViewController
#pragma mark - LifeCycle
-(void)viewDidLoad
{
    [super viewDidLoad];
    /* priority
     1.last located position
     2.
     */
    DCMapManager *mapManager = [DCMapManager shareMapManager];
    BMKReverseGeoCodeResult *lastRevResult = [mapManager lastReversePosResult];
    if (self.curSelectArea) {
        [self.cityBtn setTitle:self.curSelectArea.city.name forState:UIControlStateNormal];
        [self.specificBtn setTitle:self.curSelectArea.addressDetail ? self.curSelectArea.addressDetail : DEFAULT_DETAIL_ADDRESS_HINT forState:UIControlStateNormal];
    }
    else if (lastRevResult) {
        // Find city
        DCArea* parsedArea = [[DCArea alloc] init];
        [parsedArea parseWithBMKReverseGeoCodeResult:lastRevResult];
        if (parsedArea.city != nil) {
            // update button titles
            [self.cityBtn setTitle:parsedArea.city.name forState:UIControlStateNormal];
            [self.specificBtn setTitle:parsedArea.addressDetail forState:UIControlStateNormal];
            self.curSelectArea = parsedArea;
        }
    }
    else {
        //TODO: set default
        [self.cityBtn setTitle:DEFAULT_CITY_HINT forState:UIControlStateNormal];
        
        [self.specificBtn setTitle:DEFAULT_DETAIL_ADDRESS_HINT forState:UIControlStateNormal];
    }
}
-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cityBtn.layer.cornerRadius = 6;
    self.cityBtn.layer.masksToBounds = YES;
    self.specificBtn.layer.cornerRadius = 6;
    self.specificBtn.layer.masksToBounds = YES;
}

#pragma mark - Action
- (IBAction)curLocationClick:(id)sender {
    DCMapManager *mapManager = [DCMapManager shareMapManager];
    BMKReverseGeoCodeResult *lastRevResult = [mapManager lastReversePosResult];
    if (lastRevResult) {
        // Find city
        DCArea* parsedArea = [[DCArea alloc] init];
        [parsedArea parseWithBMKReverseGeoCodeResult:lastRevResult];
        if (parsedArea.city != nil) {
            // update button titles
            [self.cityBtn setTitle:parsedArea.city.name forState:UIControlStateNormal];
            [self.specificBtn setTitle:parsedArea.addressDetail forState:UIControlStateNormal];
            self.curSelectArea = parsedArea;
        }
        else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"无法匹配定位信息，请手动选择位置";
            [hud hide:YES afterDelay:1];
        }
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"未能获取定位信息";
        [hud hide:YES afterDelay:1];
    }
}


- (IBAction)cityClick:(id)sender {
    [self performSegueWithIdentifier:@"showSelectCityView" sender:self];
}

- (IBAction)specificLocationBtnClick:(id)sender {
    if (self.curSelectArea && self.curSelectArea.city) {
        [self performSegueWithIdentifier:@"toSpecificLocation" sender:self];
    }
    else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请选择城市";
        [hud hide:YES afterDelay:1];
    }
}
- (IBAction)commimtBtnClick:(id)sender {
    if (self.curSelectArea == nil) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"未正确选择位置";
        [hud hide:YES afterDelay:1];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(finishSettingArea:)]) {
            [self.delegate finishSettingArea:self.curSelectArea];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Delegate
-(void)selectedCity:(City *)city{
    DCArea* area = [[DCArea alloc] init];
    area.city = city;
    [self.cityBtn setTitle:city.name forState:UIControlStateNormal];
    [self.specificBtn setTitle:DEFAULT_DETAIL_ADDRESS_HINT forState:UIControlStateNormal];
    self.curSelectArea = area;
}


#pragma mark - Prepare segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showSelectCityView"]){
        DCSelectCityViewController *vc = segue.destinationViewController;
//        vc.myLocationCity = (self.curSelectArea && self.curSelectArea.city) ? self.curSelectArea.city.name : @"";
        vc.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"toSpecificLocation"]) {
        DCSelectDetailAreaViewController* vc = segue.destinationViewController;
        if (self.curSelectArea && self.curSelectArea.city) {
            vc.defaultCity = self.curSelectArea.city.name;
        }
    }
}
#pragma mark - Unwind Segue
- (IBAction)unWindToSelectAreaView:(UIStoryboardSegue*) segue {
    if ([segue.identifier isEqualToString:@"unWindFromSDA"]) {
        //unwind from the SelectDetailArea
        DDLogDebug(@"unWindToSelectAreaView unWindFromSDA");
        DCSelectDetailAreaViewController *detailSelectView = (DCSelectDetailAreaViewController*)segue.sourceViewController;
        BMKPoiInfo* areaInfo = detailSelectView.choosenPoiInfo;
        if (areaInfo) {
            DCArea* parsedArea = [[DCArea alloc] init];
            [parsedArea parseWithBMKPoiInfo:areaInfo];
            if ( parsedArea.city != nil) {
                [self.cityBtn setTitle:parsedArea.city.name forState:UIControlStateNormal];
                [self.specificBtn setTitle:parsedArea.addressDetail forState:UIControlStateNormal];
                self.curSelectArea = parsedArea;
            }
            else {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.labelText = @"无法匹配定位信息，请重新选择位置";
                [hud hide:YES afterDelay:1];
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"unWindFromSelectCityView"]) {
        //unwind from the SelectDetailArea
        DDLogDebug(@"unWindToSelectAreaView unWindFromSelectCityView");
    }
}
@end

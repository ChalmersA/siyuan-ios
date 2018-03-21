//
//  MapSearchFliterView.m
//  Charging
//
//  Created by Ben on 4/29/16.
//  Copyright © 2016 xpg. All rights reserved.
//

#import "MapSearchFliterView.h"
#import "AppDelegate.h"

@implementation MapSearchFliterView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype)showFilterViewWithBlock:(FilterResultBlock)block{
    MapSearchFliterView *filterView = [[[NSBundle mainBundle] loadNibNamed:@"MapSearchFliterView" owner:nil options:nil] firstObject];
    filterView.filterBlock = block;
    filterView.window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    filterView.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3];
    [filterView.searchKeyWordBackgroudView setUserInteractionEnabled:YES];
    [filterView.confirmButton setBackgroundColor:[UIColor paletteDCMainColor]];
    filterView.mySearchParameters = [[filterView sharedSearchParam] copy];
    [filterView setupViewData];
    
    filterView.frame = CGRectMake(0, filterView.window.bounds.size.height, CGRectGetWidth(filterView.window.frame), 0);
    [filterView.window addSubview:filterView];
    [UIView animateWithDuration:0.3 animations:^{
       filterView.frame = CGRectMake(0, 0, CGRectGetWidth(filterView.window.frame), CGRectGetHeight(filterView.window.frame));
    }];
    return filterView;
}

- (void)setupViewData{
    [self.chargeTypeAllButton setSelected:(self.mySearchParameters.chargeType == DCSearchChargeType_All)];
    [self.chargeTypeQuickButton setSelected:(self.mySearchParameters.chargeType == DCSearchChargeType_Quick)];
    [self.chargeTypeSlowButton setSelected:(self.mySearchParameters.chargeType == DCSearchChargeType_Slow)];
    
    [self.poleTypeAllButton setSelected:(self.mySearchParameters.stationType == DCSearchStationTypeAll)];
    [self.poleTypePublicButton setSelected:(self.mySearchParameters.stationType == DCSearchStationTypePublic)];
    [self.poleTypeSpecialButton setSelected:(self.mySearchParameters.stationType == DCSearchStationTypeSpecial)];
    
    [self.searchSwitch setOn:self.mySearchParameters.onlyIdle];
//    if (self.mySearchParameters.keyword && self.mySearchParameters.keyword.length > 0) {
//        [self.searchTextFeild setText:self.mySearchParameters.keyword];
//    }
}

#pragma mark - Property
- (DCSearchParameters *)sharedSearchParam {
    DCSearchParameters *param = [DCApp sharedApp].searchParam;
    if (!param) {
        param = [[DCSearchParameters alloc] init];
        [DCApp sharedApp].searchParam = param;
    }
    return param;
}

#pragma mark - Action
- (IBAction)onChargeTypeAll:(id)sender {
    self.mySearchParameters.chargeType = DCSearchChargeType_All;
    [self setupViewData];
}

- (IBAction)onChargeTypeQuick:(id)sender {
    self.mySearchParameters.chargeType = DCSearchChargeType_Quick;
    [self setupViewData];
}

- (IBAction)onChargeTypeSlow:(id)sender {
    self.mySearchParameters.chargeType = DCSearchChargeType_Slow;
    [self setupViewData];
}

- (IBAction)onPoleTypeAll:(id)sender {
    self.mySearchParameters.stationType = DCSearchStationTypeAll;
    [self setupViewData];
}

- (IBAction)onPoleTypePublic:(id)sender {
    self.mySearchParameters.stationType = DCSearchStationTypePublic;
    [self setupViewData];
}

- (IBAction)onPoleTypeSpecial:(id)sender {
    self.mySearchParameters.stationType = DCSearchStationTypeSpecial;
    [self setupViewData];
}

- (IBAction)onIdelPole:(id)sender {
    self.mySearchParameters.onlyIdle = !self.mySearchParameters.onlyIdle;
    [self setupViewData];
}

- (IBAction)onClose:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.window.bounds.size.height, CGRectGetWidth(self.window.frame), 0);
        [self removeFromSuperview];
    }];
}

- (IBAction)onConfirm:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, self.window.bounds.size.height, CGRectGetWidth(self.window.frame), 0);
//        if (self.searchTextFeild.text.length > 0) {
//            self.mySearchParameters.keyword = self.searchTextFeild.text;
//        }else{
//            self.mySearchParameters.keyword = nil;
//        }
        
        [DCApp sharedApp].searchParam = self.mySearchParameters;
        self.filterBlock();
        [self removeFromSuperview];
    }];
}
- (IBAction)jumpToAreaVCButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(clickTheSearchView)]) {
        [self.delegate clickTheSearchView];
        [self onClose:sender];
    }
}

- (IBAction)didFinishEdit:(id)sender {
//    [self.searchTextFeild resignFirstResponder];
}

@end

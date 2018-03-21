//
//  HSSYPoleInfoView.m
//  Charging
//
//  Created by xpg on 15/4/23.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCPoleInfoView.h"
#import "DCPole.h"
#import "DCMapManager.h"
#import "CWStarRateView.h"
#import "DCApp.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+HSSYSDWebImageCategory.h"
#import "UILabel+HSSYPole.h"
#import "Charging-Swift.h"

const CGFloat HSSYPoleInfoViewHeight = 100;

@interface DCPoleInfoView ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) CWStarRateView *starRateView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *naviBottomBar;
@property (weak, nonatomic) IBOutlet UIButton *naviButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *acView; //交流
@property (weak, nonatomic) IBOutlet UIView *dcView; //直流
@property (weak, nonatomic) IBOutlet UILabel *acLabel; //交流
@property (weak, nonatomic) IBOutlet UILabel *dcLabel; //直流
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dcViewLeft;

@property (strong, nonatomic) NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;

@property (nonatomic) CLLocationCoordinate2D stationCoordinate;

@property (strong, nonatomic) NSMutableDictionary *stationTypeDic;
@property (strong, nonatomic) NSMutableDictionary *poleTypeDic;
@end

@implementation DCPoleInfoView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *heightCons = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:HSSYPoleInfoViewHeight];
        [self addConstraint:heightCons];
        _heightConstraint = heightCons;
        
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDown:)];
        swipeDownGesture.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeDownGesture];
        
        UISwipeGestureRecognizer *swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp:)];
        swipeUpGesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeUpGesture];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    [self.contentView addGestureRecognizer:tapGesture];
    
    [self.userImageView setCornerRadius:8];
    self.userImageView.isLoad = @(NO);
    
    // shadow
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(0, -2);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
    //设置圆角&边框
    self.acLabel.layer.masksToBounds = YES;
    self.acLabel.layer.cornerRadius = 2.0;
    self.dcLabel.layer.masksToBounds = YES;
    self.dcLabel.layer.cornerRadius = 2.0;
    [self loadTypeDic];
}

#pragma mark - loadTypeDic
- (void)loadTypeDic{
    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
    self.stationTypeDic = [manager objectForKey:@"HSSYStationType"];
    self.poleTypeDic = [manager objectForKey:@"HSSYPoleType"];
}

- (void)configViewForPole:(DCStation *)station withUserLocation:(CLLocation *)userLocation {
    self.addressLabel.text = station.addr;
    self.nameLabel.text = station.stationName;
    
    self.stationCoordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude);
    self.distanceLabel.text = [DCMapManager getDistanceStringWithTarget:self.stationCoordinate andMapViewCenterCoordinate:userLocation.coordinate];
    
    [self.userImageView hssy_sd_setImageWithURL:[NSURL URLWithImagePath:station.coverImageUrl] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    
    if (station.alterNum > 0) {
        self.acLabel.text = [NSString stringWithFormat:@"%ld", (long)station.alterNum];
        self.dcViewLeft.constant = 5;

    }
    if (station.directNum > 0) {
        self.dcLabel.text = [NSString stringWithFormat:@"%ld", (long)station.directNum];
    }
}

- (void)showInView:(UIView *)view {
    [view addSubview:self];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    self.topConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [view addConstraint:self.topConstraint];
    
    [view layoutIfNeeded];
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.topConstraint.constant = -HSSYPoleInfoViewHeight;
        [view layoutIfNeeded];
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hide {
    UIView *superView = self.superview;
    
    [superView layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.topConstraint.constant = 0;
        [superView layoutIfNeeded];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UISwipeGestureRecognizer
- (void)swipeDown:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.swipeDownBlock) {
            self.swipeDownBlock(self);
        }
    }
}

- (void)swipeUp:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.swipeUpBlock) {
            self.swipeUpBlock(self);
        }
    }
}

- (void)tapOnView:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        if (self.tapGestureViewBlock) {
            self.tapGestureViewBlock(self);
        }
    }
}

#pragma mark - Action
- (IBAction)navigation:(id)sender {
    if (self.navigationHandler) {
        self.navigationHandler(self);
    }
}

#pragma mark - Notification
- (void)searchLocationChanged:(NSNotification *)note {
    self.distanceLabel.text = [DCMapManager getDistanceStringWithTarget:self.stationCoordinate andMapViewCenterCoordinate:[DCApp sharedApp].userLocation.coordinate];
}

@end

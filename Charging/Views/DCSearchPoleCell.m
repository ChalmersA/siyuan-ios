//
//  DCSearchPoleCell.m
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCSearchPoleCell.h"
#import "DCMapManager.h"
#import "UIView+HSSYView.h"
#import "UIImageView+WebCache.h"
#import "CWStarRateView.h"
#import "UILabel+HSSYPole.h"
#import "UIImageView+HSSYSDWebImageCategory.h"

#define TIME_LABEL_WIDTH ((deviceScreenWidth() - 8 * 2 - 12 * 2) / 3.0)

@interface DCSearchPoleCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userImageViewCons;

@property (strong, nonatomic) DCStation *station;

@property (strong, nonatomic) NSMutableDictionary *stationTypeDic;
@property (strong, nonatomic) NSMutableDictionary *poleTypeDic;

@property (nonatomic) CLLocationCoordinate2D centerCoordinate;

@end

@implementation DCSearchPoleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.userImageView setCornerRadius:8];
    //设置圆角&边框
    self.acLabel.layer.masksToBounds = YES;
    self.acLabel.layer.cornerRadius = 2.0;
    self.dcLabel.layer.masksToBounds = YES;
    self.dcLabel.layer.cornerRadius = 2.0;
    
    self.userImageViewCons.constant = 8;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectImageView.highlighted = selected;
}

#pragma mark - loadTypeDic
//- (void)loadTypeDic{
//    NSUserDefaults *manager = [NSUserDefaults standardUserDefaults];
//    self.stationTypeDic = [manager objectForKey:@"HSSYStationType"];
//    self.poleTypeDic = [manager objectForKey:@"HSSYPoleType"];
//}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.station = nil;
}

#pragma mark - Action
- (IBAction)naviButtonClicked:(id)sender {
    [self.delegate searchStationCellNavigationAction:self.station];
}

#pragma mark - Public
- (void)configureForStation:(DCStation *)station withLocation:(CLLocationCoordinate2D)centerLocation {
    
    //保存mapView的中心点
    if (centerLocation.longitude || centerLocation.latitude) {
        self.centerCoordinate = centerLocation;
    }
    
    self.station = station;
    
    self.addressLabel.text = station.addr;
    self.nameLabel.text = station.stationName;
    
    self.stationCoordinate = CLLocationCoordinate2DMake(station.latitude, station.longitude);
    self.distanceLabel.text = [DCMapManager getDistanceStringWithTarget:self.stationCoordinate andMapViewCenterCoordinate:centerLocation];
    
    [self.userImageView hssy_sd_setImageWithURL:[NSURL URLWithImagePath:station.coverImageUrl] placeholderImage:[UIImage imageNamed:@"default_pile_image_short"]];
    [self layoutIfNeeded];
    if (station.alterNum > 0) {
        self.dcViewLeft.constant = 5;
        self.acLabel.text = [NSString stringWithFormat:@"%ld", (long)station.alterNum];
    }
    if (station.directNum > 0) {
        self.dcLabel.text = [NSString stringWithFormat:@"%ld", (long)station.directNum];
    }
}

#pragma mark - Extension
- (void)updateEditingState:(BOOL)editing {
    self.selectImageView.image = [UIImage imageNamed:@"book_icon_unselect"];
    if (editing) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectImageView.hidden = NO;
        self.userImageViewCons.constant = 59;
        self.distanceLabel.hidden = YES;
        self.naviButton.hidden = YES;
    } else {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.selectImageView.hidden = YES;
        self.userImageViewCons.constant = 8;
        self.distanceLabel.hidden = NO;
        self.naviButton.hidden = NO;
    }
}

+ (CGFloat)cellHeightWithTableViewWidth:(CGFloat)width {
    return 100.f;
}

@end

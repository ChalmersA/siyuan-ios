//
//  DCSearchPoleCell.h
//  Charging
//
//  Created by xpg on 15/4/1.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStation.h"
#import "DCChargeFee.h"
#import <CoreLocation/CoreLocation.h>
#import "Charging-Swift.h"

@protocol HSSYSearchPoleCellDelegate <NSObject>

- (void)searchStationCellOrderAction:(DCStation *)station;
- (void)searchStationCellNavigationAction:(DCStation *)station;
//- (void)cancelCollectionAction:(DCStation *)pole;

//- (void)searchPoleCellOrderAction:(DCPole *)pole;
//- (void)searchPoleCellNavigationAction:(DCPole *)pole;

@end

@interface DCSearchPoleCell : UITableViewCell
@property (weak, nonatomic) id <HSSYSearchPoleCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *naviButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIView *acView; //交流
@property (weak, nonatomic) IBOutlet UIView *dcView; //直流
@property (weak, nonatomic) IBOutlet UILabel *acLabel; //交流
@property (weak, nonatomic) IBOutlet UILabel *dcLabel; //直流
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dcViewLeft;

@property (nonatomic) CLLocationCoordinate2D stationCoordinate;

- (void)configureForStation:(DCStation *)station withLocation:(CLLocationCoordinate2D)centerLocation;

//- (void)configureForPole:(DCPole *)pole withLocation:(CLLocation *)location;
- (void)updateEditingState:(BOOL)editing;
+ (CGFloat)cellHeightWithTableViewWidth:(CGFloat)width;
@end

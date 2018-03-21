//
//  DCShareImageView.h
//  Charging
//
//  Created by kufufu on 16/5/7.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Charging-Swift.h"

@interface DCShareImageView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *mapImageView;

@property (weak, nonatomic) IBOutlet UIImageView *stationIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *stationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stationTypeLabel;
@property (weak, nonatomic) IBOutlet FiveStarsView *starView;
@property (weak, nonatomic) IBOutlet UILabel *stationAddressLabel;
@property (strong, nonatomic) IBOutlet UIImageView *qrCodeImageView;



- (instancetype)initShareImageViewWith:(UIImage *)mapImage station:(DCStation *)station withBlock:(void (^)(BOOL success))block;
@end

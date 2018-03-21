//
//  DCShareViewController.h
//  Charging
//
//  Created by kufufu on 16/5/6.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "BaiduMapKits.h"
#import "DCStation.h"

@interface DCShareViewController : DCViewController
@property (weak, nonatomic) IBOutlet BMKMapView *mapView;

@property (strong, nonatomic) DCStation *shareStation;

@end

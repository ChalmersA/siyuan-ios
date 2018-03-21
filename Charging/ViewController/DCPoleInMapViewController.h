//
//  HSSYPoleInMapViewController.h
//  Charging
//
//  Created by Ben on 15/1/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import "DCViewController.h"

@interface DCPoleInMapViewController : DCViewController
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic)  NSString *address;
@property (copy, nonatomic)  NSString *stationName;
@end

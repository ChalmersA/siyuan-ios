//
//  DevicesWindowTableViewCell.h
//  GuoBangCleaner
//
//  Created by Ben on 15/8/27.
//  Copyright (c) 2015年 com.xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStation.h"

@interface DevicesWindowTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;

- (void)updateViewWithStation:(DCStation *)station;
@end

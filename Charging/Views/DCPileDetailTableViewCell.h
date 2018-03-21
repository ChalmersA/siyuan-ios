//
//  DCPileDetailTableViewCell.h
//  Charging
//
//  Created by kufufu on 15/10/13.
//  Copyright © 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCChargePort.h"

@interface DCPileDetailTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UIView *cpView1;
@property (weak, nonatomic) IBOutlet UIView *cpView2;
@property (weak, nonatomic) IBOutlet UIView *cpView3;
@property (weak, nonatomic) IBOutlet UIView *cpView4;

@property (weak, nonatomic) IBOutlet UIImageView *cpImageView1;
@property (weak, nonatomic) IBOutlet UILabel *cpIndexLabel1;

@property (weak, nonatomic) IBOutlet UIImageView *cpImageView2;
@property (weak, nonatomic) IBOutlet UILabel *cpIndexLabel2;

@property (weak, nonatomic) IBOutlet UIImageView *cpImageView3;
@property (weak, nonatomic) IBOutlet UILabel *cpIndexLabel3;

@property (weak, nonatomic) IBOutlet UIImageView *cpImageView4;
@property (weak, nonatomic) IBOutlet UILabel *cpIndexLabel4;
@property (weak, nonatomic) IBOutlet UIView *offLineView;

- (void)cellWithChargePort:(NSArray *)array;

@end

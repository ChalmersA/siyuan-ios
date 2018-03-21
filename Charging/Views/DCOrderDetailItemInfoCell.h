//
//  DCOrderDetailItemInfoCell.h
//  Charging
//
//  Created by kufufu on 16/4/22.
//  Copyright © 2016年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Charging-Swift.h"

@interface DCOrderDetailItemInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *itemTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemContentLabel;
@property (weak, nonatomic) IBOutlet FiveStarsView *starView;

@end

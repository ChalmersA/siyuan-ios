//
//  DCMenuCell.h
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@interface DCMenuCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *menuIcon;
@property (weak, nonatomic) IBOutlet UILabel *menuText;
@property (weak, nonatomic) IBOutlet UIView *badgeContainerView;
@property (weak, nonatomic) JSBadgeView *badgeView;
@end

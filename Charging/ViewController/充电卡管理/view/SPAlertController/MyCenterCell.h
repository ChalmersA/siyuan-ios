//
//  MyCenterCell.h
//  Charging
//
//  Created by gaoml on 2018/3/13.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^click)(void);

@interface MyCenterCell : UITableViewCell

@property (copy , nonatomic)click clickDeletedBtnBlock;

@property(nonatomic, strong) UILabel *cardLabel;
@property(nonatomic, strong) UIButton *deletedBtn;

@end

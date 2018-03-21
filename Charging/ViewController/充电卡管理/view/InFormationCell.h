//
//  InFormationCell.h
//  Charging
//
//  Created by 陈志强 on 2018/3/6.
//  Copyright © 2018年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^click)();

@interface InFormationCell : UITableViewCell

@property (copy , nonatomic)click clickButtonBlock;

@property (weak, nonatomic) IBOutlet UIView *blueView;
@property (weak, nonatomic) IBOutlet UILabel *cardNumLb;
@end

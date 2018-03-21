//
//  HSSYPoleShareCell.h
//  Charging
//
//  Created by xpg on 15/5/20.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCPole.h"

@interface DCPoleShareCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *suffixLabel;

@property (weak, nonatomic) IBOutlet UIView *timeView;
- (void)setShareTimeArray:(NSArray *)timeArray conflictInfo:(NSDictionary *)conflictInfo;

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
- (void)setPoleType:(HSSYPoleType)type;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceCons;

+ (CGFloat)cellHeightForShareTimeArray:(NSArray *)timeArray;
-(void)setContentLabel:(UILabel*)label WithPrice:(DCUVPrice *)price;
@end

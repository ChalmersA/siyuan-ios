//
//  HSSYAuthorizedUserTableViewCell.h
//  Charging
//
//  Created by Ben on 14/12/26.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCAuthorizedUserTableViewCell;
@protocol HSSYAuthCellDelegate <NSObject>
- (void)deleteCell:(DCAuthorizedUserTableViewCell *)cell;
@end

@interface DCAuthorizedUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) id <HSSYAuthCellDelegate> delegate;
@property (strong, nonatomic) id userInfo;
@end

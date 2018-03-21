//
//  HSSYQuickShareCell.h
//  Charging
//
//  Created by xpg on 14/12/25.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HSSYQuickShareAction) {
    HSSYQuickShareRelease,
    HSSYQuickShareUpdate,
    HSSYQuickShareCancel,
};

@protocol HSSYQuickShareCellDelegate <NSObject>

- (void)quickShare:(HSSYQuickShareAction)action withInfo:(id)info;

@end

extern NSString * const kQuickShareCellName;
extern NSString * const kQuickShareCellTime;
extern NSString * const kQuickShareCellUpdate;
extern NSString * const kQuickShareCellShare;

@interface DCQuickShareCell : UITableViewCell
@property (weak, nonatomic) id <HSSYQuickShareCellDelegate> delegate;
@property (strong, nonatomic) id cellInfo;

@property (weak, nonatomic) IBOutlet UIImageView *poleIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeSpanLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekdayLabel;

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *updateButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

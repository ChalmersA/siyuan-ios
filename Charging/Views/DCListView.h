//
//  HSSYListView.h
//  Charging
//
//  Created by xpg on 14/12/15.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+HSSYView.h"

@protocol HSSYListViewDelegate <NSObject>
- (void)listViewDismissClick;
@end

@interface DCListView : UIView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitl;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) id <HSSYListViewDelegate> delegate;
@end



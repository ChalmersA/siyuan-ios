//
//  DevicesWindow.h
//  GuoBangCleaner
//
//  Created by Ben on 15/8/27.
//  Copyright (c) 2015年 com.xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStation.h"

static const CGFloat DevicesWindow_Width = 250.0f;
static const CGFloat DevicesWindow_Height = 110.0f;

typedef void(^DevicesWindowSelctedBlcok)(id item);
@protocol DevicesWindowDelegate;

@interface DevicesWindow : UIView<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) NSArray *stations;
@property (weak, nonatomic) id<DevicesWindowDelegate>delegate;
@property (copy, nonatomic) DevicesWindowSelctedBlcok itemSelectedBlock;

- (instancetype)initWithFrame:(CGRect)frame stations:(NSArray *)stations itemSelectBlock:(DevicesWindowSelctedBlcok)block;
- (DCStation *)selectStation:(DCStation *)station;
@end

@protocol DevicesWindowDelegate <NSObject>

- (void)devicesWindow:(DevicesWindow *)DevicesWindow selectedStation:(DCStation *)station;

@end
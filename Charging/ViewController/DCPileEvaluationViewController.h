//
//  DCPileEvaluationViewController.h
//  Charging
//
//  Created by xpg on 15/9/6.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCStation.h"
#import "DCViewController.h"
//#import "HSSYEvaluateViewController.h"

@protocol DCPileEvaluationViewControllerDelegate <NSObject>

@optional
- (void)pileDidEvaluated;

@end

@interface DCPileEvaluationViewController : DCViewController
@property (weak, nonatomic) id <DCPileEvaluationViewControllerDelegate> delegate;
@property (copy, nonatomic) NSString *stationId;
@property (strong, nonatomic) DCOrder * order;

@end

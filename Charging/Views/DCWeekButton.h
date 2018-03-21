//
//  HSSYWeekButton.h
//  Charging
//
//  Created by Ben on 15/1/15.
//  Copyright (c) 2015年 xpg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WeekButtonDelegate <NSObject>

-(void)weekButtonSelectedChange;

@end
@interface DCWeekButton : UIButton
@property (weak, nonatomic) id <WeekButtonDelegate> delegate;
@end

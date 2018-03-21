//
//  DCUserViewController.h
//  Charging
//
//  Created by xpg on 14/12/16.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCViewController.h"
#import "PopUpView.h"
#import "DCOrderViewController.h"
#import "DCFavoritesViewController.h"

@interface DCUserViewController : DCViewController 
@property (strong,nonatomic) NSArray *menuItems;
@property (strong , nonatomic) NSMutableDictionary *poleMessageDict;//key:poleId value:msgNum
@end


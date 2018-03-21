//
//  DCMenuItem.m
//  Charging
//
//  Created by xpg on 14/12/17.
//  Copyright (c) 2014年 xpg. All rights reserved.
//

#import "DCMenuItem.h"

@implementation DCMenuItem

+ (NSArray *)loadMenuItems {
    return @[@[[self myOrderMenuItem], [self myWalletMenuItem], [self myChargeCardMenuItem], [self myFavoritesMenuItem], [self myEvaluationsMenuItem]],
             @[[self addPileMenuItem]],
             @[[self helpMenuItem], [self mySettingMenuItem], [self aboutMeMenuItem]]];
}

+ (instancetype)myOrderMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_order" title:@"我的订单"];
}

+ (instancetype)myWalletMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_wallet" title:@"我的钱包"];
}
             
+ (instancetype)myChargeCardMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_card" title:@"充电卡管理"];
}

+ (instancetype)myFavoritesMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_favor" title:@"我的收藏"];
}

+ (instancetype)addPileMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_station" title:@"发现桩群"];
}

+ (instancetype)myEvaluationsMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_evaluation" title:@"我的评价"];
}

+ (instancetype)helpMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_service" title:@"帮助与反馈"];
}

+ (instancetype)mySettingMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_setting" title:@"我的设置"];
}

+ (instancetype)aboutMeMenuItem {
    return [[self alloc] initWithIcon:@"menu_icon_about" title:@"关于易卫充"];
}

- (instancetype)initWithIcon:(NSString *)icon title:(NSString *)title {
    self = [super init];
    if (self) {
        _imageName = [icon copy];
        _text = [title copy];
    }
    return self;
}

@end

@implementation DCMenuCell (DCMenuItem)

- (void)configureForItem:(DCMenuItem *)item {
    self.menuIcon.image = [UIImage imageNamed:item.imageName];
    self.menuText.text = item.text;
    if (item.badgeNumber == 0) {
        [self.badgeView removeFromSuperview];
    } else {
        if (self.badgeView == nil) {
            JSBadgeView *badgeView = [[JSBadgeView alloc] initWithParentView:self.badgeContainerView alignment:JSBadgeViewAlignmentTopLeft];
            [self.badgeContainerView addSubview:badgeView];
            self.badgeView = badgeView;
        }
        
        self.badgeView.badgeText = @(item.badgeNumber).stringValue;
    }

}

@end
